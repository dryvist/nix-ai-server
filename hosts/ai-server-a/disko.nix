# Placeholder disko layout.
#
# Real `by-id` paths land in PR #2 once the hardware is on the bench
# and `ls -l /dev/disk/by-id/` enumerates the actual devices. The shape
# below documents the *intended* layout (see docs/architecture/disk-layout.svg)
# but every device path is `/dev/null`-equivalent so disko cannot
# accidentally touch a real disk during scaffold-time evaluation.
#
# Intended final layout:
#   - NVMe (root): GPT, ESP + btrfs root with subvols (@, @home, @nix, @var, @swap)
#   - SSD: ZFS L2ARC for `tank`
#   - 4x 4TB HDD: ZFS RAIDZ2 pool `tank`
{ lib, ... }:
{
  disko.devices = {
    disk = {
      # Root NVMe — placeholder path
      nvme0 = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/PLACEHOLDER-nvme-root";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@var" = {
                    mountpoint = "/var";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };

    # ZFS pool definitions are deliberately omitted from the placeholder
    # so disko cannot try to format anything if this file is run by
    # mistake. PR #2 adds:
    #   - zpool `tank` (RAIDZ2 over 4x HDD by-id paths)
    #   - L2ARC vdev (SSD by-id path)
    #   - dataset layout (tank/datasets, tank/models, tank/jupyter)
  };
}
