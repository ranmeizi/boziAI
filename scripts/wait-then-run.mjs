#!/usr/bin/env node
/**
 * 等待 N 秒后执行命令
 * 用法: node scripts/wait-then-run.mjs <秒> <脚本路径> [脚本参数...]
 */
import { spawnSync } from 'node:child_process';

let [waitSecRaw, script, ...scriptArgs] = process.argv.slice(2);
// pnpm/npm 的 `--` 分隔符会透传进来，去掉以免子脚本报「未知选项」
scriptArgs = scriptArgs.filter((a) => a !== '--');
const waitSec = Number(waitSecRaw) || 7;

if (!script) {
  console.error('用法: node scripts/wait-then-run.mjs <秒> <脚本> [参数...]');
  process.exit(1);
}

console.log(`[wait-then-run] 等待 ${waitSec}s 后执行: node ${script} ${scriptArgs.join(' ')}`.trim());
await new Promise((r) => setTimeout(r, waitSec * 1000));

const result = spawnSync(process.execPath, [script, ...scriptArgs], {
  stdio: 'inherit',
  cwd: process.cwd(),
});

process.exit(result.status === null ? 1 : result.status);
