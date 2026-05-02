{ pkgs, ... }:
{
  imports = [
    ./ghostty
    ./bash
    ./direnv
    ./emacs
    ./git
    ./nushell
    ./obsidian
    ./rust
    ./zed
    ./zellij
  ];

  home.packages = with pkgs; [
    discord
    (dbvisualizer.overrideAttrs (old: {
      installPhase = builtins.replaceStrings [ "${openjdk17}" ] [ "${openjdk21}" ] old.installPhase;
    }))

    gh
    sublime-merge
    telegram-desktop

    openvpn
    fastfetch

    postman
    koodo-reader
    (pkgs.symlinkJoin {
      name = "synology-drive-client";
      paths = [ synology-drive-client ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/synology-drive \
          --set QT_QPA_PLATFORM xcb
      '';
    })

    ripgrep
    fd
    eza
    bat
    dust
    ncspot
    hyperfine
    gitui
    yazi
    curl
    wget
    tree
    calibre
    google-chrome
    jetbrains.idea

    protonmail-desktop
  ];
}
