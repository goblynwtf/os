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
    dbvisualizer

    sublime-merge
    telegram-desktop

    openvpn
    fastfetch

    postman
    koodo-reader

    # Synology Drive is a Qt app that crashes under the global Wayland Qt
    # platform (QT_QPA_PLATFORM=wayland in modules/system/desktop); force xcb
    # for just this package via a thin wrapper.
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
    gthumb
    jetbrains.idea

    protonmail-desktop
  ];
}
