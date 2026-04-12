{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Arto Levi";
    userEmail = "arto.levi@tuta.com";

    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "base16";
      };
    };

    extraConfig = {
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
