Perfect! Here are your **interview-ready answers** for Question Set 1 (EC2 Focus), tailored for a **Cloud DevOps Engineer with 4 YOE**. Each answer includes what they're testing, a concise sample response, key revision bullets, and a pro tip.

---

### 1. How do you troubleshoot high CPU usage in an EC2 instance?
**[Scenario]**  
**What They're Testing:** Observability, debugging methodology, AWS tooling proficiency.  
**Sample Answer:**  
> "First, I'd check CloudWatch metrics for CPU utilization trends to confirm if it's sustained or spiky. Then I'd SSH into the instance and use `top` or `htop` to identify the process consuming CPU. If it's an application issue, I'd check app logs; if it's system-level, I'd look at `dmesg` or `journalctl`. For deeper analysis, I might use AWS Systems Manager Session Manager for access without SSH, or enable CloudWatch Agent for detailed process-level metrics. If the instance is part of an ASG, I'd also check if scaling policies are triggered appropriately."  

**Key Points:**  
- CloudWatch → `top`/`htop` → logs → SSM Session Manager  
- Differentiate app vs. system processes  
- Check ASG scaling policies if applicable  
- Use CloudWatch Agent for granular metrics  

**Pro Tip:** Mention you'd set up a CloudWatch Alarm with SNS notification for proactive alerting next time—shows forward-thinking.

---

### 2. How do you recover a stopped EC2 instance that won't start?
**[Scenario]**  
**What They're Testing:** Incident response, understanding of EC2 lifecycle, root cause analysis.  
**Sample Answer:**  
> "First, I'd check the instance status checks and system logs in the EC2 console to identify the failure reason—common causes include corrupted EBS volumes, insufficient capacity in the AZ, or IAM permission issues. If it's an EBS issue, I'd detach the root volume, attach it to a recovery instance, repair the filesystem, and reattach. If it's an AZ capacity issue, I'd modify the instance to launch in a different AZ. For persistent issues, I'd restore from the latest AMI or snapshot."  

**Key Points:**  
- Check Status Checks & System Logs first  
- Common causes: EBS corruption, AZ capacity, IAM roles  
- Recovery pattern: detach root volume → repair on helper instance  
- Fallback: restore from AMI/snapshot  

**Pro Tip:** Always mention you'd document the RCA and update runbooks—shows operational maturity.

---

### 3. How do you resize an EC2 instance without downtime?
**[Scenario]**  
**What They're Testing:** High availability design, zero-downtime deployment strategies.  
**Sample Answer:**  
> "For true zero downtime, I wouldn't resize the instance in-place. Instead, I'd use a blue-green approach: launch a new instance with the desired type in the same ASG or behind a load balancer, validate health, then shift traffic using ALB target groups or Route53 weighted routing. Once traffic is migrated, I'd terminate the old instance. If the instance isn't behind a load balancer, I'd use AWS Systems Manager Automation documents to perform a controlled resize with minimal interruption, but some brief downtime may be unavoidable."  

**Key Points:**  
- True zero-downtime requires load balancer + ASG  
- Blue-green deployment pattern is safest  
- In-place resize requires stop/start = downtime  
- SSM Automation can minimize but not eliminate downtime  

**Pro Tip:** Clarify that "no downtime" depends on architecture—shows you think in systems, not just commands.

---

### 4. How do you attach and mount a new EBS volume to an EC2 instance?
**[Conceptual]**  
**What They're Testing:** Linux storage management, AWS EBS operations.  
**Sample Answer:**  
> "First, I'd create and attach the EBS volume via AWS Console/CLI to the target instance. Then, SSH in and run `lsblk` to identify the new device (e.g., `/dev/xvdf`). Next, I'd format it with `mkfs -t ext4 /dev/xvdf` (if new), create a mount point like `/data`, and mount it with `mount /dev/xvdf /data`. To persist across reboots, I'd add an entry to `/etc/fstab` using the UUID from `blkid`. Finally, I'd set appropriate permissions with `chown`."  

**Key Points:**  
- Attach via AWS → `lsblk` → format (`mkfs`) → mount → update `/etc/fstab`  
- Use UUID in fstab, not device name (prevents boot issues)  
- For existing volumes: skip format, mount directly  

**Pro Tip:** Mention you'd test fstab with `mount -a` before rebooting—avoids boot failures.

---

### 5. How do you create a custom AMI from an EC2 instance?
**[Conceptual]**  
**What They're Testing:** Image management, infrastructure as code practices.  
**Sample Answer:**  
> "I'd first ensure the instance is in a clean state—stop non-essential services, clear logs/temp files. Then, using the AWS Console or CLI (`create-image`), I'd create an AMI with a descriptive name and tags. I'd enable 'No Reboot' only if I'm certain the filesystem is consistent, otherwise allow reboot for safety. Post-creation, I'd copy the AMI to other regions if needed, and update my Terraform/CloudFormation templates to reference the new AMI ID."  

**Key Points:**  
- Clean instance state before imaging  
- Use `create-image` CLI or Console  
- Prefer reboot=true for filesystem consistency  
- Tag AMIs and copy cross-region for DR  

**Pro Tip:** Mention using EC2 Image Builder for automated, compliant AMI pipelines—shows modern DevOps practice.

---

### 6. How do you recover deleted data from an EC2 instance?
**[Scenario]**  
**What They're Testing:** Backup strategy knowledge, disaster recovery mindset.  
**Sample Answer:**  
> "If the data was on an EBS volume and we have snapshots, I'd create a new volume from the latest snapshot, attach it to a recovery instance, and mount it to extract the files. If no snapshots exist, recovery is extremely limited—Linux `extundelete` or `testdisk` might work if the filesystem wasn't overwritten, but this is unreliable. This scenario reinforces why I always enforce snapshot policies via AWS Backup or Lambda scripts, and test restores regularly."  

**Key Points:**  
- Primary recovery path: restore from EBS snapshot  
- Filesystem-level tools (`extundelete`) are last-resort & unreliable  
- Prevention > cure: enforce snapshot policies  
- Test restores periodically  

**Pro Tip:** Emphasize that you design systems assuming deletion will happen—shows resilience thinking.

---

### 7. How do you handle EC2 key pair loss?
**[Scenario]**  
**What They're Testing:** Access management, security protocols, contingency planning.  
**Sample Answer:**  
> "If we lose the private key, we can't recover it—AWS doesn't store it. My approach: First, if SSM Session Manager is enabled, I'd use that for access without SSH keys. If not, I'd stop the instance, detach the root EBS volume, attach it to a helper instance, chroot into it, and add a new public key to `~/.ssh/authorized_keys`. Then reattach and restart. To prevent recurrence, I'd enforce SSM Session Manager for all instances and store key pairs in AWS Secrets Manager with rotation."  

**Key Points:**  
- Private keys are not recoverable from AWS  
- Recovery: detach root volume → modify authorized_keys on helper instance  
- Prevention: use SSM Session Manager + Secrets Manager  
- Document key pair inventory and rotation policy  

**Pro Tip:** Mention you'd audit IAM policies to ensure only authorized users can modify instance credentials—shows security-first mindset.

---

### 8. How do you connect to EC2 through a Bastion host?
**[Conceptual]**  
**What They're Testing:** Network security, SSH tunneling, least-privilege access.  
**Sample Answer:**  
> "I'd use SSH agent forwarding or a ProxyCommand. For example: `ssh -A -i key.pem ec2-user@bastion-public-ip` then from bastion `ssh ec2-user@private-instance-ip`. Better yet, I'd use `ssh -o ProxyCommand="ssh -W %h:%p -i bastion-key.pem ec2-user@bastion-ip" -i app-key.pem ec2-user@private-ip` for one-liner access. In modern setups, I prefer AWS Systems Manager Session Manager which eliminates SSH/Bastion entirely by using IAM policies for access."  

**Key Points:**  
- SSH agent forwarding or ProxyCommand syntax  
- Bastion must be in public subnet with strict SG rules  
- Prefer SSM Session Manager for auditability & no open ports  
- Use IAM policies to control who can start sessions  

**Pro Tip:** Mention you'd log all bastion access via CloudTrail + VPC Flow Logs—shows compliance awareness.

---

### 9. How do you troubleshoot slow SSH connections to EC2?
**[Scenario]**  
**What They're Testing:** Network debugging, SSH configuration knowledge.  
**Sample Answer:**  
> "I'd start by checking network latency with `mtr` or `ping` from my machine to the instance. Then verify security groups allow port 22 from my IP. On the instance, I'd check `/var/log/secure` or `journalctl -u sshd` for delays. Common causes: DNS reverse lookup delays (fix with `UseDNS no` in sshd_config), high load on instance, or intermediate network issues. I'd also test with `ssh -v` for verbose output to pinpoint where it hangs."  

**Key Points:**  
- Test network path: `mtr`, `ping`, `traceroute`  
- Check SSH logs: `/var/log/secure`, `journalctl`  
- Disable `UseDNS` in sshd_config to skip reverse lookups  
- Use `ssh -v` for connection debugging  

**Pro Tip:** Mention you'd consider AWS PrivateLink or SSM Session Manager to bypass public internet SSH entirely—shows architectural thinking.

---

### 10. How do you schedule EC2 instances to stop/start automatically?
**[Conceptual]**  
**What They're Testing:** Cost optimization, automation skills, AWS service integration.  
**Sample Answer:**  
> "I'd use Amazon EventBridge (CloudWatch Events) to trigger a Lambda function on a cron schedule. The Lambda function would use boto3 to call `stop_instances` or `start_instances` APIs for tagged instances (e.g., `Schedule=Dev`). For more complex logic, I'd use AWS Systems Manager Automation documents. I always tag resources clearly and test the Lambda in a non-prod environment first. For ASG-managed instances, I'd adjust the desired capacity instead of stopping individual instances."  

**Key Points:**  
- EventBridge + Lambda is serverless & scalable  
- Tag-based targeting for flexibility  
- Use boto3 (`stop_instances`/`start_instances`)  
- For ASG: scale desired capacity, don't stop instances  

**Pro Tip:** Mention you'd add CloudWatch Alarms to alert if scheduled actions fail—shows operational rigor.

---

### 11. How do you migrate an EC2 instance between subnets or AZs?
**[Scenario]**  
**What They're Testing:** Architecture flexibility, understanding of AWS networking.  
**Sample Answer:**  
> "You can't directly move an instance between AZs. My approach: Create an AMI of the source instance, then launch a new instance from that AMI in the target subnet/AZ. For minimal downtime, I'd use a blue-green pattern: launch new instance in target AZ, sync data via rsync or EBS snapshots, update DNS/ALB to point to new instance, then terminate old one. If the instance has an Elastic IP, I'd reassociate it post-launch. For stateful apps, I'd coordinate a maintenance window."  

**Key Points:**  
- No direct AZ migration—must recreate via AMI/snapshot  
- Blue-green deployment minimizes downtime  
- Reassociate Elastic IP if used  
- Sync data carefully for stateful applications  

**Pro Tip:** Mention you'd use AWS Application Migration Service (MGN) for complex migrations—shows awareness of enterprise tools.

---

### 12. How do you use user data to install software automatically?
**[Conceptual]**  
**What They're Testing:** Instance bootstrapping, infrastructure as code fundamentals.  
**Sample Answer:**  
> "I'd pass a shell script or cloud-init directive in the User Data field during instance launch. For example, a bash script that updates packages, installs Docker, and starts a service. I always include error handling (`set -e`) and logging to `/var/log/user-data.log`. For complex setups, I'd use AWS Systems Manager State Manager or integrate with configuration management tools like Ansible via User Data. I also test User Data scripts in a sandbox before production use."  

**Key Points:**  
- User Data supports shell, cloud-init, PowerShell  
- Always add `set -e` and logging for debugging  
- Use for simple bootstrapping; complex logic → SSM/Ansible  
- Test scripts before production deployment  

**Pro Tip:** Mention you'd store User Data scripts in SSM Parameter Store or CodeCommit for version control—shows IaC maturity.

---

### 13. How do you check system logs for EC2 boot errors?
**[Conceptual]**  
**What They're Testing:** Troubleshooting methodology, AWS observability tools.  
**Sample Answer:**  
> "In the EC2 Console, I'd select the instance and go to 'Actions → Monitor and troubleshoot → Get system log'—this shows the serial console output, useful for kernel panics or early boot failures. For running instances, I'd SSH in and check `/var/log/messages`, `/var/log/syslog`, or `journalctl -b` for boot-specific logs. If the instance is unreachable, I'd enable EC2 Serial Console access (requires IAM permissions) for deeper debugging."  

**Key Points:**  
- Console: 'Get system log' for serial output  
- SSH: `/var/log/messages`, `journalctl -b`  
- Enable EC2 Serial Console for unreachable instances (IAM-controlled)  
- CloudWatch Logs agent can stream logs centrally  

**Pro Tip:** Mention you'd configure CloudWatch Logs agent on all instances for centralized log analysis—shows proactive observability.

---

### 14. How do you increase EC2 root volume size?
**[Scenario]**  
**What They're Testing:** Storage management, zero-downtime operations.  
**Sample Answer:**  
> "First, I'd modify the EBS volume size in the AWS Console/CLI (`modify-volume`). Then, on the instance, I'd use `lsblk` to confirm the volume size increased at the block level. Next, I'd extend the partition with `growpart /dev/xvda1` (if using MBR/GPT), then resize the filesystem: `resize2fs /dev/xvda1` for ext4 or `xfs_growfs /` for XFS. I always test this process in non-prod first and ensure I have a snapshot backup before starting."  

**Key Points:**  
- Step 1: Modify EBS volume size in AWS  
- Step 2: `growpart` to extend partition (if needed)  
- Step 3: `resize2fs` (ext4) or `xfs_growfs` (XFS)  
- Always snapshot first; test in non-prod  

**Pro Tip:** Mention you'd automate this with SSM Run Command for fleet-wide operations—shows scalability thinking.

---

### 15. How do you enable detailed monitoring for EC2 instances?
**[Conceptual]**  
**What They're Testing:** Monitoring strategy, cost-awareness, CloudWatch proficiency.  
**Sample Answer:**  
> "Detailed monitoring provides 1-minute metrics instead of the default 5-minute. I'd enable it via the EC2 Console by selecting the instance and choosing 'Manage detailed monitoring', or via CLI with `monitor-instances --instance-ids i-xxx`. I'm mindful that detailed monitoring incurs additional charges, so I only enable it for production-critical instances. For even deeper insights, I'd install the CloudWatch Agent to collect custom metrics like memory or disk usage."  

**Key Points:**  
- Detailed monitoring = 1-minute granularity (vs. 5-min default)  
- Enable via Console or `monitor-instances` CLI  
- Additional cost—use selectively for critical instances  
- CloudWatch Agent for custom metrics (memory, disk, etc.)  

**Pro Tip:** Mention you'd use CloudWatch Contributor Insights to analyze metric patterns—shows advanced monitoring skills.

---

### 16. How do you troubleshoot failed EC2 instance status checks?
**[Scenario]**  
**What They're Testing:** Systematic debugging, AWS infrastructure knowledge.  
**Sample Answer:**  
> "EC2 has two status checks: Instance Status (software/network) and System Status (hardware/AWS infrastructure). If Instance Status fails, I'd check OS-level issues: SSH in, review logs, restart services. If System Status fails, it's likely AWS-side—I'd wait for AWS to auto-recover or manually stop/start the instance (which migrates it to healthy hardware). For persistent failures, I'd check EBS volume health, network ACLs, and ensure the instance type is supported in the AZ."  

**Key Points:**  
- Instance Status fail → OS/app issue (you fix)  
- System Status fail → AWS hardware issue (stop/start to migrate)  
- Check EBS, network ACLs, instance type compatibility  
- Use CloudWatch Events to auto-recover on System Status failure  

**Pro Tip:** Mention you'd set up CloudWatch Alarms on status checks with Auto-Recovery actions—shows automation mindset.

---

### 17. How do you share an AMI with another AWS account?
**[Conceptual]**  
**What They're Testing:** Cross-account collaboration, security best practices.  
**Sample Answer:**  
> "I'd go to the AMI in EC2 Console, select 'Modify Image Permissions', and add the target AWS account ID. Via CLI: `modify-image-attribute --image-id ami-xxx --launch-permission "Add=[{UserId=123456789012}]"`. Important: The AMI must be encrypted with a KMS key that grants decrypt permissions to the target account, and any associated EBS snapshots must also be shared. I always document shared AMIs and review permissions regularly via AWS Config."  

**Key Points:**  
- Use `modify-image-attribute` or Console to add account ID  
- Share associated EBS snapshots separately  
- KMS key policies must allow cross-account decryption  
- Audit shared AMIs regularly with AWS Config  

**Pro Tip:** Mention you'd use AWS Resource Access Manager (RAM) for sharing resources across accounts at scale—shows enterprise architecture awareness.

---

### 18. How do you attach multiple network interfaces to an EC2 instance?
**[Conceptual]**  
**What They're Testing:** Advanced networking, multi-homed instance design.  
**Sample Answer:**  
> "I'd create additional ENIs in the desired subnets via Console/CLI, then attach them to the instance (instance must support multiple ENIs—most do). On the OS level, I'd configure secondary interfaces: for Amazon Linux, edit `/etc/sysconfig/network-scripts/ifcfg-eth1` or use `netplan` on Ubuntu. I always assign private IPs carefully and update route tables if the instance needs to route traffic between interfaces. For high availability, I'd use ENIs with failover patterns in multi-AZ setups."  

**Key Points:**  
- Create ENIs in target subnets → attach to instance  
- Configure OS-level networking for secondary interfaces  
- Verify instance type supports multiple ENIs  
- Update route tables for inter-interface routing  

**Pro Tip:** Mention you'd use this pattern for network appliances or bastion hosts with management/data plane separation—shows practical application.

---

### 19. How do you recover corrupted EBS volumes from snapshots?
**[Scenario]**  
**What They're Testing:** Disaster recovery, backup validation, data integrity.  
**Sample Answer:**  
> "First, I'd identify the last known-good snapshot. Then create a new EBS volume from that snapshot in the same AZ as the instance. Detach the corrupted volume, attach the new one (using the same device name), and start the instance. If the instance fails to boot, I'd attach the new volume as a secondary disk to a recovery instance, mount it, and manually repair filesystem or extract critical data. Post-recovery, I'd validate data integrity and update backup policies to increase snapshot frequency if needed."  

**Key Points:**  
- Restore from latest clean snapshot → new volume  
- Swap volumes: detach corrupted, attach restored  
- Use recovery instance for filesystem repair/data extraction  
- Post-mortem: review backup RPO/RTO  

**Pro Tip:** Mention you'd test snapshot restores quarterly in a staging environment—proves you validate backups, not just create them.

---

### 20. How do you monitor EC2 disk I/O performance?
**[Conceptual]**  
**What They're Testing:** Observability strategy, performance tuning, CloudWatch expertise.  
**Sample Answer:**  
> "I'd use CloudWatch metrics like `VolumeReadOps`, `VolumeWriteOps`, `VolumeTotalReadTime`, and `BurstBalance` (for gp2/gp3). For deeper insights, I'd install the CloudWatch Agent to collect OS-level metrics like `iostat` output. I'd set dashboards to track IOPS vs. throughput limits, and create alarms for sustained high wait times. For critical databases, I'd also enable EBS volume performance mode (like `io2 Block Express`) and monitor with CloudWatch Contributor Insights to identify I/O patterns."  

**Key Points:**  
- CloudWatch EBS metrics: Read/Write Ops, TotalReadTime, BurstBalance  
- CloudWatch Agent for OS-level `iostat` metrics  
- Dashboards + Alarms for proactive monitoring  
- Choose EBS volume type based on IOPS/throughput needs  

**Pro Tip:** Mention you'd correlate disk I/O with application logs to identify root causes of performance issues—shows full-stack troubleshooting.
