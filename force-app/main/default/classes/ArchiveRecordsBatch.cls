/**
* @Class Name: ArchiveRecordsBatch
* @Description: For archiving Integration logs.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 1st Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by ArchiveRecordsBatchTest.
* =================================================================================================================
*/
global class ArchiveRecordsBatch implements Database.Batchable<sObject>, Schedulable{
    String objectName;
    String fieldName;
    public ArchiveRecordsBatch(String objectName, String fieldName){
        this.objectName = objectName;
        this.fieldName = fieldName;
    }

    public ArchiveRecordsBatch() {

    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id FROM '+objectName+' WHERE '+fieldName+' = true'; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        // process each batch of records
        delete scope;
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }

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