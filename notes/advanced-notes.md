## Terraform Advanced

**Count Meta Argument**
- Creates multiple identical resources from a single block.
- Use count = N to create N instances.
- `count.index` gives each resource a unique index (useful for tags).

```
resource "aws_instance" "example" {
  count = 2
  ami           = "ami-123"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance-${count.index + 1}"
  }
}
```
---

**for_each**
- Used to create multiple resources with different configs.
- Best when each resource needs unique values (tags, AMI, size, etc.).
- Works with maps or sets, not plain numbers like count.
- Use `each.key` and `each.value` inside the resource.

### Example:
```
locals {
  instances = {
    dev1 = { ami = "ami-111", type = "t2.micro" }
    dev2 = { ami = "ami-222", type = "t2.small" }
    dev3 = { ami = "ami-333", type = "t3.micro" }
  }
}

resource "aws_instance" "example" {
  for_each = local.instances

  ami           = each.value.ami
  instance_type = each.value.type

  tags = {
    Name = each.key
  }
}
```

*count → identical resources*
*for_each → different configs per resource*

---

**`coalesce()` Function**
- Returns the **first value that is not `null` or empty**.
- Commonly used to **set defaults** and **prioritise inputs**.
- All arguments **must be the same type**.
- If all values are empty or null → returns `null`.

### **Basic default value example**
```
variable "name" {
  type    = string
  default = null
}

locals {
  instance_name = coalesce(var.name, "default-name")
}
```

* Uses `var.name` if provided
* Falls back to `"default-name"` if not

---

### **Safe lookup + fallback (very common pattern)**

```
locals {
  description = coalesce(
    lookup(var.tags, "description", null),
    "no-description"
  )
}
```

- `lookup` avoids errors if key is missing
- `coalesce` ensures a safe default

---

### **Prioritising multiple sources**
```
locals {
  setting = coalesce(
    try(jsondecode(file("config.json")).setting, null),
    lookup(var.env_settings, "setting", null),
    "default-value"
  )
}
```

Priority:
1. `config.json`
2. environment map
3. default value

---

**When to use**
- Optional variables
- Missing map keys
- Multiple config sources

---

**`merge()` Function**
- Combines **multiple maps into one**.
- Commonly used for **tags** and shared config.
- If the same key exists multiple times → **last map wins**.
- Keeps configs **DRY** and environment-aware.

**Basic tag merge example:**
```
locals {
  default_tags = {
    ManagedBy = "Terraform"
    Team      = "Engineering"
  }

  env_tags = {
    Environment = "dev"
    Team        = "Platform"
  }

  final_tags = merge(local.default_tags, local.env_tags)
}
```

**Result:**
```
{
  ManagedBy   = "Terraform"
  Environment = "dev"
  Team        = "Platform"
}
```

(`Team` overridden by the last map)


**Using merged tags on a resource**
```
resource "aws_instance" "example" {
  ami           = "ami-123"
  instance_type = "t2.micro"

  tags = local.final_tags
}
```

**When to use**

* Default + environment tags
* Dev / prod overrides
* Shared base config with custom tweaks

---


**Conditionals (Ternary Operator)**

```
condition ? true_value : false_value
```

Used to change values, create resources, or toggle config **without duplicating code**.

---

**1. Conditional values (instance type)**

```
variable "environment" {
  default = "dev"
}

resource "aws_instance" "example" {
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
}
```

* `prod` → `t3.large`
* anything else → `t3.micro`

---

**2. Conditional resource creation**

```
resource "aws_eip" "example" {
  count = var.environment == "prod" ? 1 : 0
}
```

* Created **only in prod**
* `count = 0` = resource not created

---

**3. Conditionals in `locals` (cleaner configs)**

```
variable "is_high_priority" {
  default = false
}

locals {
  instance_type = var.is_high_priority ? "t3.large" : "t2.micro"
  extra_tags    = var.is_high_priority ? { Priority = "high" } : {}
}
```

```
resource "aws_instance" "example" {
  instance_type = local.instance_type
  tags          = merge({ Name = "app" }, local.extra_tags)
}
```

---

**4. Conditional dynamic blocks**

```
variable "enable_ssh" {
  default = false
}

dynamic "ingress" {
  for_each = var.enable_ssh ? [1] : []
  content {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

- SSH rule only added when `enable_ssh = true`

---

**5. Combining conditionals**

```
count = var.environment == "prod"
  ? (var.is_high_priority ? 3 : 2)
  : 1
```

- `prod + high priority` → 3
- `prod only` → 2
- `dev` → 1

**When to use**

- Environment-based config (dev vs prod)
- Optional resources (EIP, SSH, extras)
- Cost control
- Cleaner, reusable Terraform

---

**`concat` – Joining Lists**
- `concat()` joins **multiple lists into one**.
- Works only with **lists**
- You can pass **more than two lists**

**Basic example:**
```
locals {
  list_one = ["dev", "test"]
  list_two = ["prod", "staging"]

  merged_list = concat(local.list_one, local.list_two)
}
```

**Result:**
```
["dev", "test", "prod", "staging"]
```

---

**`file()` – Managing Files (User Data)**
- `file()` lets Terraform **read the contents of a file** and pass it into a resource.
- Most common use: **EC2 `user_data`**

**Example structure:**
```
.
├── main.tf
└── user-data.sh
```

**user-data.sh**
```
#!/bin/bash
echo "Hello from user data"
```

**Terraform usage**
```
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  user_data = file("${path.module}/user-data.sh")
}
```

---

**Template Files (`templatefile`)**
- `templatefile()` lets you **inject variables into a file** before passing it to a resource (like `user_data`).

**Template file (user-data.tpl)**
```
#!/bin/bash
echo "Server will start on port ${server_port}"
```

**Terraform usage**
```
user_data = templatefile("${path.module}/user-data.tpl", {
  server_port = var.server_port
})
```

---

**For Expressions (Loops)**
```
variable "regions" {
  default = ["us-east-1", "us-west-2"]
}

locals {
  env_regions = [
    for r in var.regions : "${r}-dev"
  ]
}
```

**Result:**
`["us-east-1-dev", "us-west-2-dev"]`

---

**Upper / Lower (String Helpers)**

- `upper()` → converts string to uppercase
- `lower()` → converts string to lowercase
- Often combined with loops and `join()`

```
variable "words" {
  default = ["hello", "terraform"]
}

locals {
  result = join("-", [
    for w in var.words : upper(w)
  ])
}
```

**Result:**
`HELLO-TERRAFORM`

---

**Terraform – `can()` Function**
- Safely checks if an expression will **fail**
- Returns `true` or `false` instead of crashing Terraform
- Commonly used with `jsondecode()`

```
locals {
  is_valid_json = can(jsondecode(var.possible_json))
}
```

---

**Terraform – `slice()` (Lists)**
- Extracts part of a list
- End index is **exclusive**

```
locals {
  first_two = slice(var.my_list, 0, 2)
}
```

**Example:**
`["apple", "banana", "cherry"] → ["apple", "banana"]`

---
