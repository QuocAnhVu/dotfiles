# home-manager profiles

`flake.nix` defines one home-manager configuration per role, each built from
the modules here:

| Configuration      | Module        | Imports                       |
| ------------------ | ------------- | ----------------------------- |
| `quocanh@server`   | `minimal.nix` | `common.nix`                  |
| `quocanh@dev`      | `full.nix`    | `minimal.nix`                 |
| `quocanh@desktop`  | `desktop.nix` | `full.nix`                    |
| `quocanh@workstation` | `workstation.nix` | `desktop.nix`, `gnome.nix` |

- `common.nix`: user, XDG directories, environment variables (shells and the
  desktop session), the Nix profile location, garbage collection, `~/.zshenv`,
  and the `link` helper.
- `minimal.nix`: shell configs and a small set of tools, for servers.
- `full.nix`: the CLI/TUI suite, toolchain managers and language servers.
- `desktop.nix`: terminal config, fonts, distrobox.
- `workstation.nix`: the Flatpak apps (nix-flatpak).
- `gnome.nix`: enabled GNOME extensions and their settings (dconf).

## Changing a profile

1. Edit the module.
2. New files must be known to git (`git add`): flakes only see tracked files.
3. Check it builds without switching: `home-manager build --flake .#quocanh@workstation`
   (leaves a `result` link; delete it afterwards).
4. Apply: `home-manager switch --flake .#quocanh@<role>`.

## Packages

- Find the attribute name with `nix search nixpkgs <name>` or on
  https://search.nixos.org/packages (channel: unstable).
- If two packages provide the same binary, the build fails with "conflicting
  subpath". Prefer one with `lib.hiPrio pkg` (as done for `rust-analyzer`,
  which `rustup` also provides).
- Not from Nix: GUI apps, compilers, `-dev` libraries, `cmake`, `meson`,
  `clangd` (see the main README).

## Config files and `link`

`link ".config/foo"` returns the source for `home.file` or `xdg.configFile`:

- `workstation`, `desktop` and `dev` (`dotfiles.liveLinks = true`): a link to the checkout at
  `~/.local/share/dotfiles`, so edits apply without switching and `theme.sh`
  can rewrite files.
- `server` (`liveLinks = false`): a copy in the Nix store, so the profile works
  from GitHub without a checkout. Edits need a switch.

Link a directory (`xdg.configFile."helix"`) when the program only reads it;
link single files (`xdg.configFile."zsh/.zshrc"`) when the program also writes
into that directory, so its state doesn't end up in the repo.

## Environment variables

- `home.sessionVariables` and `home.sessionPath` go to `hm-session-vars.sh`
  (sourced by `.config/zsh/.zshenv` and `.bashrc`) and, through
  `systemd.user.sessionVariables`, to `~/.config/environment.d`, which the
  desktop session reads at login.
- Use absolute paths (`"${config.xdg.dataHome}/foo"`), not `$XDG_DATA_HOME`:
  `hm-session-vars.sh` sets variables alphabetically, so others may not be set yet.
- Machine-specific values and secrets don't belong here; see the main README.
