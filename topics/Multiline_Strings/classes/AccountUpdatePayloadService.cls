public with sharing class AccountUpdatePayloadService {

    public class PayloadRequest {
        @AuraEnabled public Id accountId;
        @AuraEnabled public String sourceSystem;
        @AuraEnabled public String requestedBy;

        public PayloadRequest(Id accountId, String sourceSystem, String requestedBy) {
            this.accountId = accountId;
            this.sourceSystem = sourceSystem;
            this.requestedBy = requestedBy;
        }
    }

    public class PayloadResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String payload;
        @AuraEnabled public String errorMessage;

        public PayloadResponse(Boolean success, String payload, String errorMessage) {
            this.success = success;
            this.payload = payload;
            this.errorMessage = errorMessage;
        }
}

    public static PayloadResponse buildPayload(PayloadRequest request) {
        try {
            validateRequest(request);

            Account accountRecord = getAccount(request.accountId);

            String payload = '''
                {
                "account": {
                    "id": "${accountId}",
                    "name": "${accountName}",
                    "industry": "${industry}",
                    "annualRevenue": ${annualRevenue}
                },
                "summary": "${summary}",
                "audit": {
                    "sourceSystem": "${sourceSystem}",
                    "requestedBy": "${requestedBy}"
                }
                }
                '''.template(new Map<String, Object>{
                                'accountId'     => accountRecord.Id,
                                'accountName'   => escapeJson(accountRecord.Name),
                                'industry'      => escapeJson(accountRecord.Industry),
                                'annualRevenue' => accountRecord.AnnualRevenue == null ? 0 : accountRecord.AnnualRevenue,
                                'summary'       => escapeJson(buildSummary(accountRecord)),
                                'sourceSystem'  => escapeJson(request.sourceSystem),
                                'requestedBy'   => escapeJson(request.requestedBy)
                            });

            return new PayloadResponse(true, payload, null);

        } catch (Exception ex) {
            return new PayloadResponse(false, null, ex.getMessage());
        }
    }

    private static void validateRequest(PayloadRequest request) {
        if (request == null) {
            throw new AccountUpdatePayloadException('Payload request is required.');
        }

        if (request.accountId == null) {
            throw new AccountUpdatePayloadException('Account Id is required.');
        }

        if (String.isBlank(request.sourceSystem)) {
            throw new AccountUpdatePayloadException('Source system is required.');
        }

        if (String.isBlank(request.requestedBy)) {
            throw new AccountUpdatePayloadException('Requested by value is required.');
        }
    }

    private static Account getAccount(Id accountId) {
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new AccountUpdatePayloadException('You do not have access to Account records.');
        }

        Map<String, Schema.SObjectField> accountFields = Schema.sObjectType.Account.fields.getMap();

        if (
            !accountFields.get('Name').getDescribe().isAccessible() ||
            !accountFields.get('Industry').getDescribe().isAccessible() ||
            !accountFields.get('AnnualRevenue').getDescribe().isAccessible()
        ) {
            throw new AccountUpdatePayloadException('You do not have access to one or more required Account fields.');
        }

        List<Account> accounts = [
            SELECT Id, Name, Industry, AnnualRevenue
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        if (accounts.isEmpty()) {
            throw new AccountUpdatePayloadException('No Account found for the provided Id.');
        }

        return accounts[0];
    }

    private static String buildSummary(Account accountRecord) {
        String template = '''
Account ${accountName} is categorized under ${industry} and has an annual revenue of ${annualRevenue}.
''';

        return template.template(new Map<String, Object>{
            'accountName'   => accountRecord.Name,
            'industry'      => String.isBlank(accountRecord.Industry) ? 'Unspecified Industry' : accountRecord.Industry,
            'annualRevenue' => accountRecord.AnnualRevenue == null ? 0 : accountRecord.AnnualRevenue
        }).trim();
    }

    private static String escapeJson(Object value) {
        if (value == null) {
            return '';
        }

        return String.valueOf(value)
            .replace('\\', '\\\\')
            .replace('"', '\\"')
            .replace('\n', '\\n')
            .replace('\r', '\\r')
            .replace('\t', '\\t');
    }

    public class AccountUpdatePayloadException extends Exception {}
}