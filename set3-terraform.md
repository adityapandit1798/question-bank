## ✨ State Management

### 1. What are the problems with local state?
**[Conceptual]**
**Sample Answer:**
> "Local state (`terraform.tfstate` on disk) creates collaboration issues because only one person can have the file. It lacks locking, leading to race conditions if two people run apply simultaneously. It's also a security risk if the state contains secrets, as it's stored in plaintext on local drives. Finally, it breaks CI/CD pipelines which need a centralized state source."
**Key Points:**
- No collaboration (single user)
- No state locking (race conditions)
- Security risk (plaintext secrets)
- CI/CD incompatible

### 2. What is remote backend in Terraform?
**[Conceptual]**
**Sample Answer:**
> "A remote backend stores the state file in a centralized cloud storage like AWS S3 instead of locally. This enables team collaboration, versioning of state files, and integration with CI/CD pipelines. The most common pattern is S3 for storage + DynamoDB for locking."
**Key Points:**
- Centralized storage (e.g., S3, GCS, Azure Blob)
- Enables team collaboration
- Required for CI/CD
- Supports encryption & versioning

### 3. How do you store state securely?
**[Conceptual]**
**Sample Answer:**
> "I enable server-side encryption (SSE-S3 or SSE-KMS) on the S3 bucket. I enforce strict IAM policies so only specific roles (like the CI/CD runner) can access the bucket. I also enable S3 Versioning to recover from accidental corruption, and block public access entirely."
**Key Points:**
- S3 Server-Side Encryption (SSE-KMS preferred)
- Strict IAM policies (Least Privilege)
- S3 Versioning enabled
- Block public access

### 4. What happens if the state file is deleted accidentally?
**[Scenario]**
**Sample Answer:**
> "If versioning is enabled on the S3 bucket, I can restore the previous version immediately. If not, Terraform loses track of existing resources. I'd have to manually re-import them using `terraform import` to rebuild the state map without recreating the infrastructure. This is why I always enforce versioning and backup policies."
**Key Points:**
- Restore from S3 Versioning (if enabled)
- Otherwise: `terraform import` to rebuild state
- Resources still exist in AWS, just untracked
- Prevention: Versioning + Backup scripts

### 5. How do you recover a lost state file?
**[Scenario]**
**Sample Answer:**
> "First, check S3 versioning for a previous valid state. If unavailable, I'd document all existing resources in AWS, then use `terraform import` to bring them back under management one by one. For large environments, I might use tools like `terraformer` to automate the import process, then validate with `terraform plan`."
**Key Points:**
- Priority 1: S3 Versioning restore
- Priority 2: `terraform import`
- Tooling: `terraformer` for bulk import
- Validate with `terraform plan`

### 6. What is state locking?
**[Conceptual]**
**Sample Answer:**
> "State locking prevents concurrent operations on the same state file. When I run `terraform apply`, Terraform acquires a lock (usually via DynamoDB). If someone else tries to run apply, they get an error until the lock is released. This prevents state corruption from race conditions."
**Key Points:**
- Prevents concurrent writes
- Mechanism: DynamoDB (AWS)
- Prevents state corruption
- Auto-releases on completion/failure

### 7. How does Terraform handle concurrent runs?
**[Conceptual]**
**Sample Answer:**
> "Through state locking. If a lock is held, subsequent runs fail immediately with a 'lock acquired' error. In CI/CD, I configure pipelines to queue builds or fail fast if the state is locked, ensuring serial execution of infrastructure changes."
**Key Points:**
- Lock mechanism blocks second run
- CI/CD should handle lock failures (retry/queue)
- Ensures serial execution
- Prevents race conditions

---

## ✨ Environment Management

### 8. How do you manage multiple environments (Dev, QA, Prod)?
**[Conceptual]**
**Sample Answer:**
> "I prefer the **directory structure approach** over workspaces for strict isolation. I create separate folders (`env/dev`, `env/prod`) with their own state files and backend configurations. This ensures Prod changes never accidentally affect Dev state and allows different provider versions or modules per env if needed."
**Key Points:**
- Preferred: Directory structure (`env/dev`, `env/prod`)
- Alternative: Terraform Workspaces
- Directory allows full isolation (state, providers, modules)
- Workspaces share code/state logic (riskier for Prod)

### 9. What are Terraform workspaces?
**[Conceptual]**
**Sample Answer:**
> "Workspaces allow multiple state files from the same configuration. It's useful for personal dev environments or testing variations of the same infra. However, I avoid them for Prod vs. Dev separation because they share the same code base, making it harder to enforce different policies or module versions."
**Key Points:**
- Multiple states from one config
- Good for: Personal dev, temporary testing
- Bad for: Strict Env isolation (Dev vs Prod)
- Shared code = shared risk

### 10. When should you avoid using workspaces?
**[Conceptual]**
**Sample Answer:**
> "Avoid workspaces when environments need different provider versions, different module versions, or strict IAM separation. Also avoid if you need different backend configurations (e.g., different KMS keys for encryption) per environment."
**Key Points:**
- Different provider/module versions needed
- Strict IAM/Security separation required
- Different backend configs needed
- Complex state isolation required

### 11. How do you handle environment-specific variables?
**[Conceptual]**
**Sample Answer:**
> "I use separate `.tfvars` files for each environment (e.g., `dev.tfvars`, `prod.tfvars`). In CI/CD, I pass the specific file using `-var-file=env/prod.tfvars`. Sensitive variables are pulled from AWS Secrets Manager or SSM Parameter Store via data sources, not stored in files."
**Key Points:**
- Separate `.tfvars` files
- CLI flag: `-var-file`
- Secrets: AWS Secrets Manager/SSM
- Never commit sensitive `.tfvars` to git

### 12. How do you structure Terraform code for multiple environments?
**[Conceptual]**
**Sample Answer:**
> "I use a modular structure. Common resources go into a `modules/` directory. The root level has an `environments/` folder containing `dev/`, `qa/`, and `prod/`. Each env folder calls the modules with specific variables. This keeps code DRY (Don't Repeat Yourself) while maintaining state isolation."
**Key Points:**
- `modules/` for reusable code
- `environments/` for state isolation
- DRY principle
- Clear separation of concerns

---

## ✨ Advanced Resource Control

### 13. How do you prevent resource deletion in Terraform?
**[Conceptual]**
**Sample Answer:**
> "I use the `lifecycle` block with `prevent_destroy = true`. This is critical for databases or stateful resources where accidental `terraform destroy` could be catastrophic. It forces a manual removal of the lifecycle block before deletion."
**Key Points:**
- `lifecycle { prevent_destroy = true }`
- Protects critical resources (DBs, Storage)
- Requires code change to delete
- Safety net against human error

### 14. What is lifecycle block?
**[Conceptual]**
**Sample Answer:**
> "The `lifecycle` block customizes Terraform's behavior for specific resources. It controls creation order (`create_before_destroy`), prevents deletion (`prevent_destroy`), and ignores specific changes (`ignore_changes`) like tags managed by external tools."
**Key Points:**
- Customizes resource behavior
- `prevent_destroy`, `create_before_destroy`, `ignore_changes`
- Manages dependency order
- Handles external modifications

### 15. What is create_before_destroy?
**[Conceptual]**
**Sample Answer:**
> "It ensures zero-downtime updates. Terraform creates the new resource first, updates dependencies to point to it, and then destroys the old one. Essential for load balancers or databases where downtime is unacceptable."
**Key Points:**
- Zero-downtime deployment
- New resource created before old is deleted
- Essential for critical services
- May incur temporary double costs

### 16. What is prevent_destroy?
**[Conceptual]**
**See Q13.** (Focus on safety for stateful resources).

### 17. How do you modify only tags without recreating the resource?
**[Conceptual]**
**Sample Answer:**
> "Most AWS resources support tag updates without replacement. If Terraform plans a replacement due to tags, I check the provider documentation. Usually, I can use `lifecycle { ignore_changes = [tags] }` if tags are managed externally (like by AWS Backup), but normally tags are mutable attributes."
**Key Points:**
- Tags are usually mutable
- Check provider docs if replacement triggered
- `ignore_changes` if external tool manages tags
- Avoid forcing `ForceNew` on tags

### 18. Why does Terraform plan show resource replacement?
**[Scenario]**
**Sample Answer:**
> "Replacement happens when an immutable property changes (e.g., EC2 Instance Type, AMI ID, Subnet). Terraform cannot update these in-place, so it plans to destroy and recreate. I check the plan carefully to ensure this is expected, especially for stateful resources."
**Key Points:**
- Immutable properties changed (AMI, Type, Subnet)
- Provider forces `ForceNew`
- Risk of data loss for stateful resources
- Always review plan before apply

---

## ✨ AWS + Terraform

### 19. What parameters do you consider while creating an EC2 using Terraform?
**[Conceptual]**
**Sample Answer:**
> "Key parameters: `ami` (data source lookup), `instance_type`, `subnet_id`, `vpc_security_group_ids`, `iam_instance_profile`, `key_name` (or SSM), `user_data`, and `root_block_device` for storage config. I also add tags for cost allocation."
**Key Points:**
- AMI, Instance Type, Subnet
- Security Groups, IAM Role
- User Data, Storage config
- Tags for governance

### 20. How do you create EC2 in a specific VPC and subnet?
**[Coding]**
**Sample Answer:**
> "I pass the `subnet_id` argument in the `aws_instance` resource. The VPC is implied by the subnet."
```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t3.micro"
  subnet_id     = "subnet-123456" # Determines VPC
}
```
**Key Points:**
- `subnet_id` determines VPC
- Use data sources to lookup subnet IDs dynamically

### 21. How do you attach Security Groups to EC2?
**[Coding]**
**Sample Answer:**
> "I use the `vpc_security_group_ids` argument with a list of SG IDs."
```hcl
resource "aws_instance" "web" {
  # ...
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}
```
**Key Points:**
- Argument: `vpc_security_group_ids` (list)
- Can attach multiple SGs
- Ensure SG allows required traffic

### 22. How do you attach an IAM role to EC2?
**[Coding]**
**Sample Answer:**
> "I create an `aws_iam_instance_profile` and reference it in the EC2 resource."
```hcl
resource "aws_iam_instance_profile" "ec2_profile" {
  role = aws_iam_role.ec2_role.name
}
resource "aws_instance" "web" {
  # ...
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
}
```
**Key Points:**
- Requires `aws_iam_instance_profile`
- Reference profile name in EC2
- Least privilege role policy

### 23. How do you run scripts during EC2 creation?
**[Coding]**
**Sample Answer:**
> "I use the `user_data` argument with a base64-encoded script or heredoc."
```hcl
resource "aws_instance" "web" {
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              EOF
}
```
**Key Points:**
- `user_data` argument
- Runs on first boot only
- Use `user_data_replace_on_change` if updates needed

### 24. How do you provision EBS volumes using Terraform?
**[Coding]**
**Sample Answer:**
> "I define `aws_ebs_volume` and attach it using `aws_volume_attachment`."
```hcl
resource "aws_ebs_volume" "data" {
  availability_zone = "us-east-1a"
  size              = 10
}
resource "aws_volume_attachment" "data_attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.web.id
}
```
**Key Points:**
- Separate resource `aws_ebs_volume`
- Attach via `aws_volume_attachment`
- Manage lifecycle carefully (prevent destroy)

### 25. How do you change EBS volume type (gp3 → io1)?
**[Conceptual]**
**Sample Answer:**
> "I simply update the `type` argument in the `aws_ebs_volume` resource. Terraform calls the AWS ModifyVolume API. No replacement is needed, and data is preserved."
**Key Points:**
- Update `type` argument
- No resource replacement
- AWS handles migration in background
- Check IOPS limits for target type

### 26. Will data be lost when modifying EBS type?
**[Conceptual]**
**Sample Answer:**
> "No. AWS preserves data during volume type modification. However, I always take a snapshot before making changes via Terraform as a safety precaution."
**Key Points:**
- Data is preserved
- AWS ModifyVolume API
- Best practice: Snapshot before change
- Monitor status until "optimized"

---

## ✨ Security & Secrets

### 27. How do you handle secrets in Terraform?
**[Conceptual]**
**Sample Answer:**
> "Never store secrets in code or `.tfvars`. I use AWS Secrets Manager or SSM Parameter Store. Terraform retrieves them at runtime using `data` sources. In CI/CD, I inject secrets as environment variables."
**Key Points:**
- Never commit secrets to Git
- Use AWS Secrets Manager / SSM
- Retrieve via `data` sources
- CI/CD: Env vars or OIDC

### 28. How do you integrate Terraform with AWS Secrets Manager?
**[Coding]**
**Sample Answer:**
> "I use the `aws_secretsmanager_secret_version` data source."
```hcl
data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "prod/db/credentials"
}
# Access via JSON parse
```
**Key Points:**
- `data "aws_secretsmanager_secret_version"`
- Parse JSON output
- IAM role needs `secretsmanager:GetSecretValue`

### 29. How do you prevent secrets from leaking into logs?
**[Conceptual]**
**Sample Answer:**
> "I mark variables and outputs as `sensitive = true`. This masks them in CLI output and state logs. I also ensure CI/CD pipelines mask sensitive environment variables."
**Key Points:**
- `sensitive = true` in variable/output blocks
- Masks CLI output
- CI/CD masking required
- Audit CloudTrail for access

### 30. How do you mark outputs as sensitive?
**[Coding]**
**Sample Answer:**
> "Add `sensitive = true` to the output block."
```hcl
output "db_password" {
  value     = data.aws_secretsmanager_secret_version.db_creds.secret_string
  sensitive = true
}
```
**Key Points:**
- `sensitive = true`
- Hides value in `terraform output`
- Still visible in state file (encrypt state!)

---

## ✨ Troubleshooting & Debugging

### 31. Terraform plan shows unexpected changes — how do you debug?
**[Scenario]**
**Sample Answer:**
> "I check for state drift (manual changes in console). I review provider version changes that might alter defaults. I also check if `ignore_changes` is needed for attributes managed by external systems. Running `terraform refresh` (implicit in plan) helps sync state."
**Key Points:**
- Check for manual drift
- Provider version differences
- Use `ignore_changes` if external management
- Review diff carefully

### 32. Terraform apply fails midway - what happens to resources?
**[Scenario]**
**Sample Answer:**
> "Resources created before the failure remain running but might not be fully configured. The state file is updated with what succeeded. I fix the error and run `apply` again; Terraform will continue from where it left off. I always check for partial resources manually."
**Key Points:**
- Partial success possible
- State reflects successful resources
- Re-run `apply` to continue
- Check for orphaned resources

### 33. How do you import existing resources into Terraform?
**[Conceptual]**
**Sample Answer:**
> "I define the resource block in code first, then run `terraform import <address> <id>`. For example: `terraform import aws_instance.web i-123456`. Then I run `plan` to ensure the code matches the real resource."
**Key Points:**
- Define resource in code first
- Command: `terraform import`
- Run `plan` to verify no drift
- Use `import` block (TF 1.5+) for config-driven import

### 34. What is terraform taint?
**[Conceptual]**
**Sample Answer:**
> "`terraform taint` marks a resource for recreation in the next apply. It's deprecated now; the preferred method is `terraform apply -replace='aws_instance.web'`. I use this when a resource is in a broken state but still exists."
**Key Points:**
- Marks resource for recreation
- Deprecated: Use `-replace` flag
- Useful for broken resources
- Forces destroy/create cycle

### 35. What is terraform refresh?
**[Conceptual]**
**Sample Answer:**
> "It updates the state file with the real-world state of infrastructure without modifying resources. In newer Terraform versions, this happens automatically during `plan`. I rarely run it standalone unless debugging state drift."
**Key Points:**
- Syncs state with real infra
- Automatic in `plan` now
- Debugging tool for drift
- Does not change infrastructure

---

## ✨ CI/CD Integration

### 36. How do you use Terraform in Jenkins pipelines?
**[Conceptual]**
**Sample Answer:**
> "I use shell steps: `terraform init`, `terraform plan -out=plan.out`, `terraform apply plan.out`. I store the plan artifact to ensure what was reviewed is what gets applied. Credentials are injected via Jenkins Credentials Binding."
**Key Points:**
- Stages: Init → Plan → Apply
- Save plan artifact (`-out`)
- Inject credentials securely
- Use Docker agent with TF installed

### 37. How do you manage Terraform state in CI/CD?
**[Conceptual]**
**Sample Answer:**
> "Always use remote backend (S3). CI/CD runners should not store state locally. I ensure the CI role has IAM permissions to lock/unlock state in DynamoDB and read/write to S3."
**Key Points:**
- Remote backend mandatory
- IAM permissions for S3/DynamoDB
- No local state on runners
- Clean up workspace after job

### 38. How do you ensure safe Terraform apply in production?
**[Conceptual]**
**Sample Answer:**
> "I enforce a manual approval gate between Plan and Apply. The plan output is posted to a PR or Slack for review. Only senior engineers can approve the apply step. I also use `prevent_destroy` lifecycle rules for critical resources."
**Key Points:**
- Manual approval gate
- Plan review required
- Restrict who can apply (IAM/Policy)
- Lifecycle protections

### 39. How do you implement approval before Terraform apply?
**[Conceptual]**
**Sample Answer:**
> "In Jenkins, I use the `input` step. In GitHub Actions, I use Environment Protection Rules. In Atlantis, I use `Approve` comments on the PR. The pipeline pauses until approval is given."
**Key Points:**
- Jenkins: `input` step
- GitHub: Environment Protection Rules
- Atlantis: Comment approval
- Pause pipeline until human action

---

## 💥 Advanced Screen-Sharing / Coding Questions

### 40. Create an EC2 module & Reuse it (Folder Structure)
**[Coding]**
**Sample Answer:**
> "I structure modules to be reusable via variables."
**Folder Structure:**
```text
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   └── main.tf  (calls module)
│   └── prod/
│       └── main.tf  (calls module)
```
**Module Usage (`environments/dev/main.tf`):**
```hcl
module "web_server" {
  source = "../../modules/ec2"
  instance_type = "t3.micro"
  env = "dev"
}
```

### 41. Terraform backend configuration (S3 + DynamoDB)
**[Coding]**
**Sample Answer:**
> "This goes in the `backend` block of the Terraform config."
```hcl
terraform {
  backend "s3" {
    bucket         = "my-tf-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-state-lock"
  }
}
```

### 42. Use different state files for dev and prod
**[Coding]**
**Sample Answer:**
> "I use different `key` paths in the backend config per environment."
```hcl
# In environments/dev/main.tf
key = "dev/terraform.tfstate"

# In environments/prod/main.tf
key = "prod/terraform.tfstate"
```
**Key Points:**
- Separate `key` paths
- Ensures state isolation
- Can also use separate buckets for higher security

### 43. Run a shell script during EC2 creation (remote-exec)
**[Coding]**
**Sample Answer:**
> "I use the `remote-exec` provisioner (requires SSH access)."
```hcl
resource "aws_instance" "web" {
  # ...
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
    inline = [
      "sudo yum install -y httpd",
      "sudo systemctl start httpd"
    ]
  }
}
```
**Pro Tip:** Mention you prefer `user_data` or Ansible over provisioners for production reliability.

### 44. Copy a file to EC2 using file provisioner
**[Coding]**
**Sample Answer:**
```hcl
resource "aws_instance" "web" {
  # ...
  provisioner "file" {
    source      = "config/app.conf"
    destination = "/etc/app/app.conf"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}
```

### 45. Prevent accidental deletion of an EC2 instance
**[Coding]**
**Sample Answer:**
```hcl
resource "aws_instance" "web" {
  # ...
  lifecycle {
    prevent_destroy = true
  }
}
```

### 46. Replace resource without downtime
**[Coding]**
**Sample Answer:**
```hcl
resource "aws_instance" "web" {
  # ...
  lifecycle {
    create_before_destroy = true
  }
}
```

### 47. Create an EBS volume & Attach it
**[Coding]**
**See Q24.** (Use `aws_ebs_volume` + `aws_volume_attachment`).

### 48. Modify EBS volume type without data loss
**[Coding]**
**Sample Answer:**
> "Simply update the type. Terraform handles the API call safely."
```hcl
resource "aws_ebs_volume" "data" {
  # ...
  type = "gp3" # Change from gp2 to gp3
  # IOPS/Throughput might need adjustment
}
```
**Key Points:**
- No replacement triggered
- Data persists
- Monitor AWS console for optimization complete
