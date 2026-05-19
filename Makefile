COMPONENTS := elasticsearch kibana haproxy consul postgresql mysql
ANSIBLE_CFG := shared/ansible/ansible.cfg
INVENTORY := shared/ansible/inventory/hosts.yml

.PHONY: help all destroy $(COMPONENTS) \
	$(addprefix terraform-init-,$(COMPONENTS)) \
	$(addprefix terraform-plan-,$(COMPONENTS)) \
	$(addprefix terraform-apply-,$(COMPONENTS)) \
	$(addprefix terraform-destroy-,$(COMPONENTS)) \
	$(addprefix ansible-,$(COMPONENTS)) \
	terraform-init-all terraform-plan-all terraform-apply-all terraform-destroy-all \
	ansible-all ansible-lint act act-terraform act-ansible

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Per-component targets:"
	@echo "  terraform-init-<component>     Initialize Terraform for a component"
	@echo "  terraform-plan-<component>     Plan Terraform changes for a component"
	@echo "  terraform-apply-<component>    Apply Terraform for a component"
	@echo "  terraform-destroy-<component>  Destroy Terraform resources for a component"
	@echo "  ansible-<component>            Run Ansible playbook for a component"
	@echo ""
	@echo "Global targets:"
	@echo "  terraform-init-all      Init Terraform for all components"
	@echo "  terraform-plan-all      Plan all components"
	@echo "  terraform-apply-all     Apply all components"
	@echo "  terraform-destroy-all   Destroy all components"
	@echo "  ansible-all             Run all Ansible playbooks"
	@echo "  ansible-lint            Lint all Ansible playbooks"
	@echo "  all                     Provision all VMs and deploy all configs"
	@echo "  destroy                 Tear down all Multipass VMs"
	@echo "  act                     Run all GitHub workflows locally via act"
	@echo "  act-terraform           Run Terraform workflow locally via act"
	@echo "  act-ansible             Run Ansible workflow locally via act"
	@echo ""
	@echo "Components: $(COMPONENTS)"

# --- Terraform targets ---

define terraform_targets
terraform-init-$(1):
	cd $(1)/terraform && terraform init

terraform-plan-$(1):
	cd $(1)/terraform && terraform plan

terraform-apply-$(1):
	cd $(1)/terraform && terraform apply -auto-approve

terraform-destroy-$(1):
	cd $(1)/terraform && terraform destroy -auto-approve
endef

$(foreach comp,$(COMPONENTS),$(eval $(call terraform_targets,$(comp))))

terraform-init-all: $(addprefix terraform-init-,$(COMPONENTS))

terraform-plan-all: $(addprefix terraform-plan-,$(COMPONENTS))

terraform-apply-all: $(addprefix terraform-apply-,$(COMPONENTS))

terraform-destroy-all: $(addprefix terraform-destroy-,$(COMPONENTS))

# --- Ansible targets ---

define ansible_targets
ansible-$(1):
	ANSIBLE_CONFIG=$(ANSIBLE_CFG) ansible-playbook $(1)/ansible/playbook.yml -i $(INVENTORY) --diff
endef

$(foreach comp,$(COMPONENTS),$(eval $(call ansible_targets,$(comp))))

ansible-all: $(addprefix ansible-,$(COMPONENTS))

ansible-lint:
	@for comp in $(COMPONENTS); do \
		echo "=== Linting $$comp ==="; \
		ansible-lint $$comp/ansible/playbook.yml || exit 1; \
	done

# --- Combined targets ---

all: terraform-apply-all ansible-all
	@echo "All components provisioned and configured."

destroy: terraform-destroy-all
	@echo "All Multipass VMs destroyed."

# --- Local CI with act ---

act:
	docker compose -f docker-compose.act.yml run --rm act-all

act-terraform:
	docker compose -f docker-compose.act.yml run --rm act-terraform

act-ansible:
	docker compose -f docker-compose.act.yml run --rm act-ansible
