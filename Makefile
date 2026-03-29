.PHONY: stow unstow restow

PKGS := fish zed

stow:
	stow -t ~ $(PKGS)

unstow:
	stow -t ~ -D $(PKGS)

restow:
	stow -t ~ -R $(PKGS)
