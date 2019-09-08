{ stdenv, fetchurl, makeDesktopItem, openssl, xorg, curl, fontconfig, krb5, zlib, dotnet-sdk }:

stdenv.mkDerivation rec {
  pname = "wasabiwallet";
  version = "1.1.6";

  src = fetchurl {
    url = "https://github.com/zkSNACKs/WalletWasabi/releases/download/v${version}/WasabiLinux-${version}.tar.gz";
    sha256 = "1i7fhaj9chjlm7qg0h3azy4djnm9rxskbr3dzjj0n9rw8cjdqyq6";
  };

  dontBuild = true;
  dontPatchELF = true;

  desktopItem = makeDesktopItem {
    name = "wasabi";
    exec = "wasabiwallet";
    desktopName = "Wasabi";
    genericName = "Bitcoin wallet";
    comment = meta.description;
    categories = "Application;Network;Utility;";
  };

  installPhase = ''
    mkdir -p $out/opt/${pname} $out/bin $out/share/applications
    cp -Rv . $out/opt/${pname}
    cd $out/opt/${pname}
    for i in $(find . -type f -name '*.so') wassabee
      do
        patchelf --set-rpath ${stdenv.lib.makeLibraryPath [ openssl stdenv.cc.cc.lib xorg.libX11 curl fontconfig.lib krb5 zlib dotnet-sdk ]} $i
      done
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" wassabee
    ln -s $out/opt/${pname}/wassabee $out/bin/${pname}
    cp -v $desktopItem/share/applications/* $out/share/applications
  '';

  meta = with stdenv.lib; {
    description = "Privacy focused Bitcoin wallet";
    homepage = "https://wasabiwallet.io/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ mmahut ];
  };
}
