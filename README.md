# modo-tdah

**Uma skill que impede o agente de enterrar a resposta.**

Feita para quem tem TDAH, dita por voz e não necessariamente programa. Vale para
Claude Code, Codex, Cursor, Gemini CLI, Qwen Code, Kimi e OpenCode.

Em PT-BR, porque a versão em inglês perde a metade que mais importa: a tradução
do termo técnico no momento em que ele aparece.

---

## O problema

O agente sabe a resposta e te entrega sessenta linhas. A resposta está na linha
quarenta e uma. Você lê até a doze, perde o fio, e volta pro começo. Três vezes.
Depois desiste e pergunta de novo.

Não é falta de atenção. É a resposta no lugar errado.

---

## O que ela faz

Antes de escrever qualquer coisa, o agente decide entre **dois modos**. É a
única decisão que muda todas as outras regras.

| Você quer… | Modo | Como a resposta sai |
|---|---|---|
| que algo aconteça | **EXECUTAR** | comando ou caminho na **primeira linha**, passos numerados, estado repetido a cada turno, estimativa em unidade concreta, uma única próxima ação no fim |
| entender como funciona | **ENTENDER** | **a resposta na primeira linha**, um assunto por vez, todo termo técnico traduzido na mesma frase, blocos de três linhas, teto de quinze linhas |

Na dúvida, é ENTENDER.

### As regras que mais mudam o dia a dia

1. **A primeira linha é a resposta** (ou a ação). Você pode parar de ler ali.
2. **Um assunto por vez.** Perguntou quatro coisas? Responde uma, lista as três
   e pergunta qual vem agora.
3. **Termo técnico ganha tradução na hora**, não num glossário no fim — você já
   travou no meio. `bind mount` vira *"`bind mount` — a trava que o Docker põe na pasta"*.
4. **Teto de quinze linhas.** Passou? Entrega a parte 1 e oferece o resto.
   Resposta cortada que você lê inteira vale mais que resposta completa abandonada.
5. **Sem preâmbulo e sem fechamento de cortesia.** Nada de "Ótima pergunta" nem
   de "Espero ter ajudado".
6. **Uma decisão no fim, no máximo.** Lista de pendências no rodapé transfere
   pra você o trabalho de escolher por onde começar — que é o que o TDAH cobra
   mais caro.
7. **"Não entendi" não se responde com mais palavras.** Troca a explicação por
   uma analogia concreta: nave, obra, oficina, cozinha.

### Os sete fatos por trás

Memória de trabalho é pequena · saber a resposta não é fazer a resposta ·
começar é o passo mais difícil · tempo não tem textura · dopamina é escassa ·
termo técnico sem tradução derruba a leitura inteira · pergunta múltipla
respondida de uma vez vira pergunta nenhuma.

### Quando ela se cala

Ação destrutiva confirma antes. Espiral de depuração para e faz uma pergunta de
diagnóstico. "Quais são minhas opções" recebe 2 a 4 opções ranqueadas — as
opções *são* a resposta, e nesse caso a tarefa ganha do formato.

---

## Instalar

O guia completo, plataforma por plataforma, está em [INSTALL.md](INSTALL.md).
O caminho mais curto para cada uma:

### Claude Code — plugin (recomendado)

```bash
claude plugin marketplace add rafamarchetti/modo-tdah
claude plugin install modo-tdah
```

Fica **ligado sozinho** em toda sessão nova, via hook `SessionStart`.

### Claude Code — instalação manual

```bash
git clone https://github.com/rafamarchetti/modo-tdah.git
mkdir -p ~/.claude/skills
cp -r modo-tdah/skills/modo-tdah ~/.claude/skills/
```

Depois registre o hook — veja [INSTALL.md](INSTALL.md#claude-code-manual).

### Gemini CLI

```bash
git clone https://github.com/rafamarchetti/modo-tdah.git ~/.gemini/extensions/modo-tdah
```

### Cursor

```bash
git clone https://github.com/rafamarchetti/modo-tdah.git
cp -r modo-tdah/.cursor/skills/modo-tdah .cursor/skills/
```

### Codex · Kimi · Qwen · OpenCode

Cada um lê um manifesto próprio já incluído no repo
(`.codex-plugin/plugin.json`, `kimi.plugin.json`, `qwen-extension.json`,
`opencode.json`). Passo a passo em [INSTALL.md](INSTALL.md).

### Qualquer outra LLM (ChatGPT, Grok, DeepSeek…)

Não tem plugin? Copie o arquivo e cole no campo de instruções:

```bash
cat skills/modo-tdah/SKILL.md
```

Cole em **Custom Instructions** (ChatGPT, Grok), nas instruções de um **Gem**
(Gemini web), ou como primeira mensagem do chat. Peça o corte explícito, senão
o modelo "melhora" as regras e você perde o que foi calibrado:

> "Siga estas regras. Ignore o bloco YAML do topo e a seção sobre harness.
> **Não reescreva nem resuma o resto** — aplique como está."

---

## Ligar e desligar

| O que você quer | Como |
|---|---|
| desligar nesta conversa | diga **"sai do modo tdah"** ou **"modo normal"** |
| religar nesta conversa | diga **"modo tdah"** |
| desligar de vez (Claude Code) | `touch ~/.claude/.modo-tdah-off` |
| religar de vez | `rm ~/.claude/.modo-tdah-off` |
| desligar de vez (OpenCode) | `touch ~/.config/opencode/.modo-tdah-off` |

O liga/desliga por frase **não deixa rastro em disco** — é só comportamento do
modelo. Só o arquivo `.modo-tdah-off` é verificável com `ls`.

---

## Como o repo está montado

`skills/modo-tdah/SKILL.md` é a **fonte única**. Todo o resto aponta pra ele.

```
skills/modo-tdah/SKILL.md     fonte única — edite só aqui
hooks/always-on.sh            injeta o ruleset a cada sessão (Claude Code)
hooks/hooks.json              registra o hook no SessionStart
scripts/sync.sh               propaga a fonte para as cópias de cada plataforma
.claude-plugin/               manifesto do plugin + marketplace (Claude Code)
.codex-plugin/                manifesto do Codex
.cursor/skills/modo-tdah/     cópia para o Cursor (gerada pelo sync.sh)
.opencode/                    comando /modo-tdah + plugin sempre-ligado
.agents/plugins/              marketplace do Antigravity
GEMINI.md                     arquivo de contexto do Gemini CLI
gemini-extension.json · kimi.plugin.json · qwen-extension.json · opencode.json
```

Editou o `SKILL.md`? Rode `sh scripts/sync.sh` para propagar.

Já usa a skill instalada em `~/.claude/skills/modo-tdah/` e quer trazer a sua versão
pra cá: `sh scripts/sync.sh --from-claude`.

---

## Crédito

As dez regras do modo **EXECUTAR** e os cinco primeiros fatos de leitura vêm do
**[i-have-adhd](https://github.com/ayghri/i-have-adhd)**, de Ayoub G. — licença
MIT. Traduzidas e condensadas.

O modo **ENTENDER**, os fatos 6 e 7, e a estrutura em dois modos são deste
projeto. Nasceram de uma falha medida: uma resposta de ~60 linhas, com quatro
perguntas respondidas de uma vez e termo técnico sem tradução, que o leitor não
conseguiu usar. O `i-have-adhd` desliga as regras dele quando o assunto é
explicação e não põe nada no lugar — é exatamente onde a explicação vira parede.

Licença MIT. Fork à vontade e ajuste o `SKILL.md` pro seu cérebro.
