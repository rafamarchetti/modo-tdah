# Guia para agentes

Este arquivo é o mapa para agentes que trabalham neste repositório. Ele não
substitui as regras da skill em `skills/tdah/SKILL.md` — se você é o agente
aplicando o modo tdah, é aquele arquivo que você segue.

## Comece aqui

| Quero… | Vá para |
|---|---|
| entender o que a skill faz | `README.md` |
| mudar o comportamento | `skills/tdah/SKILL.md` — **fonte única** |
| instalar em alguma plataforma | `INSTALL.md` |
| entender como ela liga sozinha | `hooks/always-on.sh` |

## Regra de edição

`skills/tdah/SKILL.md` é a única fonte. Não edite as cópias — elas são geradas.

Depois de qualquer edição na fonte:

```bash
sh scripts/sync.sh
```

Isso regrava `.cursor/skills/tdah/SKILL.md`. As demais plataformas leem a fonte
diretamente pelo caminho declarado no manifesto delas.

## Mapa dos manifestos

| Plataforma | Arquivo | Como aponta para a skill |
|---|---|---|
| Claude Code | `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` | `hooks/hooks.json` → `hooks/always-on.sh` |
| Codex | `.codex-plugin/plugin.json` | `"skills": "./skills/"` |
| Gemini CLI | `gemini-extension.json` | `GEMINI.md` → `@./skills/tdah/SKILL.md` |
| Kimi | `kimi.plugin.json` | `"skills": "./skills/"` |
| Qwen | `qwen-extension.json` | `"skills": "skills"` |
| OpenCode | `opencode.json` | `.opencode/plugins/tdah.mjs` |
| Antigravity | `plugin.json`, `.agents/plugins/marketplace.json` | manifesto direto |
| Cursor | — | `.cursor/skills/tdah/SKILL.md` (cópia) |

## Diferença de padrão em relação ao i-have-adhd

O `i-have-adhd` exige opt-in: o hook só injeta se existir
`~/.claude/.i-have-adhd-always`. Aqui é o inverso — **ligado por padrão**, e o
arquivo `~/.claude/.tdah-off` é que desliga. Se você portar código de lá, a
condição do flag está invertida de propósito.

## O que este repo não tem

Não há `evals/` nem `tests/`. O `i-have-adhd` tem os dois; portar é trabalho em
aberto.
