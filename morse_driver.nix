{ lib, stdenv, fetchFromGitHub, linuxKernel, kernel ? linuxKernel.packages.linux_6_1.kernel, pkgs }:

let
  pkgsCross = import pkgs.path {
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-linux";
  };
in

stdenv.mkDerivation rec {
  pname = "morse-driver";
  version = "0-rel_1_14_1_2024_Dec_05";

  # Fetch the main repository
  src = fetchFromGitHub {
    owner = "MorseMicro";
    repo = "morse_driver";
    rev = "33f0092d5c859d8589b99c6e9a77abc58c093648";
    sha256 = "sha256-VNw5OdxkP8GltYU2kDYdBUGKWIlPhr3tkzqtW+3MigE=";
    fetchSubmodules = true;
  };

  # Dependencies for building kernel modules
  nativeBuildInputs = with pkgs; [ 
    gcc 
    gnumake 
    bc 
    libelf 
    flex 
    bison 
    pkg-config 
    perl
  ];
  buildInputs = [ kernel.dev ];

  # Disable -Werror to ignore type mismatch warning
  postPatch = ''
    substituteInPlace Makefile \
      --replace "-Werror" ""
  '';

  # Ensure cross-compilation for aarch64-linux
  makeFlags = [
    "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "ARCH=arm64"
    "CROSS_COMPILE=aarch64-unknown-linux-gnu-"
    "MORSE_TRACE_PATH=${src}"
    "CONFIG_WLAN_VENDOR_MORSE=m"
    "CONFIG_MORSE_SPI=y"
    "CONFIG_MORSE_USER_ACCESS=y"
    "CONFIG_MORSE_DEBUG=y"
    "CONFIG_MORSE_VENDOR_COMMAND=y"
    "CONFIG_MORSE_COUNTRY=US"
  ];

  # Build phase
  buildPhase = ''
    runHook preBuild
    export CC=${pkgsCross.stdenv.cc}/bin/aarch64-unknown-linux-gnu-gcc
    export PATH=${pkgsCross.stdenv.cc}/bin:$PATH
    make ${lib.concatStringsSep " " makeFlags}
    make -C dot11ah ${lib.concatStringsSep " " makeFlags}
    runHook postBuild
  '';

  # Install phase
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/misc
    cp morse.ko $out/lib/modules/${kernel.modDirVersion}/misc/
    cp dot11ah/dot11ah.ko $out/lib/modules/${kernel.modDirVersion}/misc/ || echo "Warning: dot11ah.ko not found"
    runHook postInstall
  '';

  # Metadata
  meta = with lib; {
    description = "Morse Micro Wi-Fi driver kernel module for aarch64-linux with SPI support";
    homepage = "https://github.com/MorseMicro/morse_driver";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}