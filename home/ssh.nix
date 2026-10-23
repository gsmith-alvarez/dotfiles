_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      yorku_labs = {
        HostName = "red.eecs.yorku.ca";
        User = "gsmitha";
        IdentityFile = "~/.ssh/york_lab_keys";
      };
    };
  };
}
