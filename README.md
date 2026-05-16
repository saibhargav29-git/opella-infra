# Opella Infrastructure

Reusable Terraform modules for provisioning Azure infrastructure across environments.

## Structure

```
opella-infra/
├── modules/vnet/        # Reusable VNET module
├── environments/
│   ├── dev/             # Development (westus2)
│   └── prod/            # Production (westus2)
└── .github/workflows/   # GitHub Actions CI/CD
```

## Environments

| Environment | VNET CIDR | VM Size | Storage |
|---|---|---|---|
| dev | 10.0.0.0/16 | Standard_B2ats_v2 | LRS |
| prod | 10.1.0.0/16 | Standard_B2ats_v2 | GRS |

Each environment provisions a Resource Group, VNET, subnets with NSGs, a Linux VM, and a Storage Account with Blob Container — all tagged consistently via a shared `locals` block.

## Key Decisions

- **Separate directories over workspaces** — independent state per environment, supports meaningful config differences, no risk of wrong-environment deploys
- **Resource Groups over Subscriptions** — sufficient for this scale; at enterprise scale, subscription-per-environment under Management Groups would be recommended
- **Remote state in Azure Blob** — separate state paths per environment (dev/terraform.tfstate, prod/terraform.tfstate), automatic state locking via blob leases
- **NSG per subnet** — granular security control; app and data subnets have different traffic requirements
- **Tagging on every resource** — enforced via `locals`; in production, backed by Azure Policy with `deny` effect

## Usage

```bash
cd environments/dev   # or prod
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## CI/CD

| Environment | Trigger | Apply |
|---|---|---|
| dev | Push to `main` | Auto |
| prod | Manual (`workflow_dispatch`) | Requires explicit `apply` input |

## Plan Outputs

- [Dev](environments/dev/plan-output.txt)
- [Prod](environments/prod/plan-output.txt)
- [Azure-Screenshots](https://docs.google.com/document/d/1Mcy42Zk-ZnrumFKzeuVzDBG7TKwj36K5l0ert_Z-T88/edit?usp=sharing)
