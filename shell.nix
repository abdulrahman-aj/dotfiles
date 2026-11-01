{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = with pkgs; [ bash coreutils curl fish gh git gnumake gnused gnugrep neovim python3 stow ];
}
