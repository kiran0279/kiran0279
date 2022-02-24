/***
    * TestDataUtlity class for common test data creation. This can be used in Test Classes.
    * 14/12/2020 neha.kumari@weare4c.com [REQ-ARMX-0259 and ARMX-0260] v1.0
    * 29/12/2020 sujata.chaudhari@weare4c.com v2.0
    */ 
    @isTest
    Public Class TestDataUtility{
        public static Integer numOfRecords;
        public static Map<String, Profile> profileMap;

        public static Pricebook2 createPricebook2(String name){
            return new Pricebook2(
            Name = name,
            IsActive=true);
        } 
        
        public static List<Pricebook2> createPricebook2List(Integer numOfRecords){
            List<Pricebook2> pricebookList = new List<Pricebook2>();
            for(Integer i=0;i<numOfRecords;i++){
                String name='Custom Pricebook'+i;    
                pricebookList.add(createPricebook2(name));    
            }
            return pricebookList;
        }


        public static Lead createLead(String email, String firstName, String lastName, String company){
            return createLead(email, firstName, lastName, company, null, null, null);
        }

        public static Lead createLead(String email, String firstName, String lastName, String company, String phone, String street, String mobilePhone){
            return new Lead(Email=email,
                Firstname=firstName,
                Lastname=lastName,
                Phone=phone,
                MobilePhone = mobilePhone,
                Company=company,            
                Lead_Type__c='Non Longtail',
                Segment__c='Aramex Agents',
                Vertical__c= 'Cargo',
                Country_Code__c ='AE',
                Entity__c= 'AUH',
                LeadSource='Advertisement',
                Product_Interest__c = 'Domestic',
                Avg_Contract_Value__c=1234.00,
                NumberOfEmployees= 123,
                Band__c= 'Middle Market',
                //ICP__c='',
                Street__c = street,
                City__c = 'Abu Dhabi',
                OwnerId=UserInfo.getUserId(),
                Verification_Call_Complete__c=true,
                Status='Verification',
                BDM__c= (Id)UserInfo.getUserId());
        }
        public static List<Lead> createLeads(Id pricebookId, Integer numOfRecords){
            return null;
        }
        public static List<Lead> createLeads(Integer numOfRecords){
            List<Lead> leadList = new List<Lead>();
            for(integer i=0;i<numOfRecords;i++){
                String email = '4cLead'+i+ 'test' +i+ '@testing.com';
                String firstname = '4cLead '+i+ 'test'+i;
                String lastname = 'Lastname '+i+ 'test'+i;
                String company = 'Lead'+i+ 'Companyyyyyy'+i+'test'+i;
                String phone = '8599'+ i + '16969';
                String mobilePhone = '850099'+ i + '16969';
                String street = 'test'+i+'street'+i;
                leadList.add(createLead(email, firstname, lastname, company, phone, street, mobilePhone));
            }
            return leadList;  
        }
        public static profile getProfile(String profileName){
                if(profileMap == null){
                    profileMap = new Map<String, Profile>(); 
                    profileMap.put(profileName, [SELECT Id FROM Profile WHERE Name =:profileName]);
                }
                else if(profileMap.containsKey(profileName)){
                    return profileMap.get(profileName);
                }
                else{
                    profileMap.put(profileName, ([SELECT Id FROM Profile WHERE Name =:profileName]));
                }
                return profileMap.get(profileName);
        }
        public static User createUser(String email, String uniqueName, Id pId){
            return new User(Alias = 'standt',
                Email= email,
                EmailEncodingKey='UTF-8', 
                LastName= uniqueName, 
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US',
                Band__c='Transactional',
                Segment__c='Aramex Agents',
                Division = String.valueOf(Integer.valueOf(math.rint(math.random()*1000000))),
                EmployeeNumber = String.valueOf(Integer.valueOf(math.rint(math.random()*1000000))),
                Vertical__c='Cargo',
                Entity__c='AUH',            
                TimeZoneSidKey= UserInfo.getTimeZone().getID(),
                ProfileId = pId,
                isActive = true,            
                UserName = email);
        }
        public static List<User> createUsers(Id ProfileId, Integer numOfRecords){
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;

            List<User> userList = new List<User>();
            
            for(Integer i=0; i<numOfRecords; i++){
                String email =  uniqueName + i + '@tes' + 'b'+orgId + '.com';  
                Id pId = ProfileId;    
                userList.add(createUser(email, uniqueName, pId));  
            }

            return userList;
        }
        
        private static Id companyAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        private static Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        public static Account createCompanyAccount(String name, String countryCode, String entity) {
            return new Account(
                Name = name,
                Entity__c = entity,
                RecordTypeId = companyAccountRecordTypeId,
                Country_Code__c = countryCode
            );
        }

        public static string AUTOBLOCK = 'Auto-Block';
        public static Account createBillingAccount(String name, Id parentId, String autoBlockStatus, Date blockedDueDate, String creditTerms) {
            return new Account(
                Name = name,
                RecordTypeId = billingAccountRecordTypeId,
                ParentId = parentId,
                Account_Block_Type__c = autoBlockStatus,
                Block_Due_Date__c = blockedDueDate,
                Credit_Terms__c = creditTerms
            );
        }

        public static Account createAccount(String name){
            return new Account(Name = name,
                ShippingStreet ='Test',
                ShippingCity='Test', 
                ShippingState='Victoria', 
                ShippingCountry='Australia',
                ShippingPostalCode='302022', 
                Country_Code__c = 'AE',
                Entity__c = 'AUH',
                Block_Due_Date__c = Date.TODAY(),
                Credit_Limit__c = '500',
                Credit_Terms__c = '30',
                Account_Block_Type__c = 'Auto-Block',
                Account_Block_Status__c = 'Unblocked'
                );
        }
        
        public static List<Account> createAccountList(Integer numOfRecords){
            List<Account> accList = new List<Account>();
            Account acc = new Account();
            for(Integer i=0;i<numOfRecords;i++){
                String name = 'TestAccountAramex4c' +i;
                accList.add(createAccount(name));
            }
            return accList;
        }
        
        public static Contact createContact(String firstName, Id accId){
            return new Contact(FirstName=firstName,
            LastName='Contact',
            Email='test@test.com',
            Phone='123456',
            AccountId = accId,
            Title='TestTitle');
        } 
        
        public static List<Contact> createContactList(Id accountId, Integer numOfRecords){
            List<Contact> conList = new List<Contact>();
            Contact cnt = new Contact();
            for(Integer i=0;i<numOfRecords;i++){
                String firstName='Test' + i;
                Id accId = accountId;    
                conList.add(createContact(firstName, accId));    
            }
            return conList;
        }

        public static Product2 createProduct(String name){
            return new Product2(
            Name = name,
            Family = 'Logistics'
            );
        } 
        
        public static List<Product2> createProductList(Integer numOfRecords){
            List<Product2> astList = new List<Product2>();
            for(Integer i=0;i<numOfRecords;i++){
                String name ='Test' + i;   
                astList.add(createProduct(name));    
            }
            return astList;
        }

        public static Asset createAsset(String name, Id accId){
            return new Asset(
            Name = name,
            Facility__c = 'WMWHSE1',
            AccountId = accId,
            InstallDate = System.Today(),
            UsageEndDate = System.Today()
            );
        } 
        
        public static List<Asset> createAssetList(Id accountId, Integer numOfRecords){
            List<Asset> astList = new List<Asset>();
            Asset ast = new Asset();
            for(Integer i=0;i<numOfRecords;i++){
                String name ='Test' + i;
                Id accId = accountId;    
                astList.add(createAsset(name, accId));    
            }
            return astList;
        }

        public static AccountContactRelation createAccountContactRelation(Id accId, Id conId){
            return new AccountContactRelation(
            AccountId = accId,
            ContactId = conId);
        } 

        public static List<AccountContactRelation> createAccountContactRelationList(Id accountId, Id contactId, Integer numOfRecords){
            List<AccountContactRelation> conList = new List<AccountContactRelation>();
            AccountContactRelation cnt = new AccountContactRelation();
            for(Integer i=0;i<numOfRecords;i++){
                Id accId = accountId; 
                Id conId = contactId;   
                conList.add(createAccountContactRelation(accId, conId));    
            }
            return conList;
        }
        
        public static Opportunity createOpportunity(String name, Id accId){
            return new Opportunity(Name = name,
                StageName = 'Pipeline',
                ForecastCategoryName = 'Commit', 
                AccountId = accId,
                CloseDate = Date.today());
        }
        
        public static List<Opportunity> createOpportunityList(Id accountId, Integer numOfRecords){
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = new Opportunity();
            for(Integer i=0;i<numOfRecords;i++){
                String name = 'Test Opportunity' +i;
                Id accId = accountId;    
                oppList.add(createOpportunity(name, accId));    
            }
            return oppList;
        }
        
        public static AccountTeamMember createATM(Id ownerId, Id accountId){
            return new AccountTeamMember(AccountAccessLevel= 'All', 
                        UserId = ownerId, 
                        AccountId = accountId);
        }
        
        public static List<AccountTeamMember> createAccountTeamMember(Id getOwnerId, Id getAccountId, Integer numOfRecords){
            List<AccountTeamMember> atmList = new List<AccountTeamMember>();
            for(Integer i=0;i<numOfRecords;i++){
                AccountTeamMember atm = new AccountTeamMember();
                Id ownerId = getOwnerId;
                Id accountId = getAccountId;
                atmList.add(createATM(ownerId, accountId));
            }
            return atmList;
        }
        
        public static OpportunityTeamMember createOTM(Id ownerId, Id opportunityId){
            return new OpportunityTeamMember(CurrencyIsoCode = 'USD', 
                        UserId = ownerId, 
                        OpportunityId = opportunityId);
        }
        
        public static List<OpportunityTeamMember> createOpportunityTeamMember(Id getOwnerId, Id getOpportunityId, Integer numOfRecords){
                List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
                for(Integer i=0;i<numOfRecords;i++){
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    Id ownerId = getOwnerId;
                    Id opportunityId = getOpportunityId;    
                    otmList.add(createOTM(ownerId, opportunityId));
                }
            return otmList;
        }
        
        public static Task createTask(Id whoId){
            return new Task(Subject='Call',
                        Type='Phone Call',
                        Priority='Normal',
                        Status='Open',
                        WhoId = whoId,
                        ActivityDate=System.today().addDays(5));
        }
        
        public static List<Task> createTaskList(Id ContactId, Integer numOfRecords){
            List<Task> taskList = new List<Task>();
            Task tsk = new Task();
            for(Integer i=0;i<numOfRecords;i++){
                Id whoId = ContactId;    
                taskList.add(createTask(whoId));
            }
            return taskList;
        }

        public static Integration_Log__c createIntegrationLog(Id accId){
            return new Integration_Log__c(
                            Account__c = accId,
                            Endpoint__c = 'https://salesforce-dev.integration.aramex.net/RESTAdapter/SI_CustMaster_Out',
                            Error_Message__c = 'test',
                            Is_Success__c = true,
                            Is_Integration_Related__c = true,
                            Request_Body__c = ' {   "Customer": {   "AccountNo": "10101",   "LegalEntity": "JO00",  "BusinessType": "Corporate Business",   "Name1": "Arab Bank Ltd",   "Street1": "Prince Shaker Bin Zeid Street",     "Neighbourhood": "Al Shmeisani",    "Area": "Al Abdali",    "BuildingNo": "30",     "Zipcode": "11195",     "City": "Amman",    "Country": "JO",    "PO_Box": "950545",     "POBoxCity": "Amman",   "POBoxPcd": "11195",    "Telephone1": "96265600000",    "FaxNumber": "96265606793",     "Email1": "Test@Test.com",  "OldAccountNo": "10101",    "Segment": "54",    "SubSegment": "541611",     "VATNo": "123",     "TaxRate": "16",    "RegistrationNo": "0",  "CustomerID": "36277",  "CustName": "Arab Bank Ltd",    "LegalStatus": "1Normal",   "ContactPerson": {      "ContactId": "100801",      "Name1": "Mahmoud Awad",    "Street1": "Prince Shaker Bin Zeid Street",     "Neighbourhood": "Al Shmeisani",    "Area": "Al Abdali",    "BuildingNo": "30",     "Zipcode": "11195",     "City": "Amman",    "Country": "JO",    "PO_Box": "950545",     "POBoxCity": "Amman",       "POBoxPcd": "11195",    "Telephone1": "96265600000",    "FaxNumber1": "96265606793",    "Email1": "Test@Test.com"   },  "EntityCode": "AMM",    "TeamID": "15830",  "Currency": "JOD",  "CreditTerms": "60",    "CreditLimit": "35000",     "CreditController": "16052",    "SalesEmployee": "78995",   "RecAccount": "300JOD",     "CashMgntGroup": "300JOD",  "COD": "false",     "LegalDetails": {       "LegalName": "Arab Bank Ltd",       "LegalCity": "test",    "LegalZIPCode": "test",     "LegalPOBox": "test",       "LegalBuildingNo": "test",      "LegalLocalizedAccountName": "test",    "LegalPhoneNumber": "0",    "Language": "ar"    }   } }',
                            Response_Body__c = ' {    "MessageType": "E",    "Message": "Company code JO02 is not available in the customer",    "CustomerNo": "0000010101",    "BusinessArea": "AMM",    "Sort1": 10101 }  ',
                            Response_Code__c = 200,
                            Stacktrace__c = 'Stacktrace',
                            // Archiving_Required__c = true,
                            Method__c = 'POST');
        }
        
        public static List<Integration_Log__c> createIntegrationLogList(Id accountId, Integer numOfRecords){
            List<Integration_Log__c> integrationLogList = new List<Integration_Log__c>();
            Integration_Log__c tsk = new Integration_Log__c();
            for(Integer i=0;i<numOfRecords;i++){
                Id accId = accountId;    
                integrationLogList.add(createIntegrationLog(accId));
            }
            return integrationLogList;
        }

        public static Job_Archive_Setting__c createJobArchiveSetting(String name){
            return new Job_Archive_Setting__c(Name = name,
                            IsActive__c = true,
                            sObjectType__c = 'Integration_Log__c',
                            Field__c = 'Archiving_Required__c');
        }
        
        public static List<Job_Archive_Setting__c> createJobArchiveSettingList(Integer numOfRecords){
            List<Job_Archive_Setting__c> taskList = new List<Job_Archive_Setting__c>();
            Job_Archive_Setting__c tsk = new Job_Archive_Setting__c();
            for(Integer i=0;i<numOfRecords;i++){
                String name = 'test' +i;    
                taskList.add(createJobArchiveSetting(name));
            }
            return taskList;
        }

    }