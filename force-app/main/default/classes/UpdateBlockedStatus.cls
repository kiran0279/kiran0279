/**
* @Class Name: UpdateBlockedStatus
* @Description: For update Account Blocked Status.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 5th March, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by UpdateBlockedStatusTest.
* =================================================================================================================
*/
global class UpdateBlockedStatus implements Database.Batchable <sObject>, Schedulable {
    global UpdateBlockedStatus(){
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, Account_Block_Status__c, Block_Due_Date__c, Account_Block_Type__c, Name' + 
                       ' FROM Account WHERE Account_Block_Type__c = \'Auto-Block\' AND Block_Due_Date__c <= TODAY' +
                       ' AND parent.Account_Entity__r.Auto_Blocking_Enabled__c = true  AND RecordType.DeveloperName = \'Billing\''; 
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        
        List<Account> acc = new List<Account>();
        for(Account a : scope){
            a.Account_Block_Status__c = 'Blocked';
            acc.add(a);
        }
        
        // process each batch of records
            update acc;
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new UpdateBlockedStatus(),200);
    }
}