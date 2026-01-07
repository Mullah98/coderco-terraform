# Terraform module notes

## IaC (Infrastructure as Code)
- Allows managing and deploying infrastructure through code instead of manual steps.
- Benefits: repeatable, version-controlled, scalable and reduces human error

---

## Terraform
- An open-source IaC tool by HashiCorp.
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

## Terraform Import
- Bring existing cloud resources into Terraform management without recreating them.
- Useful in production or when joining a project with pre-existing resources.
- Terraform does *not* generate the configuration automatically, you must write the resource block yourself.

**How to use terraform import**
1. Create a resource block in Terraform
    - in the .tf file add:
    resource "aws_instance" "my_instance" { 
        *AMI and instance_type are optional here; import will link the real resource*
    }
    - The **resource name (my_instance)** will be used in the import command
2. Copy the EC2 instance ID and copy it
3. Run Terraform import
    - `terraform import aws_instance.my_instance i-0abcd1234efg5678`
4. Verify with `terraform plan`
    - Should see *no changes planned* if your resource block matches the existing instance
5. Terraform now successfully manages your instance
    - Any future `terraform apply` will update or delete the instance according to your configuration

---

## Local Statefile vs Remote Statefile

|------|Local|Remote|
|-----|-------|------|
|Storage|Stored locally in your project directory|Centralized backend(eg:AWS, Terraform Cloud)|
|Best for|Single-user or small projects|Team projects, larger infrastructure, or CI/CD workflows|
|Benefits|Simple setup, no extra config needed, contained env|Collaboration, automatic locking, backup and security|
|Limitations|Risk of conflict if multiple people work on same infrastructure|--------|

- Start with *local state* for learning or solo projects. Move to *remote state* when working in teams or managing production infrastructure.

**EG: Terraform backend block for S3**
```
terraform {
  backend "s3" {
    bucket = "your-unique-bucket-name"   # Replace with your S3 bucket
    key    = "terraform/state.tfstate"   # Path inside the bucket
    region = "eu-west-1"                 # AWS region of your bucket
    encrypt = true                       # Optional: encrypt the state file
  }
}
```

---

## Terraform workflow

1. `terraform init`
- Initializes a working dir with Terraform config files
- Downloads provider pluging (for AWS, Azure), and configures the backend

2. `terraform validate`
- Checks your Terraform configuration files for syntax errors
- Ensures code is well-formed before planning or applying changes

3. `terraform plan`
- Compares current state with desired state
- Shows execution plan; what will be created, changes, or destroyed
- Verify changes before applying them

4. `terraform apply`
- Executes the plan to reach the desired state
- By default, scans the current dir for config files

5. `terraform destroy`
- Destroys all Terraform-managed infrastructure safely
- Prompts for confirmation

---

## Variables
- Used to parametarize Terraform configs.
- Make code reusable, flexible, and dynamic.
- Implements *DRY* principles (Don't Repeat Yourself).

**Defining input variables**
- Each variable has unique name, cannot use duplicate names.
- eg: ```variable "instance_type" {
            type = string
    }```

**Using variables in resources**
- `var.<variable_name>`
- eg: ```resource "aws_instance" "this" {
            ami = "ami-01ab234567cdef"
            instance_type = var.instance_type
        }```
- When running `terraform plan`, it will prompt for an *input*.

**Using default values**
- You can add a *default* value inside `variables.tf` file.
- If a default exits, Terraform *won't* prompt for input.
- eg: ```variable "instance_type" {
            type = string
            default = "t3.micro"
    }```
- Useful for testing, not ideal for real projects.

**Using `terraform.tfvars`**
- Avoid hardcoding defaults in `variables.tf`. Pass values to `terraform.tfvars` instead.
- Keeps configs clean and flexible.
- Terraform automatically loads this file, no CLI input required.

*Use variables.tf to define variables, and terraform.tfvars to supply values. Clean, scalable, and professional.*

**Using local variables**
- Used to store internal values inside Terraform.
- Useful for common tags, AMI IDs, naming patterns.
- Referenced using *local.* prefix
- eg: 
    - ```locals {
            instance_ami = "ami-01abc234567def"
        }
        ```
    - ```resource "aws_instance" "this" {
            ami = local.instance_ami
        }
        ```

**Using output variables**
- Use to display values after `terraform apply`.
- Used for resource IDs, Public/private IPs, ARNS.
- Useful for debugging, automation, passing values to other Terraform configs.

**Variable precedence (lowest -> highest)
1. *Default values*
2. *`.tfvars` files*
3. *Environment variables (TF_VAR_name)*
4. *CLI flags (-var="name=value")*

*Higest priority always wins*

**Variable types**
- `string` -> text (`"t3.micro"`)
- `number` -> integer & decimals (`42`, `8.34`)
- `bool` -> `true` / `false`

*Complex variable types**
- `list`
- `map` -> key-value pairs
- `object` -> mixed types

---

## Terraform Modules
- A module is a collection of Terraform files grouped together.
- Every Terraform folder is a *module* by default; called the **Root module**.

- **Why it matters?:**
    - *Reusability*
    - *DRY Principle*
    - *Consistency*
    - *Collaboration*

- **Things to NEVER hardcode in Modules:**
    - AMI IDs
    - Instance types
    - Regions
    - Environment-specific values
- Better to pass these in variables.

*Terraform modules allow you to package reusable infrastructure code, enforce consistency across environments, and make collaboration easier by exposing well-defined inputs and outputs.*

- `modules/EC2/` -> define the EC2 module.
- `main.tf` -> a root file that calls the EC2 module using a `module` block
- Without having `main.tf`, a module would just be a template. We need to actually call it.
- If you move resources into a module *without* calling it, Terraform thinks they are removed. It plans to *destroy* them.
- example of `main.tf`:
    - ```
        module "ec2" {
            source = "./modules/ec2"
        }
    ```

---