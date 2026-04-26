# 🔐 Apex User Mode Database Operations — Summer '26

![Salesforce](https://img.shields.io/badge/Salesforce-Summer%20'26-blue)
![Apex](https://img.shields.io/badge/Apex-API%2067.0-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

---

## 📋 Project Information

| Field               | Details                                                                 |
|---------------------|-------------------------------------------------------------------------|
| **Project Name**    | User Mode Database Operations                                           |
| **Technology**      | Apex                                                                    |
| **Salesforce Version** | Summer '26 / API 67.0                                               |
| **Feature Maturity**| Beta                                                                    |
| **Problem It Solves** | Apex database operations historically ran in system mode by default, silently bypassing user permissions and FLS. API v67 enforces user mode by default, removing the need to manually add security checks on every query and DML statement. |
| **Key Features**    | Default user mode enforcement · Explicit system mode escalation · FLS enforcement via QueryException · Sharing keyword default change · WITH SECURITY_ENFORCED deprecation |

---

## 🌟 Overview

Before Summer '26, all Apex database operations ran in **system mode** by default.  
That meant object permissions, field-level security, and sharing rules were silently bypassed unless a developer explicitly added checks — on every query, on every DML, every time.

This project demonstrates the **API v67 default user mode** behavior introduced in Summer '26:

- Plain SOQL and DML now enforce the running user's permissions without extra code
- System mode is still available but must be declared explicitly
- Classes without a sharing keyword now default to `with sharing`

**Why it matters:**  
Security should not depend on every developer remembering every platform nuance.  
API v67 moves secure behavior to the default. An accidental omission no longer becomes an accidental privilege escalation.

> ⚠️ **Beta Notice:** This feature is available in Summer '26 preview and beta orgs only.  
> These changes are version-specific. Classes on API v66 or earlier are unaffected until you explicitly bump their API version.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| **Default User Mode** | Plain `[SELECT Id FROM Account]` and `insert` now enforce object permissions and FLS automatically at API v67 |
| **Explicit System Mode** | Use `AccessLevel.SYSTEM_MODE` to intentionally escalate — visible in code review, auditable by design |
| **Mixed Mode Transactions** | Read in user mode, write a system-owned record in the same transaction where justified |
| **FLS Throw Behaviour** | User mode raises `QueryException` on inaccessible fields — does not silently strip them |
| **Sharing Default Changed** | Omitting the sharing keyword now means `with sharing`, not inheriting caller context |
| **WITH SECURITY_ENFORCED Deprecated** | Migrate to explicit `AccessLevel.USER_MODE` or `AccessLevel.SYSTEM_MODE` declarations |

---

## ⚙️ Prerequisites

- [ ] Salesforce **Summer '26** org (sandbox, scratch org, or Developer Edition)
- [ ] API version **67.0** set on your Apex class metadata
- [ ] Salesforce CLI **v2.x** installed
- [ ] VS Code with the **Salesforce Extension Pack**
- [ ] Deploy permissions on the target org
- [ ] A **Standard User** profile available for realistic permission testing

> ⚠️ **Beta Warning:** Do not deploy to production orgs until General Availability.  
> Bumping an existing class to API v67 changes its runtime behaviour — test thoroughly before upgrading.

---

## 🚀 Usage

### 1. Clone the Repository

```bash
git clone https://github.com/Mgbams/Summer26.git
cd Summer26
```

### 2. Authorise Your Org

```bash
sf org login web --alias my-summer26-org
```

### 3. Copy the Class Files

```bash
cp topics/Apex_Development/User_Mode_Database_Operations/classes/UserModeDatabaseOperations.cls \
   force-app/main/default/classes/

cp topics/Apex_Development/User_Mode_Database_Operations/classes/UserModeDatabaseOperations.cls-meta.xml \
   force-app/main/default/classes/

cp topics/Apex_Development/User_Mode_Database_Operations/classes/UserModeDatabaseOperationsTest.cls \
   force-app/main/default/classes/

cp topics/Apex_Development/User_Mode_Database_Operations/classes/UserModeDatabaseOperationsTest.cls-meta.xml \
   force-app/main/default/classes/
```

### 4. Deploy to Your Org

```bash
sf project deploy start \
  --source-dir force-app/main/default/classes/UserModeDatabaseOperations.cls \
  --target-org my-summer26-org

sf project deploy start \
  --source-dir force-app/main/default/classes/UserModeDatabaseOperationsTest.cls \
  --target-org my-summer26-org
```

### 5. Run the Tests

```bash
sf apex run test \
  --class-names UserModeDatabaseOperationsTest \
  --target-org my-summer26-org \
  --result-format human
```

### 6. Manual Testing in Developer Console

```apex
// Run as an admin to observe system-level access
UserModeDatabaseOperations.demonstrateUserMode();

// Run as a Standard User via System.runAs to observe permission enforcement
UserModeDatabaseOperations.demonstrateFieldLevelSecurity();
```

**Expected behaviour:**  
A Standard User without Read on `Account` or access to a queried field will receive a `QueryException` at runtime. An admin running the same code will succeed. This confirms user mode is enforcing permissions correctly.

---

## 🧠 Core Concepts You Must Know

### 1️⃣ User Mode (The New Default at API v67)

Plain SOQL and DML now automatically enforce the running user's:
- Object-level permissions (Create, Read, Update, Delete)
- Field-level security (FLS)
- Sharing rules

```apex
// API v67 — runs in user mode by default
List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 5];
insert newAccount;
```

No extra code required. If the user lacks permission, the operation throws.

---

### 2️⃣ System Mode (Intentional Escalation)

System mode bypasses user permissions. At API v67, you must declare it explicitly:

```apex
// Explicit system mode — visible, auditable, intentional
List<Account> accounts = Database.query(
    'SELECT Id, Name FROM Account LIMIT 5',
    AccessLevel.SYSTEM_MODE
);

Database.insert(newAccount, AccessLevel.SYSTEM_MODE);
```

**Valid reasons to use system mode:**
- Admin-owned automation
- Audit logging
- Data repair utilities
- Trusted integration logic

If you cannot justify it in a code review, it should not be system mode.

---

### 3️⃣ FLS Enforcement — Throw vs Strip

This is where most developers trip up. The two approaches have different behaviour:

| Approach | Behaviour on FLS Violation |
|---|---|
| `AccessLevel.USER_MODE` | Throws `QueryException` — hard failure |
| `Security.stripInaccessible()` | Removes inaccessible fields — execution continues |

```apex
// User mode — throws if any queried field is inaccessible
try {
    List<Account> accounts = Database.query(
        'SELECT Id, Name, Phone FROM Account LIMIT 1',
        AccessLevel.USER_MODE
    );
} catch (QueryException e) {
    Map<String, Set<String>> blocked = e.getInaccessibleFields();
    System.debug('Blocked fields: ' + blocked);
}
```

**Rule of thumb:**  
Start with user mode. Use `stripInaccessible()` only when your design requires partial results or controlled fallback rather than a hard failure.

---

### 4️⃣ Sharing Keyword Default

| API Version | No Sharing Keyword Means |
|---|---|
| v66 and earlier | Inherits sharing mode of the calling context |
| v67+ | Defaults to `with sharing` |

The ambiguity of inheriting caller context is gone. Omission now has a predictable, secure default.

---

### 5️⃣ Triggers Are Always System Mode

Triggers always run in system mode — this is now consistent across all API versions.  
The previous inconsistency where sharing rules were unexpectedly enforced in some trigger contexts is resolved.

---

## 🧪 How It Works

### Execution Flow

```text
Apex Method Called
       │
       ▼
 API v67 Class?
  ┌────┴─────┐
  Yes        No
  │          │
  ▼          ▼
User Mode  System Mode
(Default)  (Legacy default)
  │
  ▼
Permission Check
  ┌──────────┴──────────┐
  Pass                  Fail
  │                     │
  ▼                     ▼
Result Returned     QueryException / DmlException thrown
```

### Scenario Outcomes

| Scenario | User Mode Result | System Mode Result |
|---|---|---|
| User has full object + FLS access | ✅ Returns records | ✅ Returns records |
| User lacks object Read permission | ❌ QueryException thrown | ✅ Returns records |
| User lacks FLS on a queried field | ❌ QueryException thrown | ✅ Returns records |
| Admin running the same query | ✅ Returns records | ✅ Returns records |
| Trigger context (any API version) | System mode always | System mode always |

---

## 🏗 Architecture

```text
force-app/
└── main/
    └── default/
        └── classes/
            ├── UserModeDatabaseOperations.cls           # Core class — user/system/mixed mode examples
            ├── UserModeDatabaseOperations.cls-meta.xml  # API v67 metadata declaration
            ├── UserModeDatabaseOperationsTest.cls       # Test class with System.runAs coverage
            └── UserModeDatabaseOperationsTest.cls-meta.xml
```

| Component | Purpose |
|---|---|
| `UserModeDatabaseOperations.cls` | Demonstrates user mode, system mode, mixed mode, and FLS enforcement |
| `UserModeDatabaseOperationsTest.cls` | Validates security behaviour using `System.runAs` with a Standard User profile |
| `.cls-meta.xml` files | Set API version to 67.0 — required to activate Summer '26 behaviour |

---

## 🧯 Troubleshooting

| Issue | Cause | Solution |
|---|---|---|
| Existing classes behave the same after org upgrade | API v67 changes are version-specific — old classes are unaffected | Explicitly bump the class API version to 67.0 in the `.cls-meta.xml` file |
| `QueryException` thrown unexpectedly after bumping API version | User mode is now enforced — running user lacks field or object access | Review permissions for the running user profile; add missing permissions or use `AccessLevel.SYSTEM_MODE` where justified |
| Tests pass as admin but fail as Standard User | `System.runAs` not used — tests ran under admin context | Wrap test logic in `System.runAs(standardUser)` to simulate real permission boundaries |
| `WITH SECURITY_ENFORCED` compiler warning | Deprecated at API v67 | Migrate to `AccessLevel.USER_MODE` in `Database.query()` or `Database.insert()` |
| Trigger behaviour changed unexpectedly | Sharing rules were being enforced in some trigger contexts pre-v67 | Triggers are now consistently system mode — review any trigger logic that assumed sharing enforcement |

---

## ✅ Best Practices

- **Start with user mode** for all new Apex at API v67 — it is the secure default
- **Declare system mode explicitly and document why** — it should survive a code review question
- **Use `System.runAs` in every security-related test** — admin-context tests do not validate permission boundaries
- **Do not mix `WITH SECURITY_ENFORCED` with `AccessLevel` parameters** — migrate fully to the newer pattern
- **Reach for `Security.stripInaccessible()`** only when partial results are a deliberate design choice, not as a workaround
- **Audit existing classes before bumping API versions** — surface permission assumptions before they surface in production
- **Run `RunAllTestsInOrg`** in your CI pipeline before a Summer '26 release window — permission failures that were silent before may now throw

---

## 📚 Resources

| Resource | Link |
|---|---|
| Summer '26 Release Notes — Apex Default User Mode | [help.salesforce.com](https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_default_user_mode.htm&release=262&type=5) |
| Apex Developer Guide — Enforce User Mode | [developer.salesforce.com](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm) |
| Apex Developer Guide — Database Class | [developer.salesforce.com](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_database.htm) |
| Security Guide — User Mode vs System Mode | [developer.salesforce.com](https://developer.salesforce.com/docs/atlas.en-us.securityImplGuide.meta/securityImplGuide/apex_user_mode_system_mode.htm) |
| Trailhead — Secure Serverside Development | [trailhead.salesforce.com](https://trailhead.salesforce.com/content/learn/modules/secure-serverside-development/write-secure-apex-controllers) |
| Salesforce CLI Reference | [developer.salesforce.com/tools/salesforcecli](https://developer.salesforce.com/tools/salesforcecli) |

---

## 🙋 Support

Found an issue or have a question?

- 📧 Contact: Kingsley MGBAMS — your.email@example.com

---

## 🗓 Last Updated: 2026-04-26