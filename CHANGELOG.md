# Changelog

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
