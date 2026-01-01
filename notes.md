# Terraform module notes

## IaC (Infrastructure as Code)
- Allows managing and deploying infrastructure through code instead of manual steps.
- Benefits: repeatable, version-controlled, scalable and reduces human error

---

## Terraform
- An open-source IaC tool.
- *Cloud-agnostic*: Able to deploy infrastructure to different cloud providers (eg: AWS, Azure, GCP).
- Infrastructure is defined using code, not manual setup.

**Workflow:**
1. Write IaC in Terraform.
2. Run `terrafrom plan` - compares desired state vs current state, shows what will be created, updated, or changed. *Important to prevent accidental deletion or breaking live resources, and helps validate changes before applying them in production.*
3. Review the plan carefully.
4. Run `terraform apply` - applied the planned changes and deploys resources.

## Terraform providers
- Uses providers to interact with cloud platforms.
- eg: AWS, Azure, GCP.
- Providers handle resource creation, updates, and versioning.

---

## Terraform State File
- The blueprint of your infrastructure.
- Up-to-date record of what actually exists in cloud.
- Terraform relies on it to understand and manage resources correctly.
- Prevents unnecessary or destructive changes, and ensures predictable, repeatable deployments.

**Current state**
- Stored in the terraform state file.
- Represents real infrastructure (eg: existing ec2 instances).

**Desired state**
- Defined in terraform configuration files (.tf).
- Represents how you want your infrastructure to look like.

**How Terraform uses the state file**
- Terraform compares *desired state* with *current state*.
- Decides whether to create new resources, update existing ones, leave things unchanged.
- eg: *state file* has 2 ec2 instances, *config file* has 3 ec2 instances. Terraform deploys 1 new ec2 instance to match desired state.

## Idempotency
- Means running terraform multiple times gives the same result.
- No duplicate resources are created, only real changes are applied.

---

## Terraform Provider
1. **Terraform block**
    - required_providers - specifies which provider your terraform code depends on
    - source - location of the provider in the registry (namspace/provider)
    - version - specifies the provider version your code requires
2. **Provider block**
    - declared using `provider`
    - provider name - indiciates which provider to configure
3. **Deployment steps**
    - Copy *Terraform block* + *Provider block* into configuration
    - Run `terraform init` to download required provider and prep terraform env

---