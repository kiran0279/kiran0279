public with sharing class LeadHandler {
    Public void LeadConverter (List<Lead> leadlist)
    {
        // Populating the list using SOQL
        leadlist = [SELECT Id, Street From Lead Where Street != Null];
         // Iterating through each Lead record to see if the lead is Converted or No
        for(Lead lead : leadlist)
        {
         if(lead.isConverted)
         {
             // Populating the convertedcontact Id and mailing street to update the mailing street
             Contact con = [SELECT Id,MailingStreet FROM Contact WHERE Contact.Id = :lead.ConvertedContactId];
             con.MailingStreet = lead.Street;
             update con;
         }
        }
    } 
}
