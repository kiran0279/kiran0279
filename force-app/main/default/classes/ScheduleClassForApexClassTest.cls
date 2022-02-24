/**
* ───────────────────────────────────────────────────────────────────────────────────────────────────┐
	* @author         Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @modifiedBy     Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @maintainedBy   Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @version        53.0
    * @created        2021-12-09
    * @modified      
    * @systemLayer    Test Class For ScheduleClassForApexClass Schedule Class
    *  **/
@isTest
public with sharing class ScheduleClassForApexClassTest {
    @isTest static void testschedule() {
		Test.StartTest();
		ScheduleClassForApexClass testsche = new ScheduleClassForApexClass();
		String sch = '0 0 23 * * ?';

		Id jobId= system.schedule('Test status Check', sch, testsche );
		
		Test.stopTest();
		CronTrigger ct = [Select id , CronExpression from CronTrigger where Id = :jobId];
		System.assertEquals(sch,ct.CronExpression); 
	}
}