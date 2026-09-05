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
                const searchableText = [
                    contact.name,
                    contact.email,
                    contact.title
                ]
                .filter(Boolean)
                .join(' ')
                .toLowerCase();

                return searchableText.includes(normalizedSearch);
            });
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
});
