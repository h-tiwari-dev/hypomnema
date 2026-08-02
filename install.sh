#!/bin/sh
set -eu

if ! command -v python3 >/dev/null 2>&1 ||
   ! python3 -c 'import sys; raise SystemExit(sys.version_info < (3, 10))'; then
  echo "hypomnema needs Python 3.10 or newer." >&2
  exit 1
fi

install_dir="${HYPOMNEMA_INSTALL_DIR:-$HOME/.local/bin}"
profile="${ZDOTDIR:-$HOME}/.zprofile"
source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
skill_source="$source_dir/.agents/skills/hypomnema"

mkdir -p "$install_dir"
cp "$source_dir/hypomnema.py" "$install_dir/hypomnema"
chmod +x "$install_dir/hypomnema"

for skill_dir in "$HOME/.agents/skills" "$HOME/.cursor/skills" "$HOME/.claude/skills"; do
  mkdir -p "$skill_dir/hypomnema"
  cp -R "$skill_source/." "$skill_dir/hypomnema/"
done

legacy_copilot_skill="$HOME/.copilot/skills/hypomnema"
if [ -d "$legacy_copilot_skill" ]; then
  rm -r "$legacy_copilot_skill"
  echo "Removed the redundant Copilot skill copy; Copilot uses ~/.agents/skills."
fi

case ":$PATH:" in
  *":$install_dir:"*) ;;
  *)
    line='export PATH="$HOME/.local/bin:$PATH"'
    [ "$install_dir" = "$HOME/.local/bin" ] || line="export PATH=\"$install_dir:\$PATH\""
    touch "$profile"
    grep -Fqx "$line" "$profile" || printf '\n%s\n' "$line" >> "$profile"
    echo "Added $install_dir to PATH in $profile"
    ;;
esac

echo "Installed hypomnema and its Cursor, Claude, Codex, and Copilot skill."
echo "Start a new agent session without --resume, then run /skills."
