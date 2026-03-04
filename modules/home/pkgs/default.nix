{ pkgs, ... }:
{
  imports = [
    ./bash
  ];

  home.packages = with pkgs; [
    alacritty
    fuzzel
    git

    zed-editor
    claude-code
    github-copilot-cli

    slack
    telegram-desktop

    openvpn
    fastfetch

    postman

    ripgrep
    fd
    jq
    eza
    curl
    wget
    tree
  ];
}
