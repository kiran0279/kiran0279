@isTest
public with sharing class OnboardingIntegrationTest {

    private static Id companyAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    private static Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

    class UserSetup {
        public User systemAdminRecord {get; set;}
        public User bdmUserRecord {get; set;}
        public List<User> accountManagerUserRecords {get; set;}

        private Id accountManagerProfileId = [Select Id From Profile Where Name = 'Account Manager' Limit 1].Id;
        private Id BDMProfileId = [Select Id From Profile Where Name = 'Business Development Manager' Limit 1].Id;
        private Id systemAdministratorProfileId = [Select Id From Profile Where Name = 'System Administrator' Limit 1].Id;

        UserSetup() {
            /*
            * Create system admin
            */
            systemAdminRecord = TestDataUtility.createUser('system.admin@aramex.com', 'SA123432', systemAdministratorProfileId);
            insert systemAdminRecord;

            /*
            * create BDM User
            */
            bdmUserRecord = TestDataUtility.createUser('bd.one@aramex.com', 'BD123432', BDMProfileId);
            bdmUserRecord.Division = '12345';
            bdmUserRecord.EmployeeNumber = '12345';
            insert bdmUserRecord;

            /*
            * create Account Managers
            */
            List<User> existingAccountManagersToDeactivate = new List<User>();
            for(User userRecord : [Select Id From User Where Profile.Name = 'Account Manager']) {
                userRecord.isActive = false;
                userRecord.Division = '12345';
                userRecord.EmployeeNumber = '12345';
                existingAccountManagersToDeactivate.add(userRecord);
            }
            update existingAccountManagersToDeactivate;

            accountManagerUserRecords = TestDataUtility.createUsers(accountManagerProfileId, 1);
            accountManagerUserRecords[0].Division = '12345';
            accountManagerUserRecords[0].EmployeeNumber = '12345';
            insert accountManagerUserRecords;
        }

    }

    class SetupData {
        public Entity__c entityRecord {get; set;}
        public Product2 prod {get; set;}

        public void SetupData() {
             /*
              * Setup Integration Settings
              */ 
              Integration_Settings__c integrationSetting = new Integration_Settings__c(Enable_Debug_Logging__c = True);
              insert integrationSetting;
  
              /*
              * Entity
              */
              entityRecord = new Entity__c(
                  Country_Code__c = 'AE',
                  Entity__c = 'DXB',
                  Legal_Entity__c = 'AE01'
              );
              insert entityRecord;
  
              /*
              * Pricebook
              */
              Pricebook2 pricebook = TestDataUtility.createPricebook2('test'); 
              insert pricebook;
  
              /*
              * Product
              */
              prod = TestDataUtility.createProduct('test');
              prod.Family = 'Logistics';
              insert prod;
        }
    }

    class supportingData {
        public Account companyAccountRecord {get; set;}
        public Account billingAccountRecord {get; set;}

        public void supportingData(SetupData data, UserSetup users) {
            /*
            * Customer account
            */
            companyAccountRecord = new Account(
                Name = 'Test Account',
                RecordTypeId = companyAccountRecordTypeId,
                Entity__c = 'DXB',
                Country_Code__c = 'AE'
            );
            insert companyAccountRecord;

            /*
            * Billing Account
            */
            billingAccountRecord = new Account(
                Name = 'Test Billing Account',
                RecordTypeId = billingAccountRecordTypeId,
                ParentId = companyAccountRecord.Id
            );
            insert billingAccountRecord; 

            /*
            * Asset
            */
            Asset assetRecord = TestDataUtility.createAsset('test', companyAccountRecord.Id);
            assetRecord.Billing_Account__c = billingAccountRecord.Id;
            assetRecord.Product2Id = data.prod.Id;
            assetRecord.Facility__c = 'WMWHSE1';
            assetRecord.Start_Date__c = Date.Today().AddDays(-1);
            assetRecord.End_Date__c = Date.Today().AddDays(1);
            insert assetRecord;

            /*
            * Contact
            */
            Contact contactRecord = new Contact(
                FirstName = 'John',
                LastName = ' Smith',
                Email = 'john.smith@aramex.com',
                Phone = '7485969999',
                AccountId = companyAccountRecord.Id
            );
            insert contactRecord;

            /*
            * Account Team - Contract Manager
            */
            AccountTeamMember accountTeamMember = new AccountTeamMember(
                UserId = users.accountManagerUserRecords[0].Id,
                AccountId = billingAccountRecord.Id,
                TeamMemberRole = 'Credit Manager'
            );
            insert accountTeamMember;

            /*
            * Primary Contact
            */ 
            AccountContactRelation accountContactRelation = new AccountContactRelation(
                ContactId = contactRecord.Id,
                AccountId = billingAccountRecord.Id,
                Primary__c = True
            );
            insert accountContactRelation;
        }
    }

    @isTest
    public static void happyPathSAP() {
        /*
         * User setup
         */
        UserSetup users = new UserSetup();
        

        SetupData data = new SetupData();
        system.runAs(users.systemAdminRecord) {
            data.setupData();
        }
        
        SupportingData supportingData = new SupportingData();
        system.runAs(users.accountManagerUserRecords[0]) {
            supportingData.supportingData(data, users);
        }
        
        /*
         * Setup Mock
         */
        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        String responseBdy = '{}';
        Integer statsCode = 200;
        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', responseBdy, headers, statsCode);

        Test.setMock(HttpCalloutMock.class, serviceMock);

        Test.startTest();

        /*
         * Call method
         */
        system.runAs(users.accountManagerUserRecords[0]) {
            SAPCustomerIntegrationHandler.sAPOnboarding(new List<String> {supportingData.billingAccountRecord.Id});
        }

        test.stopTest();

        /*
         * Check results
         */ 
        System.assertEquals(1, [Select Id From Integration_Log__c].size(), 'No Integration Logs Found');
        System.assertEquals(null, [Select Id, Error_Message__c From Integration_Log__c][0].Error_Message__c, 'Stacktrace: [' + [Select Id, Stacktrace__c From Integration_Log__c][0].Stacktrace__c + ']');
        System.assertEquals(1, [Select Id From Integration_Log__c Where Is_Success__c = True].size(), 'No Success Integration Logs Found');
    }

    @isTest
    public static void happyPathCargowise() {
        /*
         * User setup
         */
        UserSetup users = new UserSetup();
        

        SetupData data = new SetupData();
        system.runAs(users.systemAdminRecord) {
            data.setupData();
        }
        
        SupportingData supportingData = new SupportingData();
        system.runAs(users.accountManagerUserRecords[0]) {
            supportingData.supportingData(data, users);
        }
        
        /*
         * Setup Mock
         */
        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        String responseBdy = '{}';
        Integer statsCode = 200;
        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', responseBdy, headers, statsCode);

        Test.setMock(HttpCalloutMock.class, serviceMock);

        Test.startTest();

        /*
         * Call method
         */
        system.runAs(users.accountManagerUserRecords[0]) {
            OperationalCustomerIntegrationHandler.cargoWiseOnboarding(new List<String> {supportingData.billingAccountRecord.Id});
        }

        test.stopTest();

        /*
         * Check results
         */ 
        System.assertEquals(1, [Select Id From Integration_Log__c].size(), 'No Integration Logs Found');
        System.assertEquals(null, [Select Id, Error_Message__c From Integration_Log__c][0].Error_Message__c, 'Stacktrace: [' + [Select Id, Stacktrace__c From Integration_Log__c][0].Stacktrace__c + ']');
        System.assertEquals(1, [Select Id From Integration_Log__c Where Is_Success__c = True].size(), 'No Success Integration Logs Found');
    }

    @isTest
    public static void happyPathInfor() {
        /*
         * User setup
         */
        UserSetup users = new UserSetup();
        

        SetupData data = new SetupData();
        system.runAs(users.systemAdminRecord) {
            data.setupData();
        }
        
        SupportingData supportingData = new SupportingData();
        system.runAs(users.accountManagerUserRecords[0]) {
            supportingData.supportingData(data, users);
        }
        
        /*
         * Setup Mock
         */
        List<Map<String, String>> headers = new List<Map<String, String>>();
        headers.add(new Map<String, String> {'Content-Type' => 'application/json'});

        String responseBdy = '{"_HasError":false,"_Result":"OK: Block Status Updated"}';
        Integer statsCode = 200;
        HTTPMockFactory serviceMock = new HTTPMockFactory('POST', responseBdy, headers, statsCode);

        Test.setMock(HttpCalloutMock.class, serviceMock);

        Test.startTest();

        /*
         * Call method
         */
        system.runAs(users.accountManagerUserRecords[0]) {
            InforCustomerIntegrationHandler.inforOnboarding(new List<String> {supportingData.billingAccountRecord.Id});
        }

        test.stopTest();

        /*
         * Check results
         */ 
        System.assertEquals(1, [Select Id From Integration_Log__c].size(), 'No Integration Logs Found');
        System.assertEquals(null, [Select Id, Error_Message__c From Integration_Log__c][0].Error_Message__c, 'Stacktrace: [' + [Select Id, Stacktrace__c From Integration_Log__c][0].Stacktrace__c + ']');
        System.assertEquals(1, [Select Id From Integration_Log__c Where Is_Success__c = True].size(), 'No Success Integration Logs Found');
    }
}