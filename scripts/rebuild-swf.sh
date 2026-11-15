#!/bin/bash
set -euo pipefail
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 ORIGINAL_SWF OUTPUT_SWF" >&2
  exit 2
fi
root=$(cd "$(dirname "$0")/.." && pwd)
input=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
output=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
[ "$input" != "$output" ] || { echo "Input and output must be different files." >&2; exit 1; }
jar=${DTD_FFDEC_JAR:-"$root/tools/ffdec-26.5.0/ffdec.jar"}
java=${DTD_JAVA:-java}
expected=0ff49ed237ebafdc7d179c6111910a3f1fa34dac4ccc4b23c79f5df447eb880c
actual=$(shasum -a 256 "$input" | awk '{print $1}')
[ "$actual" = "$expected" ] || { echo 'Unexpected original SWF hash; refusing to patch.' >&2; exit 1; }
[ -f "$jar" ] || { echo "JPEXS jar not found: $jar" >&2; exit 1; }
tmp=$(mktemp -d "${TMPDIR:-/tmp}/desktoptd-swf.XXXXXXXX")
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/first/__Packages" "$tmp/first/DefineSprite_759/frame_4" "$tmp/last/frame_3"
cp "$root/patches/scripts/__Packages/Grid.as" "$tmp/first/__Packages/"
cp "$root/patches/scripts/DefineSprite_759/frame_4/DoAction.as" "$tmp/first/DefineSprite_759/frame_4/"
cp "$root/patches/scripts/frame_3/DoAction.as" "$tmp/last/frame_3/"
"$java" -jar "$jar" -importScript "$input" "$tmp/first.swf" "$tmp/first"
"$java" -jar "$jar" -importScript "$tmp/first.swf" "$tmp/second.swf" "$root/patches/pcode"
"$java" -jar "$jar" -importScript "$tmp/second.swf" "$output" "$tmp/last"
shasum -a 256 "$output"
