{ pkgs, ... }:
{
  imports = [
    ./alacritty
    ./bash
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
    curl
    wget
    tree
  ];
}
