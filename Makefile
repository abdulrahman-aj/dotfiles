.PHONY: all check test test-herdr unstow stow omarchy fisher agents

TARGET ?= $(HOME)
TARGET_ABS := $(abspath $(TARGET))
STOW ?= stow
STOW_FLAGS := --no-folding
AGENT_CONFIG_DIR ?= $(TARGET_ABS)/agent-config
AGENT_CONFIG_REPO ?= git@github.com:abdulrahman-aj/agent-config.git

all: omarchy stow agents fisher

agents:
	@test -e "$(AGENT_CONFIG_DIR)" || \
		git clone -- "$(AGENT_CONFIG_REPO)" "$(AGENT_CONFIG_DIR)"
	$(MAKE) -C "$(AGENT_CONFIG_DIR)" install TARGET="$(TARGET_ABS)"

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
	$(MAKE) -C "$(AGENT_CONFIG_DIR)" check TARGET="$(TARGET_ABS)"

test:
	@bash tests/test-deploy.sh

test-herdr:
	@node --test tests/test-herdr-opencode.mjs

unstow:
	@command -v "$(STOW)" >/dev/null 2>&1 || { echo "Missing required command: $(STOW)" >&2; exit 1; }
	$(STOW) $(STOW_FLAGS) -t "$(TARGET_ABS)" -D home
	@if [ -d "$(AGENT_CONFIG_DIR)" ]; then \
		$(MAKE) -C "$(AGENT_CONFIG_DIR)" unstow TARGET="$(TARGET_ABS)"; fi
