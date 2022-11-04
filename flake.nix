{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }: {
    devShell.x86_64-linux = let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        qemu
        netcat
        # tool to interact with EBS api directly for speedy AMI imports.
        (pkgs.callPackage ./etc/pkgs/coldsnap.nix { })
      ];
      shellHook = ''
        export OVMF=${pkgs.OVMF.fd}/FV
      '';
    };

    nixosConfigurations.app = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        #(nixpkgs + "/nixos/modules/virtualisation/amazon-image.nix")
        (nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
        ({ pkgs, ... }: {

          # Let 'nixos-version --json' know about the Git revision
          # of this flake.
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          services.getty.autologinUser = "root";
          # Network configuration.
          networking.firewall.enable = false;
          boot.loader.grub.extraConfig =
            "serial; terminal_input serial; terminal_output serial";

          # Enable a web server.
          services.httpd = {
            enable = true;
            adminAddr = "morty@example.org";
          };

          systemd.services.logforward = {
            enable = true;
            wantedBy = [ "multi-user.target" ];
            path = with pkgs; [ netcat systemd ];
            after = [ "network-online.target" ];
            script = ''
              journalctl -o json -f  | nc 10.12.1.12 2002
            '';
          };

          systemd.services.healthcheck = {
            enable = true;
            wantedBy = [ "multi-user.target" ];
            after = [ "network-online.target" "httpd.service" ];

            path = with pkgs; [ curl netcat hostname systemd ];
            script = ''
              set -x
              set -e
              while ! curl localhost; do
                sleep 1;
              done
              echo $(hostname) with service is ready | nc -w 1 10.12.1.12 2001
              sleep 30
              reboot
            '';

          };
        })
      ];
    };

  };
}
