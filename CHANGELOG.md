# Changelog

## 0.5.1

- `karma update` on a Mac with Karma Yoga.app installed no longer exits with "Karma Yoga.app was not
  updated" when the release has no app image. It says no app image is available and leaves the app
  as it is. (karm-ahah)
- When `karma update` keeps the running runtime, it retries sessions whose last restore had
  already failed. If one is still down after a successful update, Karma names it and shows the
  recorded reason. (karm-7gd8)
- Updating from 0.5.0 to 0.5.1 restarts running sessions.

### Known issues:

- Everything open under 0.4.1 stays open, except what docs/known-issues.md lists as no longer open.
- A message sent from another Mac to a parked agent is not delivered. Wake the agent on its own Mac
  first.
- Link between two Macs hasn't been tested on this release.
- On an Apple Silicon Mac running a native build of 0.3.4 or older, `karma update` to 0.5.1 stops at
  the download and leaves your installed CLI and running sessions working. Open a terminal outside
  Karma and run `curl -fsSL https://karmayogaapp.com/install.sh | sh`. Intel archive installs retry
  with the `macos-x86_64` archive. (karm-ik49)
- A tell that Karma couldn't confirm can stay unsubmitted in the agent's composer. Check the pane
  with `karma agent see NAME` and review `karma crew history --full` before resending. Leave the
  composer alone if an Enter may already be pending. If the tell is still in the composer when the
  agent stops, it is cleared without being sent. `karma agent deactivate`, a restart or an update
  can name it in a warning, but not every time. `karma stop`, `karma pause` and `karma archive`
  don't name it. `karma crew history --full` keeps its text to send again.
- `karma agent interrupt` can skip resubmitting a message while another Karma operation is running,
  and then warns that the message may be unsent. Check the pane with `karma agent see NAME` and
  review `karma crew history --full` before retrying. Leave the composer alone if an Enter may
  already be pending.
- A tell with the same text as one cleared from the composer in the last hour can read unconfirmed
  though the agent got it. Check the agent with `karma agent see NAME` before you send it again.
- A tell sent while a message that looks the same is on the agent's screen can read unconfirmed
  though the agent got it. Check the agent with `karma agent see NAME` before you send it again.
- A tell sent while an agent is busy can show unconfirmed even after the agent takes it, from its
  queue or later in a long turn. Check the pane before resending. (karm-j5su, karm-o6sv)
- A raw /model tell to a Pi agent can read unconfirmed even though Pi opened its model picker.
  Check the pane before resending. (karm-ex9a)
- karma audio can lose part of the microphone track on calls where the audio route changes, such as
  AirPods. A call can split into two recordings if microphone use drops for at least the configured
  stop debounce (stopDebounceSeconds in ~/.karmayoga/audio/config.json, one second by default) and
  then resumes. (karm-gc31)
- When call recording is on, microphone use in any app can trigger a recording by default, except
  for known dictation and screen recording apps such as Superwhisper and OpenScreen. To exclude
  another app, add its name to `ignoredClients` in `~/.karmayoga/audio/config.json` and run
  `karma audio restart`. A nonempty `allowedClients` list restricts which apps can trigger
  recording. (karm-4stf)
- After a paste times out, Karma can send Enter to finish submitting the tell. If the reply to that
  Enter is lost, Karma has up to two seconds to read a record showing that the agent started or
  queued the tell. If Karma can't read that record in time, the tell can read unconfirmed even though
  the agent got it. 0.4.1 could report it as delivered. Check the agent with `karma agent see NAME`
  before you send it again.
- If Karma's saved tell history is damaged or unreadable, a tell can read unconfirmed if Karma can't
  finish reading the agent's transcript record in the first two seconds of checking. That can happen
  even when the agent recorded the tell within those two seconds and 0.4.1 would have reported it as
  delivered. Check the agent with `karma agent see NAME` before you send it again.
- Before restarting a whole session, including during an update, Karma skips recovery for notices it
  records before trying to deliver them. A notice still in the composer when the agent stops can be
  discarded. Check the pane with `karma agent see NAME` before restarting or updating. 0.4.1 also
  skipped recovery for these notices.
- During a whole-session restart, including one during an update, Karma can press Enter again for a
  newer tell with the same text as an older one if it has queued the first Enter but has yet to save
  that result. If a prompt opens between the two keypresses, the second Enter can answer it. This
  could also happen in 0.4.1. During the restart, Karma can also submit a draft you typed yourself
  if it matches an older tell.
- Pi hooks outside the TUI have no terminal Escape input; commands use their configured timeout
  (60 seconds by default). In the TUI, Karma uses Pi's native terminal-input listener to cancel
  idle prompt hooks, before Pi has a run signal; running hooks use Pi's abort signal.
- Restarting Pi refreshes Karma's owned extension. A legacy saved launch whose owned resource
  is missing, changed or unidentifiable fails naming Pi before stopping the agent; recreate it.
  Personal extensions and the old resource are left untouched. Running processes keep their
  loaded extension until restart. Older Pi managers can still report another agent's conversation
  as open; stop and start that session to refresh every Pi process before restarting or waking workers.
- Project trust in Pi applies to the whole process. By default, Karma launches Pi with `--approve`,
  which loads the agent folder's `.pi` settings.json, mcp.json, extensions, skills, prompts, themes,
  SYSTEM.md and APPEND_SYSTEM.md, installs the missing packages named in that settings.json, and
  loads the `.agents/skills` folder of every ancestor up to the git root (up to the filesystem root
  when no git folder is above). It wins over a saved "Do not trust", a `defaultProjectTrust` of
  "never" and any `project_trust` extension decision, and writes nothing to Pi's `trust.json`. Pi
  has no trust for the working folder alone.
- For sessions created with `--no-project-code`, Karma uses `--no-approve` to skip the project's
  settings, MCP servers, extensions and packages.

## 0.5.0

### Tells:

- After a usage limit or a failed turn, Karma can submit some of its own unconfirmed tells and
  notices from the last hour that it finds alone in a ready composer.
- Karma reports a new tell as undelivered only when nothing was pasted. One that may have been
  pasted but can't be confirmed is recorded as failed, and the history table shows it as
  unconfirmed.
- When a tell to `@all` can't be confirmed for every agent, Karma names the agents to tell again and
  those to check first without resending.
- After a tell to a Codex agent, Karma gives the transcript time to show the message when the screen
  is clipped or being redrawn. For any agent, it also doesn't press Enter again during that send
  once the session server has queued Enter after the paste timed out.
- Karma can press Enter again when Claude Code holds a pasted tell with image attachments in its
  composer, unless the session server already queued Enter after that paste timed out.
- With `karma agent interrupt @all`, Karma tries to interrupt every busy agent except the manager
  before it tries to resubmit any of their messages.
- A tell that timed out in the send queue before anything was written is sent once more. If the
  reply to a send is lost, Karma doesn't send again.
- Local tells usually need no separate client process, and Karma commands skip a macOS startup step.
  Both steps could hang in Codex's sandbox.
- A plain tell leaves a person who is scrolling back where they were reading, unless Karma first has
  to clear a stuck rename.
- When a blocking Claude Code permission prompt cuts off a command, the manager's notice and
  `karma agent see` show the full command or its possible matches, if the transcript has them.
- `karma crew history` names the recipient of each message, in text and as `recipient` in JSON.
- A process left over from an earlier session server can no longer act as the agent that now has its
  pane ID.
- A failed wake in `karma --json crew tell` or `karma --json agent reactivate` gives a stable error
  code, as does starting a session that is already running.
- More tells sent to a busy Claude agent read delivered once Claude queues or starts them, and Karma
  still doesn't report one as delivered before Claude has taken it. (karm-cihr)

### Sessions and agents:

- The pause key and the pause cell in the session bar are in release builds. The default key is
  Ctrl+6, shown as `⌃^`, and `keys.pause` changes it.
- If Ctrl+6 is already bound and `keys.pause` is unset, or the saved pause key is invalid or is also
  another action's key, Karma picks a free key for pause. It refuses a key change that would give
  pause and another action the same key.
- The help of `karma agent model` and `karma agent restart` says when an agent keeps its
  conversation, starts an empty one or is refused.
- When a local `karma update`, `karma restart`, `karma restart --agent` or `karma agent restart`
  interrupts an agent and brings it back, Karma tries to resume a goal that was still active when it
  stopped the agent, in the same conversation. A later `karma start` and recovery after an
  unexpected stop don't resume goals this way. Neither does an update from 0.3.4 or earlier, which
  the older Karma carries out.
- Karma doesn't send that resume into a draft. It tries to warn the manager when the goal may still
  be paused or couldn't be read before the stop.
- Setting the same text on a paused Codex goal with `karma agent goal` resumes that goal in place
  instead of replacing it, unless `--keep` is given.
- An agent in auto permissions is refused a Claude model that the catalog lists without auto mode,
  and `karma models` marks those models.
- `karma agent goal` reads a Claude goal that was set during a turn, and setting one on a busy
  Claude agent is confirmed by Claude's own record.
- Before Karma pauses a stalled goal, it checks the agent's screen and leaves the goal alone if a
  different one is shown.
- A stalled goal of an agent that is waiting for a reply pauses without a notice to the manager.
- `karma agent reactivate` still starts an agent whose saved conversation ended in a failed turn,
  and gives that error in `warning`.
- For a person, `karma crew status` prints the name and reason of each agent with an error below the
  table, when a reason is known.
- Status shows the sign-in advice when a Claude Code login has reached its time limit.
- Agent status shows the effort Codex used in its latest observed turn.
- An interrupted Codex turn no longer reads as a failed turn.
- `karma agents` keeps session, agent, tool and activity whole when it narrows the table to fit a
  terminal.
- `karma agent see` fills a Pi agent's view with earlier conversation above the live screen.
- Claude Code no longer asks you to trust the session workspace each time an agent starts.
- Restarting a Codex agent no longer adds another copy of its skill settings to the launch
  arguments.
- An agent that a session stop interrupted is told that the session stopped when it comes back. An
  idle agent, or a manager that stopped its own session, gets no notice.
- Restores retry some interrupted state reads. After such a failure, a continuation notice is sent
  again only if none of it could have been pasted.
- Continuation notices after a restart look up the agent's last message in an index when they can,
  instead of reading the whole history.
- The watcher reuses transcript, screen, history and settings data that has not changed, so it
  repeats less work with many agents.
- A low disk or memory warning returns after free space has recovered and dropped again, or when it
  falls by another fifth since the last warning.
- `karma machine --cleanup` reports the space used in known workspace and worktree folders as
  protected. Caches there that can be rebuilt still count as space you can free.
- The manager skill explains `karma kmux` for reading clients, panes and scrollback. A refused
  `list-panes -a` points to `list-panes -s`.

### Usage:

- `karma usage` groups subscription limits by window, with the pace and when each is projected to
  run out. It also shows estimated cost and any Codex credit resets.
- Without an agent name, `karma usage --json` shares a core set of fields across roles, including a
  verdict on how much to run. An agent sees only its own account and row, and scripts that read the
  old shape need an update.
- When a saved report can be used, `karma usage` shows it at once with the age of its readings and
  refreshes it in the background once it is stale. `--refresh` asks for a new one.
- If only a Codex credit reset lookup fails during a refresh, `karma usage` still uses the fresh
  report and warns that some credit reset requests failed. JSON output includes that warning as
  `refresh_error`.
- When the current roster for a session in the report can't be read, `karma usage` can still report
  the transcript totals it finds and marks them incomplete.
- Built-in prices are normally refreshed from models.dev at each release. Pi agents on Amazon
  Bedrock or OpenAI are priced by the model in the transcript when its price is known.
- When a usage limit menu blocks a Claude agent and the account has room again, Karma chooses Stop
  and tells the agent to continue. It never chooses usage credits.
- A manager can choose Stop on the usage limit menu of another session's agent with
  `karma crew tell NAME --session S --key N`.
- `karma models` shows up to ten models for each tool, including the default, and `--all` shows
  every one. JSON has no limit of ten, and without `--all` it leaves out hidden models other than
  the default.
- `karma models` answers from its saved list at once and refreshes an old list in the background.
- Claude's model list no longer times out when Claude Code keeps running after it has answered.
- By default, Pi on Amazon Bedrock hides duplicate regional copies and models the AWS account is
  known not to be able to invoke, except the default model. An unfinished check keeps the saved
  list.
- A person's plain `karma usage` covers the last 30 days. `--day`, `--week`, `--month`, `--year`,
  `--hours` and `--since` choose another period, and each table names its range. An agent's own
  usage still covers the last 24 hours by default. (karm-tzaz)
- For a person, `karma usage --all-sessions` lists every running and saved session when no session
  or agent is selected. (karm-tzaz)
- The estimated cost table prices every tool at list price, including accounts on a plan. When a
  tool reports its own billed spend, the table shows it in a Billing cycle column. (karm-hdiq)
- `karma usage` no longer ends with a line for each tool saying when it was read. (karm-aiqn)
- `karma usage` shows tokens and cost for a tool's parked agents and current builds, which it
  couldn't read before. (karm-dxh3)
- `karma models` shows list prices for the models a tool serves from other providers. A blank USAGE
  now comes with a note when the tool's own pricing has no list price. (karm-so4f)

### Feedback:

- `karma feedback` has five commands: `send`, `show`, `note`, `close` and `reopen`. A person can
  send a report and follow it by number, and so can a manager with the person's permission.
- `karma feedback --text TEXT` is removed, so use `karma feedback send TEXT` to send a report. The
  old form's error names the new command.
- `karma feedback` lists the fixes waiting for your test and counts other reports. `--all`,
  `--open`, `--limit` and `--page` choose what it lists.
- When an update restarts sessions, the notice to a returning manager can list fixes that are ready
  to retest. Feedback notices no longer appear in the session bar.
- `karma feedback show` says why a report was closed and names the original of a duplicate. A won't
  fix needs no reply, and you can reopen it with your reason.
- A machine can send up to 100 new reports a day, and a refusal over the limit says when it resets.
  If the same text was saved in this Karma home within the past hour, sending it again returns the
  saved report without another upload.
- When the feedback service limits requests, `karma feedback show` waits up to a minute and tries
  each limited page once more.
- Karma homes on one Mac share a feedback identity when Karma can read the hardware ID. A copied
  home starts a fresh report list when it detects other hardware.
- The log attached to a feedback report cuts the pane text that Karma's send warnings quote.

### Link:

- `karma auth` signs this computer in to a Karma account, shows its status and lists or signs out
  the account's devices. `karma auth login --device` signs in a computer without a browser.
- If an offline sign-out left a saved sign-in on this Mac, signing in here again can replace it
  instead of adding another machine.
- Link is on in release builds. The account service allows more than one Mac on an account. When
  you are signed in, use `karma link ls` to see other Macs listed by the account and any known
  connection status. Use `karma link rename` to rename this Mac.
- Use `karma link ls --details` to see cached connection details for each machine.
- Link tries to connect Macs on the same account directly. If that fails, it can try an encrypted
  relay.
- When Link has lists from several Macs, `karma ls` and `karma agents` group the results by Mac.
  `karma ls` can show when a Mac became unreachable and which paths Link tried.
- If no local session matches, `karma open NAME` looks for that name on linked Macs. When it finds
  just one reachable match and no other match, it opens it. Otherwise it lists any known matching
  `--host` commands.
- On a connected Mac, `--host` can select a Mac for a plain tell, an interrupt of one agent, marking
  a message read, or starting, stopping or restarting a whole session.
- When a session you are viewing over Link pauses itself, the remote viewer can show the paused
  session menu.
- Link retries stale connections and checks for network changes while retrying. If the sign-in has
  ended, `karma doctor` and `karma link ls` tell you to run `karma auth login`.
- Release builds can pair machines with `karma link add` and `karma link accept`, and manage those
  links with `karma link alias` and `karma link rm`. If SSH setup needs to install Karma on the
  other machine, it tries the release channel (0.5.0 or later), the RC channel (0.5.0-rc.2 or
  later), then a compatible dev build on macOS.
- A person's tell over Link uses the receiving Mac's user name when Karma can read it.
- A linked tell can report undelivered and give the reason when the receiving Mac refuses it before
  pasting. For a manager's tell, this includes a stopped session, a paused session that could not
  start, or a manager that could not start. For a person's `--host` tell, this includes an agent
  that exited, restarted or refused input, or a session or agent that changed after lookup.

### Setup and update:

- The installer is at `https://karmayogaapp.com/install.sh`, and the support address is
  hello@karmayogaapp.com.
- The Homebrew install path is retired, so `karma update` in a Homebrew copy can't install 0.5.0.
  Run the installer from a terminal outside Karma and make sure the install directory
  (`~/.local/bin` by default) comes before Homebrew's bin directory on your PATH.
- On an Apple Silicon Mac running a native build of 0.3.4 or older, `karma update` to 0.5.0 stops at
  the download and leaves your installed CLI and running sessions working. Open a terminal outside
  Karma and run `curl -fsSL https://karmayogaapp.com/install.sh | sh`. Intel archive installs retry
  with the `macos-x86_64` archive. (karm-ik49)
- First setup stays unfinished and exits 1 when no chosen tool's sign-in could be checked, and
  prints the command to rerun from a desktop terminal.
- `karma tools enable` reports failure when it cannot check a sign-in, and prints a failed test's
  reason on one line.
- If Anthropic refuses the API key set in the environment and setup has no verified native sign-in
  to use, it tells you to fix or unset that key.
- The first `karma init` reuses a test start that `karma tools enable` passed if the checks and the
  model still match.
- `karma tools` no longer shows a sign-in as missing when it finishes during the check.
- SIGTERM gives `karma new`, `karma init`, `karma doctor`, plain `karma tools`, and its install,
  enable and disable commands time to stop what they started.
- `karma update` waits for a restarted agent's conversation before it reports that the agent did not
  come back.
- When no copy of an installed tool passes its version check, `karma tools` and its install, enable
  and login commands show the path and the error instead of reporting the tool as missing.
  `karma doctor` does the same for a disabled tool.
- An unchanged warning about `config.toml` is logged once instead of by every command.

### Plugins:

- `karma tasks search` puts exact IDs first, then unfinished tasks. Within each status, a title with
  every search word ranks above body and comment matches, and a search for owners also finds owner.
- `karma code-review readme` prints text in a pipe, and JSON with `--json`.
- `karma code-review status` gives a count of findings to recheck, names pull requests whose GitHub
  history is cut off, and no longer says head unknown for an unreviewed one.
- `karma code-review show` names who raised each finding in a joint review. `amend` can correct one
  finished report while the other reviewer works.
- A failed GitHub read in `karma code-review` includes GitHub's answer when one was returned.
- When an analyzer fails, `karma code-quality` shows the first nonblank line of its error output, if
  there is one. It also asks analyzers not to use color.
- `karma backup` is now an opt-in alpha plugin. If you already run backups, run
  `karma plugins install backup` after updating to resume them. `karma restore` and `karma secrets`
  work without the plugin.

### Audio:

- When call recording is on, microphone use in any app can trigger a recording by default, except
  for a built in list of dictation and screen recording apps. A nonempty `allowedClients` list
  restricts which apps can trigger recording. (karm-4stf)
- A new audio config records the built-in microphone and falls back to the default input. An
  existing microphone setting is unchanged. (karm-lohe)
- `karma audio restart` reloads the current config and restarts the recorder if it was running or
  enabled. `karma audio reset` restores factory settings, keeping any existing retention settings.
  If there is an existing config, reset backs it up beside the config file and prints the backup
  path. Both keep the recording gate as it was and refuse while a recording or other audio work is
  in progress. (karm-3i0j)
- `karma audio on` shows the model download's progress. (karm-rzoa)
- The audio cell in the bottom bar shows a circle instead of a microphone: a dim circle and "off"
  when recording is off, and a red circle while karma audio waits for a call. During a recording it
  alternates red and dim beside the elapsed time. A failed check can show a yellow circle with a short
  reason; karma audio status says more. (karm-wh8y, karm-yrls)
- With dictation on, the mic now appears at the right of pane titles, including in narrow panes.
  (karm-3467)
- `karma audio --help` explains dictation: F9 or the mic starts and stops it, and F10 or a right
  click on the mic shows saved results. (karm-0tr6)
- `karma audio acceptance` passes when the only reason the check gives is informational. A check
  that fails or warns, or a transcript without the phrase, still fails it. (karm-c350)

### Docs and skills:

- The manager skill changed.
- Help changed: karma, karma audio, karma audio reset, karma audio restart, karma feedback, karma feedback send, karma feedback show, karma feedback note, karma feedback close, karma feedback reopen, karma init, karma ls, karma models, karma new, karma tools, karma tools install, karma tools login, karma tools enable, karma tools disable, karma update, karma usage, karma vdisplay, karma vdisplay status, karma vdisplay on, karma vdisplay off, karma vdisplay capture, karma vdisplay windows, karma vdisplay tree, karma vdisplay click, karma vdisplay move, karma vdisplay drag, karma vdisplay scroll, karma vdisplay type, karma vdisplay key, karma agent create, karma agent model, karma agent restart, karma audio acceptance, karma audio access, karma audio access status, karma audio devices, karma audio export, karma audio list, karma audio logs, karma audio off, karma audio on, karma audio probe, karma audio readme, karma audio recover-spool, karma audio repair, karma audio salvage, karma audio selftest, karma audio status, karma audio transcribe, karma audio transcripts, karma audio transcripts get, karma audio transcripts latest, karma audio transcripts list, karma audio uninstall, karma audio verify, karma code-review amend, karma tasks, karma tasks comment, karma tasks file, karma tasks list, karma tasks ready, karma tasks report, karma tasks search, karma tasks show.

### Known issues:

- Everything open under 0.4.1 stays open, except what docs/known-issues.md lists as no longer open.
- A message sent from another Mac to a parked agent is not delivered. Wake the agent on its own Mac
  first.
- Link between two Macs hasn't been tested on this release.
- On an Apple Silicon Mac running a native build of 0.3.4 or older, `karma update` to 0.5.0 stops at
  the download and leaves your installed CLI and running sessions working. Open a terminal outside
  Karma and run `curl -fsSL https://karmayogaapp.com/install.sh | sh`. Intel archive installs retry
  with the `macos-x86_64` archive. (karm-ik49)
- A tell that Karma couldn't confirm can stay unsubmitted in the agent's composer. Check the pane
  with `karma agent see NAME` and review `karma crew history --full` before resending. Leave the
  composer alone if an Enter may already be pending. If the tell is still in the composer when the
  agent stops, it is cleared without being sent. `karma agent deactivate`, a restart or an update
  can name it in a warning, but not every time. `karma stop`, `karma pause` and `karma archive`
  don't name it. `karma crew history --full` keeps its text to send again.
- `karma agent interrupt` can skip resubmitting a message while another Karma operation is running,
  and then warns that the message may be unsent. Check the pane with `karma agent see NAME` and
  review `karma crew history --full` before retrying. Leave the composer alone if an Enter may
  already be pending.
- A tell with the same text as one cleared from the composer in the last hour can read unconfirmed
  though the agent got it. Check the agent with `karma agent see NAME` before you send it again.
- A tell sent while a message that looks the same is on the agent's screen can read unconfirmed
  though the agent got it. Check the agent with `karma agent see NAME` before you send it again.
- A tell sent while an agent is busy can show unconfirmed even after the agent takes it, from its
  queue or later in a long turn. Check the pane before resending. (karm-j5su, karm-o6sv)
- A raw /model tell to a Pi agent can read unconfirmed even though Pi opened its model picker.
  Check the pane before resending. (karm-ex9a)
- karma audio can lose part of the microphone track on calls where the audio route changes, such as
  AirPods. A call can split into two recordings if microphone use drops for at least the configured
  stop debounce (stopDebounceSeconds in ~/.karmayoga/audio/config.json, one second by default) and
  then resumes. (karm-gc31)
- When call recording is on, microphone use in any app can trigger a recording by default, except
  for known dictation and screen recording apps such as Superwhisper and OpenScreen. To exclude
  another app, add its name to `ignoredClients` in `~/.karmayoga/audio/config.json` and run
  `karma audio restart`. A nonempty `allowedClients` list restricts which apps can trigger
  recording. (karm-4stf)
- After a paste times out, Karma can send Enter to finish submitting the tell. If the reply to that
  Enter is lost, Karma has up to two seconds to read a record showing that the agent started or
  queued the tell. If Karma can't read that record in time, the tell can read unconfirmed even though
  the agent got it. 0.4.1 could report it as delivered. Check the agent with `karma agent see NAME`
  before you send it again.
- If Karma's saved tell history is damaged or unreadable, a tell can read unconfirmed if Karma can't
  finish reading the agent's transcript record in the first two seconds of checking. That can happen
  even when the agent recorded the tell within those two seconds and 0.4.1 would have reported it as
  delivered. Check the agent with `karma agent see NAME` before you send it again.
- Before restarting a whole session, including during an update, Karma skips recovery for notices it
  records before trying to deliver them. A notice still in the composer when the agent stops can be
  discarded. Check the pane with `karma agent see NAME` before restarting or updating. 0.4.1 also
  skipped recovery for these notices.
- During a whole-session restart, including one during an update, Karma can press Enter again for a
  newer tell with the same text as an older one if it has queued the first Enter but has yet to save
  that result. If a prompt opens between the two keypresses, the second Enter can answer it. This
  could also happen in 0.4.1. During the restart, Karma can also submit a draft you typed yourself
  if it matches an older tell.
- Pi hooks outside the TUI have no terminal Escape input; commands use their configured timeout
  (60 seconds by default). In the TUI, Karma uses Pi's native terminal-input listener to cancel
  idle prompt hooks, before Pi has a run signal; running hooks use Pi's abort signal.
- Restarting Pi refreshes Karma's owned extension. A legacy saved launch whose owned resource
  is missing, changed or unidentifiable fails naming Pi before stopping the agent; recreate it.
  Personal extensions and the old resource are left untouched. Running processes keep their
  loaded extension until restart. Older Pi managers can still report another agent's conversation
  as open; stop and start that session to refresh every Pi process before restarting or waking workers.
- Project trust in Pi applies to the whole process. By default, Karma launches Pi with `--approve`,
  which loads the agent folder's `.pi` settings.json, mcp.json, extensions, skills, prompts, themes,
  SYSTEM.md and APPEND_SYSTEM.md, installs the missing packages named in that settings.json, and
  loads the `.agents/skills` folder of every ancestor up to the git root (up to the filesystem root
  when no git folder is above). It wins over a saved "Do not trust", a `defaultProjectTrust` of
  "never" and any `project_trust` extension decision, and writes nothing to Pi's `trust.json`. Pi
  has no trust for the working folder alone.
- For sessions created with `--no-project-code`, Karma uses `--no-approve` to skip the project's
  settings, MCP servers, extensions and packages.

## 0.4.1

- A new session no longer sends `/rename` to its manager on any tool, so the manager hears who it
  is sooner. A manager can still rename its conversation with the tool's own command.
- Codex agents in Karma's managed homes use your `~/.claude/CLAUDE.md` as a fallback when no
  native `AGENTS.md` exists. Existing owned files and native overrides keep precedence. Pi agents
  receive the file alongside their native rules. Both honor `CLAUDE_CONFIG_DIR` and leave personal
  files unchanged.
- The browser and Slack plugins are now beta.
- `karma browser windows --profile ACCOUNT` lists the profile's live windows and tabs, and
  `open --profile ACCOUNT --window ID --url URL` opens a new tab in the chosen window.
- A browser launch reuses Chrome's startup New Tab page instead of leaving an extra blank tab.
- `karma browser open` warns when it uses the default profile because neither `--profile` nor
  `--tab` was supplied.
- Browser consent dismissal now tries reject, then necessary cookies only, without falling back
  to accept. Use `--prefer accept` to opt in to accepting cookies.
- Browser inspection reports a detected blocking modal or consent overlay in `blocking_overlay`
  without dismissing it.
- Browser argument errors explain that a page URL must follow `--url` and that `wait --state`
  takes `present` or `absent` with `--selector`.
- On macOS, `karma browser open --hidden` keeps headed Chrome and its new windows on the Karma
  Virtual Display, starts the shared display automatically and holds it while the run has tabs.
- A hidden browser's `wait --human` brings the tab's window to the real screen and restores its
  bounds when the wait ends. Named-value `login` opens a temporary window on the real screen.
- Slack help now gives each command its own options and examples, including nested setup,
  access and outbox commands.
- `karma slack mentions` searches messages addressed to you, and `karma slack read @HANDLE`
  reads an existing direct message without opening a new conversation.
- Slack output to a pipe is one JSON document per command, including failures with an explanation
  and next action. `--human` keeps readable output when piped.
- Slack login retries a browser capture runtime failure once using the same dedicated profile,
  so a completed sign-in can be captured without another window.
- Browser and Slack sign-in capture failures name the stage that failed without printing captured
  credentials.
- Slack channel, people and DM directories apply filters and limits while collecting pages,
  so a limited read no longer needs to scan the entire directory first.
- Partial Slack reads return `next_command` with the original selection and continuation cursor.
  An unread conversation whose details could not be read remains available on the next call.
- Slack rate limits now pause only the affected API method in that workspace, so unrelated read
  methods and identity checks can still run.
- Budget errors during Slack API reads identify the workspace, API method, remaining seconds and
  retry time, and repeated source errors are grouped with their counts and affected conversations.
- Slack name lookups and catch-up retries reuse successful read pages for up to five minutes,
  so retrying the same window can make progress after a rate limit. Action previews and sending
  still collect fresh evidence.
- Changing an agent's model waits for its restored input before returning or sending the notice
  that lets interrupted work continue.
- Claude Code conversation text that wraps like a menu option no longer makes a tell look blocked
  when there is no selection hint.
- Karma notices no longer include a receipt line in the agent's conversation; delivery history
  still tracks them.
- `karma agents` uses the same published state as `karma crew status` and shows full model names
  without shortening them in narrow terminals.
- `karma usage` shows the start date of the current spending period and labels earlier periods
  as past periods.
- A person can run `karma feedback --text "TEXT"` from a terminal outside a session, as a manager
  already could from its session.
- `karma init` explains why each tool was left out and gives the install, login or enable command
  needed to add it.
- An ambiguous conversation error names the tools to choose from instead of suggesting a flag
  that the calling command might not accept.
- When the manager asks which task tracker you use, it recommends `karma tasks`, and installs it
  once you agree.
- With telemetry enabled in a configured build, recovered startup waits no longer send failure
  reports; a failed operation carries the preceding observations in its report.
- Closing a command's standard error pipe no longer prints a panic or reports a crash.

## 0.4.0

- Pi is a third agent tool beside Claude Code and Codex, for managers and agents. `karma tools
  install pi` runs Pi's official installer, which needs Node.js 22.19 or newer and npm.
- A first `karma init` sets Pi up with the other tools when Pi is installed and signed in to a
  model provider. On a computer set up before 0.4.0 a plain `karma init` does the same. A Pi that
  is turned off stays off until `karma tools enable pi` passes.
- Pi runs with bypass permissions: it has no per-tool approval or sandbox, and karma trusts the
  project folder for each Pi session only.
- With `sessions.auto_pause` turned on, a session that stays idle is paused by itself and continues
  where it was when you open it. It is off by default.
  `karma archive NAME` stops a session and hides it from `karma ls`; `karma ls --all` shows it.
- `karma pause NAME` pauses a session by hand as the idle auto pause does, and a manager may pause
  its own session.
- With `agents.auto_park` turned on, an idle agent is parked and wakes when it is told something.
  It is off by default. A parked agent keeps its conversation and shows its last saved output.
- Switching away from a session shows your paused sessions with how long ago each was paused and
  the keys that open one or leave the screen. Stopped sessions are not listed there. When no session
  is paused, the screen is skipped: switching goes straight to the next session, and leaving a linked
  session that no longer exists returns you to your last session or to the shell with the reason.
- Opening a paused or stopped session in a terminal starts it at once behind its saved screen and
  shows a progress line. Enter retries a start that failed, and the detach key or Ctrl+C leaves
  while the session keeps starting.
- Keys typed while a session is opening no longer show up as stray characters on the terminal.
- `karma ls` lists running sessions first, then paused, then stopped, each by last activity.
  `karma agents` shows when each agent was last active.
- `karma agents` lists the agents, for people, managers and agents alike. `karma agent ls` still
  runs for scripts that call it, and no help shows it.
- `karma plugins` replaces `karma experimental`. `karma plugins` lists what karma can do beyond
  sessions and agents, `karma plugins search TEXT` finds one, and a person installs or removes one
  with `karma plugins install NAME` and `karma plugins uninstall NAME`. A manager does it only when
  the person said yes, and passes `--human-approved` to say so; other agents cannot. Each plugin
  shows whether it is alpha or beta; one with no mark is complete. What you had turned on in 0.3.4
  stays installed.
- `karma tasks` is a plugin. A new setup has no plugin installed, tasks included. An update from
  0.3.4 keeps tasks installed.
- New alpha plugins: `events` (agent and task events with attention notifications), `vdisplay`,
  `social`, `video`, `email`, `slack`, `calendar` and `whatsapp`.
- The `audio` plugin shows a meetings item in the bar. A click turns meetings on or off, or
  cancels the model preparation while it runs.
- Meetings transcribe with the English only model `whisper.small.en.q8` unless `meetings.model` or
  `dictate.model` is set. Once it is ready, `karma audio on` deletes the multilingual
  `ggml-small.bin` from 0.3.4, and so does `karma audio repair` once `on` has upgraded the
  recorder. For calls in other languages, run
  `karma settings set meetings.model whisper.small`.
- `karma tools` installs, signs in and tests Claude Code, Codex and Pi (`karma tools install`,
  `login`, `enable`, `disable`). `enable` tests the tool's agents and turns the tool on when they
  answer, and `disable` turns it off. `karma doctor` only diagnoses and names the command that
  fixes each row.
- Once karma is set up, `karma init` and `karma tools enable TOOL` never turn off a tool that is
  enabled. A check that fails says why and points to `karma doctor`, and `karma init --tools`
  turns off no tool it leaves out.
- `karma doctor` shows only the settings you changed, and `karma settings ls` shows all of them.
  A tool that offers more than 10 models shows its default and the command that lists them.
- `karma settings` with nothing after it opens the settings screen in a terminal outside a session.
  `karma settings ls` lists every setting.
- `karma update` runs from any terminal or agent, keeps sessions running when the new build can
  work with the running one, and shows "updating" in the session bar instead of a dialog. The bar
  shows "(update)" when a newer build exists; clicking it asks once in a popup and then shows
  "updating karma".
- If the session server is killed while sessions should be running, it is started again with them.
  A karma home no longer replaces the running server of another karma home.
- A session that failed to restore is recovered by the next update, and opening a session works
  even when its layout cannot be set up.
- A terminal that another terminal takes over stays open with a notice and can reattach.
- A tell that follows an interrupted one is delivered even when the earlier message can no longer
  be checked.
- `karma crew tell @all` leaves parked agents out.
- `karma crew tell --key` no longer takes `BTab`, and a `--key` or `--type` that starts with `[` is
  refused.
- From a manager, `karma crew tell --raw` needs an empty message box and takes plain text or a
  slash command the tool lists, so `--raw /goal` is refused and `karma agent goal` remains.
  A manager's `--key` and `--type` reach only a blocking prompt, apart from `--key Escape`, which
  goes to any screen.
- `karma new` lets the terminal in once the panes are up and starts the workers beside the manager.
  It does not wait for the sign-in check of a tool found signed in less than 15 minutes ago, so a
  tool signed out since then can start with a warning instead of being refused. In a terminal,
  `karma new` now opens the session once its panes are up, so `--open` is no longer needed;
  `karma new -d` or `--detach` creates it without opening it, and a script run in a terminal needs
  `--detach`. The terminal goes in before the agents finish starting: an agent that fails to start
  shows on the session bar, and the failure and any late sign-in warning are printed again when you
  leave.
- `KARMA_SPEEDUP_OFF` set to any value, or a file named `speedup-off` in the karma home for the
  whole machine, puts back the path karma took before each speedup of this release: the in-process
  kmux client, the late sign-in checks, the workers starting beside the manager, the versions kept on
  disk and the early terminal.
- Agents compact at `agents.auto_compact_tokens`, default 200000, and the manager at
  `agents.manager_auto_compact_tokens`, default 300000. karma passes them at launch,
  where it wins over your own Codex or Claude Code setting, so an agent you had set to compact
  earlier now compacts later. 0 passes nothing and keeps each tool's own setting.
- `karma init` on a home that is already set up no longer starts a test agent for a tool that
  answered before and has not changed since: the same karma version, executable, tool version and
  sign-in. `karma tools enable NAME` and `karma init --tools NAME` still test it.
- `karma init` ends by naming the supported tools that are not set up and points to `karma tools`
  for them. It no longer warns about a signed out tool before it starts.
- `karma --licenses` prints the licences of the third party software built into karma. It works
  offline and before setup.
- A new session sends `/rename` only to a Claude Code manager. A Codex or Pi manager starts without
  it, so its first message arrives sooner.
- `karma agent goal NAME` reads a Claude agent's goal after its acknowledgement has scrolled away.
- An agent start on macOS that finds the pty table full for a moment, as happens while another
  terminal closes, is retried instead of failing with "open /dev/ptmx: Device not configured".
- Settings that a release removed, starting with the old coffee settings, are cleaned out of
  config.toml by `karma update`, and commands no longer print a warning for each of them.
- The karma safety guard is removed, together with its setting `features.safety_guard`. karma no
  longer checks the shell commands of an agent that runs in bypass. `karma update` cleans the
  setting out of config.toml. Session hooks of your own keep working.
- `karma update` moves the list of turned on features that 0.3.4 kept in `features.experimental`
  to `plugins.installed`.
- Changing an agent's model or effort, or restarting it, several times in a row no longer stops
  the agent. An agent that the session server stopped restarting after it crashed several times
  can be started again with `karma agent restart`, or parked with `karma agent deactivate` and
  started later with `karma agent reactivate`. Either way it keeps its conversation.
- When `karma agent restart` fails because Codex refuses a setting, the error shows Codex's own
  reason.
- `karma new --manager codex --manager-conversation ID` starts a session whose manager continues
  an existing Codex conversation, as it already could with Claude Code.
- When your Codex home keeps its sign-in in an `auth.json` file, new Codex agents run in a Codex
  home of karma's own under `KARMA_HOME/.codex`, with your sign-in, settings, skills and hooks
  linked in, so their threads are not in the ChatGPT app or your `codex resume` list.
- `karma new --copy-writer TOOL` picks the copy-writer's tool, as `--builder` and `--reviewer` do
  for theirs.
- `karma browser` reaches buttons, fields and file inputs inside open shadow roots.
- Claude Code agents no longer stop at "Teach auto mode about your environment?". karma turns off
  Claude Code's auto-mode-setup skill for its agents, so the dialog never shows and
  `/auto-mode-setup` is not offered inside karma agents. Karma Yoga is tested with Claude Code up
  to 2.1.322.
- `karma coffee` keeps the Mac awake only while it is on a charger.
- `karma code-quality` checks Rust sources and brings its own skill.
- Granting write access needs a person at a terminal.
- In a terminal, `karma new` lists the files in the folder that run programs when an agent starts,
  such as the project's own settings, hooks, MCP servers and extensions, and asks "Trust this
  folder?". "No, start without them" starts the session's agents without them, and
  `karma new --no-project-code` chooses that without the question. The session keeps the choice
  for agents created later. Only a person is asked. A Yes is remembered for the folder until
  what it would run changes.
- Only a person changes a tool's permission mode. `karma settings set TOOL.permissions` works at a
  terminal outside karma sessions or from the Mac app, and is refused for a manager or an agent.
- From a manager, `karma agent config` and `karma agent create --config` refuse the Claude Code and
  Codex settings that change what an agent may do without asking: permissions, sandbox, profiles,
  hooks and plugins. A person sets them at a terminal outside karma sessions.
- `karma kmux` is new: it runs one reading command on karma's session server. It is for a manager,
  on its own session, and agents are refused.
- `karma feedback` sends only with `--text`.
- macOS downloads are separate arm64 and x86_64 binaries.
- Downloads, updates and feedback moved to getkarmayoga.com.

## 0.3.4

- `karma tasks` moves from one list per session to named projects, each with its own id prefix. A
  task has a managing session, a manager can take it for its session, and it can be handed over.
  Outside a session, `karma tasks ls` is the one task command, and only a manager closes a task.
- `karma tasks` needs a project first: `karma tasks project create NAME --prefix P`. Tasks from
  before this release stay in their old session stores until you run `karma tasks migrate SESSION`
  for each session. `show` and `search` still find a task by its old id; a command that changes a
  task refuses an old id and names the current one.
- A `/model` change now stays with that agent across restarts. New agents still start on the
  configured model.
- A restart or update stays silent for a session only when the manager and all its agents have been
  idle for at least an hour.
- `karma ls` shows when each session was last active.
- A new manager follows its skill from the first message instead of being told to ask you.
- `karma browser` matches agent-browser more closely across launch, tabs, uploads, frames, dialogs,
  screenshots and rate limits.

## 0.3.3

Init:

- `karma init` asks nothing, of a person or an agent. A first run finds Claude Code and Codex by
  itself, and `--tools claude`, `codex` or `both` picks them instead. It installs nothing and signs nothing in: a missing or too old tool fails with
  `karma doctor install TOOL`, and a signed out one with `karma auth login TOOL`.
- `karma doctor install`, `karma auth status` and `karma auth login` are new and work before setup
  has passed. Piped, each says what to run next, and what the agent tells the person.
- Karma Yoga supports Claude Code 2.1.316 and Codex 0.166.0.
- `karma doctor install` and `karma doctor --fix` show how far a Claude Code or Codex install has
  got: the size downloaded so far, the rate and the time taken.
- `karma init` no longer ends with a line about telemetry. The `telemetry` setting is unchanged,
  and `karma settings set telemetry false` turns it off.

Agents and goals:

- A manager now runs every command but `delete`, `uninstall`, `experimental set` and `update --install`.
  It can create, open, stop and restart sessions, change settings and repair with `doctor --fix`.
- An agent outside every session, such as Claude Code on your machine, runs only `init`, `new`, the
  install commands and reads. For anything else karma tells it that a person runs that. Stdin is the
  signal, so cron and ssh with a command count as agents; piping karma's output does not.
- A goal that runs five rounds without a tool call is paused, and the manager is told once.
  `karma agent goal NAME` shows it as paused with its objective, and the next `karma crew tell` to
  the agent sets it again. The manager's own goal is never paused.
- Agents and managers can run `karma agent ls`, which lists their own session; `--session` stays
  for people.
- `karma crew status` no longer reads idle for up to one watcher tick after a turn starts, as it
  did right after a tell or a background launch.
- The TASK column of `karma agent ls` and `karma crew status` holds only ticket ids, without
  `task-`, with their count first when there are several: `[2] 71tc cv1g`. Goal text no longer
  shows there.
- `karma agent goal` confirms a goal whose objective the screen wraps after a hyphen or inside a
  long word, instead of exiting with "result not verified", and replacing a Codex goal accepts a
  wrapped objective. A confirmed goal reports the objective as it was sent.
- A resumed agent's start, as after an update, a restart or a restore, no longer fails on an old
  error or sign-in line its replayed conversation shows; only errors from the new start count.
- karma no longer presses Escape at Codex's "Set up security for Daybreak mode" notice, which could
  cancel a message being sent or interrupt the turn that had just begun.
- A delivered `karma crew tell` reports `status=ok` in its receipt even when the pane redrew late.
- An agent keeps a model or effort a person chose with `/model` or `/effort` through a restart. It
  used to come back on what karma had started it with. Claude Code's fallback on an overload is not
  saved. A `[1m]` ending is not kept, because the transcript does not record it, and an `ultrathink`
  turn moves a saved effort until the next turn.
- Ctrl-Z no longer reaches an agent. Claude Code stayed on its "suspended" notice with no way back,
  and Codex blanked its pane for seconds.

Update:

- `karma update` installs the new binary before it interrupts busy agents, so a failed install
  interrupts none, and agents interrupted by an update whose restart then fails are told to
  continue.
- After an update whose restore took the session down, `karma update` reports the restore's
  failure at once instead of waiting a minute and listing every agent as not back, and it tells
  the manager about the update only once the manager is back.
- A manager in a Codex sandbox can run `karma update --yes`: the update runs through the session
  server, outside the sandbox, survives the server's restart and tells the manager when it fails.

Machine:

- The session watcher uses much less CPU. It samples processes once a minute instead of every 3 s,
  counts an agent's background terminals from that agent's own processes, and searches only a
  Claude agent's own project folder for its conversation when that folder exists. `karma ls` shows
  CPU as the share over the last minute.
- `karma crew status` and the watcher's status reads no longer wait while an agent of the session
  is being created or reactivated.
- `karma machine` shows the CPU of each karma server and its watcher, so a stray server stands out.
- The watcher warns every live session manager when free disk or memory is low, at most once an
  hour for each. `machine.disk_warning_percent` defaults to 10 and `machine.memory_warning_percent`
  to 20.

Browser:

- `karma browser` treats sites as agent-browser does. It saves cookies only on `checkpoint` and
  when Chrome quits, starts Chrome with agent-browser's flags, focuses a field with a real click and
  types without events a page can tell were not typed, and no longer marks password fields in the
  page. `quit` and `close --all` save cookies and close Chrome. `inspect --host` counts the cookies
  saved at the last checkpoint, so a sign-in since then is not counted until the next one.
- Each command opens its own connection to Chrome and closes it at the end. A slow or refused reply
  no longer breaks the connection, connection and reply timeouts follow agent-browser's, and a
  command's time limit no longer cuts a reply short. A write cut short by its timeout or a reply
  that is not JSON leaves the connection usable, and the next call reopens a lost one.
- `read` reads the page's visible text as agent-browser does, 8000 characters by default with no
  cap and a note of how much was cut, and `read` and `wait` report the page's URL.
- A `--selector` that matches several elements acts on the first live match, as agent-browser does.
  A selector whose snapshot hint matches several elements still fails as ambiguous unless
  `--visible` or `--nth` picks one.
- A download a page starts outside the `download` command is no longer refused; it goes to
  Chrome's download folder inside the profile.
- `download` follows Chrome's download events as agent-browser does. The file keeps Chrome's
  suggested name, `--name` and the 32 MiB limit are gone, and the wait is 30 s by default and at
  most 150 s. A download that is canceled or does not finish in time now replies with its status
  under `download` instead of failing, and karma no longer stops it.
- A launched Chrome gets 15 s to start answering, as agent-browser gives it, and a launch that fails
  stops its Chrome, so the next command does not find the profile in use.
- `open` creates the tab at its URL, brings it to the front and returns without waiting for the
  load, as agent-browser does, so its reply no longer has `loaded`. If a tab of karma's is already
  on that URL, compared as agent-browser normalizes it, `open` reuses it, the one it focused last
  when there are several, so two tabs on one URL are no longer an error. Navigating an existing tab
  waits up to `--timeout`, 15 s by default, for Chrome's load event and then briefly for the page to
  settle, and its reply gives the page's status as `page`. A page Chrome fails to load is reported
  there instead of as an error, and a load that times out names the URL. `open` and `download` take
  any URL agent-browser takes, such as `about:`, `data:`, `blob:` and `view-source:`, except local
  files, Chrome's own pages and URLs with a user name or password. Pages karma attaches to report
  `navigator.webdriver` as false, and click, fill, press and scroll bring their tab to the front
  first.
- `wait` reads the page's status on every poll, every 200 ms with a 10 s default timeout, and its
  reply gives the page's title, ready state, any challenge or navigation issue and the time taken.
  `--network-idle`, and the new `--lifecycle-settled` and `--element-stable`, wait first for the
  network, the page's loading or an element's position to settle, and the reply lists which ran.
  A plain `--selector` now passes once the element exists, hidden or not, as agent-browser's does.
- `fill` no longer refuses a field by its tag or type. A select option matches by value, text or
  label, and `fill --checked` clicks a checkbox or radio only when its state differs, reads
  nothing back and reports `checked` in place of `verified`. A field is cleared as agent-browser
  clears it, with Delete, then select all and Backspace, then Backspace for each character, and
  `fill` fails if text is left. The check after typing now ignores differences in whitespace.
- `click` presses the element it is given at that element's centre, as agent-browser does, where it
  used to press the control around it, and a button that moves after the check still gets the press
  at the first point; only an element that became occluded is refused then. `click` no longer reads
  the page before and after, so its reply has no `readback`. The limits on sending still judge the
  control the element activates.
- A click whose `--expect-text` or `--expect-gone` is not met succeeds when the page moved on, with
  `postcondition.state` `uncertain_after_progress`, as agent-browser's does. If the page did not
  move, an ordinary click is activated once more through DOM events, and fails with
  `expectation_failed` only if that changes nothing either. A send is never activated twice: when
  the page moved on, with or without an expectation, it succeeds and its receipt reads `progressed`;
  otherwise it stays uncertain.
- `click --consent` takes accept, reject or the new necessary and takes no target. It dismisses a
  cookie overlay with agent-browser's probe, which knows eight consent managers and the buttons of
  any blocking overlay, and presses Escape when no button works. An overlay that stays is now a
  success, with `dismissed` false and `overlay_remains` true under `consent`. As in agent-browser,
  `--consent accept` also clicks accept, agree, continue or OK on any blocking overlay, a terms
  dialog included.
- `press` sends the key as written, so a name such as `Control+a` is no longer a chord. With a
  target it focuses as agent-browser does and clicks the element when focus does not take. With no
  target the key goes straight to the page, Enter and Space included, with no receipt, sign-in check
  or readback.
- `scroll` on the page sends one wheel event, `--delta-y` 600 by default, and on an element scrolls
  it into view with no wheel. Neither reads the position back.
- `upload` sets the selected file itself, not a private copy, and reads nothing back. It also works
  through an upload button, as agent-browser's does: when the target is not a file input but names
  an upload, file or image, karma clicks it and sets the file on the file chooser it opens. The
  reply's `method` says `file_input` or `file_chooser`. A button that opens no chooser fails, and a
  button that sends is refused.
- After a click, fill, press or scroll, karma watches for a JavaScript dialog for a second and
  reports it in the reply, and `press --dialog` answers it, with `--prompt-text` for the text of a
  prompt. `open --tab` watches until a second after the load and reports a dialog under `page`, also
  when the dialog held the load past its timeout. With no dialog open, `press --dialog` now succeeds
  with `handled` false instead of failing. A click that Chrome leaves unanswered for five seconds
  reports that a dialog may be open instead of failing.
- `open` and `tabs` no longer print a redacted URL with a doubled closing bracket.
- Every `open --tab`, click, fill, press, scroll, upload and download counts against its host before
  it is sent, paced as agent-browser's rate governor paces it, with spacing between actions, jitter
  and caps per run and per day. `inspect`, `read` and `wait` do not count. On sensitive sites such
  as X and LinkedIn a post or reply keeps the posting pace: it is checked before the click and
  recorded after it lands, one post per account at a time, and a post whose expectation was not met
  is not recorded. Posts also share a ceiling across every profile signed in to the account, which
  `inspect --rate` and `wait --rate` show as `rate.shared`. `inspect --rate --kill REASON` stops
  every counted action for a profile, on one host with `--host`, until `--resume`.
- `inspect --host H --live` replaces the `--selector` and `--text` sign-in check, and `inspect
  --text` is no longer accepted. It works as agent-browser's `auth status --live`: it loads the
  host's sign-in probe page in a blank tab, reports the state and account it finds and closes the
  tab. Without `--live`, `inspect --host` reports the state as unknown with the last state seen.
  `open` and a completed navigation to a site karma has a probe for record the state and report it
  as `auth`.

Releases:

- The installer is published with each release, so it never lags behind one.
- Internal fixes to the release process and the tests: release builds use thin link-time
  optimisation, a stopped release no longer holds the build host, end-to-end runs propose the tool
  versions they passed as karma's supported range, test servers end with their tests, and the
  browser builds as its own crate.

Experimental:

- `karma review` is now `karma code-review` and `karma sw-quality` is now `karma code-quality`, with
  no aliases. Turn them on again under the new names; an old flag left in `config.toml` is ignored.
  The ledger moves to `~/.karmayoga/code-review/ledger.jsonl`, `AGENT_REVIEW_LEDGER` is now
  `CODE_REVIEW_LEDGER`, and the limits file `.agent-quality.toml` is now `.code-quality.toml`.
- `karma code-review add`, `sync` and `posted` without gh, or signed out of it, now fail with the
  install step or `gh auth login`. `sync` used to exit 0 on an empty ledger in that state.
- `karma code-review claim --join` lets several reviewers record their own verdict and conversation
  on one round, and `karma code-review amend --add-finding` adds a finding without a new round.

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
