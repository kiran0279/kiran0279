/**
* ───────────────────────────────────────────────────────────────────────────────────────────────────┐
	* @author         Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @modifiedBy     Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @maintainedBy   Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @version        53.0
    * @created        2021-12-08
    * @modified      
    * @systemLayer    Batch  Class
    *  **/
    public class CallingTheBatchApexInBatchApex implements Database.Batchable<sObject>, Database.Stateful
    {
        public  Map<Id,List<Contact>> mapaccountById = new Map<Id,List<Contact>>();
        public  List<Account> accList = new List<Account>();
        public CallingTheBatchApexInBatchApex(Map<Id,List<Contact>> mapaccountById)
        {
            this.mapaccountById = mapaccountById;
            System.debug('The Constructor is :'+this.mapaccountById);
        }
       public  List<Account> Start(Database.BatchableContext accountList)
        {
          List<Account> accList = [SELECT Id,Number_Of_Contacts__c 
                                    FROM Account 
                                     WHERE Id in:mapaccountById.keyset()];
            return accList;
        }
       public void Execute(Database.BatchableContext accountList, List<Account> listacc)
        {
             for(Account acc : listacc )
             {
                acc.Number_Of_Contacts__c = mapaccountById.get(acc.Id).size();
                accList.add(acc);
            }
            update accList;  
        }
        public void Finish(Database.BatchableContext accountList)
        {
           
        }
}