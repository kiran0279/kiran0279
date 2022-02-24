/**
* @Class Name: SAPCustomerIntegrationHandler
* @Description: Invocable class for PB.
* ================================================================================================================
* Version | Date | Author 
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 3rd Feb, 2021 | sujata.chaudhari@weare4c.com 
* =================================================================================================================
*/
public with sharing class SAPCustomerIntegrationHandler {

    @InvocableMethod
	public static void sAPOnboarding(List<Id> AccountIds) {
        try{
            Id jobID = System.enqueueJob(new SAPCalloutHandler(AccountIds));
        }
        Catch(Exception e){
            Integration_Log__c errlog = new Integration_Log__c(
                Error_Message__c = e.getMessage(),
                Is_Success__c = false,
                Endpoint__c = SAPCalloutHandler.ACCOUNT_URL,
                Is_Integration_Related__c = false,
                Stacktrace__c = e.getStackTraceString()
            );
            If(!AccountIds.isEmpty() && AccountIds != null ){
                errlog.Account__c = AccountIds[0];
            }
            insert errlog; 
        }
    }
}