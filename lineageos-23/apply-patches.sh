#!/usr/bin/env bash
# Apply Ultra-Legacy-Hippeastrum legacy_support_patches and the patches in
# patches/ to a synced LineageOS 23.2 tree. Idempotent: skips what is applied.
# Usage: ./apply-patches.sh /path/to/lineage-23.2
# frameworks/base 0009-0012 (microG on user builds, VoLTE/HD icons) do not apply
# to current 23.2 and are not needed without IMS: they are skipped.
set -uo pipefail
here=$(cd -- "$(dirname -- "$0")" && pwd)
cd "${1:?usage: $0 <lineage-23.2 tree>}"
skip=" frameworks/base/0009 frameworks/base/0010 frameworks/base/0011 frameworks/base/0012 "
apply_dir() { # <patch root> <project dir> <skip list>
	local proot=$1 dir=$2 skipl=$3 p rel
	for p in "$proot/$dir"/*.patch; do
		[ -e "$p" ] || continue
		rel="$dir/$(basename "$p" | cut -c1-4)"
		case "$skipl" in *" $rel "*) echo "SKIP  $dir/$(basename "$p")"; continue;; esac
		if (cd "$dir" && patch -p1 -R --dry-run -s -f < "$p" >/dev/null 2>&1); then echo "DONE  $dir/$(basename "$p")"; continue; fi
		if (cd "$dir" && patch -p1 --dry-run -s -f < "$p" >/dev/null 2>&1); then
			# git am needs the ancestors, which a --depth=1 sync lacks: fall back to patch + commit
			(cd "$dir" && git am -q --ignore-whitespace < "$p" 2>/dev/null) || { (cd "$dir" && git am --abort 2>/dev/null; patch -p1 -s -f < "$p" && git add -A && git commit -q -m "$(sed -n 's/^Subject: \(\[PATCH[^]]*\] \)\?//p' "$p" | head -1)"); }
			echo "OK    $dir/$(basename "$p")"
		else echo "FAIL  $dir/$(basename "$p")"; fi
	done
}
for d in $(cd legacy_support_patches && find . -name '*.patch' -printf '%h\n' | sed 's|^\./||' | sort -u); do apply_dir "$PWD/legacy_support_patches" "$d" "$skip"; done
for d in $(cd "$here/patches" && find . -name '*.patch' -printf '%h\n' | sed 's|^\./||' | sort -u); do apply_dir "$here/patches" "$d" " "; done
