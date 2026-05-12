{ pkgs, ... }:

{
  languages.javascript.enable = true;
  languages.javascript.package = pkgs.nodejs_22;
  languages.typescript.enable = true;

  packages = with pkgs; [
    pnpm
    nodePackages.vue-language-server
  ];

  services.postgres = {
    enable = true;
    initialDatabases = [ { name = "app"; } ];
    ensureUsers = [{
      name = "app";
      password = "secret";
      ensurePermissions = { "DATABASE app" = "ALL PRIVILEGES"; };
    }];
  };

  scripts.dev.exec = "pnpm dev";
  scripts.build.exec = "pnpm build";
  scripts.lint.exec = "pnpm lint";

  enterShell = ''
    echo "🟢 Node  $(node -v)  |  📦 pnpm $(pnpm -v)"
    echo "   dev   → pnpm dev"
    echo "   build → pnpm build"
    echo "   lint  → pnpm lint"
  '';
}
