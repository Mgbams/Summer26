import { LightningElement } from 'lwc';
import { fromContext } from '@lwc/state';

import contactsStateManager from 'c/contactsStateManager';

export default class ContactTable extends LightningElement {
    contactState = fromContext(contactsStateManager);

    columns = [
        {
            label: 'Name',
            fieldName: 'name'
        },
        {
            label: 'Title',
            fieldName: 'title'
        },
        {
            label: 'Email',
            fieldName: 'email',
            type: 'email'
        },
        {
            label: 'Phone',
            fieldName: 'phone',
            type: 'phone'
        }
    ];

    get contacts() {
        return this.contactState.value.filteredContacts;
    }
}
