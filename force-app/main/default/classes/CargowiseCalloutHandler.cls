/**
* @Class Name: CargowiseCalloutHandler
* @Description: Queueable class for callouts.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 4th Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by OperationalCustomerIntegrationHandler.
* =================================================================================================================
*/
public with sharing class CargowiseCalloutHandler implements Queueable, Database.AllowsCallouts {
    List<Account> accountRecords;

    public class CargowiseIntegrationException extends Exception {}

    public CargoWiseCalloutHandler(List<String> accId) {
        accountRecords = [Select
                            Id, Legal_City__c, Parent.Country_Code__c, 
                            Tax_Rate__c, Parent.Registration_Number__c, CurrencyIsoCode, Credit_Terms__c, Credit_Limit__c,
                            parentId, AccountNumber, parent.Business_Type__c, Business_Type__c, parent.Name, parent.Phone, parent.Fax,
                            parent.Segment__c, VATNo__c, parent.CustomerID__c,  COD__c, parent.Account_Entity__r.Legal_Entity__c,
                            parent.Entity__c, parent.Legal_Name__c, parent.Legal_City__c,
                            parent.Legal_Post_Code__c, parent.Legal_Building_Number__c, parent.Legal_PO_Box__c, parent.Legal_Localized_Account_Name__c,
                            parent.Legal_Phone__c,
                            parent.Legal_Name_Language__c,
                            Owner.EmployeeNumber, Owner.Division, Account_Set__c, Parent.Account_Set__c,
                            cust_subSegment__c, cust_Segment__c, Legal_Building_Number__c, Legal_Post_Code__c, Legal_PO_Box__c, Legal_Street__c,
                            (Select Id, AccountId, UserId, User.EmployeeNumber From AccountTeamMembers Where TeamMemberRole = 'Credit Manager'), 
                            (Select Id, Contact.Id, Contact.Name, AccountId, Contact.AccountId, Contact.Phone, Contact.Fax, Contact.Email 
                            From AccountContactRelations Where Primary__c = True) From Account WHERE Id IN :accId];
                                        
        if(this.accountRecords.isEmpty()) {
            throw new CargowiseIntegrationException('Unable to find account record');
        } else if(this.accountRecords[0].AccountTeamMembers.isEmpty()) {
            throw new CargowiseIntegrationException('Unable to find a credit manager for the account record');
        } else if(this.accountRecords[0].AccountContactRelations.isEmpty()) {
            throw new CargowiseIntegrationException('Unable to find a primary contact for the account record');
        } 
    }
    
    public static String ACCOUNT_URL = 'callout:Cargowise_Credentials/amx/sf/post.aspx';
    public void execute(QueueableContext context){
        Integration_Settings__c ins = Integration_Settings__c.getOrgDefaults();
        Boolean enableDebugLog = ins.Enable_Debug_Logging__c;
        Integration_Log__c errorLog;
        String responseBody;
        Integer responseCode;
        String xmlOut;
        try{
            Payload payload = new Payload(this.accountRecords[0]);
            XMLSerializer xmlSerialize = new XMLSerializer();
            xmlOut  = xmlSerialize.serialize(payload).replace('Currency1','Currency');
            
            errorLog = ErrorLogHandler.createLog(this.accountRecords[0].Id, ACCOUNT_URL, '', true, false, '', '', 0, '', 'POST');
    
            List<Map<String, String>> headers = new List<Map<String, String>>();
        
            HttpResponse response = new RestCalloutHandler().restCallout(RestCalloutHandler.POST, ACCOUNT_URL, headers, xmlOut, errorLog, enableDebugLog);

            if(response.getStatusCode() == 200 && enableDebugLog == true ){
                upsert ErrorLogHandler.updateLog(errorLog, '', ACCOUNT_URL, true, false, xmlOut, headers,
                                            response.getBody(), response.getStatusCode(), RestCalloutHandler.POST); 
            }
            else if(response.getStatusCode() != 200){
                upsert ErrorLogHandler.updateLog(errorLog, Label.RestCalloutErrorMessage, ACCOUNT_URL, false, true, xmlOut, headers, 
                                            response.getBody(), response.getStatusCode(), RestCalloutHandler.POST);
            }
        }
        Catch(Exception ex){
            /*
             * Log out an error to the integration log
            */
            insert ErrorLogHandler.updateLog(new Integration_Log__c(Account__c = accountRecords[0].Id, Stacktrace__c = ex.getStackTraceString()), ex.getMessage(), ACCOUNT_URL, false, false, xmlOut, null, 
            responseBody, responseCode, RestCalloutHandler.POST);           
        }
    }

    class Customer{
        public String AccountNo{get; set;}
        public String LegalEntity{get; set;}
        public String BusinessType{get; set;}
        public String Name1{get; set;}
        public String Street1{get; set;}
        public String City{get; set;}
        public String Country{get; set;}
        public String POBoxCity{get; set;}
        public String Telephone1{get; set;}
        public String Email1{get; set;}
        public String OldAccountNo{get; set;}
        public String Segment{get; set;}
        public String SubSegment{get; set;}
        public String TaxRate{get; set;}
        public String RegistrationNo{get; set;}
        public String CustomerID{get; set;}
        public String CustName{get; set;}
        public String LegalStatus{get; set;}
        public ContactPerson ContactPerson{get; set;}
        public String EntityCode{get; set;}
        public String TeamID{get; set;}
        public String Currency1{get; set;}
        public String CreditTerms{get; set;}
        public String CreditLimit{get; set;}
        public String CreditController{get; set;}
        public String SalesEmployee{get; set;}
        public String RecAccount{get; set;}
        public String CashMgntGroup{get; set;}
        public LegalDetails LegalDetails{get; set;}
    }
    class ContactPerson {
        public String ContactId{get; set;}
        public String Name1{get; set;}
        public String Street1{get; set;}
        public String City{get; set;}
        public String Country{get; set;}
        public String POBoxCity{get; set;}
        public String Telephone1{get; set;}
        public String Email1{get; set;}
    }
    class LegalDetails {
        public String LegalName{get; set;}
    }
    
    public class Payload {
        public Payload(Account billingAccount) {   

            Customer customer = new Customer();
            customer.AccountNo = billingAccount.AccountNumber; // In file
            customer.LegalEntity = billingAccount.parent.Account_Entity__r.Legal_Entity__c; // In file
            customer.BusinessType = billingAccount.Business_Type__c; // In file
            customer.Name1 = billingAccount.parent.Name; // In file
            customer.Street1 = billingAccount.Legal_City__c; // In file
            customer.City = billingAccount.Legal_City__c; // In file
            customer.Country = billingAccount.Parent.Country_Code__c; // In file
            customer.Telephone1 = billingAccount.parent.Legal_Phone__c; // In file
            customer.Segment = billingAccount.cust_Segment__c;
            customer.SubSegment = billingAccount.cust_subSegment__c;
            customer.TaxRate = billingAccount.Tax_Rate__c; // In file
            customer.RegistrationNo = billingAccount.Parent.Registration_Number__c; // In File
            customer.CustomerID = billingAccount.parent.CustomerID__c; // In File
            customer.CustName = billingAccount.parent.Name; // In File
            customer.LegalStatus = '1Normal';
            customer.EntityCode = billingAccount.parent.Entity__c; // In file
            customer.Currency1 = billingAccount.CurrencyIsoCode; // In File
            customer.CreditTerms = billingAccount.Credit_Terms__c; // In file
            customer.CreditLimit = String.valueOf(billingAccount.Credit_Limit__c); // Un fule
            customer.CreditController = billingAccount.AccountTeamMembers[0].User.EmployeeNumber;
            customer.SalesEmployee = billingAccount.Owner.EmployeeNumber;
            customer.TeamID = billingAccount.Owner.Division;
            customer.RecAccount = billingAccount.Parent.Account_Set__c; // In File
            customer.CashMgntGroup = billingAccount.Parent.Account_Set__c; // In File
            // Contact Person
            
            // AccountTeamMembers
            // AccountContactRelations
            if(billingAccount.AccountContactRelations != null && billingAccount.AccountContactRelations.size() != 0 && billingAccount.AccountContactRelations[0].Id != null){
                ContactPerson contactPerson = new ContactPerson();
                customer.ContactPerson = contactPerson; 
                customer.contactPerson.ContactId = billingAccount.AccountContactRelations[0].Id;
                customer.contactPerson.Name1 = billingAccount.AccountContactRelations[0].Contact.Name;
                customer.contactPerson.Telephone1 = billingAccount.AccountContactRelations[0].Contact.Phone;
                customer.contactPerson.Email1 = billingAccount.AccountContactRelations[0].Contact.Email;
                

                customer.Email1 = billingAccount.AccountContactRelations[0].Contact.Email;
            }
            // Legal Details

            legalDetails legal = new LegalDetails();
            legal.LegalName = billingAccount.parent.Legal_Name__c;
            customer.legalDetails = legal;
            this.Customer = customer;
            
            String serializedJSON = JSON.serialize(customer);
            system.debug(serializedJSON);
        }
        public Customer Customer {get; set;}
    }
}