# Changelog

## 0.3.1

- The Mac binary is notarized by Apple, and the public repository has `install.sh` at its top
  level and the binaries under `cli/`.
- Telemetry is a setting. It is on by default, `karma init` says so at the end, and
  `karma settings set telemetry false` turns it off, after which karma sends nothing to analytics.
  Turning it off sends one last event saying so.
- `karma crew tell` refuses when the agent has a selection menu open, such as Codex's `/model`
  picker, instead of pressing Enter on it. A message karma cannot confirm the agent took is
  reported as not delivered. `karma agent goal` refuses to change a goal while a prompt, a menu or
  an unsent draft is open, and history records a goal change as delivered only once the tool
  confirms it.
- When Codex asks "Resume paused goal?", karma answers "Leave paused", so a restored agent does
  not start working on an old goal by itself.
- `karma agent interrupt` waits up to 15 seconds for the agent to stop, and `karma crew tell @all`
  reports only the agents that are running.
- The settings page of `karma init` redraws in place instead of adding a copy below the old one.

## 0.3.0

- Karma Yoga CLI runs Claude Code and Codex agents together in one terminal session. A manager
  agent gives tasks to the agents beside it, and you can talk to any of them.
- `karma init` sets up Claude Code, Codex or both, and `karma new` starts a session.
- Sessions keep running when you leave them, and `karma open` takes you back. After a crash or a
  reboot, every agent comes back on its own conversation.
- `karma doctor` checks your tools, and `karma update` installs a new release and restarts your
  sessions on it.
- It runs on macOS and Linux, and on Windows through WSL2.
