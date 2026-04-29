{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bind
    binutils
    claude-code
    cmake
    codex
    gcc
    gnumake
    helix
    i2c-tools
    nixd
    python3
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
