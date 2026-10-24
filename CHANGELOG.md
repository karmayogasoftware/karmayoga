# Changelog

## 0.3.0

- Karma Yoga CLI runs Claude Code and Codex agents together in one terminal session. A manager
  agent gives tasks to the agents beside it, and you can talk to any of them.
- `karma init` sets up Claude Code, Codex or both, and `karma new` starts a session.
- Sessions keep running when you leave them, and `karma open` takes you back. After a crash or a
  reboot, every agent comes back on its own conversation.
- `karma doctor` checks your tools, and `karma update` installs a new release and restarts your
  sessions on it.
- It runs on macOS and Linux, and on Windows through WSL2.
