{ pkgs, ... }:
{
  # Discord's auto-updater downloads gpu_encoder_helper into
  # ~/.config/discord/<version>/modules/discord_voice/ as a generic-Linux
  # ELF that hard-codes /lib64/ld-linux-x86-64.so.2. NixOS has only the
  # stub-ld there by default, so the helper fails with EACCES (or with
  # the "stub-ld" message once chmod +x is applied). When the helper
  # fails, Discord reports zero hardware encoder support, which causes
  # capture_linux to advertise an SHM-only PipeWire format list — and
  # niri's screencast offers DMA-BUF only, so negotiation dies with
  # "no more input formats" and Go Live silently fails.
  #
  # nix-ld provides a real dynamic linker at the generic-Linux path so
  # such helpers can run. The helper dlopens libva at runtime for VAAPI
  # (AMD hardware encoding probe), so libva must be on NIX_LD_LIBRARY_PATH.
  # Zed's registry-downloaded codex-acp binary is another generic-Linux
  # binary and needs libcap at runtime.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libcap.lib
      libva
    ];
  };
}
