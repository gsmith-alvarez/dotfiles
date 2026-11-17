"""Parse config sources without starting applications or loading plugins."""

import json
import subprocess
import sys
import tomllib
from pathlib import Path

count = 0
for arg in sys.argv[1:]:
    target = Path(arg)
    paths = [target] if target.is_file() else sorted(target.rglob("*"))
    for path in paths:
        if not path.is_file():
            continue
        if path.suffix == ".toml":
            tomllib.loads(path.read_text())
        elif path.suffix == ".json":
            json.loads(path.read_text())
        elif path.suffix == ".fish":
            subprocess.run(["fish", "--no-config", "--no-execute", str(path)], check=True)
        elif path.suffix == ".lua":
            subprocess.run(["luajit", "-b", str(path), "/dev/null"], check=True)
        else:
            continue
        count += 1
print(f"Parsed {count} TOML, JSON, Fish and Lua sources (JSONC excluded)")
