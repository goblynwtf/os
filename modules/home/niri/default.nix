# Live-editable niri config managed via home-manager.
#
# home-manager creates ~/.config/niri/config.kdl as an out-of-store symlink
# pointing at the live file in the repo checkout. This means:
#   - edits to modules/home/niri/config.kdl apply instantly (niri watches its config)
#   - the file is git-tracked and participates in normal commit flow
#   - no nixos-rebuild is needed for config tweaks after the initial switch
#
# Caveat: the symlink target hardcodes ~/Developer/os. Moving the checkout
# breaks the symlink until the module is updated.
{ config, lib, ... }:
let
  dmsIncludeFiles = [
    "colors.kdl"
    "layout.kdl"
    "alttab.kdl"
    "wpblur.kdl"
    "binds.kdl"
    "outputs.kdl"
    "windowrules.kdl"
    "cursor.kdl"
  ];
in
{
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Developer/os/modules/home/niri/config.kdl";

  # niri parses include targets before DMS starts. Create mutable placeholders
  # after Home Manager links its files so DMS can still replace them at runtime.
  home.activation.ensureNiriDmsIncludes = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    dms_dir="${config.xdg.configHome}/niri/dms"
    run mkdir -p $VERBOSE_ARG "$dms_dir"

    ${lib.concatMapStringsSep "\n" (name: ''
      target="$dms_dir/${name}"
      if [[ ! -e "$target" && ! -L "$target" ]]; then
        run touch "$target"
      fi
    '') dmsIncludeFiles}
  '';
}
