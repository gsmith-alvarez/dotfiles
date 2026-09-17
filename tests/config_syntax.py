"""Parse config sources without starting applications or loading plugins."""

import json
import subprocess
import sys
import tomllib
from pathlib import Path

root = Path(sys.argv[1])
count = 0
for path in sorted(root.rglob("*")):
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
