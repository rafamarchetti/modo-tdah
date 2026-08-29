// tdah — plugin do OpenCode.
//
// Espelha o comportamento do Claude Code / Codex: `skills/tdah/SKILL.md` e a
// fonte unica do ruleset.
//
//   • Sob demanda — registra o diretorio de skills e o comando /tdah.
//   • Sempre ligado — o ruleset inteiro e anexado ao system prompt a cada turno,
//     equivalente ao hook SessionStart em hooks/always-on.sh.
//
// Ligado por padrao. Desligar de vez:  touch ~/.config/opencode/.tdah-off
// Voltar a ligar:                      rm ~/.config/opencode/.tdah-off

import fs from 'fs';
import os from 'os';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const skillsDir = path.resolve(__dirname, '../../skills');
const skillPath = path.join(skillsDir, 'tdah', 'SKILL.md');

// Flag de desligamento, sob o config dir do OpenCode para que as duas
// ferramentas fiquem independentes do ~/.claude/.tdah-off do Claude Code.
const offFlagPath = path.join(
  process.env.XDG_CONFIG_HOME || path.join(os.homedir(), '.config'),
  'opencode',
  '.tdah-off',
);

// Le o SKILL.md e remove o bloco YAML de frontmatter do topo (--- ... ---).
function rulesetBody() {
  return fs
    .readFileSync(skillPath, 'utf8')
    .replace(/^---[^\S\r\n]*\r?\n[\s\S]*?\r?\n---[^\S\r\n]*(?:\r?\n|$)/, '')
    .replace(/(?:\r?\n)+$/, '');
}

export default async () => {
  return {
    // Torna a skill descoberivel para a tool `skill` e para o comando /tdah.
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(skillsDir)) config.skills.paths.push(skillsDir);
    },

    // Sempre ligado: anexa o ruleset ao system prompt a cada turno enquanto o
    // arquivo de desligamento nao existir. "sai do modo tdah" desliga por esta
    // sessao; criar o arquivo desliga de vez.
    'experimental.chat.system.transform': async (_input, output) => {
      let off = false;
      try { off = fs.existsSync(offFlagPath); } catch (e) {}
      if (off) return;

      let body;
      try { body = rulesetBody(); } catch (e) { return; }

      const header =
        'MODO TDAH ATIVO (sempre ligado). As regras abaixo valem para toda ' +
        'resposta desta sessao. Decida o modo antes de escrever: EXECUTAR ou ' +
        'ENTENDER. "sai do modo tdah" desliga por esta sessao; crie ' +
        offFlagPath + ' para desligar de vez.';
      const injected = header + '\n\n' + body;

      if (output.system.length > 0) {
        output.system[output.system.length - 1] += '\n\n' + injected;
      } else {
        output.system.push(injected);
      }
    },
  };
};
