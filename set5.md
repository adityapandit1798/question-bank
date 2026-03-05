🔥 1. How does DNS resolution work inside a pod?

→ And what do you check when a service isn’t reachable by name?

🔥 2. Walk me through what the controller manager does during a Deployment.

→ Not rollout status. Reconciliation logic.

🔥 3. What happens if a node with local storage gets autoscaled down?

→ Be careful. This one causes data loss in prod more often than you’d think.

🔥 4. Post-deploy, latency spikes for 30% of users. No errors. No logs. What now?

→ Your answer reveals if you know how to triage chaos.

🔥 5. How do you enforce runtime security in Kubernetes?

→ PSP? AppArmor? OPA? Most people just hope for the best.

🔥 6. HPA vs VPA vs Karpenter — when would you NOT use each?

→ Bonus: How would you simulate HPA behavior in staging?

🔥 7. Tell me about the last outage you debugged in Kubernetes.

→ No postmortem? You weren’t really there.

🧱 Docker

What happens if a Docker container is deleted?

What are Namespaces in Docker?

What is Docker build cache?

How to share Docker images across orgs?

How to extract .tar for Docker use?

Command to remove all stopped containers?

🌍 Terraform

Infra stuck mid-apply—what now?

How do Terraform locks work?

How to manage module dependencies?

What is terraform fmt vs terraform validate?

Explain null resources & local-exec.

Secure secrets: alternatives to storing in .tfstate.

☸️ Kubernetes

Pod stuck in Terminating state—fix?

ConfigMap not reflecting—what to do?

How to attach ConfigMap to pod?

🛡️ Istio & ALB

Attributes of an Istio gateway?

How to install Istio & create custom gateway?

How to refer secrets in Istio?

Annotations linking Istio and AWS ALB?

📉 Infra & Monitoring

ALB vs NLB: difference?

Public vs Private subnet?

Route 53 → Public/Private Hosted Zone?

Prometheus & Grafana: ports, integration, and no-data troubleshooting?

Ansible modules: what and why?

🔐 EC2 & Auth

Permission denied to EC2? Troubleshoot steps?

EC2: prevent disk deletion on reboot?

Login via username/password → required config?

GitHub self-hosted runners → AWS connectivity?

📊 Bonus: They also asked me to design an architecture diagram for:

“3 Kubernetes-hosted apps behind Istio (internal LB) and AWS ALB (external LB) routing traffic via domain

[**example.com**](http://example.com/)

.”

🔗 If you're preparing for AWS DevOps roles (esp. in product/service-based companies), I'd highly recommend brushing up these areas.

🚨 Advanced Kubernetes Interview Questions You Should Be Ready For (If You Call Yourself a DevOps Engineer) 🚨

Here’s a set of real-world, high-signal questions that go beyond “kubectl get pods” — with my detailed notes from production war rooms, outages, and scaling lessons:

🔥 1. How does DNS work in a pod? What if service name resolution fails?

Kubernetes uses CoreDNS (via /etc/resolv.conf) to resolve names like my-svc.my-namespace.svc.cluster.local.

🧠 Troubleshoot with:

dig / nslookup inside the pod

Inspect CoreDNS logs + ConfigMap

Validate CNI, iptables, node DNS access

🔥 2. What’s the lifecycle of a Deployment rollout behind the scenes?

From declarative spec → DeploymentController → ReplicaSet → kube-scheduler → kubelet → readiness gates.

📊 Strategy matters: maxUnavailable, maxSurge, rollout pause/resume, and observed generation tracking.

🔥 3. What happens if Cluster Autoscaler tries to evict a pod with local storage?

It won’t. Local volumes (emptyDir, hostPath, local PV) block eviction.

⚠️ Mitigate with proper taints, avoid local volumes unless strictly needed.

🔥 4. You deployed an update, and latency spikes for 30% of users. No CrashLoops. Debug?

✅ Metrics: compare histograms

✅ Logs: filter by time window and pod label

✅ Network: check service routing, policies, and sidecars

✅ Use tracing + load testing to isolate faulty pods

🔥 5. How do you enforce runtime security in K8s?

🔐 Seccomp, AppArmor, RBAC, OPA Gatekeeper, and tools like Falco.

Block risky syscalls, deny root containers, audit policy violations in CI/CD.

🔥 6. HPA vs VPA vs Karpenter – when to avoid each?

HPA: ✅ scale pods by metrics | ❌ not for stateful apps

VPA: ✅ tune limits/requests | ❌ avoid w/ HPA

Karpenter: ✅ dynamic nodes | ❌ not for fixed infra needs

🎯 Pro tip: Simulate HPA load in staging with kubectl run + stress-ng

🔥 7. Share an outage you helped debug. RCA and fix?

Our ingress had 502s but no pod failures.

📌 RCA: Nodes hit disk pressure → kubelet evicted pods → endpoints vanished.

✅ Fix: disk alerts + eviction thresholds + daemon for monitoring ephemeral storage.

Postmortem + learnings shared org-wide.

💥 1. “Why is the pod CrashLooping even though the image is valid?”

🧠 Real scenario:

The container pulls successfully, but the app crashes due to a missing DB_PASSWORD secret or failing DB connection.

✅ Fix: Checked kubectl logs, validated env vars from Secrets, and reviewed readiness/liveness probes.

⸻

💥 2. “How would you handle secrets across multi-region clusters?”

🧠 What I proposed:

Use AWS Secrets Manager + External Secrets Operator.

Each region (e.g., us-east-1, eu-central-1) has its own IAM-controlled sync to Kubernetes. Secrets are managed centrally, and synced locally per cluster with proper access control.

⸻

💥 3. “What’s the fastest way to rollback an Infra change in Terraform?”

🧠 Real-world approach:

A faulty security group update broke service access. I quickly reverted the Git commit and redeployed via Terraform.

Pro tip: Use terraform apply -target=

[**resource.name**](http://resource.name/)

for isolated rollback when needed.

⸻

💥 4. “How would you design a zero-downtime deployment with blue/green and traffic shifting?”

🧠 Production-grade method:

• Deploy v1 (blue) and v2 (green) in parallel

• Use Kubernetes service selector or Istio VirtualService

• Gradually shift traffic (10% → 50% → 100%)

• Rollback instantly by re-routing traffic if issues arise

⸻

These weren’t theoretical questions — they came straight from real-world production challenges. If you’re preparing for high-stake DevOps interviews, I recommend building hands-on experience with:

✅ Kubernetes

✅ Terraform

✅ Cloud-native secret management

✅ Canary / Blue-Green deployments

🚀 Cloud Engineer Interview – Questions I Was Asked!

I recently attended an interview for a Cloud Engineer role and wanted to share the questions I faced — they covered a solid mix of AWS, Linux, Networking, Python, and Troubleshooting.

📌 Interview Questions

✅ What is VPC Peering and where do we use it?

✅ Explain Transit Gateway and how it differs from VPC peering.

✅ How does Amazon Route 53 work? Name some routing policies.

✅ What's the difference between TCP and UDP?

✅ Walk me through the OSI Model — layer by layer.

✅ If your website is slow, what steps would you take?

✅ What are tuples in Python and how are they useful?

✅ IP:

[**150.150.150.150**](http://150.150.150.150/)

— identify the class.

✅ What is CIDR and how does it relate to IP address classes?

✅ How do you install packages in Linux without internet access?

✅ Explain the types of Load Balancers in AWS and their use cases.

✅ Which Linux version are you using in your project, and how do you check it?.

just wrapped up a DevOps interview — sharing my experience & questions

I recently attended an interview for a DevOps Engineer role, and it was a solid mix of real-world scenarios, troubleshooting, and tool-specific questions. If you’re preparing for DevOps interviews, these might help:

• What kind of Grafana dashboards are typically used in a DevOps environment?

• How do you configure Grafana dashboards?

• What is Node Exporter?

• How do you trigger email alerts from Grafana?

• What kind of alert conditions do you usually configure?

• What’s your Ansible experience in real projects?

• How do you manage sensitive data like passwords in Ansible?

• How do you securely run playbooks that use secrets?

• What is PM2 and how do you use it in Node.js deployments?

• How do you kill a process using PM2?

• How do you check running nodes?

• How do you kill a process in Linux?

• How to get the process ID (PID)?

• How to check system performance in Linux?

• What does chmod 555 mean?

• How do you give full permissions to a file or folder?

• Difference between a soft link and a hard link?

• How do you open the firewall in Linux?

• How to check which ports are running or open?

• What does netstat -ntlp do and how to use it?

• What is a cron job?

• How do you clear cache in Linux?

• How did you deploy SSL in your project?

• How do you resolve a merge conflict in Git?

• How to switch to a new branch?

• Finally, they asked about which AWS services/tools I’ve used and how I applied them in my project.

Hi All,

Here are some questions which was asked during my interview phase.

AWS (EC2, S3, Lambda, CloudFront):

What is EC2? How does it differ from traditional servers?

What is an S3 bucket? How is it used in DevOps pipelines?

Explain IAM roles and how they are used with EC2 and Lambda.

What is Lambda? How is it different from EC2?

Explain the lifecycle of an EC2 instance and how to automate it using user data.

How does versioning work in S3 and why is it important for DevOps?

What is CloudFront and how does it improve performance in deployment?

How would you build a serverless web app using Lambda, S3, and CloudFront?

How do you automate S3 backup and EC2 snapshot policies in a DevOps pipeline?

Design a CI/CD pipeline to deploy code to Lambda with version control and rollback.

Terraform:

Why Terraform is more popular tool in IAC? How is it different from CloudFormation and ARM Templates?

What are providers and resources in Terraform?

Explain the purpose of terraform init, plan, apply, and destroy.

What are Terraform state files? Why should they be stored securely?

How do you use variables and outputs in a Terraform project?

Explain the concept of workspaces in Terraform.

How do you manage multiple environments (dev, staging, prod) in Terraform?

Write a basic Terraform configuration to deploy an EC2 instance and differnec between tfvars and .tf ?

How do you implement remote state locking with Terraform?

Design a Terraform module for creating VPC, subnets, and EC2 instances with reusability.

Azure DevOps:

What is Azure DevOps and what services does it include?

Explain the difference between Azure Repos, Pipelines, Artifacts, and Boards.

What are build and release pipelines?

How do you create a YAML pipeline in Azure DevOps?

What is the difference between Classic pipeline and YAML pipeline?

How do you implement approvals and gates in Azure release pipelines?

How do you integrate Azure DevOps with GitHub for automated builds?

What is the role of service connections in Azure DevOps?

How would you manage secrets in Azure DevOps pipelines?

Scenario: Design an end-to-end Azure DevOps pipeline for deploying an AKS-hosted application.

CI/CD Concepts:

What is CI/CD? Why is it important in DevOps?

What tools are commonly used for CI/CD?

Explain the stages in a typical CI/CD pipeline.

What is the difference between continuous integration, delivery, and deployment?

How do you manage rollbacks in CI/CD pipelines?

How do you automate tests in a CI pipeline?

What is blue-green deployment? How is it implemented?

How do you implement canary deployment in CI/CD?

What is pipeline as code and why is it beneficial?

Scenario: Design a CI/CD strategy for a multi-service application deployed in Kubernetes.

K8s Basics :

Elaborate k8s architecture and its components.

Interview Questions I Faced for Cloud DevOps Roles – Part 2

Hi All!

In my last post, I have shared some of the Networking, Linux, and AWS Cloud questions I encountered during interviews. In this post, I’ll cover some Docker and Kubernetes questions — which I faced most often since I usually introduced myself with these technologies.

🐳 Docker:

1. What is the difference between Virtual Machines and Containers?

2. Explain the Docker lifecycle.

3. Write some Docker commands. (I don’t remember the exact commands that were asked.)

4. Write a Dockerfile for one application. Explain each layer in it (any tech stack).

5. What is a docker-compose file? Explain what it does. Write one sample file if you can.

6. By default, which Docker network is present?

7. What is the purpose of a multi-stage Dockerfile? How does it reduce the image size?

8. Write the multi-stage Dockerfile for the same.

9. How does container-to-container communication happen? Explain it.

10. Mention some Docker network types and explain their real-world use cases.

11. What is the difference between CMD and ENTRYPOINT?

12. Where are Docker volumes stored?

13. What is the difference between COPY and ADD?

14. How many containers can we run in Docker exactly?

15. What happens to the data inside a container when you delete the running container?

Scenarios:

- > You’re running an app using docker-compose with low traffic. As traffic grows, how do you scale the application in AWS? What services will you choose — EKS, ECS or EC2? Why?
- > Application works via localhost but not over the web — how will you troubleshoot?

☸️ Kubernetes:

1. Why is Kubernetes considered over Docker? Mention the advantages of it.

2. Explain the architecture of Kubernetes. Mention each component’s role.

3. What are Services in Kubernetes? Explain.

4. What is a Namespace? What is its role?

5. What is Autoscaling and its types? When can we use vertical scaling?

6. What is the difference between StatefulSet and Deployment?

7. Difference between StatefulSet, DaemonSet, and ReplicaSet. Explain use cases of each with real-world examples.

8. Write a YAML file for a simple nginx pod.

9. Write an imperative command to create a deployment with image nginx and replica count of 3.

10. What does node affinity do? Mention its rules and what it does.

Due to LinkedIn’s character limit, I am not able to post all at once. So I’ll post the remaining questions and Kubernetes scenario based questions in the next posts (excluding any project-specific ones due to confidentiality).

🚀 Most Asked DevOps Interview Questions (2–5 Yrs Experience)

📌 Preparing for interviews or just brushing up? Here are some commonly asked DevOps questions based on my experience and peer discussions:

🔧 CI/CD & Jenkins

What is the difference between Freestyle and Declarative pipelines?

How do you implement CI/CD using Jenkins and GitLab?

How do you trigger a pipeline on code commit?

🐳 Docker

What is the difference between CMD and ENTRYPOINT?

How do you create a multistage Docker build?

Explain Docker networking modes.

☸️ Kubernetes

What is the difference between Deployment and StatefulSet?

How does a Service work internally?

What are Taints and Tolerations?

🛠️ Terraform

What is the purpose of backend in Terraform?

Difference between terraform apply and terraform plan?

How do you manage secrets securely?

☁️ AWS/Azure

How do you configure auto-scaling in EC2?

What’s the use of IAM roles vs policies?

How do you integrate ECR with Jenkins?

📊 Monitoring

How do you set up alerts in Grafana/Prometheus?

Difference between ELK and EFK stacks?

🔍 Here’s what was asked during the interview:

1️⃣ You have Docker images for frontend, backend, and database — how would you deploy them using YAML in Kubernetes?

➡️ (Think: Writing separate deployment and service files, setting environment variables, handling persistent volumes)

2️⃣ Why do we use namespaces in Kubernetes?

➡️ (Spoiler: It’s not just for organizing resources — it’s also about multi-team isolation and applying resource quotas effectively)

3️⃣ What’s the difference between an Ingress and a Load Balancer in Kubernetes?

➡️ (A classic — understand L4 vs L7 routing, external access patterns, and use cases)

4️⃣ Which component in Kubernetes is responsible for watching your deployment.yaml and ensuring your Pods run as defined?

➡️ (Think about the declarative magic behind the scenes)

5️⃣ You have files in an S3 bucket, but need to access them from another AWS account. How would you make that work securely?

➡️ (Options: Bucket policies, IAM roles with AssumeRole, pre-signed URLs — all have their place)

6️⃣ Docker – But Deep Dive! 🐳

How can you reduce Docker image size effectively?

What’s the real benefit of multi-stage builds?

If a container keeps crashing, how do you debug it?

💭 What I Liked About This Round:

It wasn’t just about remembering commands — they were really trying to understand how I think, why I use certain tools, and how well I can design and troubleshoot real-world architectures.

If you’re preparing for AWS + Kubernetes + Docker interviews, these questions are a great starting point. ✅

🕯 Interview Questions for Cloud & DevOps Engineer Role

L1 & L2 level questions related to AWS, Terraform, Kubernetes, Docker, Git.

💎 Level 1 -

1. cicd workflow, what kind of pipeline.

2. use of webhook

3. purpose of webhook

4. stages of pipeline...

5. shared libraries in jenkins?

6. how do we define shared libraries?

7. how are shared libraries written?

8. how do you define a pipeline and call it?

9. what kind of app you deploy on the pipeline?

10. basic structure, folder structure of helm?

11. what command are you using deployment in helm

12. in the Jenkins pipeline, the pipeline is running successfully but the build is not happening, what are the issues?

13. in kubernetes, what are the errors you are getting, why they come and how you resolve?

14. explain the crash loop back off,

15. image pull error?

16. command to go inside a pod?

17. how can you create the kubernetes class?

18. what are the steps to create the cluster?

19. what is the master node and other node?

20. code to create a cluster using terraform?

21. stages in docker images?

22. DB entry point, CMD

23. why do we use entrypoint, CMD

24. DB ec2, eks, ecs

25. command to connect ecs

26. which tool are you using for deployment?

27. which registry for storing the docker images?

💎 Level 2 -

1. Branching strategy?

2. your release branch will break, then how u will avoid this kind of issues, then how do you merge?

3. in production having some bugs, how will you resolve?

4. typical deployment flow?

5. cicd workflow?

6. how do we do a full quality check?

7. jenkins file, different stages...

8. shared libraries in jenkins file?

9. typical structure of shared libraries...

10. are you aware of security scanning tools?

11. how do you pass the environment variables on docker build command.

12. what services do you use for storing the images?

13. DB, how do you establish the connection?

14. how do you scan the images at the registry level?

15. any extension you are using for image scanning?

16. authentication of eks cluster?

17. storing the secrets?

18. how to create lambda function, how it's taking the artifacts.

19. options on lambda to push the artifacts?

20. what is email signing and helm chart signing?

21. which tool for signing the helm chart?

The moment you mention 𝗞𝘂𝗯𝗲𝗿𝗻𝗲𝘁𝗲𝘀 in a Devops interview, expect a deep dive

Here are 17 Kubernetes questions I was asked that dive into architecture, troubleshooting, and real-world decision-making:

1. Your pod keeps getting stuck in CrashLoopBackOff, but logs show no errors. How would you approach debugging and resolution?

2. You have a StatefulSet deployed with persistent volumes, and one of the pods is not recreating properly after deletion. What could be the reasons, and how do you fix it without data loss?

3. Your cluster autoscaler is not scaling up even though pods are in Pending state. What would you investigate?

4. A network policy is blocking traffic between services in different namespaces. How would you design and debug the policy to allow only specific communication paths?

5. One of your microservices has to connect to an external database via a VPN inside the cluster. How would you architect this in Kubernetes with HA and security in mind?

6. You're running a multi-tenant platform on a single EKS cluster. How do you isolate workloads and ensure security, quotas, and observability for each tenant?

7. You notice the kubelet is constantly restarting on a particular node. What steps would you take to isolate the issue and ensure node stability?

8. A critical pod in production gets evicted due to node pressure. How would you prevent this from happening again, and how do QoS classes play a role?

9. You need to deploy a service that requires TCP and UDP on the same port. How would you configure this in Kubernetes using Services and Ingress?

10. An application upgrade caused downtime even though you had rolling updates configured. What advanced strategies would you apply to ensure zero-downtime deployments next time?

11. Your service mesh sidecar (e.g., Istio Envoy) is consuming more resources than the app itself. How do you analyze and optimize this setup?

12. You need to create a Kubernetes operator to automate complex application lifecycle events. How do you design the CRD and controller loop logic?

13. Multiple nodes are showing high disk IO usage due to container logs. What Kubernetes features or practices can you apply to avoid this scenario?

14. Your Kubernetes cluster's etcd performance is degrading. What are the root causes and how do you ensure etcd high availability and tuning?

15. You want to enforce that all images used in the cluster must come from a trusted internal registry. How do you implement this at the policy level?

16. You're managing multi-region deployments using a single Kubernetes control plane. What architectural considerations must you address to avoid cross-region latency and single points of failure?

17. During peak traffic, your ingress controller fails to route requests efficiently. How would you diagnose and scale ingress resources effectively under heavy load?

1. Tell me about yourself.

2. ⁠How your day to day activities as a DevOps Engineer.

3. ⁠What are NAT gateway?

4. ⁠What are pre-requisites to upgrade K8s cluster?

5. ⁠What in PDB in K8s?

6. ⁠Write a shell script on factorial of a number.

7. ⁠Tell me about the VPC structure setup in your project.

8. ⁠How is the CI/CD pipeline is setup in your project? What are the security tools integrated?

9. ⁠How do you manage them?

10. ⁠Write a rough pipeline script for microservices architecture.

11. ⁠What is multi stage docker build?

12. ⁠What are manifest files?

13. ⁠What is Ansible Vault?

14. ⁠How do we make a K8s cluster highly available?

15. ⁠What monitoring tools are setup ? Have you set the alerts and tell me some common errors you faced related to pod management..

16. ⁠Write a terraform script for VPC architecture for production.

17. ⁠How many objects can a S3 bucket can store?

18. ⁠What are IAM roles and policies?

19. ⁠⁠What are artifacts?

20. ⁠What are SATS and DATS?

21. ⁠How do you find errors in the pipelines?

22. ⁠What are Ansible Roles?

23. Reason for Job Change?

Interview Questions:

1. Can you give a brief self-introduction?

2. What are your daily activities as a DevOps engineer?

3. What is a Jenkinsfile.

4. Which AWS services have you worked with?

5. What is Amazon EKS, and can you explain your experience with it?

6. Have you worked with monitoring tools (e.g., Prometheus, Grafana, How do you configure them?

7. Write Terraform code to create any resource and modularize it.

8. Write a Docker Compose file for a multi-container setup.

9. Write an Ansible playbook for automation.

10. What’s the difference between Git merge and Git rebase?

11. Have you worked with Linux?

12. How do you configure Docker in a Jenkins pipeline?

13. What is an Ansible inventory file, and how is it used?

14. Are you comfortable writing shell scripts? Any examples?

15. What kind of issues or challenges do you typically encounter in your role?

16. Which Git branching strategies have you used?

17. What deployment strategies have you worked with?

I hope this helps someone who's actively preparing for DevOps interviews.

💼 Interview Experience – Deutsche Bank | DevOps Engineer | Round 1

- ------------------------------------------------------

Recently appeared for Round 1 of the DevOps Engineer interview at Deutsche Bank.

🔍 Round Focus:

This round emphasized secure DevOps pipelines, automation at scale, cloud-native infrastructure, and platform reliability — critical for the banking & financial services domain.

📌 In-Depth Questions Asked:

🔐 How do you design a DevSecOps pipeline for regulated industries like banking or insurance?

📂 What’s your approach to auditing IAM policies and access controls across AWS or Azure in an enterprise setup?

⚙️ Explain how you’d manage infrastructure provisioning across multiple environments using Terraform.

🚀 How do you ensure rollback safety and transaction integrity in multi-step deployments?

🔍 How do you approach drift detection and reconciliation in GitOps workflows?

🛡️ What steps do you take to implement network policies and pod security in Kubernetes clusters?

📈 How would you monitor and alert for critical services in a payment gateway system using Prometheus/Grafana or Splunk?

🧩 Have you worked on integrating CI/CD with security scanning tools like Snyk, Aqua, or Trivy? Explain the integration flow.

🔄 How do you automate patching and OS hardening in cloud-based systems at scale?

🌐 What’s your experience with designing HA (high availability) and DR (disaster recovery) architecture for enterprise apps?

🧠 How would you implement secrets rotation for database credentials across Kubernetes and CI/CD pipelines?

📦 Explain the difference between Helm and Kustomize. When would you use one over the other?

🔄 Can you walk us through how you set up Blue-Green or Canary deployments in Azure DevOps or ArgoCD?

⚖️ How do you handle cost optimization in cloud-native infrastructure, especially in a FinTech context?

🧩 What are the compliance checks you automate before production deployments (e.g., CIS benchmarks, encryption validation)?

📋 Describe how you would manage and track configuration drifts in a large multi-account AWS environment.

🛠️ How do you automate SSL/TLS certificate renewal in Kubernetes ingress controllers?

🔐 How do you implement Zero Trust principles in internal tooling and CI/CD systems?

📊 Have you implemented centralized logging and monitoring for audit trails and anomaly detection? Which stack did you use?

🧪 How would you use tools like LitmusChaos or Gremlin for testing system resilience in production-like environments?

🔥 Stay tuned for Round 2 updates!

List of the top 50 DevOps interview questions categorized for better preparation, covering fundamentals, tools, CI/CD, cloud, scripting, and real-time scenarios.

🔧 DevOps Fundamentals

1. What is DevOps? How is it different from Agile?

2. What are the key principles of DevOps?

3. What are the benefits of DevOps?

4. What are the phases in a DevOps lifecycle?

5. How does DevOps improve collaboration between development and operations?

⚙️ Version Control Systems – Git

6. What is Git? Why is it used in DevOps?

7. What is the difference between Git pull and Git fetch?

8. How do you resolve merge conflicts in Git?

9. What is a Git rebase vs merge?

10. Explain Git branching strategies.

🤖 CI/CD (Jenkins, GitHub Actions, etc.)

11. What is CI/CD?

12. What is Jenkins and how does it work?

13. How do you set up a Jenkins pipeline?

14. Difference between declarative and scripted pipelines in Jenkins?

15. What are build triggers in Jenkins?

16. How do you handle failed builds?

☁️ Cloud Platforms (AWS, Azure, GCP)

17. What are the benefits of using cloud in DevOps?

18. What is IAM in AWS?

19. Explain EC2, S3, and Lambda in brief.

20. What is Infrastructure as Code (IaC)?

21. How do you implement DevOps on AWS?

📦 Containers & Orchestration (Docker & Kubernetes)

22. What is Docker? How is it different from a virtual machine?

23. What is a Dockerfile?

24. How do you create and manage Docker images?

25. What is Kubernetes?

26. What is the difference between a pod and a deployment?

27. How do you scale applications in Kubernetes?

28. What is Helm?

🧪 Monitoring & Logging

29. What tools have you used for monitoring?

30. What is Prometheus and Grafana?

31. How do you monitor log files in real-time?

32. What is ELK Stack?

🔐 Security in DevOps

33. What is DevSecOps?

34. How do you manage secrets in CI/CD pipelines?

35. What is shift-left testing?

36. What is the role of security scanning tools like SonarQube or Snyk?

🛠️ Infrastructure as Code (Terraform, Ansible)

37. What is Terraform and how does it work?

38. What is the difference between Terraform and CloudFormation?

39. What is Ansible? How is it different from Puppet and Chef?

40. Explain playbooks and inventory in Ansible.

🐚 Scripting & Automation

41. What scripting languages are you familiar with?

42. Write a simple Bash script to monitor disk space.

43. How do you automate routine tasks in your current role?

🧠 Behavioral & Scenario-based Questions

44. Tell me about a major outage you handled and how you resolved it.

45. Have you ever implemented blue-green deployment or canary releases?

46. How do you manage rollback in CI/CD?

47. Describe your experience with multi-environment deployments.

48. How do you ensure high availability and reliability?

49. How do you handle application secrets in production?

50. What is the biggest DevOps challenge you’ve faced and how did you solve?

I’ve interviewed 1000+ DevOps engineers.

Most of them say, “I’ve done Kubernetes in production.”

But when the real questions come in, they freeze.

Here’s what I ask 👇

1. Your pod is running and Ready, but the business feature is still broken. What do you check beyond logs?

2. Walk me through what happens in etcd during a control plane failover. How would you verify consistency after recovery?

3. Terraform apply shows no drift, but traffic routing changes unexpectedly. What’s your root cause hypothesis?

4. In a multi-cluster setup, one cluster has DNS resolution latency spikes with no resource pressure. How do you debug?

5. An HPA scales up in staging but refuses in prod, even with identical configs. Where do you start?

6. ALB health checks pass, but users report intermittent 502s. How do you isolate if it’s LB, app, or mesh?

7. A Canary deploy succeeds, but 15% of sessions see stale data. How do you track the fault path?

Round 1 – Streaming at Scale, K8s, Cloud & Linux (45 mins)

1. How would you design auto-scaling for 50M+ concurrent viewers across multiple K8s clusters without over-provisioning?

2. During an IPL final, a new region needs to spin up instantly. How would you pre-warm nodes & scale workloads with zero cold-start impact?

3. Explain how you’d use Envoy + Istio to route low-latency live streams differently from VOD without service restarts.

4. What’s your approach to multi-zone pod affinity/anti-affinity to ensure a node failure doesn’t impact regional streaming SLAs?

5. How would you monitor HPA scaling decisions in real-time and detect if the metrics server is lagging?

6. Describe K8s readiness/liveness probe configs to catch buffering/lag issues in stream-processing microservices before users notice.

7. A kube-proxy update rolls out mid-match. What’s your network rollback plan to avoid packet drops?

Round 2 – RCA, Fire Drills & Streaming Chaos (75 mins)

1. Playback failures spike for only 3% of users in the APAC region. CPU, memory, and pods look fine. Could you walk through your triage plan?

2. Your Kafka ingestion pipeline lags by 2 minutes during a traffic surge. Producers are fine, consumers are idle. What’s your debug path?

3. Sudden tail latency on Redis-based stream session store during a Champions League match, how do you find & fix the bottleneck?

4. HPA refuses to scale in a critical podset even though Prometheus shows CPU > 90%. Root cause & fix?

5. NAT gateway costs double in 24 hours during a live series; no infra changes were made. What could be silently causing it?

Round 3 – Leadership, Reliability Culture & Scaling Influence (30 mins)

1. How do you build a culture where latency SLOs are enforced like uptime SLAs in a streaming org?

2. You’re asked to ship multi-region failover for live events in 2 weeks with no DNS-based routing allowed. What’s your plan?

3. How would you simulate chaos in a streaming pipeline without risking real user impact?

4. How do you justify infra costs for pre-warmed scaling capacity to executives before a major sports event?

🔧 Kubernetes Common Errors and explanation 🔧

🔁 CrashLoopBackOff

This means your pod starts, crashes, and Kubernetes keeps trying to restart it.

🔍 Check container logs using kubectl logs <pod> --previous to debug startup issues or failing health checks.

📦 ImagePullBackOff / ErrImagePull

Kubernetes can’t pull your container image: often due to a wrong image name, missing tag, or lack of access to a private registry.

✅ Double-check the image URL and credentials (if private).

⏳ Pending

Your pod is stuck in "Pending" state because the scheduler can’t find a suitable node.

🔍 This usually happens due to insufficient resources or missing tolerations/node selectors.

⚠️ RunContainerError

The pod gets created but the container fails to run: often caused by incorrect entrypoint commands or missing files.

✅ Review your Dockerfile CMD/ENTRYPOINT and the pod's command and args.

🚫 CreateContainerConfigError

Kubernetes can’t create the container due to a config error: often related to missing Secrets, ConfigMaps, or invalid volume mounts.

🔍 Use kubectl describe pod <pod> to inspect what’s going wrong.

🔐 SecretNotFound / ConfigMapNotFound

Your pod references a missing Secret or ConfigMap.

✅ Make sure the secret/configmap exists in the same namespace and is correctly referenced in your manifest.

🧠 OOMKilled (Out of Memory)

Your container used more memory than requested or allowed, and got killed.

🔍 Fix by adjusting the memory limits in your pod spec or optimizing the app’s memory usage.

🌐 DNSResolutionFailed

Pod fails to resolve internal or external service names.

✅ Check if kube-dns or CoreDNS is running correctly and verify the DNS configuration in your pod.

📉 LivenessProbe Failed

K8s restarts your container because the liveness probe fails continuously.

🔍 Review the probe settings and ensure the endpoint/command returns the right status code.

🔄 NodeNotReady / NodeLost

Pods get evicted or stuck due to a node going down or being unreachable.

✅ Monitor node health (kubectl get nodes), and check logs for network or disk issues.

✨ Kubernetes 1.33 – A Big Leap Forward in Cloud-Native! ✨

The Kubernetes community has just rolled out Kubernetes 1.33, and it’s packed with powerful updates that strengthen performance, security, and flexibility for modern workloads. 🌐⚡

Here are some key highlights:

🔹 Improved Pod Scheduling – Faster, smarter decisions for complex clusters.

🔹 Node Reliability Enhancements – More resilient handling of node failures.

🔹 Container Runtime Updates – Better compatibility with CRI standards.

🔹 Security Improvements – Stricter policies, admission controls & stronger defaults.

🔹 Observability Upgrades – More granular metrics & OpenTelemetry integration.

🔹 Windows Support Enhancements – Making hybrid clusters more seamless.

🔹 Extended Graceful Shutdowns – Smoother rolling updates and fewer disruptions.

Kubernetes keeps evolving to handle the future of cloud-native infrastructure, and this release shows how quickly the ecosystem is maturing.

👉 If you’re running workloads in production, this is the time to start exploring these features and planning your upgrades.

🔗
