{ pkgs, ... }:
let
  emacs = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (epkgs: [
    epkgs.treesit-grammars.with-all-grammars
  ]);
in
{
  home.packages = with pkgs; [
    emacs
    rust-analyzer
    lldb
    (aspellWithDicts (dicts: with dicts; [ en ]))
  ];

  xdg.configFile = {
    "emacs/early-init.el".source = ./early-init.el;
    "emacs/init.el".source = ./init.el;
    "emacs/lisp".source = ./lisp;
  };
}
