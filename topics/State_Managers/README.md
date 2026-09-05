# 🧠 Manage State Across LWC Components with State Managers

![LWC](https://img.shields.io/badge/LWC-API%2067.0-orange) ![State Managers](https://img.shields.io/badge/LWC-State%20Managers-purple) ![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

---

## 📋 Project Information

| Field                  | Details                                                                                                                                                                              |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Project Name**       | Manage State Across LWC Components with State Managers                                                                                                                               |
| **Technology**         | Lightning Web Components · JavaScript · Apex                                                                                                                                         |
| **Salesforce Version** | Summer '26 / API 66.0                                                                                                                                                                |
| **Feature Maturity**   | Generally Available (GA)                                                                                                                                                             |
| **Problem It Solves**  | Sharing and coordinating reactive application state across multiple LWCs can lead to prop drilling, repetitive events, and state-management logic accumulating in parent components. |
| **Key Features**       | `defineState()` · `atom()` · `computed()` · `setAtom()` · Actions · `fromContext()` · Provider/Consumer pattern · Reactive shared state                                              |

---

## 🌟 Overview

As Lightning Web Component applications grow, shared state can become increasingly difficult to manage.

A small component tree might start with a parent passing data to a child:

```html
<c-contact-table contacts={contacts}></c-contact-table>
```

and receiving changes through custom events:

```html
<c-contact-search onsearchchange={handleSearchChange}></c-contact-search>
```

That pattern works well for simple parent-child communication.

The friction begins when multiple deeply nested components need the same data.

For example:

```text
accountWorkspace
|
+-- workspaceToolbar
|   |
|   +-- contactSearch
|
+-- workspaceBody
    |
    +-- contactTable
    |
    +-- workspaceSidebar
        |
        +-- contactSummary
```

Without shared state, intermediate components may need to pass properties and events even when they don't use the data themselves.

Summer '26 introduces **LWC State Managers** as an LWC-native way to separate shared application state from component presentation logic.

A State Manager is a JavaScript module that can contain:

* Reactive state using `atom()`
* Derived state using `computed()`
* State updates using `setAtom()`
* Public actions that modify state
* Shared instances consumed through `fromContext()`

This project demonstrates State Managers using a simple **Account + Contact workspace**.

The application allows users to:

* Open the workspace from an Account record page
* Load Contacts belonging to the Account
* Search Contacts by name, email, or title
* Display filtered Contacts in a datatable
* Display total and matching Contact counts
* Share state between independent LWC components
* Avoid passing Contact state through component properties and custom events

> ⚠️ **Platform note:** LWC State Managers are currently available in Lightning Experience but are not supported in Experience Cloud.

---

## ✨ Key Features

| Feature                         | Description                                                               |
| ------------------------------- | ------------------------------------------------------------------------- |
| **`defineState()`**             | Defines a reusable State Manager and its public API                       |
| **`atom()`**                    | Stores a reactive piece of application state                              |
| **`computed()`**                | Creates values derived automatically from other state                     |
| **`setAtom()`**                 | Updates atom values and participates in LWC reactivity                    |
| **Actions**                     | Provide controlled functions for changing State Manager state             |
| **`fromContext()`**             | Allows descendant components to retrieve a shared State Manager instance  |
| **Provider / Consumer Pattern** | One enclosing component creates the instance while descendants consume it |
| **Reactive Contact Filtering**  | Search state automatically recalculates the filtered Contact collection   |
| **Derived Counts**              | Total and visible Contact counts are calculated as computed state         |
| **Apex Data Loading**           | Contacts are retrieved once by the provider and placed into shared state  |
| **User-Mode Querying**          | Apex uses `WITH USER_MODE` for Salesforce data access                     |
| **Standard Objects Only**       | Example uses Account and Contact with no custom object setup              |

---

## ⚙️ Prerequisites

* [ ] Salesforce Summer '26 org
* [ ] API version 67.0
* [ ] Salesforce CLI v2.x
* [ ] VS Code with Salesforce Extension Pack
* [ ] Lightning Web Components enabled
* [ ] Deploy permissions on the target org
* [ ] Access to Account and Contact
* [ ] Lightning Experience

> ⚠️ State Managers aren't currently supported in Experience Cloud.

---

## Usage

### 1. Clone the Repository

```bash
git clone https://github.com/Mgbams/Summer26.git

cd Summer26
```

---

### 2. Authorise Your Org

```bash
sf org login web --alias my-summer26-org
```

---

### 3. Deploy the Project

```bash
sf project deploy start --source-dir force-app --target-org my-summer26-org
```

---

### 4. Run Apex Tests

```bash
sf apex run test --class-names ContactStateControllerTest --target-org my-summer26-org --result-format human
```

---

### 5. Prepare Test Data

Create an Account with a few Contacts.

For example:

```text
Account
└── Acme Corporation
    |
    +-- Ava Adams
    |   Email: ava@example.com
    |   Title: VP Sales
    |
    +-- Ben Baker
        Email: ben@example.com
        Title: Solutions Architect
```

No custom objects or special configuration are required.

---

### 6. Add the LWC to an Account Record Page

1. Open **Lightning App Builder**
2. Edit an **Account Record Page**
3. Find **Contact Workspace**
4. Drag it onto the page
5. Save the page
6. Activate the page if necessary

The component automatically receives the current Account ID through:

```javascript
@api recordId;
```

---

### 7. Test Shared State

Open an Account containing Contacts.

The workspace displays:

* A Contact search box
* Total Contact count
* Matching Contact count when filtering
* A Contact datatable

Enter:

```text
architect
```

in the search box.

The State Manager updates the search term, recalculates the filtered Contacts, updates the table, and updates the summary without the search component communicating directly with either consumer.

---

## 🧠 Core Concepts Demonstrated

### 1️⃣ Defining a State Manager

A custom State Manager is defined using `defineState()` from `@lwc/state`.

```javascript
import { defineState } from '@lwc/state';

export default defineState(
    ({ atom, computed, setAtom }) => {
        // State Manager implementation
    }
);
```

`defineState()` returns a factory.

Calling that factory creates an independent State Manager instance.

---

### 2️⃣ Reactive State with `atom()`

An atom represents a reactive piece of state.

```javascript
const contacts = atom([]);
const searchTerm = atom('');
```

In this project:

```text
contacts
```

contains the Contacts loaded from Salesforce.

```text
searchTerm
```

contains the current client-side search value.

---

### 3️⃣ Updating State with `setAtom()`

Atoms are updated using `setAtom()`.

```javascript
const setContacts = (newContacts) => {
    setAtom(contacts, newContacts);
};

const setSearchTerm = (value) => {
    setAtom(searchTerm, value ?? '');
};
```

These functions become actions exposed by the State Manager.

Consumers therefore don't need to manipulate atom internals directly.

---

### 4️⃣ Derived State with `computed()`

`computed()` creates state derived from other reactive values.

```javascript
const filteredContacts = computed(
    [contacts, searchTerm],
    (contactList, currentSearchTerm) => {
        const normalizedSearch = currentSearchTerm
            .trim()
            .toLowerCase();

        if (!normalizedSearch) {
            return contactList;
        }

        return contactList.filter((contact) => {
            const searchableText = [
                contact.name,
                contact.email,
                contact.title
            ]
                .filter(Boolean)
                .join(' ')
                .toLowerCase();

            return searchableText.includes(
                normalizedSearch
            );
        });
    }
);
```

Whenever either:

```text
contacts
```

or:

```text
searchTerm
```

changes, the filtered Contact value can be recomputed.

---

### 5️⃣ Computed Values Can Depend on Computed Values

The project also derives summary values.

```javascript
const totalCount = computed(
    [contacts],
    (contactList) => contactList.length
);

const visibleCount = computed(
    [filteredContacts],
    (contactList) => contactList.length
);
```

This creates a reactive dependency chain:

```text
contacts
    |
    +------> totalCount
    |
    +------> filteredContacts
                  |
                  v
             visibleCount

searchTerm
    |
    +------> filteredContacts
```

---

### 6️⃣ Provider Component

The provider creates the shared State Manager instance.

```javascript
contactState = contactsStateManager();
```

In this project:

```text
contactWorkspace
```

is the provider.

It also retrieves the initial Contact records from Apex and places them into state:

```javascript
this.contactState.value.setContacts(contacts);
```

The instance is created before the provider connects to the DOM.

---

### 7️⃣ Consumer Components with `fromContext()`

Consumers don't create another State Manager.

They retrieve the provider's instance using:

```javascript
import { fromContext } from '@lwc/state';

contactState = fromContext(
    contactsStateManager
);
```

The project contains three consumers:

```text
contactSearch
contactTable
contactSummary
```

Each receives the same shared State Manager instance from the component context.

---

### 8️⃣ Actions Instead of Component Events

The search component updates state directly through an action:

```javascript
handleSearchChange(event) {
    this.contactState.value.setSearchTerm(
        event.target.value
    );
}
```

It doesn't need to dispatch:

```javascript
new CustomEvent('searchchange')
```

to a parent just so the updated state can be passed down to another child.

The State Manager handles that coordination.

---

## 🏗 Architecture

```text
force-app/
└── main/
    └── default/
        ├── classes/
        │   ├── ContactStateController.cls
        │   ├── ContactStateController.cls-meta.xml
        │   ├── ContactStateControllerTest.cls
        │   └── ContactStateControllerTest.cls-meta.xml
        │
        └── lwc/
            ├── contactsStateManager/
            │   ├── contactsStateManager.js
            │   └── contactsStateManager.js-meta.xml
            │
            ├── contactWorkspace/
            │   ├── contactWorkspace.html
            │   ├── contactWorkspace.js
            │   └── contactWorkspace.js-meta.xml
            │
            ├── contactSearch/
            │   ├── contactSearch.html
            │   ├── contactSearch.js
            │   └── contactSearch.js-meta.xml
            │
            ├── contactTable/
            │   ├── contactTable.html
            │   ├── contactTable.js
            │   └── contactTable.js-meta.xml
            │
            └── contactSummary/
                ├── contactSummary.html
                ├── contactSummary.js
                └── contactSummary.js-meta.xml
```

| Component                        | Purpose                                                                      |
| -------------------------------- | ---------------------------------------------------------------------------- |
| `contactsStateManager.js`        | Owns Contacts, search state, computed filtered Contacts, counts, and actions |
| `contactWorkspace`               | Provider that creates the shared State Manager and loads Contacts from Apex  |
| `contactSearch`                  | Consumer that updates the shared search term                                 |
| `contactTable`                   | Consumer that displays the filtered Contact collection                       |
| `contactSummary`                 | Consumer that displays total and matching Contact counts                     |
| `ContactStateController.cls`     | Retrieves Contacts belonging to the current Account                          |
| `ContactStateControllerTest.cls` | Tests Contact retrieval, empty results, and invalid input                    |

---

## 🔄 State Flow

```text
Account Record Page
       |
       v
contactWorkspace
    Provider
       |
       +---- creates contactsStateManager()
       |
       +---- ContactStateController.getContacts()
       |
       +---- setContacts()
       |
       v
+---------------------------------------+
|          contactsStateManager         |
|                                       |
|  contacts                             |
|  searchTerm                           |
|                                       |
|  filteredContacts                     |
|  totalCount                           |
|  visibleCount                         |
|                                       |
|  setContacts()                        |
|  setSearchTerm()                      |
+---------------------------------------+
       |
       +-----------------------+
       |                       |
       v                       v
 contactSearch            contactTable
 fromContext()            fromContext()
       |                       |
 setSearchTerm()          filteredContacts
       |
       +------------+
                    |
                    v
              contactSummary
               fromContext()
                    |
               totalCount
               visibleCount
```

---

## 🧩 State Manager Implementation

The core State Manager used by the project is:

```javascript
import { defineState } from '@lwc/state';

export default defineState(({ atom, computed, setAtom }) => {
  const contacts = atom([]);
  const searchTerm = atom('');

  const setContacts = (newContacts) => {
    setAtom(contacts, newContacts);
  };

  const setSearchTerm = (value) => {
    setAtom(searchTerm, value ?? '');
  };

  const filteredContacts = computed([contacts, searchTerm], (contactList, currentSearchTerm) => {
                const normalizedSearch = currentSearchTerm.trim().toLowerCase();

                if (!normalizedSearch) {
                  return contactList;
                }

                return contactList.filter((contact) => {
                  const searchableText = [contact.name, contact.email, contact.title].filter(Boolean).join(' ').toLowerCase();

                  return searchableText.includes(normalizedSearch);
                  }
                );
            }
        );

        const totalCount = computed([contacts], (contactList) => contactList.length);

        const visibleCount = computed([filteredContacts], (contactList) => contactList.length);

        return {
          contacts,
          searchTerm,
          filteredContacts,
          totalCount,
          visibleCount,
          setContacts,
          setSearchTerm
        };
    }
);
```

---

## 🔌 Provider Example

The provider creates the shared State Manager instance.

```javascript
import { LightningElement, api } from 'lwc';
import contactsStateManager from 'c/contactsStateManager';
import getContacts from '@salesforce/apex/ContactStateController.getContacts';

export default class ContactWorkspace extends LightningElement {

  @api recordId;
  contactState = contactsStateManager();

  isLoading = true;
  loadError = false;

  async connectedCallback() {
    try {
      const result = await getContacts({accountId: this.recordId});
      const contacts = result.map((contact) => ({
          id: contact.Id,
          name: contact.Name,
          email: contact.Email,
          phone: contact.Phone,
          title: contact.Title
        })
      );

      this.contactState.value.setContacts(contacts);
    } catch (error) {
      this.loadError = true;
    } finally {
      this.isLoading = false;
    }
  }
}
```

---

## 📡 Consumer Example

A consumer retrieves the provider's instance with `fromContext()`.

```javascript
import { LightningElement } from 'lwc';
import { fromContext } from '@lwc/state';
import contactsStateManager from 'c/contactsStateManager';

export default class ContactSearch extends LightningElement {

  contactState = fromContext(contactsStateManager);

  get searchTerm() {
    return this.contactState.value.searchTerm;
  }

  handleSearchChange(event) {
    this.contactState.value.setSearchTerm(event.target.value);
  }
}
```

Another consumer can independently read the derived state:

```javascript
get contacts() {
    return this.contactState.value.filteredContacts;
}
```

No property needs to travel from the search component to the table.

---

## 🗄 Apex Data Retrieval

Contacts are loaded once by the provider.

```apex
public with sharing class ContactStateController {

  @AuraEnabled(cacheable=true)
  public static List<Contact> getContacts(Id accountId) {
    if (accountId == null) {
      throw new AuraHandledException('An Account Id is required.');
    }

    return [SELECT Id, Name, Email, Phone, Title
            FROM Contact
            WHERE AccountId = :accountId
            WITH USER_MODE
            ORDER BY Name
    ];
  }
}
```

The State Manager itself doesn't provide Salesforce record security.

Security is enforced where Salesforce data is retrieved.

---

## ⚖️ State Manager vs Traditional Component Communication

### Traditional Approach

```text
Parent
|
+-- Search
|      |
|      +---- CustomEvent
|               |
|               v
|             Parent
|               |
|               +---- property
|                       |
|                       v
+-------------------- Table
|
+-------------------- Summary
```

### State Manager Approach

```text
Provider
   |
   +---- State Manager
   |
   +---- Search
   |       |
   |       +---- setSearchTerm()
   |
   +---- Table
   |       |
   |       +---- filteredContacts
   |
   +---- Summary
           |
           +---- totalCount
           +---- visibleCount
```

The difference isn't simply fewer lines of code.

The important difference is **coupling**.

Intermediate components don't need to pass state they don't use.

---

## 🧯 Troubleshooting

| Issue                                          | Cause                                                                     | Solution                                                                               |
| ---------------------------------------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| State Manager import fails                     | Org or component API version doesn't support the feature                  | Verify Summer '26 and API 67.0                                                         |
| Consumer cannot access state                   | No matching provider exists in its ancestor component tree                | Ensure an enclosing component creates the State Manager instance                       |
| Consumer gets state too early                  | State Manager context resolves during component DOM connection            | Avoid accessing consumer state from constructor-time logic                             |
| Components don't share values                  | Each component calls the State Manager factory independently              | Create one instance in the provider and use `fromContext()` in consumers               |
| State doesn't update reactively                | Atom value was mutated directly instead of updated through `setAtom()`    | Expose an action that calls `setAtom()`                                                |
| Search doesn't affect the table                | Consumer is using a different State Manager definition or instance        | Verify both import the same State Manager module and resolve the same provider         |
| LWC isn't visible in App Builder               | Provider isn't exposed                                                    | Set `<isExposed>true</isExposed>` and configure `lightning__RecordPage`                |
| Account ID is undefined                        | Component isn't on a supported record page or isn't using `@api recordId` | Add the provider to an Account record page and use `recordId`                          |
| Apex returns an authorization error            | User doesn't have required access to Contact data                         | Review sharing, object permissions, and field permissions                              |
| State Manager doesn't work in Experience Cloud | State Managers aren't currently supported there                           | Use a supported Lightning Experience context or choose another communication mechanism |

---

## ✅ Best Practices

* Create the shared State Manager instance in the enclosing provider
* Use `fromContext()` for descendant consumers
* Keep related state and actions together
* Update atoms through `setAtom()`
* Use `computed()` for values derived from existing state
* Keep the State Manager's returned public shape consistent
* Prefer plain JavaScript data where practical
* Keep DOM manipulation inside LWC components rather than State Managers
* Keep Salesforce security enforcement at the Salesforce data-access boundary
* Don't use State Managers when ordinary parent-child properties and events are simpler
* Don't assume State Manager state is automatically persisted
* Avoid turning one State Manager into a global dumping ground for unrelated state
* Evaluate built-in `lightning/stateManager*` modules before recreating Salesforce data-access state layers
* Continue using LDS or wire adapters where standalone component-level data access is the simpler solution

---

## 🚫 What State Managers Are Not

State Managers should not automatically be treated as:

* Browser storage
* Persistent Salesforce storage
* Cross-tab synchronization
* Cross-session synchronization
* A server-side cache
* A replacement for Salesforce security
* A replacement for Apex
* A replacement for Lightning Data Service
* A global event bus
* An automatic performance optimization

State management and data persistence remain separate architectural concerns.

---

## 🧱 Built-In State Managers

Salesforce also provides built-in State Managers under the `lightning/stateManager*` namespace.

Examples include State Managers for:

```text
Records
Object metadata
Layouts
Related lists
```

For example:

```javascript
import stateManagerRecord from 'lightning/stateManagerRecord';
```

These built-in State Managers integrate with Lightning Data Service and UI API.

They can be useful when multiple synchronized components need coordinated Salesforce data.

For a standalone component making a simple data request, a standard LDS wire adapter may still be the clearer choice.

---

## 🧪 Testing

The included Apex test validates:

* Contacts are returned for the requested Account
* Multiple Contacts can be returned
* An Account without Contacts returns an empty collection
* A missing Account ID is rejected

Run the tests with:

```bash
sf apex run test --class-names ContactStateControllerTest --target-org my-summer26-org --result-format human
```

State Managers are JavaScript modules without DOM dependencies, so State Manager business logic can also be isolated for JavaScript unit testing where appropriate.

---

## 📚 Resources

| Resource                                               | Link                                                                                                 |
| ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------- |
| Manage State Across LWC Components with State Managers | https://developer.salesforce.com/docs/platform/lwc/guide/state-management.html                       |
| State Management Compared with Alternatives            | https://developer.salesforce.com/docs/platform/lwc/guide/state-management-alternatives.html          |
| Define a State Manager                                 | https://developer.salesforce.com/docs/platform/lwc/guide/state-management-define.html                |
| State Manager Syntax                                   | https://developer.salesforce.com/docs/platform/lwc/guide/state-management-define-syntax.html         |
| Implement a State Manager                              | https://developer.salesforce.com/docs/platform/lwc/guide/state-management-define-implementation.html |
| Share a State Manager Across Components                | https://developer.salesforce.com/docs/platform/lwc/guide/state-management-example-fromcontext.html   |
| Nested State Manager Example                           | https://developer.salesforce.com/docs/platform/lwc/guide/state-management-example-nested.html        |
| State Management Examples                              | https://developer.salesforce.com/docs/platform/lwc/guide/state-management-examples.html              |
| Built-In State Managers                                | https://developer.salesforce.com/docs/platform/lwc/guide/reference-state-managers.html               |
| Salesforce State Management Examples                   | https://github.com/forcedotcom/state-management                                                      |
| Lightning Web Components Recipes                       | https://github.com/trailheadapps/lwc-recipes                                                         |
| Salesforce CLI Documentation                           | https://developer.salesforce.com/tools/salesforcecli                                                 |

---

## 🙋 Support

Found an issue or have a question ?

* 📧 Contact: Kingsley MGBAMS — [cmgbams@gmail.com](mailto:cmgbams@gmail.com)
---

## 🗓 Last Updated: 2026-09-06
