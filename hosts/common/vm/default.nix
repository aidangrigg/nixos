{ pkgs, config, lib, ... }:
{
  virtualisation = {
    containers.enable = true;
    docker.enable = true;
  };

  # Set up virtualisation
  virtualisation.libvirtd = {
    enable = true;

    # Enable TPM emulation (for Windows 11)
    qemu = {
      swtpm.enable = true;
    };
  };

  # Enable USB redirection
  virtualisation.spiceUSBRedirection.enable = true;

  # Allow VM management
  users.groups.libvirtd.members = [ "aidan" ];
  users.groups.kvm.members = [ "aidan" ];

  # if you use libvirtd on a desktop environment
  programs.virt-manager.enable = true;
}
