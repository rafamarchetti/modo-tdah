# Instalação

A fonte única é `skills/modo-tdah/SKILL.md`. Cada plataforma abaixo só aponta pra ela
de um jeito diferente.

---

## Claude Code — plugin (recomendado)

```bash
claude plugin marketplace add rafamarchetti/modo-tdah
claude plugin install modo-tdah
```

Pronto. O hook `SessionStart` injeta o ruleset em toda sessão nova, resumida ou
limpa com `/clear`.

Conferir se pegou: abra uma sessão nova. O texto da skill aparece no começo.

<a id="claude-code-manual"></a>
## Claude Code — manual

1. Copie a skill:

```bash
git clone https://github.com/rafamarchetti/modo-tdah.git
mkdir -p ~/.claude/skills ~/.claude/hooks
cp -r modo-tdah/skills/modo-tdah ~/.claude/skills/
cp modo-tdah/hooks/always-on.sh ~/.claude/hooks/modo-tdah-activate.sh
```

2. Ajuste o caminho da skill dentro do hook copiado — na instalação manual ela
   fica em `~/.claude/skills/modo-tdah/SKILL.md`, e não ao lado do hook:

```bash
sed -i 's|skill_path="$script_dir/../skills/modo-tdah/SKILL.md"|skill_path="$claude_dir/skills/modo-tdah/SKILL.md"|' ~/.claude/hooks/modo-tdah-activate.sh
```

3. Registre o hook em `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "sh \"$HOME/.claude/hooks/modo-tdah-activate.sh\"",
            "timeout": 30,
            "statusMessage": "Carregando modo tdah..."
          }
        ]
      }
    ]
  }
}
```

Sem o hook, a skill ainda existe — você a chama com `/modo-tdah`. Com o hook, ela
liga sozinha.

---

## Gemini CLI

```bash
git clone https://github.com/rafamarchetti/modo-tdah.git ~/.gemini/extensions/modo-tdah
```

O `gemini-extension.json` aponta para `GEMINI.md`, que importa o `SKILL.md`
inteiro com `@./skills/modo-tdah/SKILL.md`.

---

## Cursor

```bash
git clone https://github.com/rafamarchetti/modo-tdah.git /tmp/modo-tdah
mkdir -p .cursor/skills
cp -r /tmp/modo-tdah/.cursor/skills/modo-tdah .cursor/skills/
```

Por projeto. Para valer em todos, copie para `~/.cursor/skills/`.

---

## Codex

```bash
git clone https://github.com/rafamarchetti/modo-tdah.git
```

Aponte o Codex para a pasta clonada. Ele lê `.codex-plugin/plugin.json`, que
declara `"skills": "./skills/"`.

---

## Kimi Code CLI

Mesma clonagem. O manifesto é `kimi.plugin.json`, também com `"skills": "./skills/"`.

---

## Qwen Code

Mesma clonagem. O manifesto é `qwen-extension.json`, com `"skills": "skills"`.

---

## OpenCode

Adicione ao seu `opencode.json`:

```json
{ "plugin": ["./.opencode/plugins/modo-tdah.mjs"] }
```

Dois efeitos:

- registra o comando `/modo-tdah` para ligar sob demanda;
- anexa o ruleset ao system prompt a cada turno, **ligado por padrão**.

Desligar de vez: `touch ~/.config/opencode/.modo-tdah-off`.

---

## Qualquer LLM sem plugin

```bash
cat skills/modo-tdah/SKILL.md
```

Cole em Custom Instructions (ChatGPT, Grok), nas instruções de um Gem (Gemini
web), ou como primeira mensagem do chat.

Duas partes não servem fora do Claude Code e podem ser cortadas — cortá-las não
muda nenhuma regra de escrita:

1. o **frontmatter YAML** do topo (entre `---`), que só o Claude Code lê;
2. a seção **"A regra briga com o harness"**, que aponta para um system prompt
   que não existe lá fora.

Peça o corte explícito, nunca "adapta":

> "Siga estas regras. Ignore o bloco YAML do topo e a seção sobre harness.
> **Não reescreva nem resuma o resto** — aplique como está."

---

## Verificar que está funcionando

| Sinal | O que significa |
|---|---|
| o texto da skill aparece no início da sessão | o hook injetou — está ligado |
| `ls ~/.claude/.modo-tdah-off` diz que não existe | não há desligamento permanente |
| a resposta abre com a ação ou com a resposta | o modelo está aplicando |

Editou o `SKILL.md` no meio de uma sessão? A mudança **não** entra sozinha.
Rode `/clear` ou abra sessão nova.
