{ config, pkgs, username, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in {
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
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

  home.sessionVariables.EDITOR = "nvim";

  # Out-of-store symlinks point back at the repo working copy, so configs are
  # edited in place and tool-written files (lazy-lock.json) land in git.
  xdg.configFile."nvim".source = link "config/nvim";
  xdg.configFile."herdr/config.toml".source = link "config/herdr/config.toml";

  # Sourced from .bashrc/.zshrc (sync.sh adds the line); not managing the rc
  # files themselves so machine-local setup (bun installer, nvm, brew) keeps
  # ownership of them.
  xdg.configFile."dotfiles/aliases.sh".source = link "config/aliases.sh";
}
