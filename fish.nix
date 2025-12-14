{ pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    fish
    pay-respects
    grc
    fishPlugins.grc
    fishPlugins.plugin-git
    fishPlugins.done
    fishPlugins.fish-you-should-use
    zoxide
    tree
  ];
  environment.variables = {
    _PR_SHELL = "fish";
  };
  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;
  programs.fish = {
    enable = true;
    shellInit = "pay-respects fish | source && zoxide init fish";
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --impure";
      commit = "git commit -p";
      amend = "git commit -a --amend --no-edit";
      amendedit = "git commit -a --amend";
      push = "git push";
      pull = "git pull";
      reab = "git rebase --abort";
      recon = "git rebase --continue";
      force = "git push --force";
    };
  };
  users.extraUsers.ranger = {
    shell = pkgs.fish;
  };
  users.extraUsers.vguttmann = {
    shell = pkgs.fish;
  };
}
