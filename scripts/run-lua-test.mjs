#!/usr/bin/env node
/**
 * 在「仓库上级目录」执行 lua（与客户端 AI 路径约定一致）
 *
 * 用法: node scripts/run-lua-test.mjs USER_AI/test/memory.lua
 */

import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const repoParent = path.resolve(repoRoot, '..');
const repoName = path.basename(repoRoot);

const rel = process.argv[2];
if (!rel) {
  console.error('用法: node scripts/run-lua-test.mjs <相对仓库的 lua 路径>');
  process.exit(1);
}

const scriptPath = path.join(repoName, rel);
const result = spawnSync('lua', [scriptPath], {
  cwd: repoParent,
  stdio: 'inherit',
});

process.exit(result.status === null ? 1 : result.status);
