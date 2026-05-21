# =====================================================================
# HOME/GIT.NIX — GIT CONFIG + USER + HOOKS
# =====================================================================

{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "nqnhovn";
        email = "nqnho.vn@gmail.com";
      };
      init.defaultBranch = "main";
      core.hooksPath = "~/.config/nixos/.githooks";
    };
  };
}
