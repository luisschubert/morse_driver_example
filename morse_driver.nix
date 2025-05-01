{ lib, stdenv, fetchFromGitHub, linuxKernel, kernel ? linuxKernel.packages.linux_6_1.kernel }:

stdenv.mkDerivation rec {
  pname = "morse-driver";
  version = "0.1"; # Adjust to match the desired branch/commit version

  # Fetch the main repository
  src = fetchFromGitHub {
    owner = "MorseMicro";
    repo = "morse_driver";
    rev = "main"; # Use specific branch (e.g., "wilc_driver") or commit hash
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
    fetchSubmodules = true; # Fetch the mm_rate_control submodule
  };

  # Dependencies for building kernel modules
  nativeBuildInputs = [ kernel.moduleSupport ];
  buildInputs = [ kernel.dev ];

  # Ensure cross-compilation for aarch64-linux
  # Set ARCH and CROSS_COMPILE for the kernel module build
  makeFlags = [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "ARCH=arm64"
    "CROSS_COMPILE=aarch64-linux-gnu-"
  ];

  # Build phase
  buildPhase = ''
    runHook preBuild
    make ${lib.concatStringsSep " " makeFlags}
    runHook postBuild
  '';

  # Install phase
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/misc
    cp *.ko $out/lib/modules/${kernel.modDirVersion}/misc/
    runHook postInstall
  '';

  # Metadata
  meta = with lib; {
    description = "Morse Micro Wi-Fi driver kernel module for aarch64-linux";
    homepage = "https://github.com/MorseMicro/morse_driver";
    license = licenses.gpl2; # Assuming GPL-2.0
    platforms = platforms.linux;
    maintainers = [ ];
  };
}