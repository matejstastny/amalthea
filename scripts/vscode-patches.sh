#!/usr/bin/env bash
#@ patch vscode with custom css and the system font
set -euo pipefail

ROOT="$(dirname "$(realpath "$0")")/.."
CSS_SRC="$ROOT/config/code/custom.css"
FONT="Terminess Nerd Font Mono"

# visual-studio-code-bin's resources/app path varies between AUR package
# revisions, so find it instead of hardcoding it
for root in /opt/visual-studio-code-bin /usr/share/visual-studio-code-bin /usr/lib/code-bin /usr/share/code; do
	if [[ -f "$root/resources/app/product.json" ]]; then
		VSCODE="$root/resources/app"
		break
	fi
done
if [[ -z "${VSCODE:-}" ]]; then
	echo "error: could not find vscode's resources/app (checked /opt/visual-studio-code-bin, /usr/share/visual-studio-code-bin, /usr/lib/code-bin, /usr/share/code)" >&2
	exit 1
fi

sudo chown -R "$(whoami)" "$(dirname "$VSCODE")"

CSS_TARGET="$VSCODE/out/vs/workbench/workbench.desktop.main.css"
JS_TARGET="$VSCODE/out/vs/workbench/workbench.desktop.main.js"
PRODUCT_JSON="$VSCODE/product.json"
CSS_MARKER="/* dotfiles:custom-css */"
JS_MARKER="/* dotfiles:font */"

FONT_CSS="body{--vscode-font-family:\"$FONT\";}.linux{font-family:\"$FONT\",sans-serif!important;}.monaco-workbench input,.monaco-workbench select,.monaco-workbench textarea,.monaco-workbench .monaco-inputbox{font-family:\"$FONT\",sans-serif!important;}"

# some -bin repackagings ship a product.json checksums map that is already
# stale for files this script never touches (a packaging artifact, not
# something this script causes) and trips an "installation appears corrupt"
# dialog on launch. drop it rather than leave it half-updated.
drop_checksums() {
	python3 - "$PRODUCT_JSON" <<'EOF'
import sys, json, subprocess
product_path = sys.argv[1]
product = json.loads(open(product_path).read())
if product.pop("checksums", None) is not None:
    subprocess.run(["sudo","tee",product_path], input=json.dumps(product,indent="\t").encode(), capture_output=True, check=True)
EOF
}

if [[ "${1:-}" == "--force" ]]; then
	echo "✦ Stripping CSS patch..."
	python3 - "$CSS_TARGET" "$CSS_MARKER" <<'EOF'
import sys, subprocess
path, marker = sys.argv[1], sys.argv[2]
content = open(path).read()
idx = content.find(marker)
if idx != -1:
    subprocess.run(["sudo","tee",path], input=(content[:idx].rstrip()+"\n").encode(), capture_output=True, check=True)
    print("  stripped")
else:
    print("  nothing to strip")
EOF

	echo "✦ Stripping JS font injection..."
	python3 - "$JS_TARGET" "$JS_MARKER" <<'EOF'
import sys, subprocess
path, marker = sys.argv[1], sys.argv[2]
content = open(path).read()
idx = content.find(marker)
if idx != -1:
    clean = content[:content.rfind('\n', 0, idx)].rstrip()
    sourcemap_idx = content.find('\n//# sourceMappingURL=')
    tail = content[sourcemap_idx:] if sourcemap_idx != -1 else ""
    subprocess.run(["sudo","tee",path], input=(clean + tail + "\n").encode(), capture_output=True, check=True)
    print("  stripped")
else:
    print("  nothing to strip")
EOF

	echo "✦ Restoring renderer font strings..."
	python3 - "$JS_TARGET" "$FONT" <<'EOF'
import sys, subprocess
path, font = sys.argv[1], sys.argv[2]
orig = 'system-ui, "Ubuntu", "Droid Sans"'
content = open(path).read()
if font not in content:
    print("  nothing to restore")
    sys.exit(0)
count = content.count(font)
new = content.replace(font, orig)
subprocess.run(["sudo","tee",path], input=new.encode(), capture_output=True, check=True)
print(f"  restored {count} occurrences")
EOF
	echo "✦ done - restart VS Code to apply"
	exit 0
fi

# CSS layout tweaks (optional - only applied if config/code/custom.css exists)
if [[ ! -f "$CSS_SRC" ]]; then
	echo "✦ No custom.css found, skipping CSS patch"
elif grep -qF "$CSS_MARKER" "$CSS_TARGET" 2>/dev/null; then
	echo "✦ CSS already patched"
else
	{
		printf '\n%s\n' "$CSS_MARKER"
		cat "$CSS_SRC"
	} | sudo tee -a "$CSS_TARGET" >/dev/null
	echo "✦ CSS patched"
fi

if grep -qF "$JS_MARKER" "$JS_TARGET" 2>/dev/null; then
	echo "✦ JS font already injected"
else
	python3 - "$JS_TARGET" "$JS_MARKER" "$FONT_CSS" <<'EOF'
import sys, subprocess
path, marker, css = sys.argv[1], sys.argv[2], sys.argv[3]
content = open(path).read()
inject = f"\n{marker};(function(){{var s=document.createElement('style');s.textContent='{css}';document.head.appendChild(s);}}());\n"
sourcemap = '\n//# sourceMappingURL='
idx = content.find(sourcemap)
if idx == -1:
    new = content.rstrip() + inject
else:
    new = content[:idx] + inject + content[idx:]
subprocess.run(["sudo","tee",path], input=new.encode(), capture_output=True, check=True)
print("  injected")
EOF
	echo "✦ JS font injected"
fi

# renderer font replacement: the compiled JS bundle hardcodes the Linux
# sans-serif fallback stack in a handful of places that override CSS rules
if python3 -c "
import sys
content = open(sys.argv[1]).read()
sys.exit(0 if 'system-ui, \"Ubuntu\", \"Droid Sans\"' in content else 1)
" "$JS_TARGET" 2>/dev/null; then
	python3 - "$JS_TARGET" "$FONT" <<'EOF'
import sys, subprocess
path, font = sys.argv[1], sys.argv[2]
orig = 'system-ui, "Ubuntu", "Droid Sans"'
content = open(path).read()
count = content.count(orig)
new = content.replace(orig, font)
subprocess.run(["sudo","tee",path], input=new.encode(), capture_output=True, check=True)
print(f"  replaced {count} occurrences")
EOF
	echo "✦ Renderer font patched"
else
	echo "✦ Renderer font already patched"
fi

drop_checksums

echo "✦ giving perms..."
sudo chown -R "$(whoami)" "$(dirname "$VSCODE")"

echo "✦ done - restart VS Code to apply"
