/**
    * @Class Name: LeadTriggerHandlerTest
    * @Description: Used for LeadTriggerHandler and LeadTrigger as a test Class.
    * ================================================================================================================
    * Version | Date | Author 
    * -----------------------------------------------------------------------------------------------------------------
    * 1.0 | 14th Dec, 2020 | neha.kumari@weare4c.com 
    * 1.1 | 29th Dec, 2020 | sujata.chaudhari@weare4c.com 
    * 1.2 | 31st Dec, 2020 | sujata.chaudhari@weare4c.com
    * =================================================================================================================
    */
    //@isTest
    public class LeadTriggerHandlerTest{
        //@isTest
        public static void testLeadConversion(){
            testRunner(1);
        }

        public static void testRunner(Integer numberofRecords){
            
            List<Lead> leadRecords = TestDataUtility.createLeads(numberofRecords);
            insert leadRecords;
            
            test.startTest();
            /*
            * Setup the lead conversion operation 
            */
            List<Lead> ldList = [SELECT Id FROM Lead LIMIT :numberofRecords];
            List<Database.LeadConvert> listOfLeadConversions = new List<Database.LeadConvert>();
            for(Lead ld: ldList){
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(ld.id);
                lc.setOwnerId((Id)UserInfo.getUserId());
                lc.setDoNotCreateOpportunity(false);
                lc.setConvertedStatus('Converted');
                listOfLeadConversions.add(lc);
            }

            /*
            * TEST OPERATION - convert the lead
            */
        
            List<Database.LeadConvertResult> results = Database.convertLead(listOfLeadConversions);
            test.stopTest();
        }
        
        
    }