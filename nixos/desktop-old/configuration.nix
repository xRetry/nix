{ inputs, config, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";

    networking.hostName = "nix"; # Define your hostname.
    networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    time.timeZone = "Europe/Vienna";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
    };

    programs.hyprland = {
        enable = true;

        xwayland = {
            enable = true;
            hidpi = false;
        };
    };

    programs.waybar = {
        enable = true;
        package = pkgs.waybar.overrideAttrs (oldAttrs: {
            mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
        });
    };

    environment.loginShellInit = ''
        [[ "$(tty)" == /dev/tty1 ]] && Hyprland
    '';

    hardware.bluetooth.enable = true;

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        #jack.enable = true;
    };

    environment.etc = {
        "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
            bluez_monitor.properties = {
                ["bluez5.enable-sbc-xq"] = true,
                ["bluez5.enable-msbc"] = true,
                ["bluez5.enable-hw-volume"] = true,
                ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
            }
        '';
    };


    users.users.marco = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "kvm" "libwirtd" "docker" ];
        packages = with pkgs; [];
    };
    users.users.work = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "kvm" "libwirtd" "docker" ];
        packages = with pkgs; [];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        tree
        vim
        wget
        git
        gcc
        alacritty    
        pkg-config
        openssl.dev
        pavucontrol
        nerdfonts
        firefox
        networkmanagerapplet
        udiskie
        bemenu
        zip
        unzip
        docker
        tmux
    ];

    virtualisation.docker.enable = true;

    services.openssh.enable = true;

    system.stateVersion = "23.05";

    nix = {
        package = pkgs.nixFlakes;
        extraOptions = "experimental-features = nix-command flakes";
    };

    home-manager = {
        extraSpecialArgs = { inherit inputs pkgs; };
        users = {
            marco = import ./../../users/marco.nix;
        };
    };

}

