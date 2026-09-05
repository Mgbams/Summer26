import { LightningElement } from 'lwc';
import { fromContext } from '@lwc/state';

import contactsStateManager from 'c/contactsStateManager';

export default class ContactSummary extends LightningElement {
    contactState = fromContext(contactsStateManager);

    get totalCount() {
        return this.contactState.value.totalCount;
    }

    get visibleCount() {
        return this.contactState.value.visibleCount;
    }

    get hasFilter() {
        return Boolean(this.contactState.value.searchTerm.trim());
    }

    get totalContactsLabel() {
        return `Total contacts: ${this.totalCount}`;
    }

    get matchingContactsLabel() {
        return `Matching contacts: ${this.visibleCount}`;
    }
}