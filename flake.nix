{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # Use a stable release for kernel 6.1
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.morse-driver = 
      let
        # Configure nixpkgs for cross-compilation
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          crossSystem = {
            config = "aarch64-linux";
            system = "aarch64-linux";
          };
        };
      in
      pkgs.callPackage ./morse-driver.nix {
        # Explicitly use kernel 6.1 for aarch64-linux
        kernel = pkgs.linuxKernel.packages.linux_6_1.kernel;
      };
  };
}