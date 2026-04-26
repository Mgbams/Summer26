public with sharing class UserModeDatabaseOperations {
    /**
     * Demonstrates database operations in user mode (default in API 67.0+)
     * Operations respect user's object and field permissions
     */
    public static void demonstrateUserMode() {
        try {
            // This will respect the running user's permissions
            // If user doesn't have access to Account.AnnualRevenue, this will fail
            List<Account> accounts = [SELECT Id, Name, AnnualRevenue FROM Account LIMIT 5];
            System.debug('User mode query successful: ' + accounts.size() + ' accounts retrieved');

            // DML operations also run in user mode by default
            Account newAccount = new Account(Name = 'Test Account from User Mode', AnnualRevenue = 10500);
            insert newAccount; // Will fail if user lacks create permission on Account
            System.debug('User mode insert successful: ' + newAccount.Id);

        } catch (QueryException e) {
            System.debug('User mode query failed due to permissions: ' + e.getMessage());
        } catch (DmlException e) {
            System.debug('User mode DML failed due to permissions: ' + e.getMessage());
        }
    }

    /**
     * Demonstrates how to explicitly run operations in system mode
     * Bypasses user permissions - use with caution!
     */
    public static void demonstrateSystemMode() {
        try {
            // Explicitly run in system mode using Database class
            List<Account> accounts = Database.query('SELECT Id, Name, AnnualRevenue FROM Account LIMIT 5', AccessLevel.SYSTEM_MODE);
            System.debug('System mode query successful: ' + accounts.size() + ' accounts retrieved');

            // System mode DML
            Account newAccount = new Account(Name = 'Test Account from System Mode', AnnualRevenue = 10500);
            Database.insert(newAccount, AccessLevel.SYSTEM_MODE);
            System.debug('System mode insert successful: ' + newAccount.Id);

        } catch (Exception e) {
            System.debug('System mode operation failed: ' + e.getMessage());
        }
    }

    /**
     * Demonstrates mixed mode operations in the same transaction
     */
    public static void demonstrateMixedMode() {
        // Query in user mode (respects permissions)
        List<Account> userAccounts = Database.query('SELECT Id, Name, AnnualRevenue FROM Account LIMIT 2', AccessLevel.USER_MODE);

        // Insert in system mode (bypasses permissions)
        Account systemAccount = new Account(Name = 'System Mode Account', AnnualRevenue = 10500);
        Database.insert(systemAccount, AccessLevel.SYSTEM_MODE);

        System.debug('Mixed mode operations completed successfully');
    }

    /**
     * Example of how this affects field-level security
     */
    public static void demonstrateFieldLevelSecurity() {
        try {
            // In user mode, this will only return fields the user can access
            List<Account> accounts = Database.query('SELECT Id, Name, AnnualRevenue, Phone, BillingCity FROM Account LIMIT 1', AccessLevel.USER_MODE);
            if (!accounts.isEmpty()) {
                Account acc = accounts[0];
                System.debug('Name: ' + acc.Name);
                System.debug('User can access AnnualRevenue: ' + (acc.AnnualRevenue != null));
                System.debug('User can access Phone: ' + (acc.Phone != null));
                System.debug('User can access BillingCity: ' + (acc.BillingCity != null));
            }

        } catch (Exception e) {
            System.debug('Field access failed: ' + e.getMessage());
        }
    }
}