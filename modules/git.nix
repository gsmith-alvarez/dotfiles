{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gitleaks
    lazygit
  ];

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
      line-numbers = true;
      hyperlink = true;
    };
  };

  programs.git = {
    enable = true;

    includes = [
      { path = "~/.gitconfig.local"; }
      {
        path = "~/.gitconfig.work";
        condition = "gitdir:~/work/";
      }
    ];

    settings = {
      user = {
        name = "Giovanni";
        email = "smith.alvarez.g@gmail.com";
      };

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        lg = "log --oneline --graph --decorate";
      };

      core = {
        editor = "nvim";
        untrackedCache = true;
        preloadIndex = true;
        excludesfile = "${./gitignore_global}";
      };
      gc.auto = 0;
      pull.rebase = true;
      fetch.prune = true;
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";

      credential."https://github.com" = {
        helper = [
          ""
          "!gh auth git-credential"
        ];
      };
      credential."https://gist.github.com" = {
        helper = [
          ""
          "!gh auth git-credential"
        ];
      };
    };
  };

  programs = {
    gh.enable = true;
  };
}
