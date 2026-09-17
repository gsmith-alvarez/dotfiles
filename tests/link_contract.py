"""Validate live config sources and their boundary with generated files."""

import json
import sys
from pathlib import Path, PurePosixPath


def validate(root, links, generated):
    root = Path(root).resolve()
    errors = []
    for target, source in links.items():
        path = (root / source).resolve()
        if not path.is_relative_to(root) or not path.exists():
            errors.append(f"{target}: missing or external source {source}")
    targets = list(links)
    pairs = [(a, b) for i, a in enumerate(targets) for b in targets[i + 1:]]
    pairs += [(a, b) for a in targets for b in generated]
    for a, b in pairs:
        a, b = PurePosixPath(a), PurePosixPath(b)
        if a.is_relative_to(b) or b.is_relative_to(a):
            errors.append(f"overlapping owners: {a} and {b}")
    return errors


if __name__ == "__main__":
    manifest = json.loads(Path(sys.argv[2]).read_text())
    errors = validate(sys.argv[1], manifest["links"], manifest["generated"])
    if errors:
        sys.exit("\n".join(errors))
    print(f"Validated {len(manifest['links'])} live config sources and ownership boundaries")
