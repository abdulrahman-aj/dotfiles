.PHONY: check stow unstow restow

PKGS := fish ghostty zed
TARGET ?= $(HOME)
STOW ?= stow

check:
	$(STOW) --simulate -t "$(TARGET)" $(PKGS)

stow:
	$(STOW) -t "$(TARGET)" $(PKGS)

unstow:
	$(STOW) -t "$(TARGET)" -D $(PKGS)

restow:
	$(STOW) -t "$(TARGET)" -R $(PKGS)
