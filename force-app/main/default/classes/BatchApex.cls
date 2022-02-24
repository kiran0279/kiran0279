global class BatchApex implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT LastName, Amount__c
                                         FROM Contact
                                        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> conList)
    {
        List<Contact> conl = new List<Contact>();
        for(Contact con : conList)
        {
            con.Amount__c=2000;
            conl.add(con);
        }
        update conl;
    }
    public void finish(Database.BatchableContext bc)
    {
        
    }

}