# Nushell environment: only what differs from the defaults (see `config env --doc`).
# Environment variables come from the desktop session (home-manager's
# environment.d plus ~/.config/environment.d/90-local.conf), or from zsh when
# nu is started from it.

use std "path add"
path add ($env.HOME | path join ".local/share/android-studio/bin")
path add ($env.HOME | path join ".local/share/flutter/bin")
path add ($env.HOME | path join ".local/share/google-cloud-sdk/bin")

# Nix and home-manager packages, for when nu isn't started from zsh/bash (which
# already set these up). Only added if missing, so zsh's PATH order is kept.
# `path add` prepends, so list in reverse: the user profile ends up first.
# The profile is in ~/.local/state/nix with use-xdg-base-directories, else ~/.nix-profile.
let user_profile = [($env.HOME | path join ".local/state/nix/profile/bin") ($env.HOME | path join ".nix-profile/bin")]
    | where {|p| $p | path exists } | first 1
for p in (["/nix/var/nix/profiles/default/bin"] | append $user_profile) {
    if ($p | path exists) and ($p not-in $env.PATH) { path add $p }
}

# Prompt: starship (installed by home-manager), via the vendor autoload directory
if (which starship | is-not-empty) {
    mkdir ($nu.data-dir | path join "vendor/autoload")
    starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
}

# mise: generate mise.nu, which config.nu loads
if (which mise | is-not-empty) {
    ^mise activate nu | save ($nu.default-config-dir | path join mise.nu) --force
}

# Secrets (API keys) for interactive shells only: KEY=VALUE lines, untracked
let secrets = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config") | path join "secrets.env")
if ($secrets | path exists) {
    open --raw $secrets | lines | where {|l| $l != "" and not ($l | str starts-with "#") }
        | parse "{key}={value}" | reduce -f {} {|it, acc| $acc | insert $it.key $it.value }
        | load-env
}

# gpg-agent's terminal passphrase prompt needs to know the terminal
if (is-terminal --stdin) { $env.GPG_TTY = (^tty | str trim) }
