# Define Picklist Values for Apex Action Inputs — Summer '26

![Salesforce](https://img.shields.io/badge/Salesforce-Summer%20'26-blue)
![Apex](https://img.shields.io/badge/Apex-API%2067.0-purple)
![Flow](https://img.shields.io/badge/Flow-Builder-orange)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

## Project Information

| Field                  | Details                                                                        |
| ---------------------- | ------------------------------------------------------------------------------ |
| **Project Name**       | Define Picklist Values for Apex Action Inputs                                  |
| **Technology**         | Apex · Flow Builder · InvocableActionExt Metadata                              |
| **Salesforce Version** | Summer '26 / API 67.0                                                          |
| **Feature Type**       | Flow Builder configuration enhancement                                         |
| **Problem It Solves**  | Helps admins choose valid Apex action input values instead of typing free text |
| **Main Feature**       | `ProvidedValuesList` for static and dynamic picklist values                    |

## Overview

This project demonstrates the Summer '26 feature **Define Picklist Values for Apex Action Inputs**.

The example uses an invocable Apex action named `CustomerFollowUpAction`. A Flow calls the action when an Account is created and passes two configurable values:

| Input           | Type             | Source                              |
| --------------- | ---------------- | ----------------------------------- |
| `urgency`       | Static picklist  | Defined directly in XML             |
| `industryFocus` | Dynamic picklist | Read from Account `Industry` values |

The Apex action still receives normal `String` values at runtime. The feature improves the Flow Builder configuration experience.

## Prerequisites

* Salesforce Summer '26 org or preview org
* API version 67.0
* Salesforce CLI v2.x
* VS Code with Salesforce Extension Pack
* Permission to deploy Apex and metadata
* Flow Builder access

## Usage

### 1. Authorize Your Org

```bash
sf org login web --alias my-summer26-org
```

### 2. Deploy the Source

```bash
sf project deploy start --source-dir force-app --target-org my-summer26-org
```

### 3. Run Apex Tests

```bash
sf apex run test --class-names CustomerFollowUpActionTest --target-org my-summer26-org --result-format human
```

### 4. Open the Flow

1. Go to **Setup**
2. Open **Flows**
3. Open **Account Onboarding - Create Follow-Up Task**
4. Inspect the Apex action **Create Customer Follow-Up Task**

## Core Concept

The feature is configured in an `InvocableActionExt` metadata file.

```xml
<key>ProvidedValuesList</key>
```

### Static Picklist Example

```xml
<targets>
    <targetType>ActionParameter</targetType>
    <targetName>CustomerFollowUpAction.Request.urgency</targetName>
    <attributes>
        <key>ProvidedValuesList</key>
        <dataType>String</dataType>
        <value>LOW|Low,NORMAL|Normal,HIGH|High</value>
    </attributes>
</targets>
```

This gives Flow Builder these choices:

| Apex Value | Label  |
| ---------- | ------ |
| `LOW`      | Low    |
| `NORMAL`   | Normal |
| `HIGH`     | High   |

### Dynamic Picklist Example

```xml
<targets>
    <targetType>ActionParameter</targetType>
    <targetName>CustomerFollowUpAction.Request.industryFocus</targetName>
    <attributes>
        <key>ProvidedValuesList</key>
        <dataType>String</dataType>
        <value>apex://AccountIndustryPicklist</value>
    </attributes>
</targets>
```

The dynamic provider class extends `VisualEditor.DynamicPickList` and returns active Account `Industry` values.

```apex
global with sharing class AccountIndustryPicklist extends VisualEditor.DynamicPickList {
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows rows = new VisualEditor.DynamicPickListRows();

        Schema.SObjectField industryField =
            Schema.SObjectType.Account.fields.getMap().get('Industry');

        if (industryField == null) {
            return rows;
        }

        for (Schema.PicklistEntry entry : industryField.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                rows.addRow(new VisualEditor.DataRow(entry.getLabel(), entry.getValue()));
            }
        }

        return rows;
    }

    global override VisualEditor.DataRow getDefaultValue() {
        Schema.SObjectField industryField =
            Schema.SObjectType.Account.fields.getMap().get('Industry');

        if (industryField == null) {
            return new VisualEditor.DataRow('No active values found', '');
        }

        for (Schema.PicklistEntry entry : industryField.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                return new VisualEditor.DataRow(entry.getLabel(), entry.getValue());
            }
        }

        return new VisualEditor.DataRow('No active values found', '');
    }
}
```

## Architecture

```text
force-app/
└── main/
    └── default/
        ├── classes/
        │   ├── AccountIndustryPicklist.cls
        │   ├── CustomerFollowUpAction.cls
        │   └── CustomerFollowUpActionTest.cls
        │
        ├── flows/
        │   └── Account_Onboarding_Create_Follow_Up_Task.flow-meta.xml
        │
        └── invocableactionextensions/
            └── CustomerFollowUpAction.invocableactionextension-meta.xml
```

| Component                                                  | Purpose                                 |
| ---------------------------------------------------------- | --------------------------------------- |
| `CustomerFollowUpAction.cls`                               | Invocable Apex action called by Flow    |
| `AccountIndustryPicklist.cls`                              | Dynamic picklist provider               |
| `CustomerFollowUpActionTest.cls`                           | Apex unit tests                         |
| `CustomerFollowUpAction.invocableactionextension-meta.xml` | Defines static and dynamic input values |
| `Account_Onboarding_Create_Follow_Up_Task.flow-meta.xml`   | Example Flow that calls the Apex action |

## Important Notes

* The Apex action still receives `String` values.
* Flow metadata still stores selected values as `<stringValue>`.
* Apex validation is still required.
* `targetName` must match the Apex class, inner class, and variable name.
* Use `ProvidedValuesList`, not `ProvidedValueList`.
* Use a Custom Property Editor when the setup UI needs more than a simple list.

## Troubleshooting

| Issue                               | Fix                                                                            |
| ----------------------------------- | ------------------------------------------------------------------------------ |
| Inputs still appear as text fields  | Confirm the org supports the Summer '26 feature and verify `targetName` values |
| Deployment rejects the metadata key | Use `ProvidedValuesList`                                                       |
| Dynamic provider class not found    | Confirm `AccountIndustryPicklist.cls` compiles and deploys                     |
| Dynamic list is empty               | Check active values on Account `Industry`                                      |
| Invalid values still reach Apex     | Keep Apex-side validation                                                      |

## Resources

| Resource                                       | Link                                                                                                                                                    |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Define Picklist Values for Apex Action Inputs  | https://help.salesforce.com/s/articleView?id=release-notes.rn_automate_flow_extend_define_picklist_values_for_apex_action_inputs.htm&release=262&type=5 |
| InvocableActionExtension Metadata Enhancements | https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_invocableactionextension_metadata_enhancements.htm&release=262&type=5                |
| DynamicPickList Apex Reference                 | https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_VisualEditor_DynamicPickList.htm                                      |
| Custom Property Editors in Flow Builder        | https://developer.salesforce.com/docs/platform/lwc/guide/use-flow-custom-property-editor.html                                                           |
| Salesforce CLI Documentation                   | https://developer.salesforce.com/tools/salesforcecli                                                                                                    |

## Support

Questions or issues?

Contact: Kingsley MGBAMS — [cmgbams@gmail.com](mailto:cmgbams@gmail.com)

## Last Updated: 2026-05-17
