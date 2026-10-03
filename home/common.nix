# Shared by every profile: user, XDG, and how config files are linked.
{ config, lib, ... }:
let
  cfg = config.dotfiles;
in
{
  options.dotfiles = {
    path = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.local/share/dotfiles";
      description = "Dotfiles checkout that live links point to.";
    };
    liveLinks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Link config files to the checkout at `path`, so they can be edited in
        place (and by theme.sh). When false, copy them into the Nix store.
      '';
    };
  };

  config = {
    # `link ".config/helix"` -> source for home.file / xdg.configFile
    _module.args.link = path:
      if cfg.liveLinks
      then config.lib.file.mkOutOfStoreSymlink "${cfg.path}/${path}"
      else ../. + "/${path}";

    home.username = "quocanh";
    home.homeDirectory = "/home/quocanh";
    home.stateVersion = "26.05";

    # Not NixOS: set up XDG_DATA_DIRS etc. for Nix-installed apps
    targets.genericLinux.enable = true;
    # GUI apps come from apt/Flatpak, so skip the Nix GPU driver setup check
    targets.genericLinux.gpu.enable = false;
    xdg.enable = true;
    home.preferXdgDirectories = true;

    programs.home-manager.enable = true;
    news.display = "silent";
    # Flakes for `home-manager switch --flake` (Nix itself comes from the system install)
    xdg.configFile."nix/nix.conf".text = "experimental-features = nix-command flakes\n";
    # Profile in ~/.local/state/nix instead of ~/.nix-profile. The setting itself,
    # use-xdg-base-directories, is in the system nix.conf (home.sh adds it).
    nix.assumeXdg = true;

    # Environment for shells (hm-session-vars.sh) and, via systemd.user below,
    # for the desktop session and apps launched from it. Absolute paths:
    # hm-session-vars.sh sets these before the XDG variables.
    home.sessionVariables = with config.xdg; {
      EDITOR = "hx";
      VISUAL = "hx";

      # Move dotfiles out of $HOME (see xdg-ninja)
      ANDROID_USER_HOME = "${dataHome}/android";
      AWS_CONFIG_FILE = "${configHome}/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "${configHome}/aws/credentials";
      CUDA_CACHE_PATH = "${cacheHome}/nv";
      DOTNET_CLI_HOME = "${dataHome}/dotnet";
      GNUPGHOME = "${dataHome}/gnupg";
      IPYTHONDIR = "${configHome}/ipython";
      JUPYTER_CONFIG_DIR = "${configHome}/jupyter";
      LESSHISTFILE = "${stateHome}/less/history";
      NODE_REPL_HISTORY = "${stateHome}/node_repl_history";
      NPM_CONFIG_CACHE = "${cacheHome}/npm";
      NPM_CONFIG_USERCONFIG = "${configHome}/npm/npmrc";
      NUGET_PACKAGES = "${cacheHome}/NuGetPackages";
      PARALLEL_HOME = "${configHome}/parallel";
      PYTHON_HISTORY = "${stateHome}/python_history";
    };
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ]
      ++ lib.optional cfg.liveLinks "${cfg.path}/bin";

    # GNOME and other systemd-started apps read ~/.config/environment.d
    systemd.user.sessionVariables = config.home.sessionVariables // {
      PATH = lib.concatStringsSep ":" (config.home.sessionPath
        ++ [ "${config.home.profileDirectory}/bin" "/nix/var/nix/profiles/default/bin" "\${PATH}" ]);
    };

    # zsh reads its config from ~/.config/zsh; ~/.zshenv only points there. zsh
    # doesn't reread .zshenv from the new ZDOTDIR, so source it explicitly.
    home.file.".zshenv".text = ''
      export ZDOTDIR="''${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
      [[ ! -r $ZDOTDIR/.zshenv ]] || source $ZDOTDIR/.zshenv
    '';

    # Weekly: delete home-manager generations older than 30 days, then
    # garbage-collect /nix/store (keeps a month of rollbacks)
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
