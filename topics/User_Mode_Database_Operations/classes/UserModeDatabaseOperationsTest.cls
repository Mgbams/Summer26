@isTest
public class UserModeDatabaseOperationsTest {
    @TestSetup
    static void setupTestData() {
        // Create test data in system mode to ensure it exists
        Account testAccount = new Account(Name = 'Test Account');
        Database.insert(testAccount, AccessLevel.SYSTEM_MODE);
    }

    @isTest
    static void testUserModeOperations() {
        User standardUser = createStandardUser();

        System.runAs(standardUser) {
            // Test user mode operations
            UserModeDatabaseOperations.demonstrateUserMode();

            // Verify that operations respect user permissions
            // (This would fail in a real scenario if user lacks permissions)
        }
    }

    @isTest
    static void testSystemModeOperations() {
        User standardUser = createStandardUser();

        System.runAs(standardUser) {
            // Test system mode operations
            UserModeDatabaseOperations.demonstrateSystemMode();

            // Verify that system mode bypasses permissions
            List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Account from System Mode'];
            System.assert(accounts.size() > 0, 'System mode insert should succeed');
        }
    }

    @isTest
    static void testMixedModeOperations() {
        User standardUser = createStandardUser();

        System.runAs(standardUser) {
            UserModeDatabaseOperations.demonstrateMixedMode();

            // Verify both operations completed
            List<Account> systemAccounts = [SELECT Id FROM Account WHERE Name = 'System Mode Account'];
            System.assert(systemAccounts.size() > 0, 'Mixed mode operations should succeed');
        }
    }

    @isTest
    static void testFieldLevelSecurity() {
        User standardUser = createStandardUser();

        System.runAs(standardUser) {
            UserModeDatabaseOperations.demonstrateFieldLevelSecurity();
            // Test would verify field access based on user permissions
        }
    }

    private static User createStandardUser() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );

        Database.insert(testUser, AccessLevel.SYSTEM_MODE);
        return testUser;
    }
}