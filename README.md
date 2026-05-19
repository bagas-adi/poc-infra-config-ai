# poc-infra-config-ai

Centralized infrastructure repository for managing infrastructure components using Terraform (Multipass provider), Ansible, and GitHub Actions.

## Components

| Component     | CPUs | Memory | Disk | Port(s)           |
|---------------|------|--------|------|--------------------|
| Elasticsearch | 2    | 4G     | 20G  | 9200, 9300         |
| Kibana        | 2    | 2G     | 10G  | 5670               |
| HAProxy       | 1    | 1G     | 5G   | 80, 8404 (stats)   |
| Consul        | 1    | 1G     | 5G   | 8500 (UI), 8600    |
| PostgreSQL    | 2    | 2G     | 10G  | 5432               |
| MySQL         | 2    | 2G     | 10G  | 3306               |

## Directory Structure

```
├── <component>/
│   ├── terraform/        # Multipass VM provisioning
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   ├── config/           # Reference configuration files
│   └── ansible/          # Playbook and Jinja2 templates
│       ├── playbook.yml
│       └── templates/
├── shared/
│   ├── terraform/modules/multipass-vm/   # Reusable VM module
│   └── ansible/                          # Shared inventory and config
├── .github/workflows/    # CI/CD pipelines
├── scripts/
│   └── setup-runner.sh   # Self-hosted runner installer
└── Makefile                # Convenience targets
```

## Prerequisites

- [Multipass](https://multipass.run/) installed
- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.15

## Quick Start

### 1. Provision a single component

```bash
# Initialize and apply Terraform for elasticsearch
make terraform-init-elasticsearch
make terraform-apply-elasticsearch

# Deploy configuration via Ansible
make ansible-elasticsearch
```

### 2. Provision all components

```bash
make all
```

This runs `terraform apply` for all 6 components, then deploys configs via Ansible.

### 3. Destroy all VMs

```bash
make destroy
```

## Makefile Targets

### Per-Component

```bash
make terraform-init-<component>      # terraform init
make terraform-plan-<component>      # terraform plan
make terraform-apply-<component>     # terraform apply -auto-approve
make terraform-destroy-<component>   # terraform destroy -auto-approve
make ansible-<component>             # run ansible playbook
```

### Global

```bash
make terraform-init-all       # Init all components
make terraform-plan-all       # Plan all components
make terraform-apply-all      # Apply all components
make terraform-destroy-all    # Destroy all components
make ansible-all              # Run all playbooks
make ansible-lint             # Lint all playbooks
make all                      # Apply + deploy everything
make destroy                  # Destroy all VMs
```

### Self-Hosted Runner

```bash
make setup-runner     # Download and configure a GitHub Actions self-hosted runner
make start-runner     # Start the runner interactively
```

## GitHub Actions

Two workflows are included, configured to run on a **self-hosted runner**:

- **terraform.yml** -- Triggered on changes to `**/terraform/**`. Runs validate, format check, plan (on PR), and apply (on push to main) using a matrix over all 6 components.
- **ansible.yml** -- Triggered on changes to `**/ansible/**` or `**/config/**`. Runs ansible-lint, syntax check, and deploy using a matrix over all 6 components.

### Setting Up the Self-Hosted Runner

The workflows use `runs-on: self-hosted`, which requires a local runner. The setup script handles downloading and configuring it:

```bash
# Interactive setup (prompts for repo URL and token)
./scripts/setup-runner.sh

# Or pass credentials via environment variables
RUNNER_REPO_URL=https://github.com/owner/repo \
RUNNER_TOKEN=AXXXX... \
./scripts/setup-runner.sh
```

To get a runner registration token, go to your repository on GitHub: **Settings > Actions > Runners > New self-hosted runner**.

Once configured, start the runner:

```bash
make start-runner
```

On Linux, you can also install it as a system service:

```bash
cd _runner
sudo ./svc.sh install
sudo ./svc.sh start
```

## Terraform

Each component uses the shared Multipass VM module at `shared/terraform/modules/multipass-vm/`. The module accepts `name`, `cpus`, `memory`, `disk`, and `image` as inputs and outputs the VM name and IPv4 address.

## Ansible

Each component has a playbook that:

1. Adds the required package repository
2. Installs the service
3. Deploys configuration from Jinja2 templates
4. Enables and starts the service
5. Uses handlers to reload/restart on config changes

The shared inventory at `shared/ansible/inventory/hosts.yml` should be populated with VM IPs from Terraform outputs.
