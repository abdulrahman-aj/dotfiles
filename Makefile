.PHONY: all check test test-desktop-vm unstow stow fisher agents bootstrap
.NOTPARALLEL:

TARGET ?= $(HOME)
TARGET_ABS := $(abspath $(TARGET))
STOW ?= stow
STOW_FLAGS := --no-folding
AGENT_CONFIG_DIR ?= $(TARGET_ABS)/agent-config
AGENT_CONFIG_REPO ?= https://github.com/abdulrahman-aj/agent-config.git

all: bootstrap stow agents fisher

bootstrap:
	@bash scripts/setup-arch.sh "$(TARGET_ABS)"

agents:
	@test -e "$(AGENT_CONFIG_DIR)" || \
		gh repo clone "$(AGENT_CONFIG_REPO)" "$(AGENT_CONFIG_DIR)"
	$(MAKE) -C "$(AGENT_CONFIG_DIR)" install TARGET="$(TARGET_ABS)"

stow:
	@bash scripts/check-prereqs.sh
	@bash scripts/manage-conflicts.sh backup "$(TARGET_ABS)"
	$(STOW) $(STOW_FLAGS) -R -t "$(TARGET_ABS)" home

fisher:
	@bash scripts/install-fisher.sh "$(TARGET_ABS)"

check:
	@bash scripts/check-prereqs.sh
	@bash scripts/manage-conflicts.sh check "$(TARGET_ABS)"
	$(STOW) $(STOW_FLAGS) --simulate -t "$(TARGET_ABS)" home
	$(MAKE) -C "$(AGENT_CONFIG_DIR)" check TARGET="$(TARGET_ABS)"

test:
	@NIX_BUILD_SHELL="$$(command -v bash)" nix-shell --run 'bash tests/test-deploy.sh && python3 tests/test-desktop.py'

test-desktop-vm:
	python3 tests/test-desktop-vm.py $(ARGS)

unstow:
	@command -v "$(STOW)" >/dev/null 2>&1 || { echo "Missing required command: $(STOW)" >&2; exit 1; }
	$(STOW) $(STOW_FLAGS) -t "$(TARGET_ABS)" -D home
	@if [ -d "$(AGENT_CONFIG_DIR)" ]; then \
		$(MAKE) -C "$(AGENT_CONFIG_DIR)" uninstall TARGET="$(TARGET_ABS)"; fi
