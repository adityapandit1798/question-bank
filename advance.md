# Advanced DevOps Interview Questions

## Section 1 - System Design & Architecture

### 1. How would you design a highly available multi-tenant system in AWS?
**[Design]**  
**Sample Answer:**  
> "I'd use a shared EKS cluster with namespace-per-tenant isolation. Each tenant gets dedicated namespace, ResourceQuotas, NetworkPolicies, and separate databases (RDS per tenant or schema-per-tenant). An ALB with host-based routing sends traffic to the right namespace. IAM roles per tenant restrict AWS resource access. Data is encrypted at rest (KMS with tenant-specific keys) and in transit (TLS). For HA, the cluster spans 3 AZs with pod anti-affinity rules."

**Key Points:**  
- Namespace isolation + NetworkPolicies + ResourceQuotas  
- Separate data stores per tenant (RDS/DynamoDB)  
- KMS encryption with per-tenant keys  
- Multi-AZ EKS + ALB host-based routing  
- IAM roles scoped per tenant  

---

### 2. How would you reduce API response time from 30s to under 5s?
**[Design]**  
**Sample Answer:**  
> "First, profile to find the bottleneck - usually it's database queries or external API calls. Add Redis/ElastiCache for hot data. Optimize slow queries with proper indexes and EXPLAIN ANALYZE. Move heavy processing to async workers (SQS + Lambda or Celery). Add connection pooling (PgBouncer). If it's compute-bound, scale horizontally behind ALB. Use CloudFront for cacheable responses. Implement pagination instead of returning large datasets."

**Key Points:**  
- Profile first - don't guess (APM tools like X-Ray, Datadog)  
- Caching: Redis/ElastiCache for repeated reads  
- Database: indexing, query optimization, connection pooling  
- Async: offload heavy work to SQS/Lambda/Celery  
- CDN: CloudFront for cacheable API responses  

---

### 3. How would you rotate secrets securely across multiple EC2/Windows servers?
**[Design]**  
**Sample Answer:**  
> "Store all secrets in AWS Secrets Manager with automatic rotation enabled (Lambda rotation function). Applications pull secrets at startup using the SDK, not from env vars or files. For EC2/Windows, use SSM Parameter Store with IAM instance profiles - no hardcoded credentials. The rotation Lambda creates new secret, updates the service, tests it, then marks it current. Use Secrets Manager's versioning (AWSCURRENT/AWSPREVIOUS) so apps can gracefully handle rotation without downtime."

**Key Points:**  
- Secrets Manager with auto-rotation (Lambda function)  
- IAM instance profiles - never hardcode credentials  
- AWSCURRENT/AWSPREVIOUS versioning for graceful rotation  
- Applications pull secrets via SDK at runtime  
- SSM Parameter Store for non-rotating config  

---

### 4. How would you deploy a FastAPI app on EKS?
**[Design]**  
**Sample Answer:**  
> "Containerize with a multi-stage Dockerfile (build deps, then copy to slim image with uvicorn). Push to ECR. Create Kubernetes manifests: Deployment with resource limits, readiness probe on /health, HPA based on CPU/request latency. Expose via ClusterIP Service + Ingress (ALB Ingress Controller). Use ConfigMaps for config, Secrets for credentials. CI/CD pipeline: GitHub Actions builds image, pushes to ECR, updates manifests, ArgoCD syncs to cluster."

**Key Points:**  
- Multi-stage Docker build with uvicorn  
- ECR for image registry  
- Deployment + Service + Ingress (ALB controller)  
- Readiness probe on /health endpoint  
- HPA for autoscaling, resource limits to prevent noisy neighbors  
- ArgoCD or Flux for GitOps-based deployment  

---

### 5. How do you implement CI/CD in AWS?
**[Design]**  
**Sample Answer:**  
> "For AWS-native: CodePipeline orchestrates the flow, CodeBuild compiles/tests/builds Docker image, CodeDeploy handles rolling/blue-green deployment to ECS/EKS/EC2. For open-source: GitHub Actions or Jenkins for CI, ArgoCD for CD to Kubernetes. Pipeline stages: lint > unit test > build image > push to ECR > deploy to staging > integration tests > manual approval > deploy to prod. Infrastructure changes go through a separate Terraform pipeline with plan > approve > apply."

**Key Points:**  
- AWS-native: CodePipeline + CodeBuild + CodeDeploy  
- Open-source: GitHub Actions/Jenkins + ArgoCD  
- Stages: lint > test > build > staging > approval > prod  
- Separate pipeline for infrastructure (Terraform)  
- Artifacts stored in ECR (images) and S3 (build outputs)  

---

### 6. How do you handle zero-downtime deployments?
**[Design]**  
**Sample Answer:**  
> "In Kubernetes: rolling update strategy with maxSurge=1, maxUnavailable=0 ensures old pods stay up until new ones pass readiness probes. Add preStop hooks with a 5s sleep to allow endpoint propagation before shutdown. For databases, use backward-compatible migrations only - add columns, never rename/delete in the same release. For ECS: use blue-green with ALB target group switching. Always have rollback ready: keep previous image tag, use `kubectl rollout undo` or revert the Git commit in GitOps."

**Key Points:**  
- Rolling update: maxSurge=1, maxUnavailable=0  
- Readiness probes gate traffic to new pods  
- preStop hooks handle endpoint propagation delay  
- Database migrations must be backward-compatible  
- Blue-green for ECS; rolling for EKS  
- Instant rollback via previous image or Git revert  

---

### 7. How do you secure inter-service communication in Kubernetes on AWS?
**[Design]**  
**Sample Answer:**  
> "Layer 1: NetworkPolicies to restrict which pods can talk to which (default deny all, then allow specific). Layer 2: Service mesh (Istio or AWS App Mesh) for mTLS - every pod gets a sidecar that encrypts all traffic with mutual TLS certificates, automatically rotated. Layer 3: IRSA (IAM Roles for Service Accounts) so each service has least-privilege AWS access. Layer 4: OPA/Gatekeeper policies to enforce security standards across all deployments."

**Key Points:**  
- NetworkPolicies: default deny, explicit allow  
- Service mesh (Istio/App Mesh) for automatic mTLS  
- IRSA for fine-grained AWS IAM per service  
- OPA/Gatekeeper for policy enforcement  
- Encrypt all traffic - never trust the network  

---

### 8. How do you monitor 1000+ servers efficiently?
**[Design]**  
**Sample Answer:**  
> "Use a pull-based system like Prometheus with node_exporter on every server, federated across regions. For AWS-native, CloudWatch agent with custom metrics + CloudWatch Composite Alarms to reduce noise. Centralize logs with Fluentd/Fluent Bit shipping to OpenSearch or CloudWatch Logs Insights. Dashboards in Grafana with per-team views. Alert routing via PagerDuty with escalation policies. At 1000+ scale, use Thanos or Cortex on top of Prometheus for long-term storage and global querying."

**Key Points:**  
- Prometheus + node_exporter (pull-based, scales well)  
- Thanos/Cortex for multi-cluster aggregation and long-term storage  
- Fluentd/Fluent Bit for centralized logging  
- Grafana dashboards per team/service  
- PagerDuty with escalation policies for alerting  
- CloudWatch at scale needs Composite Alarms to reduce noise  

---

### 9. How do you reduce AWS cost for large-scale infrastructure?
**[Design]**  
**Sample Answer:**  
> "Start with visibility: Cost Explorer + CUR (Cost and Usage Report) to identify top spenders. Quick wins: Reserved Instances or Savings Plans for steady-state (up to 72% savings), Spot Instances for fault-tolerant workloads (up to 90% savings), right-sizing with Compute Optimizer. Storage: S3 Lifecycle policies to move old data to Glacier. Kubernetes: Karpenter for efficient node provisioning, pod right-sizing with VPA. Governance: tag everything, set AWS Budgets with alerts, shut down dev/staging outside business hours."

**Key Points:**  
- Visibility first: Cost Explorer, CUR, tagging  
- Compute: Reserved Instances, Savings Plans, Spot  
- Right-sizing: Compute Optimizer, VPA in Kubernetes  
- Storage: S3 Lifecycle rules, EBS type optimization  
- Scheduling: shut down non-prod outside hours  
- Karpenter for Kubernetes node cost optimization  

---

### 10. How would you architect a disaster recovery strategy?
**[Design]**  
**Sample Answer:**  
> "Define RTO and RPO first - they drive the architecture. For pilot light: keep AMIs/containers and DB replicas in the DR region, scale up on failover. For warm standby: run a scaled-down copy of production in the DR region behind Route 53 failover routing. For active-active: full deployment in both regions with Route 53 latency-based routing and DynamoDB Global Tables or Aurora Global Database. Automate failover with health checks and Lambda. Test quarterly with gameday exercises."

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
**[Conceptual]**  
**Sample Answer:**  
> "DNS resolves the domain to the ALB's IP. The client makes a TCP connection to the ALB. For HTTPS, TLS termination happens at the ALB (SSL certificate via ACM). The ALB evaluates listener rules (host/path-based) to pick a target group. Within the target group, the routing algorithm (round-robin or least-outstanding-requests) selects a healthy target. The ALB opens a new TCP connection to the target (or reuses via keep-alive). Health checks continuously remove unhealthy targets. The response flows back through the ALB to the client."

**Key Points:**  
- DNS > TCP connection > TLS termination at ALB  
- Listener rules match host/path to target groups  
- Round-robin or least-outstanding-requests selects a target  
- Only healthy targets receive traffic (health checks)  
- ALB operates at Layer 7 (HTTP); NLB at Layer 4 (TCP)  

---

### 12. How would you troubleshoot a Kubernetes pod stuck in CrashLoopBackOff?
**[Scenario]**  
**Sample Answer:**  
> "Step 1: `kubectl describe pod` to check events - look at exit codes and restart count. Step 2: `kubectl logs --previous` to see why the last container crashed. Step 3: Check if it's a config issue (missing env vars, bad ConfigMap/Secret mount). Step 4: Check resource limits - OOMKilled (exit 137) means the container needs more memory. Step 5: If the container exits too fast for logs, override the command with `sleep infinity` to exec into it and debug manually."

**Key Points:**  
- `kubectl describe pod` > events and exit codes  
- `kubectl logs --previous` > last crash output  
- Exit 137 = OOMKilled, Exit 1 = app error  
- Common causes: missing env vars, bad config, insufficient resources  
- Debug trick: override entrypoint with `sleep infinity`  

---

### 13. A deployment was successful but users report 502/503 errors. What could be the possible reasons?
**[Scenario]**  
**Sample Answer:**  
> "502 means the ALB got an invalid response from the backend. 503 means no healthy targets. Check: (1) readiness probe misconfigured - pod is in the target group but not ready to serve, (2) app started but hasn't finished loading (slow startup without startupProbe), (3) security group doesn't allow ALB to reach the pod/instance, (4) app is crashing right after startup, (5) target group health check path returns non-200. Also check if the new deployment's resource requests are starving the pods."

**Key Points:**  
- 502: backend sent invalid/no response (app crash, timeout)  
- 503: no healthy targets in the target group  
- Readiness probe or health check misconfigured  
- Security group blocking ALB-to-target traffic  
- Slow startup without startupProbe  
- Check ALB access logs + target group health status  

---

### 14. What steps would you take if a CI/CD pipeline suddenly starts failing after working for months?
**[Scenario]**  
**Sample Answer:**  
> "Check what changed: recent commits, dependency updates, infra changes. Read the exact error message. Common causes: (1) expired credentials/tokens, (2) a dependency published a breaking version (no version pinning), (3) Docker base image updated with breaking changes, (4) rate limiting from registry/API, (5) runner disk full or out of memory, (6) external service down (npm registry, Docker Hub). Fix: pin dependency versions, rotate credentials, check runner health, add retry logic for transient failures."

**Key Points:**  
- Read the error message first  
- Credentials/token expiry is the #1 cause  
- Unpinned dependencies break builds silently  
- Docker Hub rate limits hit CI runners hard  
- Runner resource exhaustion (disk, memory)  
- Prevention: pin versions, alert on credential expiry  

---

### 15. How does Horizontal Pod Autoscaler (HPA) decide when to scale pods?
**[Conceptual]**  
**Sample Answer:**  
> "HPA queries the metrics API every 15 seconds (default). It calculates: desiredReplicas = ceil(currentReplicas * (currentMetric / targetMetric)). For CPU: if target is 50% and current average is 80%, HPA scales up. It supports CPU, memory, and custom metrics (requests/second via Prometheus Adapter). There's a stabilization window (default 5 min for scale-down) to prevent flapping. HPA respects minReplicas and maxReplicas bounds."

**Key Points:**  
- Formula: desiredReplicas = ceil(current * (currentMetric / target))  
- Default check interval: 15 seconds  
- Scale-down stabilization: 5 minutes (prevents flapping)  
- Supports CPU, memory, custom metrics, external metrics  
- Requires metrics-server installed in the cluster  

---

### 16. Your CPU usage spikes to 95% in production after a new release. How will you investigate?
**[Scenario]**  
**Sample Answer:**  
> "Step 1: Identify which pods/instances are spiking (Grafana/CloudWatch). Step 2: Correlate with the deployment timestamp - did the spike start exactly at deploy time? Step 3: Compare the new code diff for CPU-intensive changes (tight loops, missing pagination, regex backtracking). Step 4: Profile in staging - attach a profiler (py-spy for Python, async-profiler for Java). Step 5: Check if it's a resource leak (growing thread count, connection pool exhaustion). Immediate mitigation: rollback while investigating."

**Key Points:**  
- Correlate spike with deployment time  
- Review code diff for CPU-intensive changes  
- Profile with py-spy / async-profiler / perf  
- Check for infinite loops, regex backtracking, missing pagination  
- Rollback immediately, investigate on staging  

---

### 17. How do you implement zero downtime deployments in Kubernetes?
**[Conceptual]**  
**Sample Answer:**  
> "Use rolling update strategy: maxSurge=1, maxUnavailable=0 - Kubernetes creates a new pod before killing an old one. Configure readiness probes so traffic only hits pods that are actually ready. Add a preStop lifecycle hook (sleep 5s) to allow time for endpoints to depropagation before the container receives SIGTERM. Ensure the app handles SIGTERM gracefully - stop accepting new connections, drain existing ones. For database changes, use expand-and-contract migrations."

**Key Points:**  
- Rolling update: maxSurge=1, maxUnavailable=0  
- Readiness probe gates traffic to new pods  
- preStop hook (sleep 5s) for endpoint propagation  
- Graceful shutdown on SIGTERM  
- Database: backward-compatible migrations only  

---

### 18. A Docker container exits immediately after starting. How do you debug it?
**[Scenario]**  
**Sample Answer:**  
> "Step 1: `docker logs <container>` to see stdout/stderr. Step 2: `docker inspect <container>` to check exit code (137=OOM, 1=app error, 127=command not found, 126=permission denied). Step 3: Run interactively: `docker run -it <image> /bin/sh` to get a shell and test the entrypoint manually. Step 4: Check if the CMD/ENTRYPOINT is correct in the Dockerfile. Step 5: Verify all required env vars and mounted volumes are present. Common cause: foreground vs background process - the main process must run in the foreground."

**Key Points:**  
- `docker logs` + `docker inspect` for exit code  
- Exit 137=OOM, 1=app error, 127=command not found  
- Run interactively with `/bin/sh` to debug  
- Main process must run in foreground (not daemonized)  
- Check CMD/ENTRYPOINT, env vars, volume mounts  

---

### 19. What is the difference between Infrastructure as Code and Configuration Management?
**[Conceptual]**  
**Sample Answer:**  
> "IaC (Terraform, CloudFormation) provisions infrastructure - VPCs, EC2, RDS, load balancers. It's declarative and handles resource lifecycle (create, update, destroy). Configuration Management (Ansible, Chef, Puppet) configures existing servers - installs packages, manages files, starts services. IaC answers 'what infrastructure exists?' while CM answers 'how is this server configured?' In practice, Terraform creates the EC2 instance, Ansible configures what runs on it."

**Key Points:**  
- IaC: provisions infrastructure (Terraform, CloudFormation)  
- CM: configures existing servers (Ansible, Chef, Puppet)  
- IaC = declarative resource lifecycle  
- CM = desired state of server configuration  
- They complement each other, not compete  

---

### 20. If a database suddenly becomes slow, what metrics would you check first?
**[Scenario]**  
**Sample Answer:**  
> "Check in order: (1) CPU/memory of the DB instance - is it maxed out? (2) Active connections vs max connections - connection pool exhaustion? (3) Slow query log - which queries are taking the longest? (4) IOPS and disk throughput - are you hitting EBS limits? (5) Replication lag - is a replica falling behind? (6) Lock waits - are queries blocking each other? (7) Table sizes - has a table grown unexpectedly? Then correlate with recent deployments or traffic spikes."

**Key Points:**  
- CPU/memory utilization of DB instance  
- Active connections vs connection limit  
- Slow query log (EXPLAIN ANALYZE on top offenders)  
- IOPS/throughput hitting EBS volume limits  
- Replication lag and lock contention  
- Correlate with recent code deployments  

---

### 21. Your Prometheus alerts are firing continuously even though the system looks healthy. What could be wrong?
**[Scenario]**  
**Sample Answer:**  
> "Check: (1) Stale or incorrect alert thresholds that don't match current baseline (system grew, old thresholds too tight). (2) Flapping metrics causing alerts to fire/resolve/fire repeatedly - need hysteresis or `for` duration in alert rules. (3) Prometheus scrape targets returning stale/cached data. (4) Time drift between Prometheus and targets causing incorrect rate() calculations. (5) Label cardinality explosion making aggregations incorrect. (6) The system IS unhealthy but the dashboard is showing averaged/aggregated data that hides the issue."

**Key Points:**  
- Stale thresholds that don't match current baseline  
- Missing `for` duration causes flapping  
- Time drift breaks rate() calculations  
- Label cardinality explosion skews aggregations  
- Dashboard aggregation can hide per-instance issues  
- Review and tune alert thresholds regularly  

---

### 22. A Kubernetes node goes into NotReady state. What troubleshooting steps would you take?
**[Scenario]**  
**Sample Answer:**  
> "Step 1: `kubectl describe node` to check conditions (MemoryPressure, DiskPressure, PIDPressure, NetworkUnavailable). Step 2: SSH into the node and check kubelet: `systemctl status kubelet` + `journalctl -u kubelet`. Step 3: Check if the node can reach the API server (network/firewall issue). Step 4: Check disk space (`df -h`) and memory (`free -m`). Step 5: Check if the container runtime (containerd/docker) is healthy. Step 6: If the node is unrecoverable, cordon + drain + replace it."

**Key Points:**  
- `kubectl describe node` for conditions and events  
- Check kubelet status and logs on the node  
- Common causes: disk full, OOM, kubelet crash, network partition  
- Verify API server connectivity from the node  
- Cordon > drain > replace if unrecoverable  

---

### 23. What is the difference between Liveness Probe and Readiness Probe in Kubernetes?
**[Conceptual]**  
**Sample Answer:**  
> "Liveness probe answers 'is the container alive?' - if it fails, kubelet kills and restarts the container. Use it to detect deadlocks or hung processes. Readiness probe answers 'can the container serve traffic?' - if it fails, the pod is removed from Service endpoints but NOT restarted. Use it for startup delays, dependency checks, or temporary overload. There's also startupProbe for slow-starting apps - it disables liveness/readiness until the app is initialized."

**Key Points:**  
- Liveness: failed = container restarted (detect deadlocks)  
- Readiness: failed = removed from Service endpoints (no traffic)  
- Startup: protects slow-starting apps from liveness kills  
- Liveness should NOT check dependencies (causes cascading restarts)  
- Readiness CAN check dependencies (DB connectivity, etc.)  

---

### 24. How would you secure secrets in a CI/CD pipeline?
**[Conceptual]**  
**Sample Answer:**  
> "Never store secrets in code or pipeline config files. Use the platform's native secret store: GitHub Secrets, GitLab CI Variables (masked + protected), Jenkins Credentials. For runtime, pull from AWS Secrets Manager or HashiCorp Vault using short-lived tokens. Rotate secrets regularly and alert on expiry. Mask secrets in logs (most CI platforms do this automatically). Use OIDC federation (GitHub Actions > AWS) instead of long-lived access keys. Audit secret access with CloudTrail."

**Key Points:**  
- Platform-native secret stores (GitHub Secrets, GitLab Variables)  
- Runtime: Secrets Manager or Vault  
- OIDC federation instead of long-lived keys  
- Mask secrets in CI logs  
- Rotate regularly, alert on expiry  
- Audit access with CloudTrail  

---

### 25. How do you investigate memory leaks in a containerized application?
**[Scenario]**  
**Sample Answer:**  
> "Step 1: Confirm it's a leak - check if container memory usage grows monotonically over time (Grafana + container_memory_usage_bytes). Step 2: Check OOMKilled events in `kubectl describe pod`. Step 3: Profile the app: for Python use tracemalloc/memory_profiler, for Java use jmap heap dump + Eclipse MAT, for Go use pprof. Step 4: Look for common causes: unclosed connections, growing caches without eviction, event listener accumulation. Step 5: Reproduce in staging with load testing (k6/locust) while profiling."

**Key Points:**  
- Monitor container_memory_usage_bytes over time  
- Profile: tracemalloc (Python), jmap (Java), pprof (Go)  
- Common causes: unclosed connections, unbounded caches  
- OOMKilled (exit 137) confirms the container hit its limit  
- Reproduce with load testing in staging  

---

### 26. Your Terraform deployment failed halfway. How do you recover from the inconsistent state?
**[Scenario]**  
**Sample Answer:**  
> "Terraform saves state after each resource operation, so successfully created resources are already tracked. Check the error, fix the root cause (permission, quota, invalid config), and run `terraform apply` again - it picks up where it left off. If a resource is stuck in a bad state, use `terraform apply -replace=<resource>` to force recreation. Never manually edit the state file unless absolutely necessary. If state is corrupted, restore from S3 versioning."

**Key Points:**  
- State is saved incrementally - no full rollback needed  
- Fix root cause, re-run `terraform apply`  
- `-replace=<resource>` for stuck/broken resources  
- Never manually edit state unless last resort  
- S3 versioning for state recovery  

---

### 27. What are the key SLIs, SLOs, and SLAs you track for a production system?
**[Conceptual]**  
**Sample Answer:**  
> "SLI (indicator) = the metric: request latency, error rate, availability, throughput. SLO (objective) = internal target: p99 latency < 200ms, error rate < 0.1%, availability 99.95%. SLA (agreement) = contractual promise to customers with penalties: 99.9% uptime or credits issued. I track: latency (p50, p95, p99), error rate (5xx/total), availability (successful requests/total), and saturation (CPU, memory, disk). Error budgets (100% - SLO) determine how fast we can ship risky changes."

**Key Points:**  
- SLI = measurement, SLO = target, SLA = contract  
- Key SLIs: latency, error rate, availability, saturation  
- Error budget = 100% - SLO (spend it on velocity)  
- SLOs should be slightly stricter than SLAs  
- Measure from the user's perspective, not the server's  

---

### 28. A microservice suddenly starts returning high latency. What tools would you use to debug it?
**[Scenario]**  
**Sample Answer:**  
> "Start with distributed tracing (Jaeger/X-Ray) to see which span in the request chain is slow. Check Grafana dashboards for the service: request rate, latency percentiles, error rate (RED method). Look at upstream dependencies - is a database or external API slow? Check resource utilization (CPU, memory, network). Review recent deployments. Use APM tools (Datadog, New Relic) for code-level profiling. Check connection pool metrics - exhaustion causes queuing."

**Key Points:**  
- Distributed tracing (Jaeger/X-Ray) to isolate the slow span  
- RED method: Rate, Errors, Duration  
- Check upstream dependencies (DB, external APIs)  
- APM for code-level bottleneck identification  
- Connection pool exhaustion causes queuing latency  
- Correlate with recent deployments  

---

### 29. How would you design a highly available system that can handle traffic spikes during peak sales?
**[Design]**  
**Sample Answer:**  
> "Multi-AZ deployment behind ALB with Auto Scaling Groups (EC2) or HPA (Kubernetes). Pre-scale before the event based on historical data - don't rely solely on reactive scaling. Use CloudFront + S3 for static assets. ElastiCache (Redis) for session data and hot cache. SQS to decouple and buffer writes (order processing). Aurora with read replicas for database reads. DynamoDB for high-throughput key-value lookups. Load test beforehand with realistic traffic patterns (k6/Locust)."

**Key Points:**  
- Pre-scale before the event, don't rely only on autoscaling  
- CDN (CloudFront) offloads static content  
- Cache (ElastiCache) reduces DB load  
- Queue (SQS) buffers write spikes  
- Multi-AZ + Auto Scaling for compute  
- Load test with realistic patterns before the event  

---

### 30. If multiple monitoring alerts fire at the same time, how do you prioritize incident response?
**[Scenario]**  
**Sample Answer:**  
> "Use alert severity levels: P1 (customer-facing outage) > P2 (degraded service) > P3 (internal tools) > P4 (warning). Group related alerts - multiple alerts from the same service likely share a root cause. Check if there's a common upstream dependency failure (database down triggers 10 services to alert). Use PagerDuty's alert grouping and deduplication. Start with the most upstream component - fixing the root cause resolves downstream alerts. Communicate status immediately, investigate in parallel."

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
**[Design]**  
**Sample Answer:**  
> "Monorepo or polyrepo - either way, each service has its own pipeline triggered only on its directory changes (path filter). Shared pipeline templates (GitHub reusable workflows / Jenkins shared libraries) ensure consistency. Pipeline: lint > unit test > build image > push to ECR > deploy to staging > integration test > approval > canary deploy to prod (10% traffic via Istio) > full rollout. ArgoCD for GitOps - merge to main = deploy. Rollback: revert the Git commit, ArgoCD syncs automatically."

**Key Points:**  
- Path-based triggers: only build what changed  
- Shared pipeline templates for consistency across 50+ services  
- GitOps (ArgoCD): Git as single source of truth  
- Canary deployments with traffic splitting (Istio/Flagger)  
- Rollback = Git revert, not manual intervention  
- Parallel pipelines - don't serialize 50 services  

---

### 32. In Kubernetes, how do you debug a pod stuck in CrashLoopBackOff?
**[Scenario]**  
**Sample Answer:**  
> "`kubectl describe pod <name>` to see events and the last termination reason. `kubectl logs <name> --previous` to get the crashed container's logs. Check the exit code: 137=OOMKilled (increase memory limits), 1=application error (check app logs), 127=entrypoint not found (check Dockerfile CMD). If the container exits too fast: create a debug pod with the same image using `kubectl debug` or override the command to `sleep infinity` and exec in. Check ConfigMaps, Secrets, and volume mounts for correctness."

**Key Points:**  
- `describe pod` > `logs --previous` > check exit code  
- 137=OOM, 1=app error, 127=binary not found  
- `kubectl debug` or override command for fast-crashing containers  
- Verify ConfigMap/Secret mounts and env vars  
- Check if init containers are failing silently  

---

### 33. Explain what happens internally when you run: `docker run nginx`
**[Conceptual]**  
**Sample Answer:**  
> "Docker CLI sends the request to dockerd (Docker daemon) via REST API. Daemon checks if the nginx image exists locally - if not, pulls it from Docker Hub (resolves tag > downloads layers > assembles image). Daemon calls containerd to create the container. containerd uses runc to create Linux namespaces (pid, net, mnt, uts, ipc, user) for isolation and cgroups for resource limits. runc sets up the root filesystem (overlay2), applies the image's config (CMD, EXPOSE, ENV), creates network namespace with a veth pair connected to docker0 bridge, and starts the nginx process as PID 1 inside the container."

**Key Points:**  
- Docker CLI > dockerd > containerd > runc  
- Image pull: resolve tag > download layers > overlay2 filesystem  
- Namespaces: pid, net, mnt, uts, ipc (isolation)  
- Cgroups: CPU, memory, I/O limits  
- Network: veth pair connected to docker0 bridge  
- nginx runs as PID 1 inside the container  

---

### 34. How do you manage Terraform state across multiple environments safely?
**[Conceptual]**  
**Sample Answer:**  
> "Each environment (dev/staging/prod) gets its own state file via separate backend configurations: different S3 keys (`dev/terraform.tfstate`, `prod/terraform.tfstate`). DynamoDB for state locking prevents concurrent applies. Each environment is a separate directory calling shared modules. IAM roles are scoped per environment - the dev pipeline cannot access prod state. Enable S3 versioning for state recovery. Never use workspaces for environment separation when you need strict isolation."

**Key Points:**  
- Separate state files per environment (different S3 keys)  
- DynamoDB locking prevents concurrent corruption  
- IAM roles scoped per environment  
- Shared modules, separate root configs  
- S3 versioning for disaster recovery  
- Directory-per-env over workspaces for strict isolation  

---

### 35. Design a highly available Kubernetes cluster across multiple AZs.
**[Design]**  
**Sample Answer:**  
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
**[Conceptual]**  
**Sample Answer:**  
> "Rolling: default for most services. Gradually replaces old pods with new ones. Low risk, low cost, but slow rollback (have to roll forward or undo). Blue-Green: run full old (blue) and new (green) environments simultaneously, switch traffic instantly via ALB/DNS. Fast rollback (switch back), but 2x cost during deployment. Best for critical services. Canary: send a small % of traffic (5-10%) to the new version, monitor metrics, gradually increase. Best when you need production validation before full rollout. Requires traffic splitting (Istio, Flagger, ALB weighted routing)."

**Key Points:**  
- Rolling: default, low cost, slower rollback  
- Blue-Green: instant switch, fast rollback, 2x cost  
- Canary: gradual traffic shift, best for risk reduction  
- Rolling for most services, Blue-Green for critical ones  
- Canary when you need production metric validation  
- Tooling: Istio/Flagger for canary, ALB for blue-green  

---

### 37. How would you secure secrets in a CI/CD pipeline?
**[Conceptual]**  
**Sample Answer:**  
> "Never hardcode secrets. Use OIDC federation (GitHub Actions > AWS STS) to eliminate long-lived credentials entirely. For pipeline variables, use masked + protected secrets (GitHub Secrets, GitLab CI Variables). At runtime, applications pull from Secrets Manager or Vault using IAM roles, not injected env vars. Scan for secret leaks with tools like truffleHog or gitleaks in the pipeline. Rotate credentials automatically and audit access via CloudTrail."

**Key Points:**  
- OIDC federation > long-lived access keys  
- Platform-native masked secrets  
- Runtime pull from Secrets Manager/Vault  
- Secret scanning (truffleHog/gitleaks) in CI  
- Automated rotation + expiry alerts  
- CloudTrail audit trail  

---

### 38. What strategy would you use to reduce alert fatigue in monitoring systems?
**[Scenario]**  
**Sample Answer:**  
> "Start by classifying alerts into actionable tiers: P1 pages on-call, P2 creates a ticket, P3 goes to a Slack channel, P4 is logged only. Delete alerts nobody acts on. Use alert grouping and deduplication (PagerDuty, Alertmanager). Add `for` duration in Prometheus rules to avoid flapping (e.g., `for: 5m` means it must be failing for 5 minutes). Route alerts to the owning team, not a shared channel. Review alerts monthly - if an alert fires > 10 times without action, fix the root cause or delete it."

**Key Points:**  
- Severity tiers: page > ticket > Slack > log  
- Delete alerts nobody acts on  
- `for` duration to prevent flapping  
- Alert grouping and deduplication  
- Route to owning team, not shared channels  
- Monthly review: fix root cause or delete noisy alerts  

---

### 39. How do you implement GitOps in production?
**[Conceptual]**  
**Sample Answer:**  
> "GitOps means Git is the single source of truth for infrastructure and application state. Setup: ArgoCD or Flux watches a Git repo containing Kubernetes manifests (or Helm charts). Any change to main branch triggers ArgoCD to sync the desired state to the cluster. CI pipeline builds image + updates the image tag in the Git repo. ArgoCD detects the change and deploys. Rollback = Git revert. Drift detection: ArgoCD alerts if someone makes a manual kubectl change that diverges from Git."

**Key Points:**  
- Git = single source of truth  
- ArgoCD/Flux watches repo and syncs to cluster  
- CI updates image tag in Git, CD (ArgoCD) deploys  
- Rollback = Git revert (instant, auditable)  
- Drift detection catches manual kubectl changes  
- Separation of concerns: CI builds, CD deploys  

---

### 40. What happens when etcd fails in Kubernetes?
**[Conceptual]**  
**Sample Answer:**  
> "etcd is the brain of Kubernetes - all cluster state (pods, services, secrets, configmaps) is stored there. If etcd fails: the API server can't read or write state, so no new pods can be scheduled, no deployments can update, no scaling events happen. Existing running pods continue to run (kubelet doesn't need etcd for running containers), but nothing new can be created or modified. With a 3-member etcd cluster, it tolerates 1 node failure (quorum = 2). If quorum is lost, the cluster is effectively read-only (actually, fully unavailable for writes)."

**Key Points:**  
- etcd stores ALL cluster state  
- etcd down = no new scheduling, scaling, or updates  
- Running pods continue (kubelet runs independently)  
- 3-member cluster tolerates 1 failure (quorum = 2)  
- Quorum lost = cluster is write-unavailable  
- Regular etcd snapshots are critical for recovery  

---

### 41. How do you handle database schema changes in CI/CD?
**[Conceptual]**  
**Sample Answer:**  
> "Use versioned migration tools (Flyway, Alembic, Liquibase). Every schema change is a numbered migration file committed to Git. The CI/CD pipeline runs migrations before deploying the new app version. Critical rule: migrations must be backward-compatible (expand-and-contract pattern). Phase 1: add new column (old code ignores it). Phase 2: deploy new code that uses both. Phase 3: migrate data. Phase 4: drop old column. Never rename or delete columns in the same release as the code change."

**Key Points:**  
- Versioned migrations (Flyway/Alembic/Liquibase)  
- Backward-compatible only (expand-and-contract)  
- Never rename/delete columns in same release  
- Run migrations before deploying new code  
- Test migrations against a copy of production data  
- Rollback plan: reverse migration script ready  

---

### 42. How would you migrate a monolithic app to microservices?
**[Design]**  
**Sample Answer:**  
> "Strangler Fig pattern: don't rewrite everything at once. Step 1: Put an API gateway in front of the monolith. Step 2: Identify bounded contexts (auth, payments, orders). Step 3: Extract one service at a time - start with the least coupled, highest-value piece. Route its traffic through the gateway to the new microservice instead of the monolith. Step 4: Decouple the database - each service gets its own DB (this is the hardest part). Use events (SQS/Kafka) for cross-service communication instead of shared DB. Step 5: Repeat until the monolith is empty."

**Key Points:**  
- Strangler Fig pattern: incremental, not big-bang  
- API gateway fronts both monolith and new services  
- Extract by bounded context, starting with least-coupled  
- Database decomposition is the hardest part  
- Event-driven communication (SQS/Kafka) over shared DB  
- Each service owns its data  

---

### 43. How do namespaces and cgroups work inside Docker?
**[Conceptual]**  
**Sample Answer:**  
> "Linux namespaces provide isolation - each container gets its own view of the system. PID namespace: container sees its process as PID 1. NET namespace: own network stack (IP, ports, routing). MNT namespace: own filesystem (overlay2). UTS namespace: own hostname. IPC namespace: isolated shared memory. User namespace: maps container root to unprivileged host user. Cgroups (control groups) limit resources: how much CPU, memory, disk I/O, and network bandwidth a container can use. Together, namespaces isolate WHAT a container sees, cgroups limit HOW MUCH it can use."

**Key Points:**  
- Namespaces = isolation (what the container sees)  
- Cgroups = resource limits (how much it can use)  
- PID, NET, MNT, UTS, IPC, User namespaces  
- Cgroups control: CPU, memory, I/O, PIDs  
- Containers are NOT VMs - they share the host kernel  
- This is why containers are lightweight vs VMs  

---

### 44. How do you design disaster recovery with defined RTO & RPO?
**[Design]**  
**Sample Answer:**  
> "RPO (Recovery Point Objective) = maximum acceptable data loss. RPO of 1 hour means you need backups/replication at least hourly. RPO of 0 = synchronous replication (Aurora Global, DynamoDB Global Tables). RTO (Recovery Time Objective) = how fast you must recover. RTO of minutes = active-active or warm standby. RTO of hours = pilot light. Architecture: Route 53 health checks trigger failover to DR region. Automate everything - runbooks fail under pressure. Test with quarterly gamedays. Cost increases as RTO/RPO decrease."

**Key Points:**  
- RPO = max data loss, RTO = max downtime  
- RPO 0: synchronous replication (most expensive)  
- RTO minutes: warm standby or active-active  
- RTO hours: pilot light (cheapest)  
- Route 53 health checks for automated failover  
- Test quarterly - untested DR plans don't work  

---

### 45. Production server CPU is 100% at 2 AM - what is your first action?
**[Scenario]**  
**Sample Answer:**  
> "Step 1: Check if autoscaling is triggered - if yes, let it handle while you investigate. Step 2: SSH in and run `top` / `htop` to identify the process consuming CPU. Step 3: Check if it's a cron job or scheduled task (2 AM is a common schedule for batch jobs). Step 4: If it's the application, check recent deployments and correlate. Step 5: If it's a runaway process, capture diagnostics (strace, perf record) before killing it. Step 6: Scale horizontally if the system is degraded while you investigate. Step 7: Check for crypto mining malware if nothing in your stack explains it."

**Key Points:**  
- Check autoscaling first, don't panic  
- `top` / `htop` to identify the offending process  
- 2 AM = likely a cron job or batch process  
- Capture diagnostics before killing processes  
- Scale out to mitigate impact during investigation  
- Crypto mining malware is a real possibility - check for it  

---
