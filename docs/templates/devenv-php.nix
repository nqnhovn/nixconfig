{ pkgs, ... }:

{
  languages.php.enable = true;
  languages.php.version = "8.3";
  languages.php.extensions = [ "pdo" "mbstring" "curl" "xml" "zip" "gd" ];
  languages.javascript.enable = true;
  languages.javascript.package = pkgs.nodejs_22;

  packages = with pkgs; [
    composer
    pnpm
  ];

  services.mysql = {
    enable = true;
    initialDatabases = [ { name = "app"; } ];
    ensureUsers = [{
      name = "app";
      password = "secret";
      ensurePermissions = { "app.*" = "ALL PRIVILEGES"; };
    }];
  };

  scripts.serve.exec = "php artisan serve --host=0.0.0.0";
  scripts.migrate.exec = "php artisan migrate";
  scripts.tinker.exec = "php artisan tinker";

  enterShell = ''
    echo "🐘 PHP $(php -v | head -1 | cut -d' ' -f2)  |  📦 Composer $(composer --version | cut -d' ' -f3)"
    echo "🟢 Node $(node -v)  |  🗄️  MySQL on localhost:3306"
  '';
}
