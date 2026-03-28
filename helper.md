### Naming Conventions Table

| Language | Variables & Objects | Functions / Methods | Constants | Types / Classes |
| :--- | :--- | :--- | :--- | :--- |
| **C** | `snake_case` | `snake_case` | `SCREAMING_SNAKE` | `snake_case` or `PascalCase` |
| **C++** | `snake_case` | `snake_case` or `camelCase` | `SCREAMING_SNAKE` | `PascalCase` |
| **Python** | `snake_case` | `snake_case` | `SCREAMING_SNAKE` | `PascalCase` |
| **Java** | `camelCase` | `camelCase` | `SCREAMING_SNAKE` | `PascalCase` |
| **Go** | `camelCase`* | `PascalCase`* | `camelCase` or `PascalCase` | `PascalCase` |
| **Rust** | `snake_case` | `snake_case` | `SCREAMING_SNAKE` | `PascalCase` |
| **Zig** | `camelCase` | `camelCase` | `SCREAMING_SNAKE` | `PascalCase` |
| **Bash** | `snake_case` | `snake_case` | `SCREAMING_SNAKE` | N/A |
| **Fish** | `snake_case` | `snake_case` | `snake_case` | N/A |

---


### Sourcing Files Scripts - Bash

  2. The Script-Relative Path (Recommended)
  This is the most common "pro" way to do it. It finds the location of the script itself,
  then looks for the library relative to that location. This works no matter where you call
  the script from.

Get the directory where the script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

Source the library relative to that directory
source "$SCRIPT_DIR/../lib/print.sh"
   * Trade-off: A bit more verbose, but much more reliable.

  3. The Path Search (PATH)
  If you eventually turn this into a package or install it globally, you might rely on Bash
  searching for the file in your environment.

   1 # This only works if lib/ is in your PATH or you manage it with a tool
   2 source print.sh
   * Trade-off: Requires more setup in your environment (~/.bashrc, etc.) and can lead to
     name collisions if multiple projects have a print.sh.
