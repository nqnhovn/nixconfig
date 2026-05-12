{ pkgs, ... }:

{
  languages.go.enable = true;
  languages.go.version = "1.23";

  packages = with pkgs; [
    gopls
    golangci-lint
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

  scripts.run.exec = "go run ./cmd/server";
  scripts.test.exec = "go test ./...";
  scripts.lint.exec = "golangci-lint run";

  enterShell = ''
    echo "🔵 Go $(go version | cut -d' ' -f3)  |  🗄️  Postgres on localhost:5432"
    echo "   run   → go run ./cmd/server"
    echo "   test  → go test ./..."
    echo "   lint  → golangci-lint run"
  '';
}
