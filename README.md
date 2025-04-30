# 💼 Phase 1: Production-Ready Azure Infrastructure — Terraform Project Structure

📁 **Directory Structure**
```
azure-infra-prod/
├── modules/
│   ├── vnet/
│   │   └── main.tf, outputs.tf, variables.tf
│   ├── app_gateway/
│   │   └── main.tf, outputs.tf, variables.tf
│   ├── vmss_web/
│   │   └── main.tf, outputs.tf, variables.tf
│   ├── vmss_api/
│   │   └── main.tf, outputs.tf, variables.tf
│   ├── sql_db/
│   │   └── main.tf, outputs.tf, variables.tf
│   ├── key_vault/
│   │   └── main.tf, outputs.tf, variables.tf
│   ├── firewall/
│   │   └── main.tf, outputs.tf, variables.tf
│   ├── bastion/
│   │   └── main.tf, outputs.tf, variables.tf
│   └── monitoring/
│       └── main.tf, outputs.tf, variables.tf
├── environments/
│   └── prod/
│       ├── main.tf
│       ├── backend.tf
│       ├── terraform.tfvars
│       ├── variables.tf
│       └── outputs.tf
├── README.md
└── diagrams/
    └── architecture.png# prod-infra
