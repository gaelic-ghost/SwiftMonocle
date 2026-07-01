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

fixture_nodes = set()
for node_block in re.findall(r"PackageGraphNode\((.*?)\n\s*\)", fixture_source, flags=re.DOTALL):
    node_id = re.search(r"id: \.(product|target)\(\"([^\"]+)\"\)", node_block)
    node_kind = re.search(r"kind: \.(libraryTarget|testTarget|product)", node_block)
    if node_id and node_kind:
        fixture_nodes.add((node_id.group(1), node_id.group(2), node_kind.group(1)))
fixture_edges = {
    (source_kind, source, target_kind, target, edge_kind)
    for source_kind, source, target_kind, target, edge_kind in re.findall(
        r"PackageGraphEdge\(\s*source: \.(product|target)\(\"([^\"]+)\"\),\s*target: \.(product|target)\(\"([^\"]+)\"\),\s*kind: \.(productContainsTarget|targetDependsOnTarget|testTargetTestsTarget)",
        fixture_source,
        flags=re.MULTILINE,
    )
}

expected_nodes = {}
for product in manifest["products"]:
    expected_nodes[("product", product["name"])] = "product"

for target in manifest["targets"]:
    if target["type"] == "library":
        expected_nodes[("target", target["name"])] = "libraryTarget"
    elif target["type"] == "test":
        expected_nodes[("target", target["name"])] = "testTarget"

expected_edges = set()
for product in manifest["products"]:
    for target in product["targets"]:
        expected_edges.add(("product", product["name"], "target", target, "productContainsTarget"))

for target in manifest["targets"]:
    if target["type"] == "library":
        edge_kind = "targetDependsOnTarget"
    elif target["type"] == "test":
        edge_kind = "testTargetTestsTarget"
    else:
        continue

    for dependency in target.get("target_dependencies", []):
        expected_edges.add(("target", target["name"], "target", dependency, edge_kind))

fixture_node_names = {(kind, name) for kind, name, _ in fixture_nodes}
fixture_node_kinds = {(kind, name): node_kind for kind, name, node_kind in fixture_nodes}
missing_nodes = sorted(set(expected_nodes) - fixture_node_names)
extra_nodes = sorted(fixture_node_names - set(expected_nodes))
wrong_node_kinds = sorted(
    (kind, name, fixture_node_kinds[(kind, name)], expected_kind)
    for kind, name in set(expected_nodes) & fixture_node_names
    for expected_kind in [expected_nodes[(kind, name)]]
    if fixture_node_kinds[(kind, name)] != expected_kind
)
missing_edges = sorted(expected_edges - fixture_edges)
extra_edges = sorted(fixture_edges - expected_edges)

problems = []
if missing_nodes:
    problems.append(f"missing manifest-backed graph nodes: {missing_nodes}")
if extra_nodes:
    problems.append(f"extra manifest-backed graph nodes not present in Package.swift: {extra_nodes}")
if wrong_node_kinds:
    problems.append(f"manifest-backed graph nodes with incorrect graph kind: {wrong_node_kinds}")
if missing_edges:
    problems.append(f"missing manifest-backed graph edges: {missing_edges}")
if extra_edges:
    problems.append(f"extra manifest-backed graph edges not present in Package.swift: {extra_edges}")

if problems:
    raise SystemExit(
        "ERROR: SwiftMonocleGraph bootstrap fixture drifted from Package.swift. "
        + " ".join(problems)
    )

print("Package graph fixture matches Package.swift products, targets, and target dependencies.")
PY
