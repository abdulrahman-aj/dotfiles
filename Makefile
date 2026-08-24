.PHONY: all check test unstow

PKGS := bin fish alacritty zed git cloc lazygit ai-shared opencode omarchy
TARGET ?= $(HOME)
TARGET_ABS := $(abspath $(TARGET))
STOW ?= stow
STOW_FLAGS := --no-folding

all:
	@bash scripts/setup-omarchy.sh "$(TARGET_ABS)"
	@bash scripts/check-prereqs.sh
	@bash scripts/manage-conflicts.sh backup "$(TARGET_ABS)" $(PKGS)
	$(STOW) $(STOW_FLAGS) -R -t "$(TARGET_ABS)" $(PKGS)
	@bash scripts/install-kickstart.sh "$(TARGET_ABS)"
	@bash scripts/install-fisher.sh "$(TARGET_ABS)"

check:
	@bash scripts/check-prereqs.sh
	@bash scripts/manage-conflicts.sh check "$(TARGET_ABS)" $(PKGS)
	$(STOW) $(STOW_FLAGS) --simulate -t "$(TARGET_ABS)" $(PKGS)

test:
	@bash tests/test-deploy.sh
	@bash tests/test-worktree.sh

unstow:
	@command -v "$(STOW)" >/dev/null 2>&1 || { echo "Missing required command: $(STOW)" >&2; exit 1; }
	$(STOW) $(STOW_FLAGS) -t "$(TARGET_ABS)" -D $(PKGS)
