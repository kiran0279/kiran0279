/**
* @Class Name: AutoCreateRandomNumberHandler
* @Description: Used for AccountTrigger as handler Class.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 28th July, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used as handler for AccountTrigger.
* =================================================================================================================
*/
public without sharing class AutoCreateRandomNumberHandler{
    public static void setPinNumberOnAccount(List<Account> billingAccountList){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        for(Account acc: billingAccountList){
            if(acc.RecordTypeId == recordTypeId){
                String str = string.valueof(Math.abs(Crypto.getRandomLong()));
                String randomNumber = str.substring(0, 6);
                acc.Pin_Number__c= randomNumber;
            }
        }
    }
}