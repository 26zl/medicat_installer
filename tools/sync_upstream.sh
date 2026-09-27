#!/usr/bin/env bash
# Merge new commits from the upstream project into main. The upstream remote is fetch-only:
# its push URL is disabled here and nothing in this script pushes anywhere but origin.
#
#   tools/sync_upstream.sh            merge upstream/main into main
#   tools/sync_upstream.sh --dry-run  only show what is new
#   tools/sync_upstream.sh --linux    also merge upstream's linux branch into linux/
#   tools/sync_upstream.sh --push     push main to origin when the merge and checks pass
set -euo pipefail

UPSTREAM_URL="https://github.com/mon5termatt/medicat_installer.git"
DRY_RUN=false
PUSH=false
SYNC_LINUX=false

usage() {
	sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
	case "$arg" in
		--dry-run) DRY_RUN=true ;;
		--push) PUSH=true ;;
		--linux) SYNC_LINUX=true ;;
		-h|--help) usage; exit 0 ;;
		*) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
	esac
done

repoRoot=$(git rev-parse --show-toplevel)
cd "$repoRoot"

if ! git remote get-url upstream >/dev/null 2>&1; then
	git remote add upstream "$UPSTREAM_URL"
fi
git remote set-url --push upstream no_push

if [[ "$(git branch --show-current)" != "main" ]]; then
	echo "Switch to main first (git checkout main)." >&2
	exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
	echo "The working tree is not clean; commit or stash first." >&2
	exit 1
fi

git fetch --prune upstream

# Print what a ref adds on top of HEAD; returns 1 when there is nothing new.
report() {
	local ref="$1"
	local count
	count=$(git rev-list --count HEAD.."$ref")
	if (( count == 0 )); then
		echo "$ref: nothing new."
		return 1
	fi
	echo "$ref: $count new commit(s):"
	git log --oneline --no-merges HEAD.."$ref" | head -40
	return 0
}

# Merge a ref with extra strategy options; on conflict leave the merge for the user to finish.
mergeRef() {
	local ref="$1"
	local message="$2"
	shift 2
	if git merge --no-ff --no-edit "$@" -m "$message" "$ref"; then
		return 0
	fi
	cat >&2 <<EOF

Merge of $ref stopped on conflicts. Resolve them, then run:
  python3 tools/gen_spec.py && python3 tools/i18n_codegen.py
  git add -A && git commit
Files under linux/ diverged a lot from upstream's script; port changes from linux/CHANGELOG.md by hand when needed.
EOF
	exit 1
}

regenerate() {
	python3 tools/gen_spec.py
	python3 tools/i18n_codegen.py
	if [[ -n "$(git status --porcelain)" ]]; then
		git commit -q -am "Regenerate spec and i18n after the upstream merge."
		echo "Committed regenerated outputs."
	fi
	python3 tools/gen_spec.py --check
	bash -n linux/Medicat_Installer.sh
}

mergedSomething=false
if report upstream/main; then
	if ! $DRY_RUN; then
		mergeRef upstream/main "Merge upstream/main ($(git rev-parse --short upstream/main)) into main."
		mergedSomething=true
	fi
fi

if $SYNC_LINUX && report upstream/linux; then
	if ! $DRY_RUN; then
		mergeRef upstream/linux "Merge upstream/linux ($(git rev-parse --short upstream/linux)) into linux/." -X subtree=linux
		mergedSomething=true
	fi
fi

if $DRY_RUN; then
	echo "Dry run: nothing merged."
	exit 0
fi
if ! $mergedSomething; then
	exit 0
fi

regenerate
echo "Merged. Review with: git log --oneline origin/main..main"
if $PUSH; then
	git push origin main
else
	echo "Push when happy: git push origin main"
fi
