# ☁️ Salesforce Summer '26 — Training Project

![Salesforce](https://img.shields.io/badge/Salesforce-Summer%20'26-blue)
![Apex](https://img.shields.io/badge/Apex-API%2067.0-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

A structured collection of Salesforce Summer '26 feature demos, organised by topic. Each topic contains working Apex code, deployment instructions, and a dedicated README.

---

## 📋 Topics

| Topic | Description | API Version |
|---|---|---|
| [User Mode Database Operations](topics/User_Mode_Database_Operations/README.md) | Apex database operations running in user mode by default | 67.0 |
| [Write Cleaner Code by Using Multiline Strings](topics/Multiline_Strings/README.md) | Write Cleaner Code by Using Multiline Strings | 67.0 |
| [Define Picklist Values for Apex Action Inputs](topics/Picklistvalues_ForActionInput/README.md) | Define Picklist Values for Apex Action Inputs | 67.0 |
| [State Managers](topics/State_Managers/README.md) | Manage State Across LWC Components with State Managers | 67.0 |

---

## ⚙️ Prerequisites

- [ ] [Salesforce CLI v2.x](https://developer.salesforce.com/tools/salesforcecli)
- [ ] Git
- [ ] Salesforce Developer Edition org, sandbox, or scratch org
- [ ] VS Code + [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode) *(recommended)*

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Mgbams/Summer26.git
cd Summer26
```

### 2. Authorise Your Org

```bash
# Authenticate against an existing org
sf org login web --alias my-org
```

### 3. Create a Scratch Org *(Recommended)*

```bash
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias TrainingOrg \
  --set-default
```

### 4. Deploy a Topic

Each topic has its own README with exact file paths and deployment commands.  
The general pattern is:

```bash
# Copy topic files into the deployable source directory
cp topics/<TopicFolder>/classes/<ClassName>.cls force-app/main/default/classes/
cp topics/<TopicFolder>/classes/<ClassName>.cls-meta.xml force-app/main/default/classes/

# Deploy
sf project deploy start \
  --source-dir force-app/main/default/classes/<ClassName>.cls \
  --target-org TrainingOrg
```

### 5. Verify and Test

```bash
# Check deployment status
sf project deploy report

# Run all tests
sf apex run test --target-org TrainingOrg --result-format human

# Open the org in a browser
sf org open --target-org TrainingOrg
```

---

## 🔁 Deploying to an Existing Sandbox

```bash
sf org login web --alias MySandbox

sf project deploy start \
  --source-dir force-app/main/default \
  --target-org MySandbox \
  --test-level RunLocalTests
```

---

## 🧯 Troubleshooting

| Issue | Solution |
|---|---|
| Files not found after deploy | Confirm files were copied to the correct `force-app/main/default/` subfolder |
| Authentication expired | Re-run `sf org login web --alias <alias>` |
| Insufficient permissions | Verify the running user has Deploy permissions on the target org |
| Scratch org no longer needed | `sf org delete scratch --target-org TrainingOrg` |

---

## 🤝 Contributing

To add a new topic:

1. Create a subfolder under `topics/` following the existing structure
2. Include a `README.md`, class files, and metadata files
3. Add an entry to the Topics table in this file

---

## 🗓 Last Updated: 2026-04-26