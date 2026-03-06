# Advanced DevOps Interview Questions

## Section 1 - System Design & Architecture

### 1. How would you design a highly available multi-tenant system in AWS?
 
"I'd use a shared EKS cluster with namespace-per-tenant isolation. Each tenant gets dedicated namespace, ResourceQuotas, NetworkPolicies, and separate databases (RDS per tenant or schema-per-tenant). An ALB with host-based routing sends traffic to the right namespace. IAM roles per tenant restrict AWS resource access. Data is encrypted at rest (KMS with tenant-specific keys) and in transit (TLS). For HA, the cluster spans 3 AZs with pod anti-affinity rules."

**Key Points:**  
- Namespace isolation + NetworkPolicies + ResourceQuotas  
- Separate data stores per tenant (RDS/DynamoDB)  
- KMS encryption with per-tenant keys  
- Multi-AZ EKS + ALB host-based routing  
- IAM roles scoped per tenant  

---

### 2. How would you reduce API response time from 30s to under 5s?
 
"First, profile to find the bottleneck - usually it's database queries or external API calls. Add Redis/ElastiCache for hot data. Optimize slow queries with proper indexes and EXPLAIN ANALYZE. Move heavy processing to async workers (SQS + Lambda or Celery). Add connection pooling (PgBouncer). If it's compute-bound, scale horizontally behind ALB. Use CloudFront for cacheable responses. Implement pagination instead of returning large datasets."

**Key Points:**  
- Profile first - don't guess (APM tools like X-Ray, Datadog)  
- Caching: Redis/ElastiCache for repeated reads  
- Database: indexing, query optimization, connection pooling  
- Async: offload heavy work to SQS/Lambda/Celery  
- CDN: CloudFront for cacheable API responses  

---

### 3. How would you rotate secrets securely across multiple EC2/Windows servers?
 
"Store all secrets in AWS Secrets Manager with automatic rotation enabled (Lambda rotation function). Applications pull secrets at startup using the SDK, not from env vars or files. For EC2/Windows, use SSM Parameter Store with IAM instance profiles - no hardcoded credentials. The rotation Lambda creates new secret, updates the service, tests it, then marks it current. Use Secrets Manager's versioning (AWSCURRENT/AWSPREVIOUS) so apps can gracefully handle rotation without downtime."

**Key Points:**  
- Secrets Manager with auto-rotation (Lambda function)  
- IAM instance profiles - never hardcode credentials  
- AWSCURRENT/AWSPREVIOUS versioning for graceful rotation  
- Applications pull secrets via SDK at runtime  
- SSM Parameter Store for non-rotating config  

---

### 4. How would you deploy a FastAPI app on EKS?

"Containerize with a multi-stage Dockerfile (build deps, then copy to slim image with uvicorn). Push to ECR. Create Kubernetes manifests: Deployment with resource limits, readiness probe on /health, HPA based on CPU/request latency. Expose via ClusterIP Service + Ingress (ALB Ingress Controller). Use ConfigMaps for config, Secrets for credentials. CI/CD pipeline: GitHub Actions builds image, pushes to ECR, updates manifests, ArgoCD syncs to cluster."

**Key Points:**  
- Multi-stage Docker build with uvicorn  
- ECR for image registry  
- Deployment + Service + Ingress (ALB controller)  
- Readiness probe on /health endpoint  
- HPA for autoscaling, resource limits to prevent noisy neighbors  
- ArgoCD or Flux for GitOps-based deployment  

---

### 5. How do you implement CI/CD in AWS?
 
"For AWS-native: CodePipeline orchestrates the flow, CodeBuild compiles/tests/builds Docker image, CodeDeploy handles rolling/blue-green deployment to ECS/EKS/EC2. For open-source: GitHub Actions or Jenkins for CI, ArgoCD for CD to Kubernetes. Pipeline stages: lint > unit test > build image > push to ECR > deploy to staging > integration tests > manual approval > deploy to prod. Infrastructure changes go through a separate Terraform pipeline with plan > approve > apply."

**Key Points:**  
- AWS-native: CodePipeline + CodeBuild + CodeDeploy  
- Open-source: GitHub Actions/Jenkins + ArgoCD  
- Stages: lint > test > build > staging > approval > prod  
- Separate pipeline for infrastructure (Terraform)  
- Artifacts stored in ECR (images) and S3 (build outputs)  

---

### 6. How do you handle zero-downtime deployments?
 
"In Kubernetes: rolling update strategy with maxSurge=1, maxUnavailable=0 ensures old pods stay up until new ones pass readiness probes. Add preStop hooks with a 5s sleep to allow endpoint propagation before shutdown. For databases, use backward-compatible migrations only - add columns, never rename/delete in the same release. For ECS: use blue-green with ALB target group switching. Always have rollback ready: keep previous image tag, use `kubectl rollout undo` or revert the Git commit in GitOps."

**Key Points:**  
- Rolling update: maxSurge=1, maxUnavailable=0  
- Readiness probes gate traffic to new pods  
- preStop hooks handle endpoint propagation delay  
- Database migrations must be backward-compatible  
- Blue-green for ECS; rolling for EKS  
- Instant rollback via previous image or Git revert  

---

### 7. How do you secure inter-service communication in Kubernetes on AWS?
 
"Layer 1: NetworkPolicies to restrict which pods can talk to which (default deny all, then allow specific). Layer 2: Service mesh (Istio or AWS App Mesh) for mTLS - every pod gets a sidecar that encrypts all traffic with mutual TLS certificates, automatically rotated. Layer 3: IRSA (IAM Roles for Service Accounts) so each service has least-privilege AWS access. Layer 4: OPA/Gatekeeper policies to enforce security standards across all deployments."

**Key Points:**  
- NetworkPolicies: default deny, explicit allow  
- Service mesh (Istio/App Mesh) for automatic mTLS  
- IRSA for fine-grained AWS IAM per service  
- OPA/Gatekeeper for policy enforcement  
- Encrypt all traffic - never trust the network  

---

### 8. How do you monitor 1000+ servers efficiently?
 
"Use a pull-based system like Prometheus with node_exporter on every server, federated across regions. For AWS-native, CloudWatch agent with custom metrics + CloudWatch Composite Alarms to reduce noise. Centralize logs with Fluentd/Fluent Bit shipping to OpenSearch or CloudWatch Logs Insights. Dashboards in Grafana with per-team views. Alert routing via PagerDuty with escalation policies. At 1000+ scale, use Thanos or Cortex on top of Prometheus for long-term storage and global querying."

**Key Points:**  
- Prometheus + node_exporter (pull-based, scales well)  
- Thanos/Cortex for multi-cluster aggregation and long-term storage  
- Fluentd/Fluent Bit for centralized logging  
- Grafana dashboards per team/service  
- PagerDuty with escalation policies for alerting  
- CloudWatch at scale needs Composite Alarms to reduce noise  

---

### 9. How do you reduce AWS cost for large-scale infrastructure?
 
"Start with visibility: Cost Explorer + CUR (Cost and Usage Report) to identify top spenders. Quick wins: Reserved Instances or Savings Plans for steady-state (up to 72% savings), Spot Instances for fault-tolerant workloads (up to 90% savings), right-sizing with Compute Optimizer. Storage: S3 Lifecycle policies to move old data to Glacier. Kubernetes: Karpenter for efficient node provisioning, pod right-sizing with VPA. Governance: tag everything, set AWS Budgets with alerts, shut down dev/staging outside business hours."

**Key Points:**  
- Visibility first: Cost Explorer, CUR, tagging  
- Compute: Reserved Instances, Savings Plans, Spot  
- Right-sizing: Compute Optimizer, VPA in Kubernetes  
- Storage: S3 Lifecycle rules, EBS type optimization  
- Scheduling: shut down non-prod outside hours  
- Karpenter for Kubernetes node cost optimization  

---

### 10. How would you architect a disaster recovery strategy?
 
"Define RTO and RPO first - they drive the architecture. For pilot light: keep AMIs/containers and DB replicas in the DR region, scale up on failover. For warm standby: run a scaled-down copy of production in the DR region behind Route 53 failover routing. For active-active: full deployment in both regions with Route 53 latency-based routing and DynamoDB Global Tables or Aurora Global Database. Automate failover with health checks and Lambda. Test quarterly with gameday exercises."

**Key Points:**  
- RTO/RPO define the strategy and cost  
- Pilot light (cheapest) > Warm standby > Active-active (most expensive)  
- Route 53 failover/latency routing for DNS switchover  
- Aurora Global DB or DynamoDB Global Tables for data replication  
- Automate everything - manual failover fails under pressure  
- Quarterly gameday testing is mandatory  

---

## Section 2 - Troubleshooting & Concepts

### 11. What happens internally when a request hits a Load Balancer before reaching an application server?
 
"DNS resolves the domain to the ALB's IP. The client makes a TCP connection to the ALB. For HTTPS, TLS termination happens at the ALB (SSL certificate via ACM). The ALB evaluates listener rules (host/path-based) to pick a target group. Within the target group, the routing algorithm (round-robin or least-outstanding-requests) selects a healthy target. The ALB opens a new TCP connection to the target (or reuses via keep-alive). Health checks continuously remove unhealthy targets. The response flows back through the ALB to the client."

**Key Points:**  
- DNS > TCP connection > TLS termination at ALB  
- Listener rules match host/path to target groups  
- Round-robin or least-outstanding-requests selects a target  
- Only healthy targets receive traffic (health checks)  
- ALB operates at Layer 7 (HTTP); NLB at Layer 4 (TCP)  

---

### 12. How would you troubleshoot a Kubernetes pod stuck in CrashLoopBackOff?

"Step 1: `kubectl describe pod` to check events - look at exit codes and restart count. Step 2: `kubectl logs --previous` to see why the last container crashed. Step 3: Check if it's a config issue (missing env vars, bad ConfigMap/Secret mount). Step 4: Check resource limits - OOMKilled (exit 137) means the container needs more memory. Step 5: If the container exits too fast for logs, override the command with `sleep infinity` to exec into it and debug manually."

**Key Points:**  
- `kubectl describe pod` > events and exit codes  
- `kubectl logs --previous` > last crash output  
- Exit 137 = OOMKilled, Exit 1 = app error  
- Common causes: missing env vars, bad config, insufficient resources  
- Debug trick: override entrypoint with `sleep infinity`  

---

### 13. A deployment was successful but users report 502/503 errors. What could be the possible reasons?

"502 means the ALB got an invalid response from the backend. 503 means no healthy targets. 
Check: 
(1) readiness probe misconfigured - pod is in the target group but not ready to serve, 
(2) app started but hasn't finished loading (slow startup without startupProbe), 
(3) security group doesn't allow ALB to reach the pod/instance,
(4) app is crashing right after startup, 
(5) target group health check path returns non-200. Also check if the new deployment's resource requests are starving the pods."

**Key Points:**  
- 502: backend sent invalid/no response (app crash, timeout)  
- 503: no healthy targets in the target group  
- Readiness probe or health check misconfigured  
- Security group blocking ALB-to-target traffic  
- Slow startup without startupProbe  
- Check ALB access logs + target group health status  

---

### 14. What steps would you take if a CI/CD pipeline suddenly starts failing after working for months?

"Check what changed: recent commits, dependency updates, infra changes. Read the exact error message. 

Common causes: 
(1) expired credentials/tokens, 
(2) a dependency published a breaking version (no version pinning), 
(3) Docker base image updated with breaking changes, 
(4) rate limiting from registry/API, 
(5) runner disk full or out of memory, 
(6) external service down (npm registry, Docker Hub). 

Fix: pin dependency versions, rotate credentials, check runner health, add retry logic for transient failures."

**Key Points:**  
- Read the error message first  
- Credentials/token expiry is the #1 cause  
- Unpinned dependencies break builds silently  
- Docker Hub rate limits hit CI runners hard  
- Runner resource exhaustion (disk, memory)  
- Prevention: pin versions, alert on credential expiry  

---

### 15. How does Horizontal Pod Autoscaler (HPA) decide when to scale pods?
 
"HPA queries the metrics API every 15 seconds (default). It calculates: desiredReplicas = ceil(currentReplicas * (currentMetric / targetMetric)). For CPU: if target is 50% and current average is 80%, HPA scales up. It supports CPU, memory, and custom metrics (requests/second via Prometheus Adapter). There's a stabilization window (default 5 min for scale-down) to prevent flapping. HPA respects minReplicas and maxReplicas bounds."

**Key Points:**  
- Formula: desiredReplicas = ceil(current * (currentMetric / target))  
- Default check interval: 15 seconds  
- Scale-down stabilization: 5 minutes (prevents flapping)  
- Supports CPU, memory, custom metrics, external metrics  
- Requires metrics-server installed in the cluster  

---

### 16. Your CPU usage spikes to 95% in production after a new release. How will you investigate?

"Step 1: Identify which pods/instances are spiking (Grafana/CloudWatch). Step 2: Correlate with the deployment timestamp - did the spike start exactly at deploy time? Step 3: Compare the new code diff for CPU-intensive changes (tight loops, missing pagination, regex backtracking). Step 4: Profile in staging - attach a profiler (py-spy for Python, async-profiler for Java). Step 5: Check if it's a resource leak (growing thread count, connection pool exhaustion). Immediate mitigation: rollback while investigating."

**Key Points:**  
- Correlate spike with deployment time  
- Review code diff for CPU-intensive changes  
- Profile with py-spy / async-profiler / perf  
- Check for infinite loops, regex backtracking, missing pagination  
- Rollback immediately, investigate on staging  

---

### 17. How do you implement zero downtime deployments in Kubernetes?
 
"Use rolling update strategy: maxSurge=1, maxUnavailable=0 - Kubernetes creates a new pod before killing an old one. Configure readiness probes so traffic only hits pods that are actually ready. Add a preStop lifecycle hook (sleep 5s) to allow time for endpoints to depropagation before the container receives SIGTERM. Ensure the app handles SIGTERM gracefully - stop accepting new connections, drain existing ones. For database changes, use expand-and-contract migrations."

**Key Points:**  
- Rolling update: maxSurge=1, maxUnavailable=0  
- Readiness probe gates traffic to new pods  
- preStop hook (sleep 5s) for endpoint propagation  
- Graceful shutdown on SIGTERM  
- Database: backward-compatible migrations only  

---

### 18. A Docker container exits immediately after starting. How do you debug it?

"Step 1: `docker logs <container>` to see stdout/stderr. Step 2: `docker inspect <container>` to check exit code (137=OOM, 1=app error, 127=command not found, 126=permission denied). Step 3: Run interactively: `docker run -it <image> /bin/sh` to get a shell and test the entrypoint manually. Step 4: Check if the CMD/ENTRYPOINT is correct in the Dockerfile. Step 5: Verify all required env vars and mounted volumes are present. Common cause: foreground vs background process - the main process must run in the foreground."

**Key Points:**  
- `docker logs` + `docker inspect` for exit code  
- Exit 137=OOM, 1=app error, 127=command not found  
- Run interactively with `/bin/sh` to debug  
- Main process must run in foreground (not daemonized)  
- Check CMD/ENTRYPOINT, env vars, volume mounts  

---

### 19. What is the difference between Infrastructure as Code and Configuration Management?
 
"IaC (Terraform, CloudFormation) provisions infrastructure - VPCs, EC2, RDS, load balancers. It's declarative and handles resource lifecycle (create, update, destroy). Configuration Management (Ansible, Chef, Puppet) configures existing servers - installs packages, manages files, starts services. IaC answers 'what infrastructure exists?' while CM answers 'how is this server configured?' In practice, Terraform creates the EC2 instance, Ansible configures what runs on it."

**Key Points:**  
- IaC: provisions infrastructure (Terraform, CloudFormation)  
- CM: configures existing servers (Ansible, Chef, Puppet)  
- IaC = declarative resource lifecycle  
- CM = desired state of server configuration  
- They complement each other, not compete  

---

### 20. If a database suddenly becomes slow, what metrics would you check first?

"Check in order: (1) CPU/memory of the DB instance - is it maxed out? (2) Active connections vs max connections - connection pool exhaustion? (3) Slow query log - which queries are taking the longest? (4) IOPS and disk throughput - are you hitting EBS limits? (5) Replication lag - is a replica falling behind? (6) Lock waits - are queries blocking each other? (7) Table sizes - has a table grown unexpectedly? Then correlate with recent deployments or traffic spikes."

**Key Points:**  
- CPU/memory utilization of DB instance  
- Active connections vs connection limit  
- Slow query log (EXPLAIN ANALYZE on top offenders)  
- IOPS/throughput hitting EBS volume limits  
- Replication lag and lock contention  
- Correlate with recent code deployments  

---

### 21. Your Prometheus alerts are firing continuously even though the system looks healthy. What could be wrong?

"Check: (1) Stale or incorrect alert thresholds that don't match current baseline (system grew, old thresholds too tight). (2) Flapping metrics causing alerts to fire/resolve/fire repeatedly - need hysteresis or `for` duration in alert rules. (3) Prometheus scrape targets returning stale/cached data. (4) Time drift between Prometheus and targets causing incorrect rate() calculations. (5) Label cardinality explosion making aggregations incorrect. (6) The system IS unhealthy but the dashboard is showing averaged/aggregated data that hides the issue."

**Key Points:**  
- Stale thresholds that don't match current baseline  
- Missing `for` duration causes flapping  
- Time drift breaks rate() calculations  
- Label cardinality explosion skews aggregations  
- Dashboard aggregation can hide per-instance issues  
- Review and tune alert thresholds regularly  

---

### 22. A Kubernetes node goes into NotReady state. What troubleshooting steps would you take?

"Step 1: `kubectl describe node` to check conditions (MemoryPressure, DiskPressure, PIDPressure, NetworkUnavailable). Step 2: SSH into the node and check kubelet: `systemctl status kubelet` + `journalctl -u kubelet`. Step 3: Check if the node can reach the API server (network/firewall issue). Step 4: Check disk space (`df -h`) and memory (`free -m`). Step 5: Check if the container runtime (containerd/docker) is healthy. Step 6: If the node is unrecoverable, cordon + drain + replace it."

**Key Points:**  
- `kubectl describe node` for conditions and events  
- Check kubelet status and logs on the node  
- Common causes: disk full, OOM, kubelet crash, network partition  
- Verify API server connectivity from the node  
- Cordon > drain > replace if unrecoverable  

---

### 23. What is the difference between Liveness Probe and Readiness Probe in Kubernetes?
 
"Liveness probe answers 'is the container alive?' - if it fails, kubelet kills and restarts the container. Use it to detect deadlocks or hung processes. Readiness probe answers 'can the container serve traffic?' - if it fails, the pod is removed from Service endpoints but NOT restarted. Use it for startup delays, dependency checks, or temporary overload. There's also startupProbe for slow-starting apps - it disables liveness/readiness until the app is initialized."

**Key Points:**  
- Liveness: failed = container restarted (detect deadlocks)  
- Readiness: failed = removed from Service endpoints (no traffic)  
- Startup: protects slow-starting apps from liveness kills  
- Liveness should NOT check dependencies (causes cascading restarts)  
- Readiness CAN check dependencies (DB connectivity, etc.)  

---

### 24. How would you secure secrets in a CI/CD pipeline?
 
"Never store secrets in code or pipeline config files. Use the platform's native secret store: GitHub Secrets, GitLab CI Variables (masked + protected), Jenkins Credentials. For runtime, pull from AWS Secrets Manager or HashiCorp Vault using short-lived tokens. Rotate secrets regularly and alert on expiry. Mask secrets in logs (most CI platforms do this automatically). Use OIDC federation (GitHub Actions > AWS) instead of long-lived access keys. Audit secret access with CloudTrail."

**Key Points:**  
- Platform-native secret stores (GitHub Secrets, GitLab Variables)  
- Runtime: Secrets Manager or Vault  
- OIDC federation instead of long-lived keys  
- Mask secrets in CI logs  
- Rotate regularly, alert on expiry  
- Audit access with CloudTrail  

---

### 25. How do you investigate memory leaks in a containerized application?

"Step 1: Confirm it's a leak - check if container memory usage grows monotonically over time (Grafana + container_memory_usage_bytes). Step 2: Check OOMKilled events in `kubectl describe pod`. Step 3: Profile the app: for Python use tracemalloc/memory_profiler, for Java use jmap heap dump + Eclipse MAT, for Go use pprof. Step 4: Look for common causes: unclosed connections, growing caches without eviction, event listener accumulation. Step 5: Reproduce in staging with load testing (k6/locust) while profiling."

**Key Points:**  
- Monitor container_memory_usage_bytes over time  
- Profile: tracemalloc (Python), jmap (Java), pprof (Go)  
- Common causes: unclosed connections, unbounded caches  
- OOMKilled (exit 137) confirms the container hit its limit  
- Reproduce with load testing in staging  

---

### 26. Your Terraform deployment failed halfway. How do you recover from the inconsistent state?

"Terraform saves state after each resource operation, so successfully created resources are already tracked. Check the error, fix the root cause (permission, quota, invalid config), and run `terraform apply` again - it picks up where it left off. If a resource is stuck in a bad state, use `terraform apply -replace=<resource>` to force recreation. Never manually edit the state file unless absolutely necessary. If state is corrupted, restore from S3 versioning."

**Key Points:**  
- State is saved incrementally - no full rollback needed  
- Fix root cause, re-run `terraform apply`  
- `-replace=<resource>` for stuck/broken resources  
- Never manually edit state unless last resort  
- S3 versioning for state recovery  

---

### 27. What are the key SLIs, SLOs, and SLAs you track for a production system?
 
"SLI (indicator) = the metric: request latency, error rate, availability, throughput. SLO (objective) = internal target: p99 latency < 200ms, error rate < 0.1%, availability 99.95%. SLA (agreement) = contractual promise to customers with penalties: 99.9% uptime or credits issued. I track: latency (p50, p95, p99), error rate (5xx/total), availability (successful requests/total), and saturation (CPU, memory, disk). Error budgets (100% - SLO) determine how fast we can ship risky changes."

**Key Points:**  
- SLI = measurement, SLO = target, SLA = contract  
- Key SLIs: latency, error rate, availability, saturation  
- Error budget = 100% - SLO (spend it on velocity)  
- SLOs should be slightly stricter than SLAs  
- Measure from the user's perspective, not the server's  

---

### 28. A microservice suddenly starts returning high latency. What tools would you use to debug it?

"Start with distributed tracing (Jaeger/X-Ray) to see which span in the request chain is slow. Check Grafana dashboards for the service: request rate, latency percentiles, error rate (RED method). Look at upstream dependencies - is a database or external API slow? Check resource utilization (CPU, memory, network). Review recent deployments. Use APM tools (Datadog, New Relic) for code-level profiling. Check connection pool metrics - exhaustion causes queuing."

**Key Points:**  
- Distributed tracing (Jaeger/X-Ray) to isolate the slow span  
- RED method: Rate, Errors, Duration  
- Check upstream dependencies (DB, external APIs)  
- APM for code-level bottleneck identification  
- Connection pool exhaustion causes queuing latency  
- Correlate with recent deployments  

---

### 29. How would you design a highly available system that can handle traffic spikes during peak sales?
 
"Multi-AZ deployment behind ALB with Auto Scaling Groups (EC2) or HPA (Kubernetes). Pre-scale before the event based on historical data - don't rely solely on reactive scaling. Use CloudFront + S3 for static assets. ElastiCache (Redis) for session data and hot cache. SQS to decouple and buffer writes (order processing). Aurora with read replicas for database reads. DynamoDB for high-throughput key-value lookups. Load test beforehand with realistic traffic patterns (k6/Locust)."

**Key Points:**  
- Pre-scale before the event, don't rely only on autoscaling  
- CDN (CloudFront) offloads static content  
- Cache (ElastiCache) reduces DB load  
- Queue (SQS) buffers write spikes  
- Multi-AZ + Auto Scaling for compute  
- Load test with realistic patterns before the event  

---

### 30. If multiple monitoring alerts fire at the same time, how do you prioritize incident response?

"Use alert severity levels: P1 (customer-facing outage) > P2 (degraded service) > P3 (internal tools) > P4 (warning). Group related alerts - multiple alerts from the same service likely share a root cause. Check if there's a common upstream dependency failure (database down triggers 10 services to alert). Use PagerDuty's alert grouping and deduplication. Start with the most upstream component - fixing the root cause resolves downstream alerts. Communicate status immediately, investigate in parallel."

**Key Points:**  
- Severity tiers: P1 (outage) > P2 (degraded) > P3 > P4  
- Group correlated alerts to find root cause  
- Start from the most upstream failing component  
- PagerDuty grouping + deduplication reduces noise  
- Communicate first, then investigate  
- Post-incident: tune alerts that didn't add value  

---

## Section 3 - Expert Level

### 31. How would you design a CI/CD pipeline for 50+ microservices with zero downtime deployment?
 
"Monorepo or polyrepo - either way, each service has its own pipeline triggered only on its directory changes (path filter). Shared pipeline templates (GitHub reusable workflows / Jenkins shared libraries) ensure consistency. Pipeline: lint > unit test > build image > push to ECR > deploy to staging > integration test > approval > canary deploy to prod (10% traffic via Istio) > full rollout. ArgoCD for GitOps - merge to main = deploy. Rollback: revert the Git commit, ArgoCD syncs automatically."

**Key Points:**  
- Path-based triggers: only build what changed  
- Shared pipeline templates for consistency across 50+ services  
- GitOps (ArgoCD): Git as single source of truth  
- Canary deployments with traffic splitting (Istio/Flagger)  
- Rollback = Git revert, not manual intervention  
- Parallel pipelines - don't serialize 50 services  

---

### 32. In Kubernetes, how do you debug a pod stuck in CrashLoopBackOff?

"`kubectl describe pod <name>` to see events and the last termination reason. `kubectl logs <name> --previous` to get the crashed container's logs. Check the exit code: 137=OOMKilled (increase memory limits), 1=application error (check app logs), 127=entrypoint not found (check Dockerfile CMD). If the container exits too fast: create a debug pod with the same image using `kubectl debug` or override the command to `sleep infinity` and exec in. Check ConfigMaps, Secrets, and volume mounts for correctness."

**Key Points:**  
- `describe pod` > `logs --previous` > check exit code  
- 137=OOM, 1=app error, 127=binary not found  
- `kubectl debug` or override command for fast-crashing containers  
- Verify ConfigMap/Secret mounts and env vars  
- Check if init containers are failing silently  

---

### 33. Explain what happens internally when you run: `docker run nginx`
 
"Docker CLI sends the request to dockerd (Docker daemon) via REST API. Daemon checks if the nginx image exists locally - if not, pulls it from Docker Hub (resolves tag > downloads layers > assembles image). Daemon calls containerd to create the container. containerd uses runc to create Linux namespaces (pid, net, mnt, uts, ipc, user) for isolation and cgroups for resource limits. runc sets up the root filesystem (overlay2), applies the image's config (CMD, EXPOSE, ENV), creates network namespace with a veth pair connected to docker0 bridge, and starts the nginx process as PID 1 inside the container."

**Key Points:**  
- Docker CLI > dockerd > containerd > runc  
- Image pull: resolve tag > download layers > overlay2 filesystem  
- Namespaces: pid, net, mnt, uts, ipc (isolation)  
- Cgroups: CPU, memory, I/O limits  
- Network: veth pair connected to docker0 bridge  
- nginx runs as PID 1 inside the container  

---

### 34. How do you manage Terraform state across multiple environments safely?
 
"Each environment (dev/staging/prod) gets its own state file via separate backend configurations: different S3 keys (`dev/terraform.tfstate`, `prod/terraform.tfstate`). DynamoDB for state locking prevents concurrent applies. Each environment is a separate directory calling shared modules. IAM roles are scoped per environment - the dev pipeline cannot access prod state. Enable S3 versioning for state recovery. Never use workspaces for environment separation when you need strict isolation."

**Key Points:**  
- Separate state files per environment (different S3 keys)  
- DynamoDB locking prevents concurrent corruption  
- IAM roles scoped per environment  
- Shared modules, separate root configs  
- S3 versioning for disaster recovery  
- Directory-per-env over workspaces for strict isolation  

---

### 35. Design a highly available Kubernetes cluster across multiple AZs.
 

> "Control plane: EKS manages this automatically (multi-AZ etcd + API servers). For self-managed: 3 master nodes across 3 AZs with etcd running as a 3-member cluster. Worker nodes: node groups spread across 3 AZs. Pod topology: use topologySpreadConstraints to distribute pods evenly across AZs. Storage: use EBS CSI driver with volume topology awareness (EBS is AZ-bound). Networking: VPC CNI with subnets in each AZ, ALB Ingress routes to pods across all AZs. PodDisruptionBudgets ensure minimum availability during node maintenance."

**Key Points:**  
- 3 AZs minimum for HA  
- EKS handles control plane HA automatically  
- topologySpreadConstraints for even pod distribution  
- EBS is AZ-bound - use EFS for cross-AZ shared storage  
- PodDisruptionBudgets for safe node drains  
- Node groups across all AZs with Karpenter/Cluster Autoscaler  

---

### 36. Blue-Green vs Canary vs Rolling deployment - when do you use each?
 
"Rolling: default for most services. Gradually replaces old pods with new ones. Low risk, low cost, but slow rollback (have to roll forward or undo). Blue-Green: run full old (blue) and new (green) environments simultaneously, switch traffic instantly via ALB/DNS. Fast rollback (switch back), but 2x cost during deployment. Best for critical services. Canary: send a small % of traffic (5-10%) to the new version, monitor metrics, gradually increase. Best when you need production validation before full rollout. Requires traffic splitting (Istio, Flagger, ALB weighted routing)."

**Key Points:**  
- Rolling: default, low cost, slower rollback  
- Blue-Green: instant switch, fast rollback, 2x cost  
- Canary: gradual traffic shift, best for risk reduction  
- Rolling for most services, Blue-Green for critical ones  
- Canary when you need production metric validation  
- Tooling: Istio/Flagger for canary, ALB for blue-green  

---

### 37. How would you secure secrets in a CI/CD pipeline?
 
"Never hardcode secrets. Use OIDC federation (GitHub Actions > AWS STS) to eliminate long-lived credentials entirely. For pipeline variables, use masked + protected secrets (GitHub Secrets, GitLab CI Variables). At runtime, applications pull from Secrets Manager or Vault using IAM roles, not injected env vars. Scan for secret leaks with tools like truffleHog or gitleaks in the pipeline. Rotate credentials automatically and audit access via CloudTrail."

**Key Points:**  
- OIDC federation > long-lived access keys  
- Platform-native masked secrets  
- Runtime pull from Secrets Manager/Vault  
- Secret scanning (truffleHog/gitleaks) in CI  
- Automated rotation + expiry alerts  
- CloudTrail audit trail  

---

### 38. What strategy would you use to reduce alert fatigue in monitoring systems?

"Start by classifying alerts into actionable tiers: P1 pages on-call, P2 creates a ticket, P3 goes to a Slack channel, P4 is logged only. Delete alerts nobody acts on. Use alert grouping and deduplication (PagerDuty, Alertmanager). Add `for` duration in Prometheus rules to avoid flapping (e.g., `for: 5m` means it must be failing for 5 minutes). Route alerts to the owning team, not a shared channel. Review alerts monthly - if an alert fires > 10 times without action, fix the root cause or delete it."

**Key Points:**  
- Severity tiers: page > ticket > Slack > log  
- Delete alerts nobody acts on  
- `for` duration to prevent flapping  
- Alert grouping and deduplication  
- Route to owning team, not shared channels  
- Monthly review: fix root cause or delete noisy alerts  

---

### 39. How do you implement GitOps in production?

"GitOps means Git is the single source of truth for infrastructure and application state. Setup: ArgoCD or Flux watches a Git repo containing Kubernetes manifests (or Helm charts). Any change to main branch triggers ArgoCD to sync the desired state to the cluster. CI pipeline builds image + updates the image tag in the Git repo. ArgoCD detects the change and deploys. Rollback = Git revert. Drift detection: ArgoCD alerts if someone makes a manual kubectl change that diverges from Git."

**Key Points:**  
- Git = single source of truth  
- ArgoCD/Flux watches repo and syncs to cluster  
- CI updates image tag in Git, CD (ArgoCD) deploys  
- Rollback = Git revert (instant, auditable)  
- Drift detection catches manual kubectl changes  
- Separation of concerns: CI builds, CD deploys  

---

### 40. What happens when etcd fails in Kubernetes?
 
"etcd is the brain of Kubernetes - all cluster state (pods, services, secrets, configmaps) is stored there. If etcd fails: the API server can't read or write state, so no new pods can be scheduled, no deployments can update, no scaling events happen. Existing running pods continue to run (kubelet doesn't need etcd for running containers), but nothing new can be created or modified. With a 3-member etcd cluster, it tolerates 1 node failure (quorum = 2). If quorum is lost, the cluster is effectively read-only (actually, fully unavailable for writes)."

**Key Points:**  
- etcd stores ALL cluster state  
- etcd down = no new scheduling, scaling, or updates  
- Running pods continue (kubelet runs independently)  
- 3-member cluster tolerates 1 failure (quorum = 2)  
- Quorum lost = cluster is write-unavailable  
- Regular etcd snapshots are critical for recovery  

---

### 41. How do you handle database schema changes in CI/CD?
 
"Use versioned migration tools (Flyway, Alembic, Liquibase). Every schema change is a numbered migration file committed to Git. The CI/CD pipeline runs migrations before deploying the new app version. Critical rule: migrations must be backward-compatible (expand-and-contract pattern). Phase 1: add new column (old code ignores it). Phase 2: deploy new code that uses both. Phase 3: migrate data. Phase 4: drop old column. Never rename or delete columns in the same release as the code change."

**Key Points:**  
- Versioned migrations (Flyway/Alembic/Liquibase)  
- Backward-compatible only (expand-and-contract)  
- Never rename/delete columns in same release  
- Run migrations before deploying new code  
- Test migrations against a copy of production data  
- Rollback plan: reverse migration script ready  

---

### 42. How would you migrate a monolithic app to microservices?
 
"Strangler Fig pattern: don't rewrite everything at once. Step 1: Put an API gateway in front of the monolith. Step 2: Identify bounded contexts (auth, payments, orders). Step 3: Extract one service at a time - start with the least coupled, highest-value piece. Route its traffic through the gateway to the new microservice instead of the monolith. Step 4: Decouple the database - each service gets its own DB (this is the hardest part). Use events (SQS/Kafka) for cross-service communication instead of shared DB. Step 5: Repeat until the monolith is empty."

**Key Points:**  
- Strangler Fig pattern: incremental, not big-bang  
- API gateway fronts both monolith and new services  
- Extract by bounded context, starting with least-coupled  
- Database decomposition is the hardest part  
- Event-driven communication (SQS/Kafka) over shared DB  
- Each service owns its data  

---

### 43. How do namespaces and cgroups work inside Docker?

"Linux namespaces provide isolation - each container gets its own view of the system. 
PID namespace: container sees its process as PID 1. NET namespace: own network stack (IP, ports, routing). MNT namespace: own filesystem (overlay2). 
UTS namespace: own hostname. IPC namespace: isolated shared memory. 
User namespace: maps container root to unprivileged host user. Cgroups (control groups) limit resources: how much CPU, memory, disk I/O, and network bandwidth a container can use. Together, namespaces isolate WHAT a container sees, cgroups limit HOW MUCH it can use."

**Key Points:**  
- Namespaces = isolation (what the container sees)  
- Cgroups = resource limits (how much it can use)  
- PID, NET, MNT, UTS, IPC, User namespaces  
- Cgroups control: CPU, memory, I/O, PIDs  
- Containers are NOT VMs - they share the host kernel  
- This is why containers are lightweight vs VMs  

---

### 44. How do you design disaster recovery with defined RTO & RPO?
 

"RPO (Recovery Point Objective) = maximum acceptable data loss. RPO of 1 hour means you need backups/replication at least hourly. RPO of 0 = synchronous replication (Aurora Global, DynamoDB Global Tables). RTO (Recovery Time Objective) = how fast you must recover. RTO of minutes = active-active or warm standby. RTO of hours = pilot light. Architecture: Route 53 health checks trigger failover to DR region. Automate everything - runbooks fail under pressure. Test with quarterly gamedays. Cost increases as RTO/RPO decrease."

**Key Points:**  
- RPO = max data loss, RTO = max downtime  
- RPO 0: synchronous replication (most expensive)  
- RTO minutes: warm standby or active-active  
- RTO hours: pilot light (cheapest)  
- Route 53 health checks for automated failover  
- Test quarterly - untested DR plans don't work  

---

### 45. Production server CPU is 100% at 2 AM - what is your first action?

Step 1: Check if autoscaling is triggered - if yes, let it handle while you investigate. 
Step 2: SSH in and run `top` / `htop` to identify the process consuming CPU. 
Step 3: Check if it's a cron job or scheduled task (2 AM is a common schedule for batch jobs). 
Step 4: If it's the application, check recent deployments and correlate. 
Step 5: If it's a runaway process, capture diagnostics (strace, perf record) before killing it. 
Step 6: Scale horizontally if the system is degraded while you investigate. 
Step 7: Check for crypto mining malware if nothing in your stack explains it."

**Key Points:**  
- Check autoscaling first, don't panic  
- `top` / `htop` to identify the offending process  
- 2 AM = likely a cron job or batch process  
- Capture diagnostics before killing processes  
- Scale out to mitigate impact during investigation  
- Crypto mining malware is a real possibility - check for it  

---



🚨 Real DevOps Scenario — EC2 Not Reachable (Production Type Issue)

Recently, I practiced a common real-world troubleshooting scenario: EC2 instance suddenly became unreachable.

🔎 Troubleshooting steps I followed:

- Verified Security Group inbound rules (SSH / app ports)
- Checked NACL rules for blocked traffic
- Reviewed Route Table for internet gateway path
- Confirmed instance status checks & system logs
- Tested SSH connectivity and disk usage

💡 Key learning:
Most outages are not complex — they are usually network rules, permissions, or resource exhaustion.

✅ Fix approach:

- Corrected inbound rules
- Restarted networking service
- Validated monitoring alerts to avoid future impact

🎯 Lesson learned:
A structured troubleshooting approach saves time and prevents panic during incidents.

---


🚨 Scenario-Based SRE / DevOps Interview Questions (Real Production Cases)

🔹 Scenario 1 — Users suddenly report 502 errors from your Load Balancer. What do you do first?

Question: How would you troubleshoot this in production?

Answer:
I’d validate the flow layer by layer:

• Check target health — are instances/pods failing health checks?
• Validate backend app logs for crashes/timeouts
• Confirm security groups/NACL allow LB → backend traffic
• Inspect listener & target group configuration
• Verify backend port mapping & readiness probes
• Check Auto Scaling / Kubernetes replicas & resource usage


Most 502 issues come from unhealthy targets, timeout misconfiguration, or backend app failures — not the load balancer itself.

“Production is down. Users are reporting 502/503 errors. What will you do?”

✅ Structured Answer (What Interviewers Expect)

1️⃣ Stay Calm & Acknowledge
First, I would confirm:
Is it affecting all users or specific regions?
Since when did it start?
Any recent deployment or infra changes?

2️⃣ Check Monitoring & Alerts
Immediately check:
Application metrics (CPU, memory, request count)
Error rate dashboard
Load balancer health status
Recent deployment history
If using Amazon CloudWatch, I would check alarms and logs.

3️⃣ Identify Layer of Failure
I troubleshoot layer by layer:
🔹 Load Balancer Layer
Are targets healthy?
Any spike in 5xx from LB?
🔹 Application Layer
Check app logs
Check if instances are running
Check resource utilization
If using Auto Scaling with Amazon EC2, I verify:
Instances are healthy
No scaling failure
No crash due to memory leak
🔹 Database Layer If DB latency is high in Amazon RDS, it can cascade and cause 5xx errors.

`User → Load Balancer → Ingress → Service → Pod → Application`

4️⃣ Immediate Mitigation
Depending on root cause:
If bad deployment → Rollback immediately
If high traffic → Scale out
If instance crash → Replace unhealthy nodes
If DB bottleneck → Increase capacity or enable read replica
Goal: Restore service first, then investigate deeply.

5️⃣ Communication
Inform stakeholders
Share ETA
Update incident channel
Avoid blame during incident

6️⃣ Post-Incident (Very Important)
After recovery:
Perform RCA (Root Cause Analysis)
Document timeline
Add monitoring if gap found
Improve deployment strategy (Blue-Green / Canary)
Add autoscaling or better alerts if needed.

---

🔹 Scenario 2 — You must choose between ALB and NLB for a production system. How do you decide?

Question: When would you choose each?

Answer:
I decide based on traffic behavior:

Application-style routing → use ALB
• Path/host routing
• HTTP/HTTPS awareness
• Microservices ingress

High-performance TCP/UDP workloads → use NLB
• Ultra low latency
• Static IP requirement
• Millions of connections

Choice is workload-driven, not preference-driven.

🔹 Scenario 3 — A client requires static IP whitelisting but your app needs path-based routing. What’s your solution?

Answer:
Yes — common in advanced production architectures:

Example pattern:
Internet → NLB (static IP + performance) → ALB (smart routing)
Useful when:
• Clients require static IP whitelisting
• Need Layer-4 performance + Layer-7 routing
• Hybrid or legacy integrations exist

This pattern balances networking control with application intelligence.

🔹 Scenario 4 — Your organization has 40 VPCs that must communicate securely. What architecture would you design?

Question: What scales best?

Answer:
Manual peering becomes operational chaos.

Production solution:

• Central transit architecture
• Route segmentation
• Security isolation
• Policy-driven connectivity

This provides scalable routing, centralized control, and cleaner governance.

🔹 Scenario 5 — How do you securely connect App Servers to a Database in production?

Answer:
Never expose databases publicly.

Best practice:

• Private subnets for DB
• Strict security group referencing (app → DB only)
• No internet route for DB
• Encryption in transit
• IAM/secret management for credentials

Principle: least privilege + network isolation.

---

👉 “What actually happens when a pod restarts?”
Silence. Or generic answers.
Here’s what interviewers expect you to understand:
• How kubelet detects failure
 • How ReplicaSets maintain desired state
 • What happens to Service endpoints
 • How readiness & liveness probes behave
 • What happens to in-flight traffic
Kubernetes isn’t about kubectl commands.
It’s about control loops and state reconciliation.
If you’re in the 3–6 year range:
Be honest - can you explain pod lifecycle without Googling?

**How kubelet detects failure:**  
> "Kubelet runs on every node and continuously monitors containers. It executes liveness probes (HTTP, TCP, or exec) at configured intervals. If a liveness probe fails `failureThreshold` consecutive times, kubelet kills the container and restarts it based on the pod's `restartPolicy` (Always, OnFailure, Never). It also detects OOMKilled (exit code 137) via cgroup memory limits and CrashLoopBackOff when the container keeps failing on startup."

**How ReplicaSets maintain desired state:**  
> "The ReplicaSet controller watches the API server via informers. When a pod dies or enters a terminal state, the current replica count drops below `spec.replicas`. The controller's reconciliation loop detects the mismatch and creates a new pod spec. The scheduler assigns it to a node, and kubelet pulls the image and starts the container. This is the core control loop: observe > diff > act."

**What happens to Service endpoints:**  
> "The Endpoints controller watches pod status. When a pod becomes unready or terminates, the controller removes it from the Endpoints object. kube-proxy (or the CNI) updates iptables/IPVS rules on every node so traffic stops routing to the dead pod. The new pod only gets added back to endpoints after its readiness probe passes. There is a brief window where stale connections may still hit the terminating pod."

**How readiness & liveness probes behave during restart:**  
> "When kubelet restarts a container, the pod stays in Running phase but the container state is Waiting (CrashLoopBackOff) or Running if it starts successfully. Readiness probe starts fresh - the pod is marked NotReady until it passes. Service endpoints exclude it - no traffic flows until the new container is healthy. Liveness probe resets its initialDelaySeconds timer. If startupProbe is configured, liveness/readiness probes are paused until the startup probe succeeds."

**What happens to in-flight traffic:**  
> "Existing TCP connections to the terminating container receive SIGTERM. The container has terminationGracePeriodSeconds (default 30s) to finish processing. Well-behaved apps catch SIGTERM, stop accepting new connections, drain existing ones, and exit. If the app doesn't exit in time, kubelet sends SIGKILL. Meanwhile, the Endpoints update propagates asynchronously - there is a race condition where kube-proxy on some nodes may still route new requests to the dying pod for a few seconds. This is why preStop hooks with a small sleep (2-5s) are a best practice - they give endpoints time to propagate before the app starts shutting down."

**Key Points:**  
- Kubelet detects via liveness probes, OOM signals, and process exit codes  
- ReplicaSet controller reconciles desired vs actual count (observe > diff > act)  
- Endpoints controller removes unready/dead pods from Service routing  
- Readiness probe gates traffic; pod gets zero requests until healthy  
- In-flight requests depend on graceful shutdown + preStop hook timing  
- The entire system is asynchronous - race conditions exist between SIGTERM and endpoint removal  

---

 10 Kubernetes Interview Questions That Actually Matter in Production

1️⃣ Your pod is stuck in CrashLoopBackOff. Walk me through your troubleshooting process.
💡 Hint: kubectl logs --previous + kubectl describe pod reveals 80% of the story.
The other 20% is usually hiding in init containers or configuration issues.

2️⃣ How do you handle zero-downtime deployments in Kubernetes, and what can still go wrong?
💡 Hint: Rolling updates aren’t magic.
A misconfigured readinessProbe can send traffic to broken pods mid-deployment.

3️⃣ A node hits 100% memory. What happens to workloads and how do you prevent it?
💡 Hint: Understand the difference between:

Guaranteed
Burstable
BestEffort

These QoS classes decide eviction priority.

4️⃣ How would you design a multi-tenant Kubernetes cluster?
💡 Hint: Your isolation toolkit:

Namespaces
RBAC
NetworkPolicies
LimitRanges
ResourceQuotas

Without these → teams will collide.

5️⃣ Your HPA isn't scaling even though metrics exist. Why?
💡 Hint: Check:
metrics-server health
CPU request values
targetCPUUtilizationPercentage
Bad resource requests = broken scaling logic.

6️⃣ Why are Pod Disruption Budgets critical during node upgrades?
💡 Hint: Without PDBs, a node drain could terminate all replicas simultaneously.

That’s how production outages start.

7️⃣ A service is intermittently unreachable inside the cluster. How do you debug DNS?
💡 Hint: Start with:

kubectl exec
nslookup
CoreDNS logs
Misconfigured ndots values cause many internal DNS issues.

8️⃣ How do you secure Kubernetes secrets beyond base64 encoding?
💡 Hint: Production-grade approach:

Encryption at rest
External Secrets Operator
Vault / AWS Secrets Manager
Base64 alone is not security.

9️⃣Your Cluster Autoscaler isn’t adding nodes while pods remain pending. What do you check?
💡 Hint: Look for:

Node selectors
Taints & tolerations
Node group limits
Pods must match node constraints before scaling.

🔟 What does your Kubernetes observability stack look like?
💡 Hint: A complete stack includes:

Metrics → Prometheus
Logs → Loki / EFK
Traces → Tempo / Jaeger
Alerts → Alertmanager

---


🔹 1️⃣ “How would you migrate a monolithic application to microservices?”
They expected discussion around:
CI/CD redesign
Containerization strategy
Service communication
Monitoring changes
Deployment strategy
🔹 2️⃣ “How do you prevent a bad deployment from impacting all users?”
This went into:
Canary releases
Blue-green deployment
Feature flags
Rollback planning
🔹 3️⃣ “How do you design logging and monitoring for distributed systems?”
Not just tools — but:
Centralized logging
Correlation IDs
Alert thresholds
Avoiding alert fatigue
🔹 4️⃣ “How do you secure your entire DevOps lifecycle?”
Discussion included:
IAM policies
Pipeline security
Image scanning
Secret rotation
RBAC design
🔹 5️⃣ “How do you handle configuration management across environments?”
They expected clarity on:
Environment-specific variables
Secrets handling
Drift detection
GitOps principles
🔹 6️⃣ “If your CI pipeline takes 40 minutes, how would you optimize it?”
This tested:
Parallel jobs
Caching
Incremental builds
Test optimization
Artifact reuse
🔹 7️⃣ “What metrics do you track to measure DevOps maturity?”
Examples discussed:
Deployment frequency
Lead time for changes
Change failure rate
MTTR

---

## ✨ Real-World Scenarios

> **What interviewers are evaluating:**
> - Do you understand state management and its implications?
> - Can you reason about drift and idempotency?
> - Do you structure modules for reuse and clarity?
> - How do you handle secrets and environment separation?
> - What happens when a plan fails mid-apply?

**Do you understand state management and its implications?**
> "Yes. Terraform state is the single source of truth that maps your config to real cloud resources. It tracks metadata, dependencies, and resource attributes. Without it, Terraform can't plan or detect drift. Implications: it must be stored remotely (S3) for collaboration, encrypted for security (it contains sensitive outputs), locked (DynamoDB) to prevent concurrent corruption, and versioned for disaster recovery. Mismanaging state — deleting it, corrupting it, or skipping locking — is the #1 cause of Terraform incidents in production."

**Can you reason about drift and idempotency?**
> "Drift is when the real infrastructure diverges from what Terraform state expects — caused by manual changes, external automation, or another tool modifying resources. Terraform detects drift on every `plan` by comparing state vs cloud reality. Idempotency means running `terraform apply` multiple times with the same config produces the same result — if nothing has changed, the plan is empty. This is core to Terraform's declarative model: you describe the desired end state, not the steps to get there. If drift exists, Terraform's apply converges reality back to the declared config."

**Do you structure modules for reuse and clarity?**
> "Yes. I follow a `modules/` + `environments/` pattern. Child modules encapsulate a logical unit (e.g., EC2 + EBS + security group) with clear input variables and outputs. Root modules in `environments/dev|qa|prod` call the child modules with environment-specific values. Modules are versioned via Git tags so a change doesn't break all environments at once. Variables have descriptions, types, and sensible defaults. Outputs expose only what consumers need."

**How do you handle secrets and environment separation?**
> "Secrets never go in `.tf` or `.tfvars` files committed to Git. I pull them at runtime from AWS Secrets Manager or SSM Parameter Store using data sources. Variables holding secrets are marked `sensitive = true`. In CI/CD, secrets are injected as `TF_VAR_*` environment variables from the pipeline's secret store (GitHub Secrets, Vault). For environment separation, each env has its own directory, backend config, state file, and IAM role — so dev can never accidentally touch prod state."

**What happens when a plan fails mid-apply?**
> "Terraform saves state after each individual resource operation, not at the end. So if apply fails on resource #5 out of 10, resources 1–4 are already in state and won't be re-created on the next run. The failed resource may be partially created — Terraform marks it as tainted or errored. I fix the root cause (permissions, quota, bad config), then re-run `terraform apply`. It picks up from where it left off. If a resource is stuck in a bad state, I use `terraform apply -replace=<resource>` to force clean recreation."

---

### 49. Terraform state is accidentally deleted. What will you do?
**[Scenario]**
**Sample Answer:**
> "First, check if S3 versioning is enabled — if yes, restore the previous state version immediately. If versioning wasn't enabled, the resources still exist in the cloud but Terraform has no record. I'd use `terraform import` to bring each resource back under management. For large environments, `terraformer` can automate bulk imports. Then validate with `terraform plan` to confirm zero diff."
**Key Points:**
- Restore from S3 versioning (best case)
- `terraform import` to rebuild state manually
- `terraformer` for bulk recovery
- Cloud resources are unaffected — only tracking is lost

### 50. Two engineers run terraform apply at the same time. What happens?
**[Scenario]**
**Sample Answer:**
> "If you're using a remote backend with DynamoDB locking, the second apply will fail immediately with a lock error — only one operation can hold the lock at a time. Without locking, both runs read the same state, compute independent plans, and apply concurrently, causing state corruption and resource conflicts."
**Key Points:**
- With DynamoDB lock: second apply is blocked (safe)
- Without locking: state corruption and race conditions
- Always enable `dynamodb_table` in backend config
- CI/CD should serialize applies per workspace

### 51. terraform apply partially fails. How do you recover?
**[Scenario]**
**Sample Answer:**
> "Terraform writes state after each resource operation, so successfully created resources are already tracked. I check the error message, fix the root cause (permissions, quota, bad config), and run `terraform apply` again. Terraform picks up where it left off — it won't recreate resources that already exist in state. If a resource is in a broken state, I use `terraform taint` (or `terraform apply -replace`) to force recreation."
**Key Points:**
- State is saved incrementally — no rollback needed
- Fix the root cause, then re-run `terraform apply`
- `terraform apply -replace=<resource>` for broken resources
- Never manually delete state entries to "fix" things

### 52. You need to manage infra across multiple AWS/GCP/Azure accounts. How do you design it?
**[Scenario]**
**Sample Answer:**
> "I use provider aliases to define multiple providers in one config, each targeting a different account/region. For full isolation, I use separate root modules per account with their own state files and backend configs. Cross-account access is handled via IAM `assume_role` in the provider block. Shared modules live in a central registry or Git repo."
```hcl
provider "aws" {
  alias  = "prod"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::PROD_ACCOUNT:role/TerraformRole"
  }
}

provider "aws" {
  alias  = "dev"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::DEV_ACCOUNT:role/TerraformRole"
  }
}
```
**Key Points:**
- Provider aliases for multi-account in one config
- Separate state files per account for isolation
- `assume_role` for cross-account access
- Shared modules via Git/registry

### 53. Terraform keeps detecting changes even when nothing was modified. Why?
**[Scenario]**
**Sample Answer:**
> "This is phantom drift. Common causes: (1) a resource attribute is set by AWS after creation (like default tags, ARN suffixes) that doesn't match the config, (2) someone modified the resource manually outside Terraform, (3) a computed attribute keeps changing (timestamps, random values), or (4) provider bugs. Fix with `ignore_changes` for known volatile attributes, or import the manual change."
```hcl
lifecycle {
  ignore_changes = [tags["LastModified"], ebs_optimized]
}
```
**Key Points:**
- External/manual changes cause state-vs-cloud mismatch
- Computed attributes (timestamps, generated names) cause diffs
- `ignore_changes` for attributes managed outside Terraform
- Run `terraform refresh` then `terraform plan` to isolate cause

### 54. A resource was manually deleted in cloud but still exists in Terraform state. How do you fix it?
**[Scenario]**
**Sample Answer:**
> "Run `terraform plan` — it will show a 'create' action because the resource exists in state but not in the cloud. If you want it back, run `terraform apply` to recreate it. If the deletion was intentional, run `terraform state rm <resource_address>` to remove it from state without Terraform trying to recreate it."
**Key Points:**
- `terraform plan` detects the missing resource
- `terraform apply` to recreate it
- `terraform state rm` to accept the deletion
- Prevent with RBAC restricting manual cloud changes

### 55. You need different configurations for dev, stage, and prod. How do you manage them?
**[Scenario]**
**Sample Answer:**
> "I use a directory-per-environment pattern: `environments/dev/`, `environments/stage/`, `environments/prod/`. Each calls the same shared modules with environment-specific `.tfvars` files. Each environment has its own backend config with a separate state file key. This gives full isolation while keeping the module code DRY."
```
environments/
├── dev/
│   ├── main.tf          # calls modules/
│   ├── backend.tf       # key = "dev/terraform.tfstate"
│   └── terraform.tfvars # t2.micro, small EBS
├── stage/
│   └── ...
└── prod/
    ├── main.tf
    ├── backend.tf       # key = "prod/terraform.tfstate"
    └── terraform.tfvars # t3.medium, large EBS
```
**Key Points:**
- Directory-per-environment for state isolation
- Shared modules for DRY code
- Separate `.tfvars` per environment
- Separate state files prevent cross-env blast radius

### 56. Secrets are exposed in Terraform files. How do you secure them?
**[Scenario]**
**Sample Answer:**
> "Never hardcode secrets in `.tf` or `.tfvars` files. Pull secrets at runtime using `data` sources from AWS Secrets Manager or SSM Parameter Store. Mark variables as `sensitive = true` so they're redacted from plan output. Add `*.tfvars` with secrets to `.gitignore`. In CI/CD, inject secrets as environment variables (`TF_VAR_` prefix)."
```hcl
data "aws_secretsmanager_secret_version" "db_pass" {
  secret_id = "prod/db-password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_pass.secret_string
}
```
**Key Points:**
- `sensitive = true` on variables
- Secrets Manager / SSM Parameter Store as data sources
- `TF_VAR_*` environment variables in CI/CD
- `.gitignore` for sensitive `.tfvars`

### 57. A module change breaks multiple environments. How do you prevent this?
**[Scenario]**
**Sample Answer:**
> "Version-pin your modules. Use Git tags or a Terraform registry with semantic versioning. Environments reference a specific version, not `main` branch. Roll out changes progressively — update dev first, validate, then stage, then prod. Use `terraform plan` in CI to catch breaking changes before apply."
```hcl
module "ec2" {
  source  = "git::https://github.com/org/modules.git//ec2?ref=v1.2.0"
}
```
**Key Points:**
- Pin module versions with Git tags or registry versions
- Progressive rollout: dev → stage → prod
- `terraform plan` in CI as a gate before apply
- Semantic versioning for breaking vs non-breaking changes

### 58. Terraform deployment deletes a critical resource. How do you stop this in the future?
**[Scenario]**
**Sample Answer:**
> "Add `lifecycle { prevent_destroy = true }` on all critical resources (databases, EBS volumes, S3 buckets). Use `terraform plan` review in CI/CD as a mandatory gate. Set up policy-as-code with Sentinel or OPA to block plans that destroy protected resource types. Enable S3 versioning on state for recovery."
**Key Points:**
- `prevent_destroy = true` on critical resources
- Mandatory `terraform plan` review before apply
- Sentinel / OPA policies to block destructive operations
- S3 state versioning for disaster recovery

### 59. CI/CD pipeline runs Terraform but fails due to permission issues. How do you debug?
**[Scenario]**
**Sample Answer:**
> "First, check the error message — AWS returns specific 'AccessDenied' errors with the action and resource ARN. Verify the IAM role/user attached to the CI runner has the required permissions. Use `TF_LOG=DEBUG` to get full API call traces. Check STS `assume_role` if cross-account. Validate the role trust policy allows the CI service to assume it."
**Key Points:**
- `TF_LOG=DEBUG` for full API trace
- Check IAM role policies attached to CI runner
- Verify `assume_role` trust policy for cross-account
- AWS CloudTrail shows denied API calls with exact reason

### 60. Terraform state file is locked and cannot be unlocked. What do you do?
**[Scenario]**
**Sample Answer:**
> "This happens when a previous apply crashed or timed out without releasing the DynamoDB lock. First, confirm no other operation is genuinely running. Then use `terraform force-unlock <LOCK_ID>` to release it. The lock ID is shown in the error message. Never force-unlock if another apply is actually in progress — it will cause state corruption."
**Key Points:**
- `terraform force-unlock <LOCK_ID>` to release
- Verify no other operation is running first
- Lock ID is printed in the error message
- Investigate why the previous run didn't release (crash/timeout)

### 61. You need to rotate cloud credentials without downtime. How do you implement it?
**[Scenario]**
**Sample Answer:**
> "Create the new credentials first (new IAM access key), update the secret store (Secrets Manager/Vault), then deactivate the old key. Never delete the old key immediately — deactivate first, monitor for failures, then delete after a grace period. If Terraform itself uses the credentials, update the CI/CD environment variables and run a no-op `terraform plan` to validate before deleting the old key."
**Key Points:**
- Create new → update references → deactivate old → delete old
- Grace period between deactivate and delete
- Validate with `terraform plan` after rotation
- Automate with Secrets Manager auto-rotation if possible

### 62. Terraform plan shows unexpected resource replacement. How do you analyze it?
**[Scenario]**
**Sample Answer:**
> "Check the plan output — Terraform marks attributes causing replacement with `# forces replacement`. Common causes: changing an immutable attribute (AMI ID, subnet), renaming a resource, or changing the `provider`. Run `terraform plan` with `-detailed-exitcode` and review the diff. If the replacement is unwanted, use `lifecycle { ignore_changes }` or `moved` block for renames."
**Key Points:**
- Look for `# forces replacement` in plan output
- Immutable attributes (AMI, key_name) trigger replacement
- `moved` block handles renames without destroy
- `ignore_changes` for attributes you don't want to track

### 63. Terraform version upgrade breaks existing code. How do you handle it safely?
**[Scenario]**
**Sample Answer:**
> "Pin the Terraform version using `required_version` in the `terraform` block. Before upgrading, read the changelog for breaking changes. Test the upgrade in dev first. Run `terraform plan` to see if the new version changes behavior. Use `terraform state replace-provider` if provider naming changed. Keep the state file backed up before any upgrade."
```hcl
terraform {
  required_version = ">= 1.5.0, < 2.0.0"
}
```
**Key Points:**
- `required_version` prevents accidental upgrades
- Test in dev/stage before prod
- Backup state before upgrading
- Read changelog for deprecations and breaking changes

### 64. Terraform code is duplicated across teams. How do you standardize it?
**[Scenario]**
**Sample Answer:**
> "Build a shared module library in a central Git repo or private Terraform registry. Enforce module usage via Sentinel/OPA policies — teams must use approved modules instead of raw resources. Define naming conventions, tagging standards, and required variables in module interfaces. Conduct module reviews the same way you review application code."
**Key Points:**
- Central module registry (Git repo or Terraform Cloud)
- Policy-as-code to enforce module usage
- Standardized naming, tagging, and variable interfaces
- Module versioning with semantic releases

### 65. Drift is detected in production. What steps do you take?
**[Scenario]**
**Sample Answer:**
> "Run `terraform plan` to see the full diff between state and reality. Determine if the drift was intentional (emergency manual fix) or accidental. If intentional, either update the Terraform code to match the manual change or import the new state. If accidental, run `terraform apply` to bring the resource back to the desired config. Document the incident and tighten RBAC to prevent manual changes."
**Key Points:**
- `terraform plan` to identify exact drift
- Decide: accept drift (update code) or correct it (apply)
- `terraform refresh` updates state to match cloud reality
- Prevent recurrence with RBAC and change management

### 66. You are asked to implement approval before terraform apply. How do you do it?
**[Scenario]**
**Sample Answer:**
> "In CI/CD, split the pipeline into `plan` and `apply` stages with a manual approval gate between them. The plan output is saved to a file (`terraform plan -out=tfplan`) and reviewed. Only after approval does the pipeline run `terraform apply tfplan`. Terraform Cloud/Enterprise has native run approvals. GitHub Actions supports `environment` protection rules for this."
```yaml
# GitHub Actions example
jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - run: terraform plan -out=tfplan
      - uses: actions/upload-artifact@v4
        with: { name: tfplan, path: tfplan }
  apply:
    needs: plan
    environment: production    # requires manual approval
    steps:
      - uses: actions/download-artifact@v4
        with: { name: tfplan }
      - run: terraform apply tfplan
```
**Key Points:**
- `terraform plan -out=tfplan` → review → `terraform apply tfplan`
- Manual approval gate between plan and apply
- Terraform Cloud has built-in run approvals
- GitHub/GitLab environment protection rules

### 67. Terraform performance is slow in large infrastructures. How do you optimize it?
**[Scenario]**
**Sample Answer:**
> "Break the monolith into smaller state files using directory-per-service or directory-per-team. Use `-target` for focused applies during development. Enable parallelism (`-parallelism=20`). Use `terraform plan -refresh=false` when you know state is current. Reference outputs across states with `terraform_remote_state` data source instead of putting everything in one state."
**Key Points:**
- Split large state into smaller, scoped states
- `-parallelism=N` to increase concurrent operations
- `-refresh=false` to skip state refresh when safe
- `-target` for focused applies (dev only, not CI)

### 68. When would you avoid using Terraform and choose another IaC tool?
**[Scenario]**
**Sample Answer:**
> "Avoid Terraform when: (1) you need imperative/procedural logic — use Pulumi or CDK instead, (2) you're managing only Kubernetes resources — use Helm/Kustomize, (3) you need OS-level configuration — use Ansible, (4) the team is all-in on one cloud with native IaC — AWS CloudFormation/CDK might integrate better, or (5) you need real-time event-driven infra changes — Terraform is declarative and plan/apply doesn't fit reactive patterns."
**Key Points:**
- Kubernetes-only: Helm / Kustomize
- Configuration management: Ansible / Chef
- Imperative logic needed: Pulumi / AWS CDK
- Single-cloud deep integration: CloudFormation / ARM templates
- Terraform excels at multi-cloud, declarative, stateful infra

---