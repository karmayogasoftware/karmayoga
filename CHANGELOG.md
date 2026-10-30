# Changelog

## 0.3.2

Init and new:

- `karma init` sets up each tool so you only sign in, and a tool passes only once an agent of it
  answers. It asks which tools to set up, counts the seconds its test start has taken out of the
  most it may take, and finishes with whatever passed when a tool or the supervisor install fails,
  with one plain line for each failure. Setup servers of an interrupted `karma init` or
  `karma doctor test` stop on their own.
- The installer ends with "Run karma init to set up your tools", and says why when it cannot read
  a release and what to do.
- A new session starts a manager, a builder, a reviewer and a copy-writer. With both tools signed
  in, the reviewer runs on Codex and the others on Claude Code; with one tool, all four use it.
  `karma new --model MODEL --effort EFFORT` chooses the manager's model and effort.
- `karma new NAME` works in the current folder. In your home folder it asks for a folder, with
  `~/NAME` as the default, and creates it. It waits until every agent is ready and opens the
  session only with `--open`; otherwise it ends with the command that opens it.
- `karma new` starts the manager as soon as its own tool's sign-in check passes and the workers at
  the same time as each other, greets each agent once it has started, and gives the time each step
  was reached in `karma new --json`.
- `karma new` reports an agent whose start failed instead of calling it ready, and keeps the
  session and its other agents.
- Each session has a workspace folder, `~/.karmayoga/workspace/NAME`, for its agents' briefs,
  drafts, logs and caches, and `~/.karmayoga/secrets/NAME` for its tokens. Both move with the
  session when it is renamed.

Tasks:

- `karma tasks` keeps a task list for each session. Agents file, claim, comment on, assign and
  close tasks, set priorities and dependencies, and list the tasks that are ready.
- `karma tasks search TEXT` searches titles, bodies and comments, with exact phrases first and the
  matches highlighted.
- A task goes through review before it closes: reviewed names the reviewer, the PR and its head,
  in review means merged, verified means checked on a real build, and closed means shipped, with a
  resolution.
- Tasks take a target release and a parent epic, and closing one as fixed names the release that
  shipped it.
- A person in a plain terminal, or another session, reaches a session's tasks with
  `--session NAME`, and can file, list, show, search and comment on them but not edit them or
  change their status. Every change records who made it.
- `karma tasks ls` shows the tasks in progress by default, one line each, with switches for the
  other statuses.

Usage:

- `karma usage` is no longer experimental.
- It shows each account's windows once, with what is left, how far that is from an even pace and
  whether it lasts until the reset, then one sentence per account on how much to run on it. A
  person sees the running sessions, a manager its agents and an agent itself. Accounts billed by
  the token, such as an API key or Bedrock, show their spend at list prices.
- `--hours`, `--since` and `--all` choose the period, and `--day`, `--week`, `--month` and `--year`
  a calendar period.
- It asks every tool at the same time behind a spinner, keeps a report for 5 minutes
  (`usage.cache_minutes`), and `--refresh` asks again.
- Prices cover Codex's Terra models.

Machine and cleanup:

- `karma machine` shows the host's load, memory and disk and the karma agents using them, each with
  its model alias and effort: a session's own agents from inside it, a line per session from
  outside, and one session with `--session NAME`.
- `karma agent ls` lists every session's agents with their tool, model, effort and the CPU and
  memory each one's processes use, and `karma ls` shows each session's CPU and memory.
- `karma machine --cleanup` lists the build caches, karma logs, test leftovers and tool caches
  that could be freed, with their sizes, whether each is in use and the command that frees it,
  including the session workspaces. A cache a running build works in is in use. It frees nothing
  itself. `karma machine --full-cleanup` lists the biggest folders on the disk, without counting a
  folder twice through macOS firmlinks.

Browser:

- `karma browser`, an experimental feature, drives Chrome with account profiles that keep their
  sign-ins across sessions, with the commands listed under Experimental.
- Opening, reading and closing pages are more reliable: a cold open returns its tab when the load
  takes longer than the wait, text in pages with a zero height body is read, a closed tab is gone
  before the command returns, and a busy Chrome gets a bounded time to answer.
- Profiles work across Codex sandboxes: a stale browser process from another sandbox is replaced,
  commands that only read do not start a stopped profile, and a profile counts as signed in only
  with a cookie for the site and the account's name on the page.
- Filling and clicking reach the page as a person's input, fill works on email sign-in fields, and
  sign-in checks look only at the control's own block.

Agents and crew:

- A person in a terminal can message a session's manager with `karma crew tell manager TEXT`,
  adding `--session NAME` when several sessions run.
- An agent that is compacting its conversation, or whose Codex background terminals or Claude Code
  background shells run, counts as busy, and `karma crew status` gives their count. Claude Code
  2.1.312 is supported.
- `karma crew tell` refuses before pasting at Codex startup prompts, questions and dialogs with no
  choices, so Enter never answers one. It confirms a tell a busy or compacting Codex queued, keeps
  confirming across redraws and updates, does not count old history redrawn on screen as a
  delivery, does not take boxed text above the composer for a menu, and waits a moment after an
  agent restarts.
- `karma agent goal NAME --clear` succeeds when Codex has no goal. Replacing a busy agent's goal no
  longer reports a failure when a screen read takes longer than 5 seconds, which 0.3.1 listed as
  open; a change that never confirms still fails. A long Codex objective that wraps can be
  replaced, and once a Claude goal is achieved a new one can be set, as on Codex.
- `karma agent model NAME MODEL` changes an agent's model, and `--force` changes a busy one and
  then tells it it can continue. The agent keeps its effort when the new model takes it. Model
  names take aliases such as `opus`, `sol`, `terra` and `luna`, each the newest model of its
  family, and human lists leave out hidden and specialist models.
- `karma interrupt` takes the same forms as `karma restart`, and a manager's
  `karma agent interrupt @all` stops every busy agent but the manager.
- An idle manager restarts after its tool has updated itself, and a Codex manager can restart its
  agents.
- After `karma stop` and `karma start`, an agent that was stopped in the middle of its work is told
  to continue.
- Claude Code and Codex startup dialogs, including the workspace trust question, are answered the
  same way on both tools, and a reactivated agent waits until they are gone.
- Codex agents in Auto mode can use karma's browser, tasks, review and workspace folders, and an
  agent's `env.NAME=VALUE` setting reaches the commands Codex runs.
- An agent whose introduction karma could not confirm is introduced again before its next
  message, and a resumed manager's restore no longer fails when a question disappears from the
  screen while karma answers it.
- Copying from a pane joins the lines the tool wrapped, and a double-click opens the link under the
  pointer.
- `karma crew status` and `karma ls` read the session watcher's last snapshot and start no other
  programs, and a renamed session stays listed as running.
- Claude Code's feedback survey is turned off for karma agents, so it cannot hold up a tell.
- `karma doctor --fix` keeps the tools it finds unless given `--reinstall`, and a locked ssh
  keychain is not reported as a sign-out.
- `karma feedback "TEXT"` sends a report to the Karma Yoga developers.
- With telemetry on, karma reports its own failures and crashes through a private outbox, and
  commands do not wait for it.
- `karma experimental ls` leaves out features this system does not support, such as coffee on
  Linux.

Experimental:

- Coffee holds while it is on without sudo, suspends once every agent has been idle, and the cup in
  the bar turns it off and on.
- `karma audio` records calls and keeps their transcripts, on macOS.
- `karma review` and `karma sw-quality` are new, off by default.

Update and test builds:

- `karma --changelog` prints the notes of the last five releases from a copy built into karma, so
  it works offline, and update notices say to run it.
- `karma update --rc` installs the newest candidate build of the next release, and a plain
  `karma update` goes back to the latest release.
- Releases publish archives only, and the installer's debug option is gone.

Docs and skills:

- The manager and agent skills are rewritten. A manager picks models from `karma models` and
  `karma usage`, keeps every usage window above 10%, tracks work in `karma tasks` or the person's
  own tracker, and parks agents whose work is merged. An agent's skill says how to take a task,
  which tests to run and where the session's workspace and secrets are, and that an agent never
  changes its own model but tells the manager when its account cannot go on.
- `karma crew history NAME --help` says which messages NAME matches and what `--full` shows.

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
