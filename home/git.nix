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
    };
  };
}
