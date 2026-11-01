{ pkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/fa1373130d5a21c040a47c5dbe1913d59ed91808.tar.gz";
    sha256 = "sha256-HzgjxrLY4AEc0044ZuM5CHbLSWLZgDlay1idmzvvpJs=";
  }) {} }:
pkgs.mkShell {
  packages = with pkgs; [ bash coreutils curl fish gh git gnumake gnused gnugrep neovim python3 stow ];
}
