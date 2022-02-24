/**
* @Class Name: InforCustomerIntegrationHandler
* @Description: Invocable class for PB.
* ================================================================================================================
* Version | Date | Author 
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 11th Feb, 2021 | sujata.chaudhari@weare4c.com 
* =================================================================================================================
*/
public with sharing class InforCustomerIntegrationHandler {
    @InvocableMethod
	public static void inforOnboarding(List<Id> AccountIds) {
        try{
            Id jobID = System.enqueueJob(new InforCalloutHandler(AccountIds));
        }
        catch(Exception e){
            Integration_Log__c errlog = new Integration_Log__c();
            If(!AccountIds.isEmpty() && AccountIds != null ){
                errlog.Account__c = AccountIds[0];
            }
            errlog.Error_Message__c = e.getMessage();
            errlog.Is_Success__c = false; 
            errlog.Is_Integration_Related__c = false;
            errlog.Stacktrace__c = e.getStackTraceString();   
            insert errlog; 
        }
    }
}