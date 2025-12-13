{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./locale.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "cowboy-linux";
    firewall.allowedTCPPorts = [ 22 ];
    #wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  };

  networking.networkmanager.enable = true;

  programs = {
    git = {
      enable = true;
    };
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  security.rtkit.enable = true;
  services = {
    openssh = {
      enable = true;
    };
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = "ranger";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      #jack.enable = true;
      #media-session.enable = true;
    };
  };
  systemd = {
    defaultUnit = "graphical.target";
    settings.Manager.RuntimeWatchdogSec = "10";
    services.NetworkManager-wait-online.enable = false;
  };

  users.users = {
    vguttmann = {
      isNormalUser = true;
      description = "vguttmann";
      extraGroups = [ "networkmanager" "wheel" "plugdev" "input" ];
    };
    ranger = {
      isNormalUser = true;
      description = "ranger";
      initialPassword = "gesamtsituation";
      extraGroups = [ "video" "input" "seat" "networkmanager" "wheel"];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    kitty
    libfido2
  ];

  system.stateVersion = "25.11"; # Did you read the comment?

}
