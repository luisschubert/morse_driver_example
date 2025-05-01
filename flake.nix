{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.morse-driver = 
      let
        # Configure nixpkgs for cross-compilation to aarch64-linux
        pkgs = import nixpkgs {
          localSystem = "x86_64-linux";
          crossSystem = "aarch64-linux";
        };
      in
      pkgs.callPackage ./morse_driver.nix {
        kernel = pkgs.linuxKernel.packages.linux_6_1.kernel;
      };
  };
}