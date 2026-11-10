.PHONY: test social-preview

SOCIAL_HTML ?= assets/social-preview.html
SOCIAL_PNG ?= assets/social-preview.png
SOCIAL_VIEWPORT ?= 1200,630

test:
	bash -n scripts/*.sh tests/*.sh
	bash tests/convert-obsidian-images.test.sh

social-preview:
	bash scripts/capture_social_preview.sh "$(SOCIAL_HTML)" "$(SOCIAL_PNG)" "$(SOCIAL_VIEWPORT)"
