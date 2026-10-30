#!/bin/sh
set -eu
fail() {
    [ -n "$n" ] || { printf '%s✗%s %s\n' "$red" "$reset" "$1" >&2; exit 1; }
    stop; show "${red}✗${reset}" "$1"; exit 1
}
usage='Usage: curl -fsSL https://karmayoga.dev/install.sh | sh -s -- [--dev]'
releases=https://get.karmayoga.dev
suffix=
init='karma init'
for arg in "$@"; do
    case "$arg" in
        --dev) releases=https://dev.karmayoga.dev; suffix=-debug ;;
        -h|--help) echo "$usage"; exit 0 ;;
        *) echo "$usage" >&2; exit 1 ;;
    esac
done
# On a terminal each step pulses in place until it is done; elsewhere it is one plain line once done.
tty='' clear='' green='' red='' bold='' dim='' orange='' reset=''
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    tty=1 clear=$(printf '\r\033[J') green=$(printf '\033[32m') red=$(printf '\033[31m') bold=$(printf '\033[1m')
    dim=$(printf '\033[2m') orange=$(printf '\033[38;2;255;154;82m') reset=$(printf '\033[0m')
fi
# Step $n's line with the mark $1 and, after it, the detail $2.
show() {
    printf '%s%s %s/%s  %s%s\n' "$clear" "$1" "$n" "$total" "$title" "${2:+  $dim$2$reset}"
}
# Pulses step $n with $live's detail until $work/stop exists. Once a line matching $boundary shows
# in karma's errors, step $n is done with $detail and step $n+1, $after, pulses on.
pulse() {
    i=0
    while [ -d "$work" ] && [ ! -e "$work/stop" ]; do
        if [ -n "$boundary" ] && grep -qx "$boundary" "$work/err" 2>/dev/null; then
            show "${green}✓${reset}" "$detail"
            : > "$work/next"
            n=$((n + 1)) title=$after boundary=
        fi
        if [ -n "$tty" ]; then
            case $((i % 4)) in 0) frame=◇ ;; 2) frame=◆ ;; *) frame=◈ ;; esac
            line=$($live)
            # Without wrapping, so the line is one row whatever the width and the next pulse clears it.
            printf '\033[?7l\r\033[J%s%s%s %s/%s  %s%s\r\033[?7h' "$orange" "$frame" "$reset" "$n" "$total" "$title" "${line:+  $dim$line$reset}"
        fi
        i=$((i + 1)); sleep 0.12
    done
}
n='' pulsing='' boundary='' detail='' after=''
# Starts step N, TITLE, pulsing with the detail its function LIVE prints.
begin() {
    n=$1 title=$2 live=${3:-}
    rm -f "$work/stop" "$work/next"
    (trap - EXIT HUP INT TERM; pulse) & pulsing=$!
}
stop() {
    [ -n "$pulsing" ] || return 0
    : > "$work/stop"; wait "$pulsing" || :; pulsing=
    # The boundary may show after the pulse last looked.
    if [ -e "$work/next" ]; then
        n=$((n + 1)) title=$after
    elif [ -n "$boundary" ] && grep -qx "$boundary" "$work/err" 2>/dev/null; then
        show "${green}✓${reset}" "$detail"
        n=$((n + 1)) title=$after
    fi
}
tick() { stop; show "${green}✓${reset}" "$1"; }
# The session karma restarts now, while it restarts several.
restarting() { sed -n 's/^Restarting \(.* ([0-9]* of [0-9]*)\)$/\1/p' "$work/err" 2>/dev/null | tail -n 1; }
megabytes() { set -- "$(($1 / 100000))"; printf '%d.%d' "$(($1 / 10))" "$(($1 % 10))"; }
size() { wc -c < "$1" | tr -d ' '; }
# What the archive has of the size the server gave, while the server gave one.
progress() {
    total_size=$(tail -n 1 "$work/length" 2>/dev/null) || total_size=
    [ -n "$total_size" ] && [ -f "$work/archive" ] || return 0
    printf '%s of %s MB' "$(megabytes "$(size "$work/archive")")" "$(megabytes "$total_size")"
}
fetch() {
    curl -fsIL "$base/$version/$1" 2>/dev/null | sed -n 's/^[Cc]ontent-[Ll]ength: *\([0-9][0-9]*\).*/\1/p' > "$work/length" || :
    curl -fsL "$base/$version/$1" -o "$work/archive"
}
base=${KARMA_RELEASE_URL:-$releases}
dest=${KARMA_INSTALL_DIR:-$HOME/.local/bin}
work=$(mktemp -d)
trap 'stop; rm -rf "$work"' EXIT
trap 'exit 1' HUP INT TERM
curl -fsL "$base/latest" -o "$work/latest" || fail 'Could not reach the Karma Yoga CLI releases. Check your internet connection, then try again.'
version=$(cat "$work/latest")
case "$version" in ''|.*|*[!a-zA-Z0-9.-]*) fail 'The Karma Yoga CLI release version is invalid.' ;; esac
first='' total=5 doing='Updating to' finished=Updated
[ -e "$dest/karma" ] || first=1 total=4 doing=Installing finished=Installed
printf '%s◆%s  %sKarma Yoga CLI%s\n   %s%s %s%s\n\n' "$orange" "$reset" "$bold" "$reset" "$dim" "$doing" "$version" "$reset"
begin 1 'Check platform'
case "$(uname -s)" in
    Darwin)
        platform=macos arch=universal about='macOS · Intel'
        [ "$(uname -m)" != arm64 ] || about='macOS · Apple Silicon' ;;
    Linux)
        platform=linux
        case "$(uname -m)" in
            x86_64|amd64) arch=x86_64 ;;
            aarch64|arm64) arch=aarch64 ;;
            *) fail 'Karma Yoga CLI supports Linux on x86_64 and aarch64.' ;;
        esac
        about="Linux · $arch" ;;
    MINGW*|MSYS*|CYGWIN*) fail 'On Windows, install Karma Yoga CLI inside WSL2 using the Linux installer.' ;;
    *) fail 'Karma Yoga CLI supports macOS and Linux. On Windows, install it inside WSL2.' ;;
esac
[ "$releases" != https://dev.karmayoga.dev ] || [ "$platform" = macos ] || fail 'Karma Yoga CLI dev builds are available on macOS only.'
tick "$about"
begin 2 'Download release' progress
name="karma-$version-$platform-$arch$suffix.tar.gz"
if ! fetch "$name"; then
    [ "$platform" = macos ] && [ "$(uname -m)" = x86_64 ] || fail 'Could not download Karma Yoga CLI.'
    name="karma-$version-macos-x86_64$suffix.tar.gz"
    fetch "$name" || fail 'Could not download Karma Yoga CLI.'
fi
tick "$(megabytes "$(size "$work/archive")") MB"
begin 3 'Verify download'
curl -fsL "$base/$version/$name.sha256" -o "$work/checksum" || fail 'Could not download the Karma Yoga CLI checksum.'
read -r digest filename rest < "$work/checksum" || fail 'The Karma Yoga CLI checksum is invalid.'
[ "$filename" = "$name" ] && [ -z "$rest" ] && [ "${#digest}" = 64 ] || fail 'The Karma Yoga CLI checksum is invalid.'
case "$digest" in *[!a-fA-F0-9]*) fail 'The Karma Yoga CLI checksum is invalid.' ;; esac
if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$work/archive")
else
    actual=$(shasum -a 256 "$work/archive")
fi
[ "${actual%% *}" = "$digest" ] || fail 'The Karma Yoga CLI download failed its checksum check. Run the installer again. If it happens again, contact hello@karmayoga.dev.'
[ "$(tar -tzf "$work/archive" 2>/dev/null)" = karma ] || fail 'The Karma Yoga CLI release archive is invalid.'
tar -xzf "$work/archive" -C "$work" 2>/dev/null || fail 'Could not extract Karma Yoga CLI.'
[ -f "$work/karma" ] && [ ! -L "$work/karma" ] || fail 'The Karma Yoga CLI release binary is invalid.'
tick ''
shown=$dest
physical_home=$(cd "$HOME" 2>/dev/null && pwd -P) || physical_home=$HOME
for display_home in "$HOME" "$physical_home"; do
    case "$dest" in "$display_home"|"$display_home"/*) shown="~${dest#"$display_home"}"; break ;; esac
done
# Karma writes itself beside the old binary and renames it over it. When the session server runs, it
# restarts it on the new binary so every agent comes back on its conversation, saying so on stderr
# as it starts and naming each session as it restarts it, and while any agent is busy it refuses,
# changing nothing.
detail="$shown/karma" after='Restart sessions'
[ -n "$first" ] || boundary='Restarting [0-9][0-9]* sessions*'
begin 4 'Install executable' restarting
[ ! -d "$dest/karma" ] || fail 'The Karma Yoga CLI install path is a directory.'
if ! "$work/karma" update --install "$dest/karma" --json > "$work/out" 2> "$work/err"; then
    stop
    # karma's error as it gave it, unwrapped from its JSON, after a sentence naming the product.
    error=$(tail -n 1 "$work/err" | sed 's/^{"error":"\(.*\)"}$/\1/; s/\\"/"/g; s/\\\\/\\/g; s/\.$//')
    case "$error" in *'Karma Yoga CLI'*) fail "$error." ;; esac
    if [ "$n" = 4 ]; then fail "Karma Yoga CLI could not finish the installation. $error."; fi
    fail "Karma Yoga CLI was installed, but restarting its sessions failed. $error."
fi
stop
# This build was installed already and the server runs it, so karma changed nothing.
current=; ! grep -q '"state":"up to date"' "$work/out" || current=1
[ -n "$current" ] || [ "$n" = 5 ] || tick "$detail"
if [ -z "$first$current" ]; then
    n=5 title=$after
    resumed=$(tr '{' '\n' < "$work/out" | sed -n 's/.*"session":"\([^"]*\)".*/\1/p' | sort -u | wc -l | tr -d ' ')
    case "$resumed" in
        0) tick 'No sessions were running.' ;;
        1) tick '1 session restarted on its conversations' ;;
        *) tick "$resumed sessions restarted on their conversations" ;;
    esac
fi
if [ -n "$tty" ]; then
    columns=$(stty size < /dev/tty 2>/dev/null) || columns=
    columns=${columns#* } rule='' i=0
    case "$columns" in ''|*[!0-9]*) columns=60 ;; esac
    while [ "$i" -lt "$columns" ]; do rule="${rule}─" i=$((i + 1)); done
    printf '%s%s%s\n' "$dim" "$rule" "$reset"
fi
if [ -n "$current" ]; then
    printf '\n%s✓%s Karma Yoga CLI %s is up to date.\n' "$green" "$reset" "$version"
else
    printf '\n%s%s✓ %s successfully%s\n\n' "$green" "$bold" "$finished" "$reset"
    printf '%sVersion%s   %s\n%sLocation%s  %s\n' "$dim" "$reset" "$version" "$dim" "$reset" "$shown/karma"
fi
path=; case ":$PATH:" in *":$dest:"*) ;; *) path=1 ;; esac
[ -z "$path$first" ] || echo
if [ -n "$path" ]; then
    path_dir=$(printf '%s\n' "$shown" | sed 's/[\\$`"]/\\&/g')
    case "$shown" in \~|\~/*) path_dir="\$HOME${path_dir#\~}" ;; esac
    # shellcheck disable=SC2016 # PATH expands when the shell runs the line.
    line=$(printf 'export PATH="%s:$PATH"' "$path_dir")
    # The rc file new terminals read, written once. This shell's PATH stays as it was.
    rc=
    case "${SHELL:-}" in
        *zsh) rc=${ZDOTDIR:-$HOME}/.zshrc ;;
        *bash)
            rc=$HOME/.bashrc
            if [ "$platform" = macos ]; then
                # Terminal opens login shells, which read the first of these that exists.
                for rc in "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.profile"; do [ ! -e "$rc" ] || break; done
                [ -e "$rc" ] || rc=$HOME/.bash_profile
            fi ;;
    esac
    # A PATH assignment that already has the whole directory, in any of its spellings.
    dirs=$(printf '%s\n' "$dest" "$path_dir" "$shown" | sed 's/[][\.*^$+?(){}|]/\\&/g' | paste -sd '|' -)
    added=
    if [ -n "$rc" ] && { grep -Eq "^[[:space:]]*(export[[:space:]]+)?PATH=(.*[:\"'])?($dirs)([:\"'].*)?\$" "$rc" 2>/dev/null || {
        # On its own line, even when the file's last line has no newline.
        end=; [ ! -s "$rc" ] || [ -z "$(tail -c 1 "$rc")" ] || end='\n'
        printf '%b%s\n' "$end" "$line" 2>/dev/null >> "$rc" && added=1; }; }; then
        case "$rc" in "$HOME"/*) rc="~${rc#"$HOME"}" ;; esac
        printf 'Added %s to your PATH in %s, so new terminals find karma.\n' "$shown" "$rc"
        if [ -n "$added" ]; then
            case "$rc" in *[!A-Za-z0-9_./~+-]*)
                source_rc=$(printf '%s\n' "$rc" | sed 's/[\\$`"]/\\&/g')
                case "$rc" in \~|\~/*) source_rc="\$HOME${source_rc#\~}" ;; esac
                rc="\"$source_rc\"" ;;
            esac
            init="source $rc, then $init"
        fi
    else
        printf 'Add %s%s%s to your shell profile.\n' "$bold" "$line" "$reset"
        # Without a PATH line, run karma by its path, quoted when the path needs it.
        case "$shown" in *[!A-Za-z0-9_./~+-]*) init="\"$path_dir/karma\"${init#karma}" ;; *) init=$shown/$init ;; esac
    fi
fi
if [ -n "$first" ]; then printf 'Run %s%s%s to set up your tools\n' "$bold" "$init" "$reset"; fi
