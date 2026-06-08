{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Compilers & build tools
    gcc
    gnumake
    cmake
    binutils

    # Languages & language servers
    python3
    nixd

    # Fallback CLI editor (primary editors zed/emacs are configured in home-manager)
    helix

    # AI coding CLIs
    claude-code
    codex

    # Networking / hardware diagnostics
    bind # dig/nslookup (BIND client tools)
    i2c-tools # i2c bus probing for sensors
  ];
}
