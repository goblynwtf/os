{ ... }:
{
  nix.channel.enable = false;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Only root is trusted. A trusted user can make the nix-daemon build and
    # substitute arbitrary content as root, which would bypass the sudo
    # password gate; `sudo nixos-rebuild` still works since it runs as root.
    trusted-users = [ "root" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
