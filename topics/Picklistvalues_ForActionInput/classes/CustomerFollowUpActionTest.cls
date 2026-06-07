@IsTest
private class CustomerFollowUpActionTest {
    @IsTest
    static void createsTaskForAccount() {
        Account accountRecord = new Account(
            Name = 'Acme Solar'
        );
        insert accountRecord;

        CustomerFollowUpAction.Request request = new CustomerFollowUpAction.Request();
        request.accountId = accountRecord.Id;
        request.urgency = 'HIGH';
        request.industryFocus = 'Technology';

        Test.startTest();
        List<CustomerFollowUpAction.Result> results =
            CustomerFollowUpAction.createTasks(
                new List<CustomerFollowUpAction.Request>{ request }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success, results[0].message);
        System.assertNotEquals(null, results[0].taskId);

        Task createdTask = [
            SELECT Subject, Priority, WhatId
            FROM Task
            WHERE Id = :results[0].taskId
        ];

        System.assertEquals(accountRecord.Id, createdTask.WhatId);
        System.assertEquals('High', createdTask.Priority);
        System.assert(createdTask.Subject.contains('Technology'));
    }

    @IsTest
    static void rejectsInvalidUrgency() {
        Account accountRecord = new Account(
            Name = 'Bad Urgency Example'
        );
        insert accountRecord;

        CustomerFollowUpAction.Request request = new CustomerFollowUpAction.Request();
        request.accountId = accountRecord.Id;
        request.urgency = 'ASAP';
        request.industryFocus = 'Technology';

        Test.startTest();
        List<CustomerFollowUpAction.Result> results =
            CustomerFollowUpAction.createTasks(
                new List<CustomerFollowUpAction.Request>{ request }
            );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
        System.assert(results[0].message.contains('Urgency must be'));
    }
}