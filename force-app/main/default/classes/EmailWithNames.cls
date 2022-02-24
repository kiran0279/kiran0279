/**
* ───────────────────────────────────────────────────────────────────────────────────────────────────┐
	* @author         Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @modifiedBy     Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @maintainedBy   Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
    * @version        53.0
    * @created        2021-12-02
    * @modified      
    * @systemLayer    Batch  Class
    *  **/
public class EmailWithNames implements Database.Batchable<sObject>, Database.Stateful
{
    /**
    * @description Start Method to get the all contacts
    * ───────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Database.QueryLocator
    * @param    returns the list of contacts present in Contact Object
    * @param    Contact Object
    * ───────────────────────────────────────────────────────────────────────────────────────────────────┘ 
    *  **/
    //This is Start Method to retrieve the Contacts from the Ui Page 
   public  Database.QueryLocator start(Database.BatchableContext contactList)
    {
       String con='SELECT Id,Email,firstname FROM Contact';
       return Database.getQueryLocator(con);
    }
    public List<Contact> conLst = new List<Contact>();
    /**
    *
    * @description Execute  Method to filter the contacts contaning (saibalu) word in email 
    * ───────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    List<Contact> listCon
    * @param    returns the list of contacts conataining same word in Email in Contact Object
    * @param    Contact Object
    * ───────────────────────────────────────────────────────────────────────────────────────────────────┘ 
    *  **/
    // This is the Execute method to iterate the contacts containing saibalu in email address
    public void Execute(Database.BatchableContext contactList, List<Contact> listCon)
    {
         
        for(Contact cl : listCon)
        {
            if(cl.Email != null 
               && cl.Email.contains('raagvitech'))
            {
               conLst.add(cl); 
            }
        }
       }
     /**
    *
    * @description Final Method to send the contact Ids contaning (saibalu) word in email as URL link to UserInfo Mail
    * ───────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    UserInfo.getUserEmail
    * @param    returns the user logged in mail
    * @param    URL.getSalesforceBaseUrl().toExternalForm()
    * @param    returns the cotact ids as url 
    * ───────────────────────────────────────────────────────────────────────────────────────────────────┘ 
    *  **/
        // This is the final Method to Send the Contact Names as Hyperlink to UserInfo Mail Address
    public void Finish(Database.BatchableContext contactList)
    {
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] loggedUserEmail =new String[] {UserInfo.getUserEmail()};
             mail.setToAddresses(loggedUserEmail);
        String conStr=''; 
         for(Contact con :conLst)
        {
             //conStr += con.FirstName +' : ' +URL.getSalesforceBaseUrl().toExternalForm()+' / '+ con.id +> '<br/>';
            conStr +=' : <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+con.id+'">'+con.firstName+'</a>' + '<br/>'+'<br/>';
                 mail.setHtmlBody(conStr);
           }
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}