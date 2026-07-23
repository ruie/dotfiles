{ config, pkgs, username, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in {
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    fzf
    jq
    gh
    bun
    nodejs_22
  ];

  # Out-of-store symlinks point back at the repo working copy, so configs are
  # edited in place and tool-written files (lazy-lock.json) land in git.
  xdg.configFile."nvim".source = link "nvim";
  xdg.configFile."herdr/config.toml".source = link "herdr/config.toml";

  # Sourced from .bashrc (sync.sh adds the line); not managing .bashrc itself
  # so machine-local setup (bun installer, nvm, brew) keeps ownership of it.
  xdg.configFile."dotfiles/aliases.sh".source = link "aliases.sh";
}
