public with sharing class ContactStateController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('An Account Id is required.');
        }

        return [
            SELECT Id, Name, Email, Phone, Title
            FROM Contact
            WHERE AccountId = :accountId
            WITH USER_MODE
            ORDER BY Name
        ];
    }
}
