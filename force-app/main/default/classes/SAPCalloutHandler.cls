/**
* @Class Name: SAPCalloutHandler
* @Description: Queueable class for callouts.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 2st Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by SAPCustomerIntegrationHandler.
* =================================================================================================================
*/
public with sharing class SAPCalloutHandler implements Queueable, Database.AllowsCallouts {
    
    List<Account> accountRecords;

    public class SAPIntegrationException extends Exception {}

    public SAPCalloutHandler(List<String> accId) {
        accountRecords = [Select
                            Id, Legal_City__c, Parent.Country_Code__c, Tax_Rate__c, Parent.Registration_Number__c, CurrencyIsoCode, Credit_Terms__c, Credit_Limit__c,
                            Legal_Street__c, parentId, AccountNumber, parent.Business_Type__c, Business_Type__c, parent.Name, parent.Phone, parent.Fax,
                            parent.Segment__c, VATNo__c, parent.CustomerID__c,  COD__c, parent.Account_Entity__r.Legal_Entity__c, parent.Legal_Street__c,
                            parent.Entity__c, parent.Legal_Name__c, parent.Legal_City__c, parent.Legal_Apartment_Number__c, parent.Legal_Floor_Number__c,
                            parent.Legal_Building_Name__c, parent.Legal_Neighbourhood__c, parent.Legal_Area__c, parent.Legal_State__c,
                            parent.Legal_Post_Code__c, parent.Legal_Building_Number__c, parent.Legal_PO_Box__c, parent.Legal_Localized_Account_Name__c,
                            parent.Legal_Phone__c,
                            parent.Legal_Name_Language__c, 
                            Owner.EmployeeNumber, Owner.Division, Account_Set__c, Parent.Account_Set__c,
                            cust_subSegment__c, cust_Segment__c, Legal_Apartment_Number__c, Legal_Floor_Number__c, Legal_Building_Name__c, Legal_Neighbourhood__c,
                            Legal_Area__c, Legal_State__c, Legal_Building_Number__c, Legal_Post_Code__c, Legal_PO_Box__c,
                            (Select Id, AccountId, UserId, User.EmployeeNumber From AccountTeamMembers Where TeamMemberRole = 'Credit Manager'), 
                            (Select Id, Contact.Id, Contact.Name, AccountId, Contact.AccountId, Contact.Phone, Contact.Fax, Contact.Email 
                            From AccountContactRelations Where Primary__c = True) From Account WHERE Id IN :accId];
                                        
        if(accountRecords.isEmpty()) {
            throw new SAPIntegrationException('Unable to find account record');
        } else if(accountRecords[0].AccountTeamMembers.isEmpty()) {
            throw new SAPIntegrationException('Unable to find a credit manager for the account record');
        } else if(accountRecords[0].AccountContactRelations.isEmpty()) {
            throw new SAPIntegrationException('Unable to find a primary contact for the account record');
        }
    }   

    public static String ACCOUNT_URL = 'callout:SAP_Credentials/RESTAdapter/SI_SF_CustMaster_Out';

    public void execute(QueueableContext context){
        Integration_Settings__c ins = Integration_Settings__c.getOrgDefaults();
        Boolean enableDebugLog = ins.Enable_Debug_Logging__c;
        Integration_Log__c errorLog;
        String responseBody;
        Integer responseCode;
        String jsonOut;
        try{
            Payload payload = new Payload(accountRecords[0]);
            jsonOut  = JSON.serializePretty(payload).replace('Currency1','Currency');
            errorLog = ErrorLogHandler.createLog(this.accountRecords[0].Id, ACCOUNT_URL, '', true, false, '', '', 0, '', 'POST');

            List<Map<String, String>> headers = new List<Map<String, String>>();

            HttpResponse response = new RestCalloutHandler().restCallout(RestCalloutHandler.POST, ACCOUNT_URL, headers, jsonOut, errorLog, enableDebugLog);
            
            responseBody = response.getBody();
            responseCode = response.getStatusCode();

            SAPCalloutHandler.CustomerResponse getPayload;
            if(response.getStatusCode() == 200) {
                getPayload =  (SAPCalloutHandler.CustomerResponse) JSON.deserialize(responseBody, SAPCalloutHandler.CustomerResponse.class);
            }

            if(response.getStatusCode() == 200 && getPayload != null && getPayload.MessageType == 'E'){
                insert new Integration_Log__c(
                    Account__c = accountRecords[0].Id,
                    Request_Body__c = jsonOut,
                    Response_Body__c = responseBody,
                    Response_Code__c = responseCode,
                    Endpoint__c = ACCOUNT_URL,
                    Is_Success__c = false,
                    Error_Message__c = getPayload.Message,
                    Is_Integration_Related__c = true
                );
            }
            else if(response.getStatusCode() == 200 && enableDebugLog == true ){
                upsert ErrorLogHandler.updateLog(errorLog, '', ACCOUNT_URL, true, false, jsonOut, headers,
                                            response.getBody(), response.getStatusCode(), RestCalloutHandler.POST); 
            }
            else if(response.getStatusCode() != 200){
                upsert ErrorLogHandler.updateLog(errorLog, Label.RestCalloutErrorMessage, ACCOUNT_URL, false, true, jsonOut, headers, 
                                            response.getBody(), response.getStatusCode(), RestCalloutHandler.POST);
            }
        }
        catch(Exception ex){
            /*
             * Log out an error to the integration log
            */
            insert ErrorLogHandler.updateLog(new Integration_Log__c(Account__c = accountRecords[0].Id, Stacktrace__c = ex.getStackTraceString()), 
                ex.getMessage(), ACCOUNT_URL, false, false, jsonOut, null,
                responseBody, responseCode, RestCalloutHandler.POST);
        }

        accountRecords.remove(0);
        if(!accountRecords.isEmpty()) {
            SAPCustomerIntegrationHandler.sAPOnboarding(new List<Id>(new Map<Id, Account>(accountRecords).keySet()));
        }
    }

    class Customer{
        public String AccountNo{get; set;}
        public String LegalEntity{get; set;}
        public String BusinessType{get; set;}
        public String Name1{get; set;}
        public String Street1{get; set;}
        public String ApartmentNo{get; set;}
        public String Floor{get; set;}
        public String BuildingName{get; set;}
        public String State{get; set;}
        public String Neighbourhood{get; set;}
        public String Area{get; set;}
        public String BuildingNo{get; set;}
        public String Zipcode{get; set;}
        public String City{get; set;}
        public String Country{get; set;}
        public String PO_Box{get; set;}
        public String POBoxCity{get; set;}
        public String POBoxPcd{get; set;}
        public String Telephone1{get; set;}
        public String FaxNumber{get; set;}
        public String Email1{get; set;}
        public String OldAccountNo{get; set;}
        public String Segment{get; set;}
        public String SubSegment{get; set;}
        public String VATNo{get; set;}
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
        public String COD{get; set;}
        public LegalDetails LegalDetails{get; set;}
    }
    class ContactPerson {
        public String ContactId{get; set;}
        public String Name1{get; set;}
        public String Street1{get; set;}
        public String Neighbourhood{get; set;}
        public String ApartmentNo{get; set;}
        public String BuildingNo{get; set;}
        public String Zipcode{get; set;}
        public String City{get; set;}
        public String Country{get; set;}
        public String PO_Box{get; set;}
        public String POBoxCity{get; set;}
        public String POBoxPcd{get; set;}
        public String Telephone1{get; set;}
        public String FaxNumber1{get; set;}
        public String Email1{get; set;}
    }
    class LegalDetails {
        public String LegalName{get; set;}
        public String LegalCity{get; set;}
        public String LegalZIPCode{get; set;}
        public String LegalPOBox{get; set;}
        public String LegalBuildingNo{get; set;}
        public String LegalApartmentNo{get; set;}
        public String LegalFloorNo{get; set;}
        public String LegalBuildingName{get; set;}
        public String LegalNeighborhood{get; set;}
        public String LegalArea{get; set;}
        public String LegalStreet{get; set;}
        public String LegalState{get; set;}
        public String LegalLocalizedAccountName{get; set;}
        public String LegalPhoneNumber{get; set;}
        public String Language{get; set;}
    }
    
    public class Payload {

        public Payload(Account billingAccount) {   
            Customer customer = new Customer();
            customer.AccountNo = billingAccount.AccountNumber; // In file
            customer.LegalEntity = billingAccount.parent.Account_Entity__r.Legal_Entity__c; // In file
            customer.BusinessType = billingAccount.Business_Type__c; // In file
            customer.Name1 = billingAccount.parent.Name; // In file
            customer.Street1 = billingAccount.Legal_Street__c; // In file
            customer.ApartmentNo = billingAccount.Legal_Apartment_Number__c; // In file
            customer.Floor = billingAccount.Legal_Floor_Number__c; // In file
            customer.BuildingName = billingAccount.Legal_Building_Name__c; // In file
            customer.State = billingAccount.Legal_State__c; // In file
            customer.Neighbourhood = billingAccount.Legal_Neighbourhood__c;
            customer.Area = billingAccount.Legal_Area__c;
            customer.BuildingNo = billingAccount.Legal_Building_Number__c;
            customer.Zipcode = billingAccount.Legal_Post_Code__c;
            customer.City = billingAccount.Legal_City__c; // In file 
            customer.Country = billingAccount.Parent.Country_Code__c; // In file
            customer.PO_Box = billingAccount.Legal_PO_Box__c;
            customer.Telephone1 = billingAccount.parent.Legal_Phone__c; // In file
            customer.FaxNumber = billingAccount.parent.Fax; // In file
            customer.OldAccountNo = billingAccount.AccountNumber;
            customer.Segment = billingAccount.cust_Segment__c;
            customer.SubSegment = billingAccount.cust_subSegment__c;
            customer.VATNo = billingAccount.VATNo__c; // In file
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
            customer.RecAccount = billingAccount.Account_Set__c; // In File
            customer.CashMgntGroup = billingAccount.Account_Set__c; // In File
            customer.COD = String.valueOf(billingAccount.COD__c); // In file
            if(billingAccount.AccountContactRelations != null && billingAccount.AccountContactRelations.size() != 0 && billingAccount.AccountContactRelations[0].Id != null){
                ContactPerson contactPerson = new ContactPerson();
                customer.ContactPerson = contactPerson;
                customer.ContactPerson.ContactId = billingAccount.AccountContactRelations[0].Id;
                customer.ContactPerson.Name1 = billingAccount.AccountContactRelations[0].Contact.Name;
                customer.ContactPerson.Country = billingAccount.Parent.Country_Code__c;
                customer.ContactPerson.Telephone1 = billingAccount.AccountContactRelations[0].Contact.Phone;
                customer.ContactPerson.FaxNumber1 = billingAccount.AccountContactRelations[0].Contact.Fax;
                customer.ContactPerson.Email1 = billingAccount.AccountContactRelations[0].Contact.Email;
                customer.Email1 = billingAccount.AccountContactRelations[0].Contact.Email;
            }
            // Legal Details

            legalDetails legal = new LegalDetails();
            customer.legalDetails = legal;
            customer.legalDetails.LegalName = billingAccount.parent.Legal_Name__c; // In file
            customer.legalDetails.LegalCity = billingAccount.parent.Legal_City__c; // In file
            customer.legalDetails.LegalZIPCode = billingAccount.parent.Legal_Post_Code__c; // In file
            customer.legalDetails.LegalPOBox = billingAccount.parent.Legal_PO_Box__c; // Question on this
            customer.legalDetails.LegalBuildingNo = billingAccount.parent.Legal_Building_Number__c; // Question on this
            customer.legalDetails.LegalLocalizedAccountName = billingAccount.parent.Legal_Localized_Account_Name__c; // In file
            customer.legalDetails.LegalPhoneNumber = billingAccount.parent.Legal_Phone__c; // In file
            customer.legalDetails.Language =  billingAccount.parent.Legal_Name_Language__c; // In file
            customer.legalDetails.LegalApartmentNo =  billingAccount.parent.Legal_Apartment_Number__c; // In file
            customer.legalDetails.LegalFloorNo =  billingAccount.parent.Legal_Floor_Number__c; // In file
            customer.legalDetails.LegalBuildingName =  billingAccount.parent.Legal_Building_Name__c; // In file
            customer.legalDetails.LegalNeighborhood =  billingAccount.parent.Legal_Neighbourhood__c; // In file
            customer.legalDetails.LegalArea =  billingAccount.parent.Legal_Area__c; // In file
            customer.legalDetails.LegalState =  billingAccount.parent.Legal_State__c; // In file
            customer.legalDetails.LegalStreet =  billingAccount.parent.Legal_Street__c; // In file
            
            this.Customer = customer;
            
            String serializedJSON = JSON.serialize(customer);
            system.debug(serializedJSON);
        }

        public Customer Customer {get; set;}
    }
    public class CustomerResponse{
        public String MessageType;  //E
        public String Message;  //Company code JO02 is not available in the customer
        public String CustomerNo;   //0000010101
        public String BusinessArea; //AMM
        public String Sort1;    //10101
    }
}