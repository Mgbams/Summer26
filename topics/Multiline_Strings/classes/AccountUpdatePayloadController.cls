public with sharing class AccountUpdatePayloadController {

    @AuraEnabled
    public static AccountUpdatePayloadService.PayloadResponse generatePayload(Id accountId) {
        return AccountUpdatePayloadService.buildPayload(
            new AccountUpdatePayloadService.PayloadRequest(
                accountId,
                'LWC Payload Previewer',
                UserInfo.getName()
            )
        );
    }
}