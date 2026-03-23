{ pkgs, ... }:
{
  imports = [
    ./bash
  ];

  home.packages = with pkgs; [
    emacs
    zed-editor
    discord
    vscode
    claude-code
    github-copilot-cli
    opencode
    (dbvisualizer.overrideAttrs (old: {
      installPhase = builtins.replaceStrings [ "${openjdk17}" ] [ "${openjdk21}" ] old.installPhase;
    }))

    sublime-merge
    telegram-desktop

    openvpn
    fastfetch

    postman
    obsidian
    synology-drive-client

    ripgrep
    fd
    jq
    eza
    curl
    wget
    tree
  ];
}
