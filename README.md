# Karma Yoga CLI

Run a fleet of persistent Claude Code and Codex agents in your terminal. Each session has a manager and many crew agents. The manager agent takes your task, briefs the agents, with a build and review loop, and reports back. 

![Karma Yoga session: manager pane on the left, agents on the right](docs/demo.gif)

## Install

The recommended install is with your agent. Paste this prompt into Claude Code, Codex or any agent of your choice.

```text
Go to karmayoga.dev/agent, install the Karma Yoga CLI and follow the steps to open inside a Karma Yoga session.
```

In Codex, first type `/permissions` and choose Full Access, because Codex blocks network access by default.

When your agent finishes, open a new terminal and run the `karma open` command it gives you.

To install by hand instead, use one of the methods below.

### Install script (macOS and Linux)

```sh
curl -fsSL https://karmayoga.dev/install.sh | sh
```

### Homebrew (macOS and Linux)

```sh
brew install karmayogasoftware/tap/karma
```

### Windows

Open PowerShell as administrator, run `wsl --install` and restart your computer. Open Ubuntu from the Start menu, choose a username and password, then run the install script inside Ubuntu.

<details>
<summary>Click here to see how to install directly from GitHub Releases</summary>

Each [release](https://github.com/karmayogasoftware/karmayoga/releases) has an archive for each platform and a SHASUMS256.txt. On macOS:

```sh
v=0.3.3
curl -fLO https://github.com/karmayogasoftware/karmayoga/releases/download/v$v/karma-$v-macos-universal.tar.gz
curl -fLO https://github.com/karmayogasoftware/karmayoga/releases/download/v$v/SHASUMS256.txt
shasum -a 256 -c --ignore-missing SHASUMS256.txt
tar -xzf karma-$v-macos-universal.tar.gz
mkdir -p ~/.local/bin && mv karma ~/.local/bin/
```

On Linux, for x86_64 and aarch64:

```sh
v=0.3.3
a=karma-$v-linux-$(uname -m).tar.gz
curl -fLO https://github.com/karmayogasoftware/karmayoga/releases/download/v$v/$a
curl -fLO https://github.com/karmayogasoftware/karmayoga/releases/download/v$v/SHASUMS256.txt
sha256sum -c --ignore-missing SHASUMS256.txt
tar -xzf $a
mkdir -p ~/.local/bin && mv karma ~/.local/bin/
```

Make sure `~/.local/bin` is on your PATH.

</details>

## Quick start

If your agent installed Karma Yoga CLI, your session is ready, so skip to the last command. By hand, install a tool, sign in, set up and start a session. Use `codex` for Codex, and `--tools both` for both.

```sh
karma doctor install claude
karma auth login claude
karma init --tools claude
karma new demo --default-dir
karma open demo
```

The session starts with two agents: the manager on the left and an assistant on the right. Give the manager work by typing in its pane, and ask it to start more agents when you need them. Ctrl-\ detaches and leaves the session running, and the bar at the bottom shows the other keys. After setup, `karma` opens the menu.

## Everyday commands

- `karma ls` lists every session, stopped ones too, with its state and its agents.
- `karma open NAME` opens a session, and starts it first if it is stopped.
- `karma stop NAME` stops a session. Its records and conversations stay.
- `karma start NAME` starts a stopped session on the same conversations, without opening it.
- `karma restart NAME` restarts every agent of a session, the manager too, on its conversation, and tells busy agents to continue. Use it when an agent is stuck, or to give the manager new settings. `--manager` or `--agent AGENT` restarts only that one.
- `karma update` installs the latest release and restarts the running sessions on it.
- `karma settings` lists the settings, and `karma settings set KEY VALUE` changes one. Agents other than the manager take a new tool setting once they are idle.
- `karma models` lists the models each tool offers your account and the efforts each takes.

## FAQ

**What accounts do I need?**
You need either Claude Code, Codex or both, signed in on your own accounts. A subscription, API billing or a provider such as Bedrock or Vertex all are supported. `karma doctor install TOOL` installs a missing tool with its official installer and `karma auth login TOOL` signs it in. `karma doctor --fix` uses the same installers, `https://claude.ai/install.sh` for Claude Code and `https://chatgpt.com/codex/install.sh` for Codex, with commands in `~/.local/bin` by default. `karma doctor reset` resets settings and leaves the tools installed.

**Does it run on Linux and Windows?**
It runs on macOS and on Linux for x86_64 and aarch64. On Windows it runs inside WSL2.

**How do I update or uninstall it?**
Run `karma update`, which upgrades through Homebrew when Homebrew installed karma. Once every session is stopped, `karma uninstall` removes the binary and the service that keeps sessions running. With Homebrew it leaves the binary, and `brew uninstall karma` removes it.

**Where does it keep its files?**
Its settings, session records, message history and logs are in `~/.karmayoga/karma`. The conversations stay where Claude Code and Codex keep them. `karma delete NAME` removes a stopped session's records and never touches its working directory.

## Contact

Our website is [karmayoga.dev](https://karmayoga.dev). Please send questions and bug reports to [hello@karmayoga.dev](mailto:hello@karmayoga.dev).

## License

See [LICENSE.md](LICENSE.md).
