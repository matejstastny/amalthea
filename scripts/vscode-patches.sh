#!/usr/bin/env bash
#@ patch vscodium with the system font and marketplace access
set -euo pipefail

FONT="Terminess Nerd Font Mono"

# vscodium-bin's resources/app has moved between AUR package revisions
# (/opt/vscodium-bin vs /usr/share/vscodium-bin), so find it instead of
# hardcoding it
for root in /usr/share/vscodium-bin /opt/vscodium-bin /usr/lib/vscodium-bin /usr/share/codium; do
	if [[ -f "$root/resources/app/product.json" ]]; then
		VSCODE="$root/resources/app"
		break
	fi
done
if [[ -z "${VSCODE:-}" ]]; then
	echo "error: could not find vscodium's resources/app (checked /usr/share/vscodium-bin, /opt/vscodium-bin, /usr/lib/vscodium-bin, /usr/share/codium)" >&2
	exit 1
fi

sudo chown -R "$(whoami)" "$(dirname "$VSCODE")"

CSS_TARGET="$VSCODE/out/vs/workbench/workbench.desktop.main.css"
JS_TARGET="$VSCODE/out/vs/workbench/workbench.desktop.main.js"
PRODUCT_JSON="$VSCODE/product.json"
JS_MARKER="/* dotfiles:font */"

FONT_CSS="body{--vscode-font-family:\"$FONT\";}.linux{font-family:\"$FONT\",sans-serif!important;}.monaco-workbench input,.monaco-workbench select,.monaco-workbench textarea,.monaco-workbench .monaco-inputbox{font-family:\"$FONT\",sans-serif!important;}"

update_checksums() {
	python3 - "$CSS_TARGET" "$JS_TARGET" "$PRODUCT_JSON" <<'EOF'
import sys, hashlib, base64, json, subprocess
css_path, js_path, product_path = sys.argv[1], sys.argv[2], sys.argv[3]
def sha256b64(p): return base64.b64encode(hashlib.sha256(open(p,"rb").read()).digest()).decode()
product = json.loads(open(product_path).read())
product.setdefault("checksums", {}).update({
    "vs/workbench/workbench.desktop.main.css": sha256b64(css_path),
    "vs/workbench/workbench.desktop.main.js":  sha256b64(js_path),
})
subprocess.run(["sudo","tee",product_path], input=json.dumps(product,indent="\t").encode(), capture_output=True, check=True)
EOF
}

if [[ "${1:-}" == "--force" ]]; then
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
	update_checksums
	echo "✦ done - restart VSCodium to apply"
	exit 0
fi

echo "✦ Pointing extensionsGallery at the real marketplace..."
python3 - "$PRODUCT_JSON" <<'EOF'
import sys, json, subprocess
path = sys.argv[1]
product = json.loads(open(path).read())
product["extensionsGallery"] = {
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
    "itemUrl": "https://marketplace.visualstudio.com/items",
    "controlUrl": "",
    "recommendationsUrl": ""
}
subprocess.run(["sudo","tee",path], input=json.dumps(product, indent="\t").encode(), capture_output=True, check=True)
EOF

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

update_checksums

echo "✦ giving perms..."
sudo chown -R "$(whoami)" "$(dirname "$VSCODE")"

echo "✦ done - restart VSCodium to apply"
