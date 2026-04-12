{ pkgs, ... }:
{
  imports = [
    ./alacritty
    ./bash
    ./fish
    ./git
    ./rust
    ./starship
  ];

  home.packages = with pkgs; [
    emacs-pgtk
    zed-editor
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
    obsidian
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
    du-dust
    ncspot
    hyperfine
    gitui
    yazi
    zellij
    curl
    wget
    tree
  ];
}
