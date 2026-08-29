#!/usr/bin/env sh
# Propaga a fonte unica (skills/tdah/SKILL.md) para as copias que cada
# plataforma exige em caminho proprio. Rode depois de editar o SKILL.md.
#
#   sh scripts/sync.sh
#
# Opcional: --from-claude copia primeiro o SKILL.md instalado em
# ~/.claude/skills/tdah/ para dentro do pacote, tratando o instalado como fonte.
set -e

root=$(cd -- "$(dirname -- "$0")/.." && pwd)
src="$root/skills/tdah/SKILL.md"

if [ "$1" = "--from-claude" ]; then
  claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  installed="$claude_dir/skills/tdah/SKILL.md"
  [ -f "$installed" ] || { echo "nao achei $installed"; exit 1; }
  cp "$installed" "$src"
  echo "fonte atualizada a partir de $installed"
fi

[ -f "$src" ] || { echo "fonte ausente: $src"; exit 1; }

mkdir -p "$root/.cursor/skills/tdah"
cp "$src" "$root/.cursor/skills/tdah/SKILL.md"

echo "sincronizado:"
echo "  .cursor/skills/tdah/SKILL.md"
echo "(Gemini, Codex, Kimi, Qwen e OpenCode leem skills/tdah/SKILL.md direto)"
