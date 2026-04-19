# 🚀 MERN Stack Deployment on AWS using Terraform & Ansible

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonaws) ![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform) ![Ansible](https://img.shields.io/badge/Config-Ansible-EE0000?logo=ansible) ![MongoDB](https://img.shields.io/badge/DB-MongoDB-47A248?logo=mongodb) ![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?logo=node.js) ![React](https://img.shields.io/badge/Frontend-React-61DAFB?logo=react)

---

## 📌 Objective

Design, provision, and deploy a production-grade **MERN** (MongoDB, Express, React, Node.js) application on AWS using:

| Tool | Purpose |
|---|---|
| **Terraform** | Infrastructure as Code (IaC) — VPC, EC2, subnets, security groups |
| **Ansible** | Configuration Management — software install, app deployment |
| **AWS EC2** | Application hosting (web server + DB server) |
| **Private Networking** | Secure, isolated communication between app and database |

---

## 📦 Deliverables

- [x] Terraform scripts for full AWS infrastructure
- [x] Ansible playbooks for automated deployment
- [x] Fully working MERN application
- [x] Detailed documentation (this file)
- [x] Screenshots / demo proof

---

## 🧠 Architecture Overview

<img width="818" height="610" alt="image" src="https://github.com/user-attachments/assets/88de4cbc-a23e-4d8e-8007-574e9df1654b" />


**Traffic flow:**

```
User (Browser)
    ↓  HTTP :3000
Frontend (React)
    ↓  API calls :3001
Backend (Node.js / Express)
    ↓  TCP :27017 (private network only)
MongoDB (Private EC2)
```

---

## 🗂 Project Structure

```
terraform-mern-ansible/
├── terraform/
│   ├── modules/
│   │   ├── vpc/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── output.tf
│   │   ├── subnet/
│   │   ├── igw/
│   │   ├── nat/
│   │   ├── route_table/
│   │   ├── security_group/
│   │   └── ec2/
│   └── environments/
│       └── dev/
│           ├── main.tf
│           └── terraform.tfvars
├── ansible/
│   ├── inventory/
│   │   └── hosts.ini
│   └── playbooks/
│       ├── web.yml
│       └── db.yml
└── README.md
```

---

## 🏗 Phase 1: Infrastructure Setup (Terraform)

### Step 1 — Initialize Terraform

```bash
cd terraform/environments/dev
terraform init
```

**Expected output:**
- ✅ Providers downloaded and installed
- ✅ `.terraform/` directory created
- ✅ `Terraform has been successfully initialized!`

> ⚠️ **Note:** Never commit the `.terraform/` directory to Git. Add it to `.gitignore`. Provider binaries can exceed 800 MB and will be rejected by GitHub.

---

### Step 2 — Plan Infrastructure

```bash
terraform plan
```

**Resources planned:**

| Resource | Count |
|---|---|
| VPC | 1 |
| Public Subnet | 1 |
| Private Subnet | 1 |
| Internet Gateway | 1 |
| NAT Gateway | 1 |
| Route Tables | 2 |
| Security Groups | 2 |
| EC2 Instances | 2 |

---

### Step 3 — Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

**Expected output:**
- ✅ EC2 web server created with a **public IP**
- ✅ EC2 DB server created with a **private IP only**
- ✅ `Apply complete! Resources: X added, 0 changed, 0 destroyed.`

---
<img width="1918" height="412" alt="image" src="https://github.com/user-attachments/assets/87c7ead8-f093-43e1-96f0-c8b16f93b5ba" />

### Step 4 — Verify in AWS Console

| Resource | Check |
|---|---|
| VPC | Created with correct CIDR |
| Public/Private Subnets | Correctly associated with route tables |
| Internet Gateway | Attached to VPC |
| NAT Gateway | Active, in public subnet |
| Security Groups | Web SG (ports 22, 3000, 3001), DB SG (port 27017 from web SG only) |
| EC2 Instances | Both in `running` state |

---
<img width="1917" height="881" alt="image" src="https://github.com/user-attachments/assets/27249532-7ab7-46f3-a26a-ed49149a83d0" />

## 🔐 Phase 2: Networking Validation

### Step 5 — SSH into Web Server

```bash
chmod 400 key.pem
ssh -i key.pem ubuntu@<web-public-ip>
```
<img width="1712" height="812" alt="image" src="https://github.com/user-attachments/assets/97f69040-ad03-4e11-b766-045c85b91420" />

✅ Expected: SSH login successful

---

### Step 6 — Test Private Connectivity (ICMP)

```bash
ping <db-private-ip>
```
<img width="958" height="313" alt="image" src="https://github.com/user-attachments/assets/a0419c34-d236-4cc3-87f4-85ef5815d629" />

> ❌ Ping may fail — ICMP is typically blocked by security groups by default. Use TCP test below instead to check.

---

### Step 7 — Test TCP Connectivity to MongoDB Port

```bash
nc -zv <db-private-ip> 27017
```

✅ Expected: `Connection to <db-private-ip> 27017 port [tcp/*] succeeded!` (once MongoDB is running)

---

## ⚙️ Phase 3: Configuration using Ansible

### Step 8 — Setup Inventory

**`ansible/inventory/hosts.ini`**

```ini
[web]
<web-public-ip> ansible_user=ubuntu ansible_ssh_private_key_file=key.pem

[db]
<db-private-ip> ansible_user=ubuntu ansible_ssh_private_key_file=key.pem ansible_ssh_common_args='-o ProxyJump=ubuntu@<web-public-ip>'
```

**Verify connectivity:**

```bash
ansible all -i inventory/hosts.ini -m ping
```

✅ Expected:
<img width="1570" height="432" alt="image" src="https://github.com/user-attachments/assets/3ad72bfc-6356-49dd-a3e1-d65ecf308d54" />

```
web | SUCCESS => { "ping": "pong" }
db  | SUCCESS => { "ping": "pong" }
```

---

### Step 9 — Run DB Playbook

```bash
ansible-playbook -i inventory/hosts.ini playbooks/db.yml
```

**Tasks performed:**
- Install MongoDB (community edition)
- Configure apt repository and GPG key
- Enable and start `mongod` service
- Update `bindIp` in `/etc/mongod.conf` to allow remote connections from the web server
<img width="1782" height="893" alt="image" src="https://github.com/user-attachments/assets/9416c431-d909-4e91-bde4-993165fd6e7b" />

**Verify:**

```bash
# SSH to web server, then hop to DB
ssh -i key.pem ubuntu@<web-public-ip>
ssh ubuntu@<db-private-ip>

# On DB server
systemctl status mongod
```
<img width="1902" height="398" alt="image" src="https://github.com/user-attachments/assets/a5c6e202-3032-44b0-ada0-ab14e2a82d60" />

✅ Expected: `Active: active (running)`

---

### Step 10 — Run Web Playbook

```bash
ansible-playbook -i inventory/hosts.ini playbooks/web.yml
```

**Tasks performed:**
- Install Node.js (v18+) via NodeSource
- Clone application repository
- Install backend dependencies (`npm install`)
- Install and build frontend (`npm run build`)
- Start services using **PM2** process manager

<img width="1910" height="770" alt="image" src="https://github.com/user-attachments/assets/b6096df0-9aac-4b2e-ae3c-20e32f332929" />
<img width="1918" height="771" alt="image" src="https://github.com/user-attachments/assets/c9239406-b86e-44de-836a-08f5752e968d" />

**Verify:**

```bash
# SSH to web server
pm2 status
```

✅ Expected:

```
┌────┬──────────┬────────┬───┬─────┬──────────┐
│ id │ name     │ status │ ↺ │ cpu │ memory   │
├────┼──────────┼────────┼───┼─────┼──────────┤
│ 0  │ backend  │ online │ 0 │ 0%  │ 50mb     │
│ 1  │ frontend │ online │ 0 │ 0%  │ 30mb     │
└────┴──────────┴────────┴───┴─────┴──────────┘
```
<img width="1687" height="227" alt="image" src="https://github.com/user-attachments/assets/257cc0d0-a0b1-45f1-9b1b-b5269db30b77" />
---

## 🔄 Phase 4: Application Validation

### Step 11 — Test Backend API

```bash
# On web server
curl http://localhost:3001/api/trip
```

✅ Expected: `[]` or a JSON array of trip records

---

### Step 12 — Access Frontend in Browser

```
http://<web-public-ip>:3000
```

✅ Expected:
- Application loads without errors
- Trips list shows (empty `[]` is fine on a fresh DB)
- Adding a new trip stores it via the backend and reflects in the UI

---

## 🐛 Phase 5: Troubleshooting & Fixes

### ❌ Issue 1 — SSH Permission Denied

**Cause:** Incorrect key file permissions  
**Fix:**
```bash
chmod 400 key.pem
```

---

### ❌ Issue 2 — `terraform destroy` Stuck

**Cause:** NAT Gateway has ENI dependencies that block deletion order  
**Fix:**
1. Open AWS Console → **VPC → NAT Gateways**
2. Manually delete the NAT Gateway
3. Wait for state to become `deleted`
4. Re-run `terraform destroy`

---

### ❌ Issue 3 — MongoDB Not Connecting

**Cause:** `MONGO_URI` environment variable not loaded by PM2  
**Fix:** Inject env variables directly at startup:
```bash
MONGO_URI=mongodb://<db-private-ip>:27017/travelmemory PORT=3001 \
  pm2 start index.js --name backend
```

---

### ❌ Issue 4 — `.env` File Not Loaded by PM2

**Cause:** PM2 does not automatically source `.env` files  
**Fix:** Use PM2 ecosystem file or pass env inline (see Issue 3 fix above).  
Alternatively, create `ecosystem.config.js`:

```javascript
module.exports = {
  apps: [{
    name: "backend",
    script: "index.js",
    env: {
      MONGO_URI: "mongodb://<db-private-ip>:27017/travelmemory",
      PORT: 3001
    }
  }]
};
```
Then run: `pm2 start ecosystem.config.js`

---

### ❌ Issue 5 — Frontend Error: `n.map is not a function`

**Cause:** Frontend was calling the wrong API URL (defaulting to port 3000 instead of 3001)  
**Fix:** Update the base URL in the frontend config:

```javascript
// src/url.js or equivalent
export const baseUrl = "http://<web-public-ip>:3001/api";
```

Rebuild and restart:
```bash
npm run build
pm2 restart frontend
```

---

## 🔗 Component Interaction Summary

<img width="805" height="572" alt="image" src="https://github.com/user-attachments/assets/d1d4bef9-edd2-4a18-8ead-01f037840e99" />


---

## 🔒 Security Best Practices Applied

- DB server has **no public IP** — accessible only via private subnet
- MongoDB port `27017` is open only to the **web server's security group**, not to the internet
- SSH key (`key.pem`) uses `chmod 400` — owner read-only
- `.terraform/` and `*.pem` files are excluded from version control via `.gitignore`

---

## 📝 .gitignore Recommendations

```gitignore
# Terraform
**/.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
crash.log

# SSH keys
*.pem
*.key

# Node
node_modules/
.env
```

---

## 👤 Author

**Priyank Pandey** — MERN Stack Deployment Assignment  
Infrastructure: AWS | IaC: Terraform | Config: Ansible
