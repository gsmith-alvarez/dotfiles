{
  ...
}:
{
  home.programs.ssh = {
    enable = true;
    matchBlocks = {
      "yorku_labs" = {
        hostname = "red.eecs.yorku.ca";
        user = "gsmitha";
        identityFile = "~/.ssh/york_lab_keys";
      };
    };
  };
}
