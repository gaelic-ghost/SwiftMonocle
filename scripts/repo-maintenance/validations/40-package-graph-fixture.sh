#!/usr/bin/env sh
set -eu

SELF_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
export REPO_MAINTENANCE_COMMON_DIR="$SELF_DIR/../lib"
. "$SELF_DIR/../lib/common.sh"

fixture_path="$REPO_ROOT/Sources/SwiftMonocleGraph/SwiftMonoclePackageGraph.swift"

if [ ! -f "$fixture_path" ]; then
  log "Skipping package graph fixture validation because $fixture_path is not present."
  exit 0
fi

python3 - "$REPO_ROOT" "$fixture_path" <<'PY'
import json
import re
import subprocess
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
fixture_path = Path(sys.argv[2])
fixture_source = fixture_path.read_text(encoding="utf-8")

description = subprocess.run(
    ["swift", "package", "describe", "--type", "json"],
    cwd=repo_root,
    check=False,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True,
)

if description.returncode != 0:
    raise SystemExit(
        "ERROR: Package graph fixture validation could not read SwiftPM manifest JSON. "
        f"Command `swift package describe --type json` failed in {repo_root}: {description.stderr.strip()}"
    )

manifest = json.loads(description.stdout)

def swift_string_array(source):
    return re.findall(r'"([^"]+)"', source)


fixture_products = {}
for name, targets_source in re.findall(
    r'Product\(\s*name: "([^"]+)",\s*targets: \[(.*?)\]\s*\)',
    fixture_source,
    flags=re.DOTALL,
):
    fixture_products[name] = swift_string_array(targets_source)

fixture_targets = {}
for target_block in re.findall(r"Target\((.*?)\n\s*\)", fixture_source, flags=re.DOTALL):
    name = re.search(r'name: "([^"]+)"', target_block)
    path = re.search(r'path: "([^"]+)"', target_block)
    target_type = re.search(r"type: \.([A-Za-z]+)", target_block)
    target_dependencies = re.search(r"targetDependencies: \[(.*?)\]", target_block, flags=re.DOTALL)
    product_dependencies = re.search(r"productDependencies: \[(.*?)\]", target_block, flags=re.DOTALL)
    if name and path and target_type:
        fixture_targets[name.group(1)] = {
            "path": path.group(1),
            "type": target_type.group(1),
            "target_dependencies": swift_string_array(target_dependencies.group(1)) if target_dependencies else [],
            "product_dependencies": swift_string_array(product_dependencies.group(1)) if product_dependencies else [],
        }

expected_products = {
    product["name"]: product["targets"]
    for product in manifest["products"]
}
expected_targets = {
    target["name"]: {
        "path": target["path"],
        "type": {
            "system-target": "system",
        }.get(target["type"], target["type"]),
        "target_dependencies": target.get("target_dependencies", []),
        "product_dependencies": target.get("product_dependencies", []),
    }
    for target in manifest["targets"]
}

missing_products = sorted(set(expected_products) - set(fixture_products))
extra_products = sorted(set(fixture_products) - set(expected_products))
wrong_products = sorted(
    (name, fixture_products[name], expected_products[name])
    for name in set(expected_products) & set(fixture_products)
    if fixture_products[name] != expected_products[name]
)

missing_targets = sorted(set(expected_targets) - set(fixture_targets))
extra_targets = sorted(set(fixture_targets) - set(expected_targets))
wrong_targets = sorted(
    (name, fixture_targets[name], expected_targets[name])
    for name in set(expected_targets) & set(fixture_targets)
    if fixture_targets[name] != expected_targets[name]
)

problems = []
if missing_products:
    problems.append(f"missing SwiftPM products: {missing_products}")
if extra_products:
    problems.append(f"extra SwiftPM products not present in Package.swift: {extra_products}")
if wrong_products:
    problems.append(f"SwiftPM products with mismatched targets: {wrong_products}")
if missing_targets:
    problems.append(f"missing SwiftPM targets: {missing_targets}")
if extra_targets:
    problems.append(f"extra SwiftPM targets not present in Package.swift: {extra_targets}")
if wrong_targets:
    problems.append(f"SwiftPM targets with mismatched metadata: {wrong_targets}")

if problems:
    raise SystemExit(
        "ERROR: SwiftMonocleGraph SwiftPM description bootstrap drifted from Package.swift. "
        + " ".join(problems)
    )

print("Package graph SwiftPM description matches Package.swift products, targets, and dependencies.")
PY
