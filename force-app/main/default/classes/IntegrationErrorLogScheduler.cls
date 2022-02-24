/**
* @Class Name: IntegrationErrorLogScheduler
* @Description: Scheduled logs.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 1st Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used to schedule ArchiveRecordsBatch.
* =================================================================================================================
*/
global class IntegrationErrorLogScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        List<Job_Archive_Setting__c> settingList = [SELECT Field__c, sObjectType__c FROM Job_Archive_Setting__c WHERE IsActive__c = true];
        for (Job_Archive_Setting__c recordObj : settingList) {
            Database.executeBatch(new ArchiveRecordsBatch(
                recordObj.sObjectType__c,
                recordObj.Field__c
            ),200);
        }
    }
}