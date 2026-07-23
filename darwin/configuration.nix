{ user, ... }:

{
  # Determinate manages the Nix daemon itself; nix-darwin must not.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # x86_64-darwin for an Intel Mac

  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}";
  system.stateVersion = 6;

  nix-homebrew = {
    enable = true;
    inherit user;
  };

  homebrew = {
    enable = true;
    # "none" leaves existing unlisted brews alone; flip to "zap" once this
    # list is the complete inventory of what should be on the machine.
    onActivation.cleanup = "none";
    onActivation.autoUpdate = true;
    brews = [
      "herdr"
    ];
    casks = [
      # GUI apps live here, e.g. "wezterm", "tailscale-app", "raycast"
    ];
  };
}
