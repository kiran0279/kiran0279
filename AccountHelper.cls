public with sharing class AccountHelper { 
    @AuraEnabled(Cacheable = false)
    public static List<Contact> getContacts(Id sourceAccount){
        List<Contact> contactFields= [SELECT Id,Name,Account.Name,LastName,FirstName,Email,Phone,MobilePhone
                FROM Contact where AccountId =: sourceAccount]; 
                return contactFields;       
    }
    @AuraEnabled
        public static void EditedCon(List<Contact> contList){
            List<Contact> contactFields = contList;
            upsert contactFields;
        }
}