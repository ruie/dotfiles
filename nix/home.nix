{ config, lib, pkgs, username, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in {
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Don't nag about unread home-manager changelog entries on every sync
  news.display = "silent";

  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    fzf
    jq
    tree
    ast-grep
    gh
    lazygit
    starship
    bun
    nodejs_22
    nerd-fonts.jetbrains-mono
  ];

  # Registers the nerd font with fontconfig on Linux (no-op elsewhere);
  # macOS registers it via fonts.packages in nix/darwin.nix.
  fonts.fontconfig.enable = true;

  home.sessionVariables.EDITOR = "nvim";

  # Out-of-store symlinks point back at the repo working copy, so configs are
  # edited in place and tool-written files (lazy-lock.json) land in git.
  # home/.config/<x> in the repo IS ~/.config/<x> on the machine.
  xdg.configFile."nvim".source = link "home/.config/nvim";
  xdg.configFile."herdr/config.toml".source = link "home/.config/herdr/config.toml";
  xdg.configFile."starship.toml".source = link "home/.config/starship.toml";
  xdg.configFile."wezterm" = lib.mkIf pkgs.stdenv.isDarwin { source = link "home/.config/wezterm"; };

  # Sourced from .bashrc/.zshrc (sync.sh adds the line); not managing the rc
  # files themselves so machine-local setup (bun installer, nvm, brew) keeps
  # ownership of them.
  xdg.configFile."shell.sh".source = link "home/.config/shell.sh";
}
