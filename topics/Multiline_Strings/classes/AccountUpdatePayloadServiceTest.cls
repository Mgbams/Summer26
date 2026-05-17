@IsTest
private class AccountUpdatePayloadServiceTest {

    @IsTest
    static void buildPayload_returnsFormattedJsonPayload() {
        Account accountRecord = new Account(
            Name = 'Acme Corp',
            Industry = 'Technology',
            AnnualRevenue = 1500000
        );
        insert accountRecord;

        AccountUpdatePayloadService.PayloadRequest request =
            new AccountUpdatePayloadService.PayloadRequest(
                accountRecord.Id,
                'Customer Intelligence Platform',
                'Integration User'
            );

        AccountUpdatePayloadService.PayloadResponse response =
            AccountUpdatePayloadService.buildPayload(request);

        String expectedPayload = '''
            {
            "account": {
                "id": "${accountId}",
                "name": "Acme Corp",
                "industry": "Technology",
                "annualRevenue": 1500000
            },
            "summary": "Account Acme Corp is categorized under Technology and has an annual revenue of 1500000.",
            "audit": {
                "sourceSystem": "Customer Intelligence Platform",
                "requestedBy": "Integration User"
            }
            }
            '''.template(new Map<String, Object>{
                        'accountId' => accountRecord.Id
                    });

        System.assertEquals(true, response.success, 'The payload should be generated successfully.');
        System.assertEquals(null, response.errorMessage, 'No error should be returned.');
        System.assertEquals(expectedPayload, response.payload, 'The generated payload should match the expected JSON.');
    }

    @IsTest
    static void buildPayload_escapesJsonValues() {
        Account accountRecord = new Account(
            Name = 'Acme "Enterprise"',
            Industry = 'Technology',
            AnnualRevenue = 2500000
        );
        insert accountRecord;

        AccountUpdatePayloadService.PayloadRequest request =
            new AccountUpdatePayloadService.PayloadRequest(
                accountRecord.Id,
                'External "Analytics" Platform',
                'Ops User'
            );

        AccountUpdatePayloadService.PayloadResponse response =
            AccountUpdatePayloadService.buildPayload(request);

        System.assertEquals(true, response.success, 'The payload should be generated successfully.');
        System.assert(response.payload.contains('Acme \\"Enterprise\\"'), 'Double quotes in Account Name should be escaped.');
        System.assert(response.payload.contains('External \\"Analytics\\" Platform'), 'Double quotes in source system should be escaped.');
    }

    @IsTest
    static void buildPayload_returnsErrorWhenRequestIsMissing() {
        AccountUpdatePayloadService.PayloadResponse response =
            AccountUpdatePayloadService.buildPayload(null);

        System.assertEquals(false, response.success, 'The response should fail for a missing request.');
        System.assertEquals(null, response.payload, 'No payload should be returned.');
        System.assertEquals('Payload request is required.', response.errorMessage);
    }

    @IsTest
    static void buildPayload_returnsErrorWhenAccountIdIsMissing() {
        AccountUpdatePayloadService.PayloadRequest request =
            new AccountUpdatePayloadService.PayloadRequest(
                null,
                'Customer Intelligence Platform',
                'Integration User'
            );

        AccountUpdatePayloadService.PayloadResponse response =
            AccountUpdatePayloadService.buildPayload(request);

        System.assertEquals(false, response.success, 'The response should fail for a missing Account Id.');
        System.assertEquals('Account Id is required.', response.errorMessage);
    }

    @IsTest
    static void buildPayload_usesFallbackValuesForOptionalFields() {
        Account accountRecord = new Account(
            Name = 'No Industry Account'
        );
        insert accountRecord;

        AccountUpdatePayloadService.PayloadRequest request =
            new AccountUpdatePayloadService.PayloadRequest(
                accountRecord.Id,
                'Customer Intelligence Platform',
                'Integration User'
            );

        AccountUpdatePayloadService.PayloadResponse response =
            AccountUpdatePayloadService.buildPayload(request);

        System.assertEquals(true, response.success, 'The payload should be generated successfully.');
        System.assert(response.payload.contains('"industry": ""'), 'Blank Industry should be represented as an empty string in the payload.');
        System.assert(response.payload.contains('"annualRevenue": 0'), 'Missing AnnualRevenue should default to zero.');
        System.assert(
            response.payload.contains('Unspecified Industry'),
            'The generated summary should use a readable fallback for missing Industry.'
        );
    }
}