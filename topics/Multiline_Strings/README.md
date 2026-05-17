# 🧹 Write Cleaner Code by Using Multiline Strings — Summer '26

![Salesforce](https://img.shields.io/badge/Salesforce-Summer%20'26-blue)
![Apex](https://img.shields.io/badge/Apex-API%2067.0-purple)
![LWC](https://img.shields.io/badge/LWC-Lightning_Web_Components-orange)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

---

## 📋 Project Information

| Field | Details |
|---|---|
| **Project Name** | Write Cleaner Code by Using Multiline Strings |
| **Technology** | Apex · Lightning Web Components (LWC) |
| **Salesforce Version** | Summer '26 / API 67.0 |
| **Feature Maturity** | Preview / New Feature |
| **Problem It Solves** | Apex string concatenation becomes difficult to read and maintain when building JSON payloads, SOQL templates, email bodies, or mock responses. |
| **Key Features** | Apex multiline strings · `String.template()` · JSON payload preview · Dynamic placeholder replacement · LWC payload viewer |

---

## 🌟 Overview

Before Summer '26, creating structured text in Apex often required long chains of string concatenation and escaped characters.

JSON payloads, SOQL templates, email bodies, and test fixtures quickly became difficult to review and maintain:

```apex
String body = '{\n' +
    '  "accountName": "' + acc.Name + '",\n' +
    '  "industry": "' + acc.Industry + '"\n' +
    '}';
````

Summer '26 introduces two language improvements:

* **Multiline strings** using triple single quotes (`'''`)
* **`String.template()`** for named placeholder replacement

This project demonstrates how to use both features in a real-world integration scenario.

The application allows users to:

* Select an Account
* Generate a formatted JSON payload
* Preview the payload visually in an LWC component
* Copy the generated payload
* Validate readable Apex integration patterns

---

## ✨ Key Features

| Feature                     | Description                                                               |
| --------------------------- | ------------------------------------------------------------------------- |
| **Multiline Strings**       | Create readable multiline JSON and text blocks using triple single quotes |
| **`String.template()`**     | Replace named placeholders dynamically using a `Map<String, Object>`      |
| **LWC Payload Previewer**   | Visual interface for generating and previewing JSON payloads              |
| **Readable JSON Templates** | JSON structure remains easy to review and maintain                        |
| **Error Handling**          | Graceful validation and exception handling                                |
| **Security Checks**         | Basic CRUD/FLS checks before querying Account data                        |
| **Test Coverage**           | Unit tests validate formatting, escaping, and fallback logic              |

---

## ⚙️ Prerequisites

* [ ] Salesforce Summer '26 org
* [ ] API version 67.0
* [ ] Salesforce CLI v2.x
* [ ] VS Code with Salesforce Extension Pack
* [ ] Lightning Web Components enabled
* [ ] Deploy permissions on the target org

> ⚠️ This feature requires Summer '26 preview or supported orgs.

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

### 3. Deploy the Project

```bash
sf project deploy start \
  --source-dir force-app \
  --target-org my-summer26-org
```

### 4. Run Apex Tests

```bash
sf apex run test \
  --class-names AccountUpdatePayloadServiceTest \
  --target-org my-summer26-org \
  --result-format human
```

### 5. Add the LWC to a Lightning Page

1. Open **Lightning App Builder**
2. Create or edit a page
3. Drag **Account Payload Previewer** onto the page
4. Save and activate the page

### 6. Generate a Payload

1. Select an Account
2. Click **Generate Payload**
3. Review the generated JSON
4. Copy the payload if needed

---

## 🧠 Core Concepts Demonstrated

### 1️⃣ Apex Multiline Strings

Multiline strings preserve formatting and eliminate repetitive concatenation.

```apex
String payload = '''
{
  "accountName": "Acme Corp",
  "industry": "Technology"
}
''';
```

---

### 2️⃣ String.template()

Named placeholders improve readability compared to positional formatting.

```apex
String payload = '''
{
  "accountName": "${accountName}",
  "industry": "${industry}"
}
'''.template(new Map<String, Object>{
    'accountName' => accountRecord.Name,
    'industry' => accountRecord.Industry
});
```

---

### 3️⃣ Readable JSON Payload Generation

The JSON structure remains visually aligned with the final output, making:

* Code reviews easier
* Git diffs cleaner
* Maintenance simpler
* Test fixtures easier to validate

---

### 4️⃣ Visual Payload Preview with LWC

The Lightning Web Component displays the generated payload inside a formatted preview panel.

This helps developers and admins validate:

* Payload structure
* Dynamic value replacement
* Escaping behaviour
* Readability improvements

---

## 🏗 Architecture

```text
force-app/
└── main/
    └── default/
        ├── classes/
        │   ├── AccountUpdatePayloadService.cls
        │   ├── AccountUpdatePayloadService.cls-meta.xml
        │   ├── AccountUpdatePayloadController.cls
        │   ├── AccountUpdatePayloadController.cls-meta.xml
        │   ├── AccountUpdatePayloadServiceTest.cls
        │   └── AccountUpdatePayloadServiceTest.cls-meta.xml
        │
        └── lwc/
            └── accountPayloadPreview/
                ├── accountPayloadPreview.html
                ├── accountPayloadPreview.js
                ├── accountPayloadPreview.css
                └── accountPayloadPreview.js-meta.xml
```

| Component                             | Purpose                                          |
| ------------------------------------- | ------------------------------------------------ |
| `AccountUpdatePayloadService.cls`     | Generates JSON payloads using multiline strings  |
| `AccountUpdatePayloadController.cls`  | Exposes Apex methods to LWC                      |
| `AccountUpdatePayloadServiceTest.cls` | Validates payload generation and escaping        |
| `accountPayloadPreview`               | LWC interface for payload generation and preview |

---

## 🧪 Example Generated Payload

```json
{
  "account": {
    "id": "001XXXXXXXXXXXX",
    "name": "Acme Corp",
    "industry": "Technology",
    "annualRevenue": 1500000
  },
  "summary": "Account Acme Corp is categorized under Technology and has an annual revenue of 1500000.",
  "audit": {
    "sourceSystem": "LWC Payload Previewer",
    "requestedBy": "Integration User"
  }
}
```

---

## 🧯 Troubleshooting

| Issue                                | Cause                                        | Solution                                               |
| ------------------------------------ | -------------------------------------------- | ------------------------------------------------------ |
| Generate Payload button does nothing | Apex wrapper fields missing `@AuraEnabled`   | Add `@AuraEnabled` to response properties              |
| LWC shows undefined response         | Apex response object not serializable        | Ensure all response fields are public and Aura-enabled |
| Payload formatting looks broken      | Dynamic values contain quotes or line breaks | Escape inserted values before template replacement     |
| LWC not visible in App Builder       | Component not exposed                        | Set `<isExposed>true</isExposed>` in meta XML          |
| Deployment fails on multiline syntax | Unsupported org or API version               | Verify Summer '26 org and API 67.0                     |

---

## ✅ Best Practices

* Use multiline strings for stable structured text blocks
* Use `String.template()` for readable placeholder replacement
* Escape inserted values before building JSON or HTML
* Prefer readable templates over excessive concatenation
* Keep payload structures visually aligned with final output
* Add unit tests for generated payloads and escaping logic
* Use LWC preview components for easier debugging and demonstrations

---

## 📚 Resources

| Resource                                     | Link                                                                                                                                                                                                                     |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Summer '26 Release Notes — Multiline Strings | [https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_multiline_string.htm&release=262&type=5](https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_multiline_string.htm&release=262&type=5) |
| Apex String Class Documentation              | [https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_string.htm](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_string.htm)           |
| Lightning Web Components Developer Guide     | [https://developer.salesforce.com/docs/component-library/documentation/en/lwc](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)                                                             |
| Salesforce CLI Documentation                 | [https://developer.salesforce.com/tools/salesforcecli](https://developer.salesforce.com/tools/salesforcecli)                                                                                                             |

---

## 🙋 Support

Found an issue or have a question?

* 📧 Contact: Kingsley MGBAMS — [cmgbams@gmail.com](mailto:cmgbams@gmail.com)

---

## 🗓 Last Updated: 2026-05-17
