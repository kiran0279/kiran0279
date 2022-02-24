/**
* ───────────────────────────────────────────────────────────────────────────────────────────────────┐
	* @author         Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @modifiedBy     Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @maintainedBy   Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @version        53.0
    * @created        2021-12-02
    * @modified      
    * @systemLayer    Test Class BatchApex
    *  **/
@isTest
public class EmailWithNamesTest {
	 @testSetup
    static void setup() 
    {
        List<Contact> contacts = new List<Contact>();
        //Inserting 10 contacts for the testing
         for (Integer r=0; r<2; r++) {
            contacts.add(new Contact(FirstName='krishna '+r,
                LastName='sai', Email=''));
        }
        for (Integer s=0; s<10; s++) {
            contacts.add(new Contact(FirstName='jaikrishna '+s,
                LastName='Psycho', Email='krishna@jai.com'));
        }
       
        insert contacts;
    }
        @isTest static void test() {
        Test.startTest();
        EmailWithNames ewn = new EmailWithNames();
        Id batchId = Database.executeBatch(ewn);
        Test.stopTest();
        }
}