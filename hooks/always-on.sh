#!/usr/bin/env sh
# SessionStart hook: injeta o ruleset do modo tdah em toda sessao.
#
# Ligado por padrao, ao contrario do i-have-adhd (que exige opt-in). Desligar
# sem editar settings.json:
#   touch ~/.claude/.tdah-off      -> para de injetar
#   rm    ~/.claude/.tdah-off      -> volta a injetar
#
# Nunca bloqueia o inicio da sessao: qualquer falha sai com 0.

claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
off_flag="$claude_dir/.tdah-off"

# $0 e o caminho absoluto do script substituido pelo Claude Code, entao
# resolvemos o SKILL.md relativo a ele em vez de confiar numa variavel de ambiente.
script_dir=$(dirname -- "$0")
skill_path="$script_dir/../skills/tdah/SKILL.md"

[ -f "$off_flag" ] && exit 0
[ -f "$skill_path" ] || exit 0

# Remove o bloco YAML de frontmatter do topo. Duas passadas: a primeira decide
# se existe um --- de fechamento, para que uma cerca nao terminada nao seja
# confundida com frontmatter e o arquivo saia inteiro.
body=$(awk '
  NR == FNR {
    if (NR == 1 && $0 ~ /^---[[:space:]]*$/) { in_fm = 1; next }
    if (in_fm && $0 ~ /^---[[:space:]]*$/)   { in_fm = 0; closed = 1 }
    next
  }
  FNR == 1 { strip = closed }
  strip && FNR == 1 && $0 ~ /^---[[:space:]]*$/ { skipping = 1; next }
  skipping && $0 ~ /^---[[:space:]]*$/          { skipping = 0; next }
  !skipping { print }
' "$skill_path" "$skill_path") || exit 0

printf 'MODO TDAH ATIVO (sempre ligado). As regras abaixo valem para toda resposta desta sessao.\nDecida o modo antes de escrever: EXECUTAR ou ENTENDER. "sai do modo tdah" desliga por esta sessao;\n`touch %s` desliga de vez.\n\n%s\n' \
  "$off_flag" "$body"
