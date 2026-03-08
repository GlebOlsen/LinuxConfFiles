{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    overwriteBackup = true;
  };
  home-manager.users.div = {
    # home.packages = with pkgs; [
    #
    # ];
    imports = [ ../home ];
    home.stateVersion = config.system.stateVersion;
  };
}
