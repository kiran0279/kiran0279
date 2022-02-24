/**
* ───────────────────────────────────────────────────────────────────────────────────────────────────┐
	* @author         Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @modifiedBy     Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @maintainedBy   Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @version        53.0
    * @created        2021-12-09
    * @modified      
    * @systemLayer    Test  Class For UpdatingAccountNameAsContactName
    *  **/
@isTest
public class UpdatingAccountNameAsContactNameTest {
    @isTest static void runTest(){
        Account acc = new Account();
        acc.Name = 'Akhanda';
        acc.AccountNumber = '5474';
        insert acc;
        Id sd = acc.Id;
        Contact con = new Contact();
        con.LastName = 'Balayya';
         con.Email = 'balayya@akhanda.com';
         con.AccountId = sd;
        insert con;

        Test.startTest();
        UpdatingAccountNameAsContactName ewn = new UpdatingAccountNameAsContactName();
        Id batchId = Database.executeBatch(ewn);
        Test.stopTest();
        Contact conObj = [Select Id, AccountId From Contact Where LastName = 'Balayya'];
        System.assertEquals(conObj.AccountId, sd );
    }
}