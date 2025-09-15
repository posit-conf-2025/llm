# Use qvm to manage quarto
QUARTO_VERSION ?= 1.8.24
QUARTO_PATH = ~/.local/share/qvm/versions/v${QUARTO_VERSION}/bin/quarto

.PHONY: install-quarto
install-quarto:
	@echo "🔵 Installing quarto"
	@if ! [ -z $(command -v qvm)]; then \
		@echo "Error: qvm is not installed. Please visit https://github.com/dpastoor/qvm/releases/ to install it." >&2 \
		exit 1; \
	fi
	qvm install v${QUARTO_VERSION}
	@echo "🔹 Updating .vscode/settings.json"
	@awk -v path="${QUARTO_PATH}" '/"quarto.path":/ {gsub(/"quarto.path": ".*"/, "\"quarto.path\": \"" path "\"")} 1' .vscode/settings.json > .vscode/settings.json.tmp && mv .vscode/settings.json.tmp .vscode/settings.json
	@echo "🔹 Updating .github/workflows/publish.yml"
	@awk -v ver="${QUARTO_VERSION}" '/QUARTO_VERSION:/ {gsub(/QUARTO_VERSION: .*/, "QUARTO_VERSION: " ver)} 1' .github/workflows/publish.yml > .github/workflows/publish.yml.tmp && mv .github/workflows/publish.yml.tmp .github/workflows/publish.yml


.PHONY: secret-decrypt
secret-decrypt: ## [setup] Decrypt the secret env file
	./secret.py decrypt .env.secret > .env

.PHONY: py-setup
py-setup:  ## [py] Setup Python environment
	uv sync --all-extras

.PHONY: py-upgrade
py-upgrade:
	uv sync --all-extras --upgrade

.PHONY: r-setup
r-setup:  ## [r] Setup R environment
	Rscript -e 'if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")'
	Rscript -e 'renv::restore()'

.PHONY: r-setup-dev
r-setup-dev: ## [r] Setup R environment for dev
	Rscript -e "if (!requireNamespace('pak', quietly = TRUE)) install.packages('pak')"
	Rscript -e "pak::local_install_dev_deps(dependencies = 'Config/Needs/dev')"

.PHONY: secret-encrypt
secret-encrypt:
	./secret.py encrypt .env > .env.secret

.PHONY: render
render: ## [docs] Build the workshop website
	cd website && ${QUARTO_PATH} render

.PHONY: preview
preview:  ## [docs] Preview the workshop website
	cd website && ${QUARTO_PATH} preview

.PHONY: format
format: r-format py-format  ## Format code in all languages
	@echo "📏 📐 Code formatted!"

.PHONY: r-format
r-format:
	air format .

.PHONY: py-format
py-format:
	uv run ruff check --fix --select I
	uv run ruff format

.PHONY: py-ipynb
py-ipynb:  py-format ## Convert all Python scripts to Jupyter notebooks
	@echo "\n"
	@echo "📝 Converting Python scripts to Jupyter notebooks"
	find _exercises -name "*.py" -not -name "*app.py" -print0 | xargs -0 -I{} uv run jupytext --update --to ipynb "{}"
	find _solutions -name "*.py" -not -name "*app.py" -print0 | xargs -0 -I{} uv run jupytext --update --to ipynb "{}"
	find _demos/19_tools -name "*.py" -not -name "*app.py" -print0 | xargs -0 -I{} uv run jupytext --update --to ipynb "{}"

	@echo "\n\n\n"
	@echo "🧹 Cleaning Jupyter notebook outputs"
	find _exercises -name "*.ipynb" -print0 | xargs -0 -I{} uv run jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace "{}"
	find _solutions -name "*.ipynb" -print0 | xargs -0 -I{} uv run jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace "{}"
	find _demos/19_tools -name "*.ipynb" -print0 | xargs -0 -I{} uv run jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace "{}"

.PHONY: help
help:  ## Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; { \
		printf "\033[32m%-18s\033[0m", $$1; \
		if ($$2 ~ /^\[setup\]/) { \
			printf "\033[1m\033[37m[setup]%s\033[0m\n", substr($$2, 8); \
		} else if ($$2 ~ /^\[docs\]/) { \
			printf " \033[37m[docs]%s\n", substr($$2, 7); \
		} else if ($$2 ~ /^\[py\]/) { \
			printf "   \033[31m[py]%s\033[0m\n", substr($$2, 5); \
		} else if ($$2 ~ /^\[r\]/) { \
			printf "    \033[34m[r]%s\033[0m\n", substr($$2, 4); \
		} else if ($$2 ~ /^\[js\]/) { \
			printf "   \033[33m[js]\033[0m%s\n", substr($$2, 5); \
		} else { \
			printf "        %s\n", $$2; \
		} \
	}'

.DEFAULT_GOAL := help
