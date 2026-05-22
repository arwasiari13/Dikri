# Skills Install Report

Generated: 2026-05-22

## Environment Detected

- OS: Microsoft Windows 11 Pro
- Shell: Windows PowerShell 5.1.26100.8457
- Working directory: `C:\Users\arwas\Downloads\dikriflutter`
- Node.js: `v22.18.0`
- npm: `10.9.3`
- npx: `10.9.3`
- Git: `git version 2.51.0.windows.1`
- Codex CLI: `codex-cli 0.133.0-alpha.1`
- Codex path: `c:\Users\arwas\.vscode\extensions\openai.chatgpt-26.519.32039-win32-x64\bin\windows-x86_64\codex.exe`
- Claude Code CLI: not found on PATH

## Commands Executed

```powershell
node -v
npm -v
npx -v
git --version
$PSVersionTable.PSVersion.ToString()
(Get-CimInstance Win32_OperatingSystem).Caption
claude --version
codex --version
where.exe claude
where.exe codex
npx skills update
npx skills add vercel-labs/skills --skill find-skills -g -a claude-code -a codex -y
npx skills add anthropics/skills --skill frontend-design --skill webapp-testing --skill docx --skill pdf --skill pptx --skill xlsx -g -a claude-code -a codex -y
npx skills add vercel-labs/agent-skills --skill '*' -g -a claude-code -a codex -y
npx skills list
npx skills find testing
npx skills find frontend
npx skills find vercel
npx skills list -g
npx skills update
npx skills --help
npx skills list -g -a codex --json
npx skills list -g -a claude-code --json
npx skills list -g --json
```

## Skills Installed

Installed globally under:

- `C:\Users\arwas\.agents\skills`
- `C:\Users\arwas\.claude\skills`

Installed skills:

- `find-skills` from `vercel-labs/skills`
- `docx` from `anthropics/skills`
- `frontend-design` from `anthropics/skills`
- `pdf` from `anthropics/skills`
- `pptx` from `anthropics/skills`
- `webapp-testing` from `anthropics/skills`
- `xlsx` from `anthropics/skills`
- `deploy-to-vercel` from `vercel-labs/agent-skills`
- `vercel-cli-with-tokens` from `vercel-labs/agent-skills`
- `vercel-composition-patterns` from `vercel-labs/agent-skills`
- `vercel-optimize` from `vercel-labs/agent-skills`
- `vercel-react-best-practices` from `vercel-labs/agent-skills`
- `vercel-react-native-skills` from `vercel-labs/agent-skills`
- `vercel-react-view-transitions` from `vercel-labs/agent-skills`
- `web-design-guidelines` from `vercel-labs/agent-skills`

## Verification Results

- `npx skills update`: completed successfully.
- Initial `npx skills update`: no global skills were tracked yet.
- Final `npx skills update`: all 15 global skills are up to date.
- `npx skills list`: reported no project-local skills. This is expected because the install target was global.
- `npx skills list -g`: listed all 15 global skills.
- `npx skills find testing`: found `anthropics/skills@webapp-testing` as the top trusted result.
- `npx skills find frontend`: found `anthropics/skills@frontend-design` as the top trusted result.
- `npx skills find vercel`: found `vercel-labs/skills@find-skills` and several `vercel-labs/agent-skills` entries.

## Errors Encountered

- `claude --version` failed because `claude` is not available on PATH.
- `where.exe claude` failed because Claude Code CLI is not available on PATH.
- `npx skills list` reported no project skills. This was not a failure; it checks project scope by default.

## Fixes Applied

- Used global installation with `-g`.
- Verified global installs with `npx skills list -g`.
- Kept installs limited to trusted repositories requested by the user:
  - `vercel-labs/skills`
  - `anthropics/skills`
  - `vercel-labs/agent-skills`
- Avoided installing unrelated search results from other repositories.

## Security Notes

- The skills CLI warned that skills run with full agent permissions.
- The Anthropic `pdf` skill showed `High Risk` in the Snyk column, but generation checks showed `Safe` and socket checks showed `0 alerts`.
- `vercel-cli-with-tokens` showed `Med Risk`.
- `web-design-guidelines` showed `Med Risk`.
- No secrets, tokens, or credentials were printed or stored in this report.

## Codex And Claude Code Notes

- The install commands accepted both `-a claude-code` and `-a codex`.
- During install, the CLI reported skills as `universal: Codex` and `symlinked: Claude Code`.
- The final `npx skills list -g --json` output labels the installed agent as `Claude Code`, even when filtering with `-a codex`.
- `C:\Users\arwas\.codex\skills` currently contains only `.system`; the skills.sh CLI installed the universal skill copies under `C:\Users\arwas\.agents\skills`.
- Claude Code itself is not installed or not on PATH, but its skill directory was created/populated.

## Final Recommended Skills For This Workflow

Already installed and recommended:

- `frontend-design`
- `webapp-testing`
- `docx`
- `pdf`
- `pptx`
- `xlsx`
- `find-skills`
- `deploy-to-vercel`
- `vercel-react-best-practices`
- `vercel-composition-patterns`
- `vercel-react-view-transitions`
- `vercel-optimize`
- `web-design-guidelines`

Use with care:

- `vercel-cli-with-tokens`, because it is intended for workflows involving Vercel tokens.
- `pdf`, because the skills CLI reported a high Snyk risk even though the source repository is trusted.

Recommended next steps:

- Install Claude Code CLI if you want to use these skills directly from Claude Code.
- Restart Codex and Claude Code after installation so newly installed skills are picked up.
- Run `npx skills update -g` periodically to keep global skills current.
