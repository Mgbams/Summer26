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
