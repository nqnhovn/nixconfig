# =====================================================================
# HOME/GIT.NIX — GIT CONFIG + USER + HOOKS
# =====================================================================

{ lib, ... }:

let
  infoPath = ../../../../secrets/info.nix;
  infoExamplePath = ../../../../secrets/info.example.nix;
  userInfo = if builtins.pathExists infoPath
    then import infoPath
    else if builtins.pathExists infoExamplePath
    then import infoExamplePath
    else { };
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = userInfo.gitUser or userInfo.user or "user";
        email = userInfo.gitEmail or userInfo.email or "user@example.com";
      };
      init.defaultBranch = "main";
      core.hooksPath = "~/.config/nixos/.githooks";
    };
  };
}
