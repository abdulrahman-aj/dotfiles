.PHONY: all check test test-herdr unstow stow omarchy fisher

TARGET ?= $(HOME)
TARGET_ABS := $(abspath $(TARGET))
STOW ?= stow
STOW_FLAGS := --no-folding

all: omarchy stow fisher

stow:
	@bash scripts/check-prereqs.sh
	@bash scripts/manage-conflicts.sh backup "$(TARGET_ABS)"
	$(STOW) $(STOW_FLAGS) -R -t "$(TARGET_ABS)" home

omarchy:
	@bash scripts/setup-omarchy.sh "$(TARGET_ABS)"

fisher:
	@bash scripts/install-fisher.sh "$(TARGET_ABS)"

check:
	@bash scripts/check-prereqs.sh
	@bash scripts/manage-conflicts.sh check "$(TARGET_ABS)"
	$(STOW) $(STOW_FLAGS) --simulate -t "$(TARGET_ABS)" home

test:
	@bash tests/test-deploy.sh

test-herdr:
	@node --test tests/test-herdr-opencode.mjs

unstow:
	@command -v "$(STOW)" >/dev/null 2>&1 || { echo "Missing required command: $(STOW)" >&2; exit 1; }
	$(STOW) $(STOW_FLAGS) -t "$(TARGET_ABS)" -D home
