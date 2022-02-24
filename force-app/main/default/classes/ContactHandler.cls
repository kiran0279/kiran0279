public  class ContactHandler {
    public static void updateContactOnAccount(List<Contact> listOfContacts){
        Set<Id> accountSet = new Set<Id>();
        List<Account> listOfAccountToBeUpdate = new List<Account>();
        // Add each contact's AccountId in a set
        for(Contact con : listOfContacts) {
            accountSet.add(con.AccountId);
        }      
        List<Account> accountsUpdate = [SELECT Id, Total_Amount__c,
        (SELECT Id, Amount__c FROM Contacts ) 
        FROM Account Where id IN :accountSet]; 
        for (Account acc : accountsUpdate) {
            Decimal total = 0;
            for (Contact con : acc.Contacts) {
                if(con.Amount__c != null) 
                {
                    total += con.Amount__c;
                }
            }
            acc.Total_Amount__c = total; 
        }
        
        update accountsUpdate;
     
    }
    public void preventDuplicate( List<Contact> newContacts)
    {
        //Set to store LastNames
        set <String> lastnameSet = new Set<String>();
        set <String> lastnameSet1 = new Set<String>();
        // Set to store email ids
        Set <String> emailSet = new Set<String>(); 
        Set <String> emailSet1 = new Set<String>(); 
        // Set to store phone numbers
        Set <String> phoneSet = new Set<String>();
        Set <String> phoneSet1 = new Set<String>();

         // Iterate through each Contact and add their LastName, email and phone number to their respective Sets
        for(Contact con : newContacts)
        {
            lastnameSet.add(con.LastName);
            emailSet.add(con.Email);
            phoneSet.add(con.Phone);
        }
         // Populating the list using SOQL
         List<Contact> esistingContacts = [SELECT LastName, Email ,Phone 
                                            FROM Contact 
                                            WHERE (LastName IN:lastnameSet  AND LastName != Null) OR (Email IN :emailSet AND Email!= Null) OR (Phone IN :phoneSet  AND Phone != Null)];
          // Iterating through each Contact record to see if the same email or phone or LastName was found
          System.debug('$$$$ :'+esistingContacts.size());
        for(Contact con : esistingContacts) 
        {
            lastnameSet1.add(con.LastName);
            emailSet1.add(con.Email);
            phoneSet1.add(con.Phone);
            
        }
        for(Contact con : newContacts)
        {
            if(lastnameSet1.contains(con.Email) || emailSet1.contains(con.Email) || phoneSet1.contains(con.Phone))
            {
                con.AddError('Duplicate record is not allowed');
            }
            else
                 {
                lastnameSet1.add(con.LastName);
                emailSet1.add(con.Email);
                phoneSet1.add(con.Phone);
                }
        }
    }
}