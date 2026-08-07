{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gitleaks
    delta
  ];

  programs.git = {
    enable = true;
    userName = "Giovanni";
    userEmail = "gio@example.com";

    # [alias]
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      lg = "log --oneline --graph --decorate";
    };

    # [delta] & [core] pager
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        hyperlink = true;
      };
    };

    # [include] & [includeIf]
    includes = [
      { path = "~/.gitconfig.local"; }
      {
        path = "~/.gitconfig.work";
        condition = "gitdir:~/work/";
      }
    ];

    extraConfig = {
      core = {
        editor = "nvim";
        untrackedCache = true;
        preloadIndex = true;
        exludesfile = "${./gitignore_global}";
      };
      gc.auto = 0;
      pull.rebase = true;
      fetch.prune = true;
      init.defaultBranch = "main";
      interactive.diffFilter = "delta --color-only";
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

    lazygit = {
      enable = true;
      settings = {
        git = {
          diffRenderers = [
            {
              command = "delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
            }
          ];
        };
        gui = {
          theme = {
            activeBorderColor = [ "#89b4fa" "bold" ];
            inactiveBorderColor = [ "#a6adc8" ];
            searchingActiveBorderColor = [ "#f9e2af" ];
            optionsTextColor = [ "#89b4fa" ];
            selectedLineBgColor = [ "#313244" ];
            inactiveViewSelectedLineBgColor = [ "#6c7086" ];
            cherryPickedCommitFgColor = [ "#89b4fa" ];
            cherryPickedCommitBgColor = [ "#45475a" ];
            markedBaseCommitFgColor = [ "#89b4fa" ];
            markedBaseCommitBgColor = [ "#f9e2af" ];
            unstagedChangesColor = [ "#f38ba8" ];
            defaultFgColor = [ "#cdd6f4" ];
          };
          authorColors = {
            "*" = "#b4befe";
          };
        };
      };
    };
  };
}
