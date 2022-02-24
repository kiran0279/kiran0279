/**
* ───────────────────────────────────────────────────────────────────────────────────────────────────┐
	* @author         Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @modifiedBy     Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @maintainedBy   Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @version        53.0
    * @created        2021-12-02
    * @modified      
    * @systemLayer    Batch  Class
	
    * @description Batch class to Send Contact Ids as URL to User Email
    * ───────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    List<Contact> conLst
    * @param    List<Contact> Getting the Contact Ids which contains same word in email 
    * @param    Contact Object
    * ───────────────────────────────────────────────────────────────────────────────────────────────────┘ 
    *  **/
public class EmailName implements Database.Batchable<sObject>
{
    //This is Start Method to retrieve the Contacts from the Ui Page 
   public  Iterable<sObject> start(Database.BatchableContext contactList)
    {
       List<Contact> con=[SELECT firstname,LastName FROM Contact WHERE Email Like '%saibalu%'];
        return con;
    }
     List<Contact> conLst = new List<Contact>();
    // This is the Execute method to iterate the contacts containing saibalu in email address
    public void Execute(Database.BatchableContext contactList, List<Contact> listCon)
    {
      
        system.debug(conLst);
        for(Contact cl : listCon)
        {
           Contact con = new Contact();
           con.Id = cl.Id;
            con.LastName=cl.LastName;
           con.Email = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cl.Id;
           con.FirstName = cl.FirstName;
           conLst.add(con);
        }
        System.debug(conLst);
        }
        // This is the final Method to Send the Contact Names as Hyperlink to UserInfo Mail Address
    public void Finish(Database.BatchableContext contactList)
    {
        
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] loggedUserEmail =new String[] {UserInfo.getUserEmail()};
             mail.setToAddresses(loggedUserEmail);
             String conStr ='Contacts having same Email string : <br/>';
        for(Integer i=0; i<5; i++)
        {
            for(Contact cons:conLst)
            {
           conStr += String.ValueOf(i) + '. ' + cons.FirstName +' : '+ cons.Email + '<br/>';
            }
              System.debug(conStr);
        }
        mail.setHtmlBody(conStr);
      
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}