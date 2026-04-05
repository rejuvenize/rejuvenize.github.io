.PHONY: help sync sync-all sync-%

BLUE := \033[34m
GREEN := \033[32m
RED := \033[31m
BOLD := \033[1m
RESET := \033[0m

help:
	@printf '$(BOLD)Targets:$(RESET)\n'
	@printf '  $(BLUE)make sync PROJECT=<project>$(RESET)  Sync one project from .env into the matching folder\n'
	@printf '  $(BLUE)make sync-<project>$(RESET)          Sync a named project directly\n'
	@printf '  $(BLUE)make sync-all$(RESET)                Sync every *_PUBLIC_WEB_PATH project from .env\n'

sync:
	@test -n "$(PROJECT)" || { printf '$(RED)[error]$(RESET) Usage: make sync PROJECT=<project>\n' >&2; exit 1; }
	@./scripts/sync-public-web.sh "$(PROJECT)"

sync-all:
	@projects="$$(./scripts/sync-public-web.sh --list)"; \
	  test -n "$$projects" || { printf '$(RED)[error]$(RESET) No *_PUBLIC_WEB_PATH entries found in .env\n' >&2; exit 1; }; \
	  for project in $$projects; do \
	    ./scripts/sync-public-web.sh "$$project"; \
	  done

sync-%:
	@./scripts/sync-public-web.sh "$*"

.DEFAULT:
	@printf '$(RED)[error]$(RESET) Unknown target: $(BOLD)$@$(RESET)\n' >&2
	@printf 'Run $(GREEN)make help$(RESET) to see available targets.\n' >&2
	@exit 2