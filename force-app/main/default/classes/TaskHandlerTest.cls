/**
* Trigger to handle operations on Task object
*  ===============================================================
* Version | Date | Author 
* -------------------------------------------------------------------
* 1.0 | 29/12/2020 | sujata.chaudhari@weare4c.com
*/
@isTest
public class TaskHandlerTest {
    @testSetup static void testSetup(){
        
       Account testAccount = TestDataUtility.createAccount('Test');
       insert testAccount;
       Contact testContact = TestDataUtility.createContact('First Name', testAccount.Id); 
       insert testContact;
       
       Lead testLead = TestDataUtility.createLead('etst@hmail.com', 'testf', 'testl', 'Tesla', '057483746574', null, '057483746574');
       testLead.Number_of_Call_Attempts_Made__c = 2;
       insert testLead;
       
       Task testTask = TestDataUtility.createTask(testContact.Id);
       testTask.Call_Response__c = 'Un Answered';
       testTask.WhoId = testLead.Id; 
       insert testTask;
        
    }
    @isTest
    public static void testTaskUpdateLead(){
        List<Task> getTaskList = [SELECT Id, WhoId FROM Task LIMIT 2];
        Test.startTest();
        TaskHandler.TaskUpdateLead(getTaskList);
       
        Lead testLead = [SELECT Id, Name, Number_of_Call_Attempts_Made__c FROM Lead LIMIT 1];
        testLead.Number_of_Call_Attempts_Made__c = 6;
        update testLead;
  		delete getTaskList;
        undelete getTaskList;
        Test.stopTest();
    }
}