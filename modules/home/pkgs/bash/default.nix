{ ... }:
{
  programs.bash = {
    enable = true;

    bashrcExtra = ''
      # Auto-stop devenv services when leaving a project directory
      _devenv_chdir() {
        if [[ "$PWD" != "$_DEVENV_PREV_DIR" ]]; then
          if [[ -f "$_DEVENV_PREV_DIR/devenv.nix" ]] && [[ "$PWD" != +"$_DEVENV_PREV_DIR"* ]]; then
            (cd "$_DEVENV_PREV_DIR" && devenv processes down &>/dev/null &)
          fi
        _DEVENV_PREV_DIR="$PWD"
        fi
      }
      _DEVENV_PREV_DIR="$PWD"
      PROMPT_COMMAND="_devenv_chdir''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    '';
  };
}
