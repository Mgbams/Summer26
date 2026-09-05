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
            }));

            this.contactState.value.setContacts(contacts);
        } catch (error) {
            this.loadError = true;

            // Replace with your application's preferred logging strategy.
            console.error('Unable to load contacts', error);
        } finally {
            this.isLoading = false;
        }
    }
}
