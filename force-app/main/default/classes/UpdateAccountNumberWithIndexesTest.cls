/**
* ───────────────────────────────────────────────────────────────────────────────────────────────────┐
* @author         Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
* @modifiedBy     Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
* @maintainedBy   Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
* @version        53.0
* @created        2021-12-07
* @modified      
* @systemLayer    Test Apex  Class
*  **/
/**
* @description Test Class to Test the UpdateAccountNumberWithIndexes Apex Class
* ───────────────────────────────────────────────────────────────────────────────────────────────────
* @param    List<List<Account>> accounts
* @param    To store the list of accounts inserted
* @param    Account Object
* ───────────────────────────────────────────────────────────────────────────────────────────────────┘ 
*  **/
@isTest
public class UpdateAccountNumberWithIndexesTest {
    @isTest static void test() {
        List<List<Account>> accounts = new List<List<Account>>();
        List<Account> accs = new List<Account>();
        
        Account acc = new Account();
        acc.Name='sai';
        acc.AccountNumber = '5474';
        accs.add(acc);
        insert accs;
        accounts.add(accs);
        
        Test.startTest();
        UpdateAccountNumberWithIndexes.getAccountIds(accounts);
        Test.stopTest();
        
        Account accObj = [Select Id, AccountNumber From Account Where name = 'sai'];
        System.assertEquals(acc.AccountNumber, '1');
    }
}