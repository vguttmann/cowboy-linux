{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gh
  ];
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
