# Nushell environment: only what differs from the defaults (see `config env --doc`).
# Environment variables (XDG locations, EDITOR) come from home-manager.

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
