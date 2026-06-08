{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Arto Levi";
      user.email = "arto.levi@outlook.com";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  # GitHub CLI lives here next to git (no settings to manage yet).
  programs.gh.enable = true;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "base16";
    };
  };
}
