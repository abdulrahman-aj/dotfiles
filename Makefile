.PHONY: all check test test-herdr unstow stow omarchy fisher agents bootstrap

TARGET ?= $(HOME)
TARGET_ABS := $(abspath $(TARGET))
STOW ?= stow
PROFILE ?= auto
export PROFILE
DEPLOY_PROFILE := $(shell bash scripts/profile.sh)
ifeq ($(filter $(DEPLOY_PROFILE),arch full),)
$(error Invalid deployment profile)
endif
ARCH_IGNORE := \.config/(hypr|omarchy|alacritty|opencode)(/|$$)
STOW_FLAGS := --no-folding
ifeq ($(DEPLOY_PROFILE),arch)
STOW_FLAGS += --ignore='$(ARCH_IGNORE)'
endif
AGENT_CONFIG_DIR ?= $(TARGET_ABS)/agent-config
AGENT_CONFIG_REPO ?= https://github.com/abdulrahman-aj/agent-config.git

all:
	$(MAKE) bootstrap TARGET="$(TARGET_ABS)"
	$(MAKE) stow TARGET="$(TARGET_ABS)"
	$(MAKE) agents TARGET="$(TARGET_ABS)"
	$(MAKE) fisher TARGET="$(TARGET_ABS)"

bootstrap:
ifeq ($(DEPLOY_PROFILE),arch)
	@bash scripts/setup-arch.sh "$(TARGET_ABS)"
else
	@bash scripts/setup-omarchy.sh "$(TARGET_ABS)"
endif

agents:
	@test -e "$(AGENT_CONFIG_DIR)" || \
		gh repo clone "$(AGENT_CONFIG_REPO)" "$(AGENT_CONFIG_DIR)"
	$(MAKE) -C "$(AGENT_CONFIG_DIR)" install TARGET="$(TARGET_ABS)"

stow:
	@bash scripts/check-prereqs.sh
	@bash scripts/manage-conflicts.sh backup "$(TARGET_ABS)" "$(DEPLOY_PROFILE)"
	$(STOW) $(STOW_FLAGS) -R -t "$(TARGET_ABS)" home

omarchy:
	@bash scripts/setup-omarchy.sh "$(TARGET_ABS)"

fisher:
	@bash scripts/install-fisher.sh "$(TARGET_ABS)"

check:
	@bash scripts/check-prereqs.sh
	@bash scripts/manage-conflicts.sh check "$(TARGET_ABS)" "$(DEPLOY_PROFILE)"
	$(STOW) $(STOW_FLAGS) --simulate -t "$(TARGET_ABS)" home
	$(MAKE) -C "$(AGENT_CONFIG_DIR)" check TARGET="$(TARGET_ABS)"

test:
	@bash tests/test-deploy.sh
	@bash tests/test-arch.sh

test-herdr:
	@node --test tests/test-herdr-opencode.mjs

unstow:
	@command -v "$(STOW)" >/dev/null 2>&1 || { echo "Missing required command: $(STOW)" >&2; exit 1; }
	$(STOW) $(STOW_FLAGS) -t "$(TARGET_ABS)" -D home
	@if [ -d "$(AGENT_CONFIG_DIR)" ]; then \
		$(MAKE) -C "$(AGENT_CONFIG_DIR)" unstow TARGET="$(TARGET_ABS)"; fi
