{ pkgs, ... }:
let
  vaults = [
    # Paths are relative to the home directory.
    "Box/Obsidian/Health"
  ];

  jsonFile = value: {
    force = true;
    text = builtins.toJSON value;
  };

  appSettings = {
    alwaysUpdateLinks = true;
    attachmentFolderPath = "Attachments";
    defaultViewMode = "source";
    livePreview = true;
    newFileLocation = "current";
    newLinkFormat = "relative";
    promptDelete = false;
    readableLineLength = true;
    showLineNumber = true;
    spellcheck = true;
    spellcheckDictionary = [ "en-US" ];
    strictLineBreaks = false;
    useMarkdownLinks = true;
  };

  appearanceSettings = {
    baseFontSize = 16;
    enabledCssSnippets = [ "nix-managed" ];
    interfaceFontFamily = "Berkeley Mono";
    monospaceFontFamily = "PragmataPro Mono Liga";
    nativeMenus = false;
    textFontFamily = "Berkeley Mono";
    theme = "obsidian";
  };

  corePlugins = {
    "audio-recorder" = false;
    backlink = true;
    bases = true;
    bookmarks = true;
    canvas = true;
    "command-palette" = true;
    "daily-notes" = true;
    "editor-status" = true;
    "file-explorer" = true;
    "file-recovery" = true;
    footnotes = false;
    "global-search" = true;
    graph = true;
    "markdown-importer" = false;
    "note-composer" = true;
    outline = true;
    "outgoing-link" = true;
    "page-preview" = true;
    properties = true;
    publish = false;
    "random-note" = false;
    "slash-command" = true;
    slides = false;
    switcher = true;
    sync = true;
    "tag-pane" = true;
    templates = true;
    webviewer = false;
    "word-count" = true;
    workspaces = false;
    "zk-prefixer" = false;
  };

  graphSettings = {
    "collapse-color-groups" = true;
    "collapse-display" = true;
    "collapse-filter" = true;
    "collapse-forces" = true;
    close = true;
    colorGroups = [ ];
    centerStrength = 0.5;
    hideUnresolved = false;
    linkDistance = 250;
    linkStrength = 1;
    lineSizeMultiplier = 1;
    nodeSizeMultiplier = 1;
    repelStrength = 10;
    scale = 1;
    search = "";
    showArrow = false;
    showAttachments = false;
    showOrphans = true;
    showTags = true;
    textFadeMultiplier = 0;
  };

  snippetCss = ''
    body {
      --font-interface: "Berkeley Mono";
      --font-text: "Berkeley Mono";
      --font-monospace: "PragmataPro Mono Liga";
      --file-line-width: 760px;
      --line-height-normal: 1.6;
    }

    .markdown-source-view.mod-cm6 .cm-line,
    .markdown-preview-view {
      font-size: 16px;
    }
  '';

  vaultFiles = vault: {
    "${vault}/.obsidian/app.json" = {
      force = true;
      text = builtins.toJSON appSettings;
    };

    "${vault}/.obsidian/appearance.json" = jsonFile appearanceSettings;

    "${vault}/.obsidian/core-plugins.json" = jsonFile corePlugins;

    "${vault}/.obsidian/graph.json" = jsonFile graphSettings;

    "${vault}/.obsidian/snippets/nix-managed.css" = {
      force = true;
      text = snippetCss;
    };
  };
in
{
  home.packages = with pkgs; [
    obsidian
  ];

  home.file = builtins.foldl' (files: vault: files // vaultFiles vault) { } vaults;

  xdg.mimeApps.defaultApplications = {
    "text/markdown" = "obsidian.desktop";
    "text/x-markdown" = "obsidian.desktop";
    "x-scheme-handler/obsidian" = "obsidian.desktop";
  };
}
