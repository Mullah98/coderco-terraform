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

## Terraform Core Commands

### Terraform init
- Means to initialize.
- First command you run in any terraform project.
- Sets up the project so Terraform can work correctly.

**What does `terraform init` do?**
- *Initialize the backend* - Backend = where terraform stores the state file. State can be stored locally or remotely (eg: S3)
- *Download provider plugins* - Reads your terraform + provider blocks. Downloads required providers from the Terraform registry

**Importance**
- Allows terraform to track infrastructure, maintain idempotency, communicate with cloud providers.

*Without `init`, terraform cannot deploy anything. Always run `terraform init` before plan or apply.*

---

### Terraform plan
- Previews changes before they happen.
- Core to a security-first deployment mindset.
- Always review the output and summary before applying to make sure everything looks correct.
- Summary at the bottom shows resource to *add, change, and destroy*. If you only expect new resources, *destroy should be 0*.

**How `terraform plan` works**
- Compares *desired state* and *current state*.
- Generates a plan to show exactly what will change.

**Plan symbols:**
- `+` Create -> New resource will be created.
- `~` Update in plance -> Existing resource will be modified.
- `-` Destroy -> Resource will be deleted.

---

### Terraform apply
- Command that actually makes changes to real infrastructure.
- Turns your *desired state* into reality.
- Important to prevent accidental or destructive changes, gives you one last safety check.
- *Always run `terraform plan` before `terraform apply`.

**What happens when you run it?**
1. Terraform creates an execution plan
2. Shows a summary (add / change / destroy)
3. Asks for confirmation (`yes`)
4. Applied the changes
5. Updates the *state file*

---

### Terraform destroy
- Safely removes all resources managed by terraform.
- Reads *configuration + state file*.
- Generates a *destruction plan*, prompts for confirmation.
- Updates the *state file* after deletion.

---

## Resource Block
- Defines a piece of infrastructure to manage.

- Structure: `resource "<TYPE>" "<NAME>" { ... }`
    - Example: `resource "aws_instance" "test" { ... }`

- *Key attributes for AWS EC2:*
- ami → Amazon Machine Image (OS template)
- instance_type → Hardware config (CPU/memory)
- tags → Labels for environment (dev, prod, staging)

---