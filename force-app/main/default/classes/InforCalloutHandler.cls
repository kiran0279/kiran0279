/**
* @Class Name: InforCalloutHandler
* @Description: Queueable class for callouts.
* ================================================================================================================
* Version | Date | Author | Comments
* -----------------------------------------------------------------------------------------------------------------
* 1.0 | 10th Feb, 2021 | sujata.chaudhari@weare4c.com | 1. This class is used by SAPCustomerIntegrationHandler.
* =================================================================================================================
*/
public with sharing class InforCalloutHandler implements Queueable, Database.AllowsCallouts{
    List<Account> accountRecords;

    public class InforIntegrationException extends Exception {}

    public InforCalloutHandler(List<String> accId){
        List<Account> accountRecords = [SELECT 
                                    Id, Account_Block_Status__c, CurrencyIsoCode,
                                    parentId, parent.Name, AccountNumber, parent.Entity__c, 
                                    parent.BillingCity, parent.BillingCountry, parent.Business_Type__c
                                FROM Account WHERE Id IN :accId];
        
        if(accountRecords.isEmpty()) {
            throw new InforIntegrationException('Unable to find account record');
        }

        this.accountRecords = accountRecords;
    }
    
    private static String ACCOUNT_URL = 'callout:Infor_Credentials/RestService_Users/Storer/UpdateStorer';

    public void execute(QueueableContext context){
        Integration_Settings__c ins = Integration_Settings__c.getOrgDefaults();
        Boolean enableDebugLog = ins.Enable_Debug_Logging__c;
        Integration_Log__c errorLog;
        String responseBody;
        Integer responseCode;
        String jsonOut;

        List<Asset> assetRecords = [Select 
                                        Id, Facility__c 
                                    From 
                                        Asset 
                                    Where 
                                        AccountId = :accountRecords[0].ParentId AND 
                                        Product2.Family = 'Logistics' AND 
                                        Facility__c != null];

        try{

            if(assetRecords.isEmpty()) {
                throw new InforIntegrationException('Unable to find a logistics asset record with a facility code assigned');
            }
    
            Asset assetRecord = assetRecords[0];
            
            Payload payload = new Payload(this.accountRecords[0], assetRecord);
            jsonOut  = JSON.serializePretty(payload);
            
            jsonOut  = jsonOut.replace('BlockStatus','_BlockStatus'); 
            jsonOut  = jsonOut.replace('BusinessCategory', '_BusinessCategory');
            jsonOut  = jsonOut.replace('City', '_City');
            jsonOut  = jsonOut.replace('Company', '_Company');
            jsonOut  = jsonOut.replace('Country', '_Country');
            jsonOut  = jsonOut.replace('CurrCode', '_CurrCode');
            jsonOut  = jsonOut.replace('Entity', '_Entity');
            jsonOut  = jsonOut.replace('StorerKey', '_StorerKey');
            jsonOut  = jsonOut.replace('FacilityStr', '_FacilityStr');
            jsonOut  = jsonOut.replace('"PassWord"', '"_PassWord"');
            jsonOut  = jsonOut.replace('"UserName"', '"_UserName"');
            jsonOut  = jsonOut.replace('CLoginTokenInfor', '_CLoginToken');

            errorLog = ErrorLogHandler.createLog(this.accountRecords[0].Id, ACCOUNT_URL, '', true, false, '', '', 0, ' ', 'POST');

            List<Map<String, String>> headers = new List<Map<String, String>>();

            headers.add(new Map<String, String> {'Content-Type' => 'application/json'});
            headers.add(new Map<String, String> {'Accept' => 'application/json'});

            HttpResponse response = new RestCalloutHandler().restCallout(RestCalloutHandler.POST, ACCOUNT_URL, headers, jsonOut, errorLog, enableDebugLog);
            
            responseBody = response.getBody();
            responseCode = response.getStatusCode();

            //Parse JSON response to get the field values.
            JSONParser parser = JSON.createParser(responseBody);
            Boolean HasError;
            String Result;

            parser.nextToken();
            // Advance to the next value.
            parser.nextValue();
            // Get the Boolean value.
            HasError = parser.getBooleanValue();
            parser.nextToken();
            // Advance to the next value.
            parser.nextValue();
            // Get the String value.
            Result = parser.getText();

            if(response.getStatusCode() == 200 && HasError == true){

                    Integration_Log__c errlog = new Integration_Log__c(
                        Account__c = accountRecords[0].Id,
                        Request_Body__c = jsonOut,
                        Response_Body__c = responseBody,
                        Response_Code__c = responseCode,
                        Endpoint__c = ACCOUNT_URL,
                        Is_Success__c = false,
                        Is_Integration_Related__c = true
                    );
                    insert errlog;
            }
            else if(response.getStatusCode() == 200 && enableDebugLog == true){
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
            Integration_Log__c errlog = new Integration_Log__c();
            errlog.Account__c = accountRecords[0].Id;
            errlog.Request_Body__c = jsonOut;
            if(responseBody != null) {
                errlog.Response_Body__c = responseBody;
            }
            if(responseCode != null) {
                errlog.Response_Code__c = responseCode;
            }
            errlog.Endpoint__c = ACCOUNT_URL;
            errlog.Error_Message__c = ex.getMessage();
            errlog.Is_Success__c = false; 
            errlog.Is_Integration_Related__c = false;
            errlog.Stacktrace__c = ex.getStackTraceString();    
            insert errlog;  
        }

        this.accountRecords.remove(0);
        if(!this.accountRecords.isEmpty()) {
            InforCustomerIntegrationHandler.inforOnboarding(new List<Id>(new Map<Id, Account>(this.accountRecords).keySet()));
        }
    }

    class CLoginTokenInfor {
        public String FacilityStr {get; set;}
        public String PassWord {get; set;}
        public String UserName {get; set;}
    }
    
    public class Payload {

        public Payload(Account accountRecord, Asset assetRecord) { 
            

            /*
             * Billing account
             */
            this.BlockStatus = accountRecord.Account_Block_Status__c == 'Blocked';
            this.CurrCode = accountRecord.CurrencyIsoCode;

            /*
             * Company account
             */
            this.BusinessCategory = accountRecord.parent.Business_Type__c;
            this.City = accountRecord.parent.BillingCity;
            this.Company = accountRecord.parent.Name;
            this.Country = accountRecord.parent.BillingCountry;
            this.Entity = accountRecord.parent.Entity__c;
            this.StorerKey = accountRecord.AccountNumber;

            CLoginTokenInfor cLoginToken = new CLoginTokenInfor();

            cLoginToken.UserName = '{!$Credential.UserName}';
            cLoginToken.PassWord = '{!$Credential.Password}';
            

            this.CLoginTokenInfor = cLoginToken;
            /*
            * Asset
            */
            cLoginToken.FacilityStr = assetRecord.Facility__c;          
            String serializedJSON = JSON.serialize(this);
            system.debug(serializedJSON);
        }

        public Boolean BlockStatus {get; set;}
        public String BusinessCategory {get; set;}
        public CLoginTokenInfor CLoginTokenInfor {get; set;}
        public String City {get; set;}
        public String Company {get; set;}
        public String Country {get; set;}
        public String CurrCode {get; set;}
        public String Entity {get; set;}
        public String StorerKey {get; set;}
    }
}