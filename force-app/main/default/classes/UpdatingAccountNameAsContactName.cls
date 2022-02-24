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
    public class UpdatingAccountNameAsContactName implements Database.Batchable<sObject>, Database.Stateful
    {
        /**
        * @description Start Method to get the all contacts
        * ───────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    Database.QueryLocator
        * @param    returns the list of contacts present in Contact Object which contains Account Id
        * @param    Contact Object
        * ───────────────────────────────────────────────────────────────────────────────────────────────────┘ 
        *  **/
        //This is Start Method to retrieve the Records from the Contact which contains accountid 
       public  Database.QueryLocator start(Database.BatchableContext contactList)
        {
           String con='SELECT Id,Email,LastName,AccountId FROM Contact WHERE Account.Name != null';
           return Database.getQueryLocator(con);
        }
        /**
        *
        * @description Execute  Method to Map the AccountId and List of contacts related to it
        * ───────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    Map<Id,List<Contact>> mapaccountById
        * @param    returns the AccountId, list of contacts regarding to that account
        * @param    Contact Object 
        * ───────────────────────────────────────────────────────────────────────────────────────────────────┘ 
        *  **/
        public  Map<Id,List<Contact>> mapaccountById = new Map<Id,List<Contact>>();
        public  List<Account> accList = new List<Account>();
        public void Execute(Database.BatchableContext contactList, List<Contact> listCon)
        {
            System.debug('$$$$$$'+listCon);
           
            for(Contact con : listCon)
            {
                if(!mapaccountById.containsKey(con.AccountId)){
                    mapaccountById.put(con.AccountId, new List<Contact>());
                }
                mapaccountById.get(con.AccountId).add(con);
            }
            System.debug('Map of Contacts'+mapaccountById);
            System.debug('%%%%%%%%%%%'+mapaccountById.values().size());
          
        }
        public void Finish(Database.BatchableContext contactList)
        {
            Database.executeBatch(new CallingTheBatchApexInBatchApex(mapaccountById));
           
        }
}