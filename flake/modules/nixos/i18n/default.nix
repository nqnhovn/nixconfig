# =====================================================================
# MODULES/NIXOS/I18N — LOCALE DEFERRAL SYSTEM
# =====================================================================
# Giải quyết bug GLF-OS: locale build kéo dài 15-25 phút trên internet chậm.
#
# Chiến lược:
#   GĐ1 (cài đặt):   en_US.UTF-8 (luôn có binary cache)
#   GĐ2 (post-install): locale mong muốn (vi_VN, ja_JP...) + push Cachix
#
# Cách dùng trong host config:
#   flake.i18n.targetLocale = "vi_VN.UTF-8";
#   flake.i18n.extraLocales = [ "ja_JP.UTF-8" ];

{ config, lib, ... }:

let
  cfg = config.flake.i18n;
in
{
  options.flake.i18n = {
    enableDeferral = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Trì hoãn locale build sau cài đặt (dùng en_US trước)";
    };

    targetLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "Locale mong muốn cuối cùng";
    };

    extraLocales = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "vi_VN.UTF-8" "ja_JP.UTF-8" ];
      description = "Danh sách locale bổ sung cần build";
    };

    buildLocalesOnInstall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Build locale ngay khi cài đặt (mất 15-25 phút nếu không có cache)";
    };
  };

  config = {
    # Luôn có en_US (binary cache sẵn) — nền tảng an toàn
    i18n.defaultLocale = "en_US.UTF-8";

    # Chỉ build locale cần thiết (không build toàn bộ glibc)
    i18n.supportedLocales =
      if cfg.buildLocalesOnInstall then
      # Build ngay: en_US + target + extras
        [ "en_US.UTF-8/UTF-8" ] ++
        (if cfg.targetLocale != "en_US.UTF-8" then [ "${cfg.targetLocale}/UTF-8" ] else [ ]) ++
        (map (l: "${l}/UTF-8") cfg.extraLocales)
      else if cfg.enableDeferral then
      # Deferral: chỉ en_US trong ISO, các locale khác thêm sau
        [ "en_US.UTF-8/UTF-8" ] ++
        (if cfg.targetLocale != "en_US.UTF-8" then [ "${cfg.targetLocale}/UTF-8" ] else [ ]) ++
        (map (l: "${l}/UTF-8") cfg.extraLocales)
      else
      # Mặc định: chỉ en_US
        [ "en_US.UTF-8/UTF-8" ];
  };
}
