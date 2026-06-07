public with sharing class CustomerFollowUpAction {
    public class Request {
        @InvocableVariable(
            label='Account Id'
            description='The Account that needs a follow-up task.'
            required=true
        )
        public Id accountId;

        @InvocableVariable(
            label='Urgency'
            description='Static picklist example. Values are defined in the InvocableActionExtension XML file.'
            required=true
        )
        public String urgency;

        @InvocableVariable(
            label='Industry Focus'
            description='Dynamic picklist example. Values come from AccountIndustryPicklist.'
            required=true
        )
        public String industryFocus;
    }

    public class Result {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Task Id')
        public Id taskId;
    }

    @InvocableMethod(
        label='Create Customer Follow-Up Task'
        description='Creates a follow-up Task for an Account.'
        category='Sales'
    )
    public static List<Result> createTasks(List<Request> requests) {
        List<Result> results = new List<Result>();

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        Set<Id> accountIds = new Set<Id>();

        for (Request request : requests) {
            Result result = new Result();
            result.success = false;
            results.add(result);

            if (request == null || request.accountId == null) {
                result.message = 'Account Id is required.';
                continue;
            }

            accountIds.add(request.accountId);
        }

        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Id, Name
            FROM Account
            WHERE Id IN :accountIds
        ]);

        List<Task> tasksToInsert = new List<Task>();
        List<Integer> resultIndexes = new List<Integer>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request request = requests[i];

            if (request == null || request.accountId == null) {
                continue;
            }

            Account accountRecord = accountsById.get(request.accountId);

            if (accountRecord == null) {
                results[i].message = 'The Account was not found or is not visible to the running user.';
                continue;
            }

            String urgency = normalizeUrgency(request.urgency);

            if (urgency == null) {
                results[i].message = 'Urgency must be LOW, NORMAL, or HIGH.';
                continue;
            }

            if (String.isBlank(request.industryFocus)) {
                results[i].message = 'Industry Focus is required.';
                continue;
            }

            Task followUpTask = new Task();
            followUpTask.WhatId = accountRecord.Id;
            followUpTask.Subject = 'Follow up with ' + accountRecord.Name + ' - ' + request.industryFocus;
            followUpTask.Status = 'Not Started';
            followUpTask.Priority = toTaskPriority(urgency);
            followUpTask.ActivityDate = Date.today().addDays(daysUntilDue(urgency));
            followUpTask.Description =
                'Created by Flow using an Apex action with picklist-enabled inputs.\n' +
                'Urgency: ' + urgency + '\n' +
                'Industry Focus: ' + request.industryFocus;

            tasksToInsert.add(followUpTask);
            resultIndexes.add(i);
        }

        if (tasksToInsert.isEmpty()) {
            return results;
        }

        List<Database.SaveResult> saveResults = Database.insert(tasksToInsert, false, AccessLevel.USER_MODE);

        for (Integer i = 0; i < saveResults.size(); i++) {
            Integer resultIndex = resultIndexes[i];

            if (saveResults[i].isSuccess()) {
                results[resultIndex].success = true;
                results[resultIndex].taskId = saveResults[i].getId();
                results[resultIndex].message = 'Follow-up task created.';
            } else {
                results[resultIndex].success = false;
                results[resultIndex].message = saveResults[i].getErrors()[0].getMessage();
            }
        }

        return results;
    }

    private static String normalizeUrgency(String urgency) {
        if (String.isBlank(urgency)) {
            return null;
        }

        String normalized = urgency.trim().toUpperCase();

        Set<String> allowedValues = new Set<String>{
            'LOW',
            'NORMAL',
            'HIGH'
        };

        return allowedValues.contains(normalized) ? normalized : null;
    }

    private static String toTaskPriority(String urgency) {
        if (urgency == 'HIGH') {
            return 'High';
        }

        if (urgency == 'LOW') {
            return 'Low';
        }

        return 'Normal';
    }

    private static Integer daysUntilDue(String urgency) {
        if (urgency == 'HIGH') {
            return 1;
        }

        if (urgency == 'LOW') {
            return 7;
        }

        return 3;
    }
}