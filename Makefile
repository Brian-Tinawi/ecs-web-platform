# Portfolio project Makefile. Intentionally has NO apply/destroy targets:
# apply/destroy go through `terraform -chdir=envs/<env> ...` so the guardrail hook can gate them.
# Lifecycle: make plan → terraform apply tfplan → make verify → make evidence → terraform destroy.
# Deployments are temporary: default TTL 4h; never > 24h without Brian's OK (the apply gate enforces it).
SHELL := /bin/bash
ENV ?= dev
TTL_HOURS ?= 4
TTL ?= $(shell date -u -d '+$(TTL_HOURS) hours' +%Y-%m-%dT%H:%M:%SZ)
export AWS_PROFILE ?= portfolio
ENVS := $(wildcard envs/*)

.PHONY: fmt validate lint scan init plan cost verify evidence docs diagrams check

fmt:
	terraform fmt -recursive

validate:
	@for d in $(ENVS); do echo "== $$d"; terraform -chdir=$$d init -backend=false -input=false -no-color >/dev/null && terraform -chdir=$$d validate -no-color || exit 1; done

lint:
	tflint --init --config=$(CURDIR)/.tflint.hcl >/dev/null
	tflint --recursive --config=$(CURDIR)/.tflint.hcl --no-color

scan:
	checkov -d . --config-file .checkov.yaml

init:
	terraform -chdir=envs/$(ENV) init -input=false -no-color

plan: init
	terraform -chdir=envs/$(ENV) plan -input=false -no-color -var "ttl=$(TTL)" -out=tfplan
	@$(MAKE) --no-print-directory cost ENV=$(ENV)

cost:
	@$(HOME)/cloud-portfolio/scripts/cost-estimate.sh envs/$(ENV) | tee /dev/stderr | awk -F= -v h=$(TTL_HOURS) '/HOURLY_USD/{printf "PER_DEPLOYMENT_USD=%.2f (%sh TTL)\n", $$2*h, h}'

# Smoke tests against the LIVE deployment of $(ENV) — proves the project's core claim.
verify:
	tests/smoke/run.sh $(ENV)

# After `make verify` passes: log the run, refresh the "Last verified" badge.
evidence:
	$(HOME)/cloud-portfolio/scripts/record-evidence.sh . $(ENV) pass

docs:
	@for m in modules/*/; do terraform-docs markdown table --output-file README.md --output-mode inject $$m; done

diagrams:
	@for f in docs/architecture/*.py; do $(HOME)/.local/share/portfolio-py/bin/python $$f; done

check: fmt validate lint scan
