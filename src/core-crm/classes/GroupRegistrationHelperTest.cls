/**
 * @description Test Class for GroupRegistrationHelper
 * @see ../class/GroupRegistrationHelper
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | January 30, 2023      | DEPP-4684            | Created file                 | 
 */
@isTest
public with sharing class GroupRegistrationHelperTest {
    public static final String CCE_CATEGORY_CB = 'Corporate Bundle';
    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final Id ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id ACTIVITY_COURSE_ID = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static final Id BUSINESS_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static final Id PR_CORPBUNDLE_RECTYPEID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Corporate_Bundle').getRecordTypeId();
    private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department; 
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final Integer NUMBER_OF_RECORDS = 10;

    @testSetup
    static void setupData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
    }

    @isTest
    static void cceBulkRegistrationTest(){
        createCCERecord();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<hed__Course_Offering__c> offerings = [SELECT Id From hed__Course_Offering__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Contact> contactList = createContactList(3);
            Id corpPriceBook = [SELECT Id FROM Pricebook2 WHERE Name Like 'Corporate%' WITH SECURITY_ENFORCED LIMIT 1].Id;
            List<PricebookEntry> pbEntryList = [SELECT Id, Name, Pricebook2.Name FROM PricebookEntry WHERE Pricebook2Id =: corpPriceBook WITH SECURITY_ENFORCED];

            GroupRegistrationCtrl.RegistrationDetails registrationDetails = new GroupRegistrationCtrl.RegistrationDetails();
            registrationDetails.prescribedProgram = false;
            registrationDetails.discountAmount = 0;
            registrationDetails.promotionId = null;
            registrationDetails.offeringId = offerings[0].Id;
            registrationDetails.contacts = contactList;
            registrationDetails.priceBookEntryId = pbEntryList[0].Id;

            String response = GroupRegistrationCtrl.bulkRegister(registrationDetails);

            System.assertEquals('Success', response, 'Failed to register CB learners.');
        }
    }

    @isTest
    static void opeBulkRegistrationTest(){
        createRecord(RT_ACTIVITY_ID);
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            WebStore webStore = new WebStore();
            webStore.Name = 'Study';
            webStore.DefaultLanguage = 'en_US';
            insert webStore;

            List<hed__Course_Offering__c> offerings = [SELECT Id From hed__Course_Offering__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Contact> contactList = createContactList(3);
            List<PricebookEntry> pbEntryList = [SELECT Id FROM PricebookEntry WITH SECURITY_ENFORCED LIMIT 1];
            GroupRegistrationCtrl.RegistrationDetails registrationDetails = new GroupRegistrationCtrl.RegistrationDetails();
            registrationDetails.prescribedProgram = false;
            registrationDetails.discountAmount = 0;
            registrationDetails.promotionId = null;
            registrationDetails.offeringId = offerings[0].Id;
            registrationDetails.contacts = contactList;
            registrationDetails.priceBookEntryId = pbEntryList[0].Id;

            Test.startTest();
            String response = GroupRegistrationCtrl.bulkRegister(registrationDetails);
            Test.stopTest();

            System.assertEquals('Success', response, 'Failed to register learners.');
        }
    }

    @isTest
    static void cceTailoredBulkRegistrationTest(){
        createRecord(RT_ACTIVITY_ID);
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<hed__Course_Offering__c> offerings = [SELECT Id From hed__Course_Offering__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Contact> contactList = createContactList(3);

            GroupRegistrationCtrl.RegistrationDetails registrationDetails = new GroupRegistrationCtrl.RegistrationDetails();
            registrationDetails.prescribedProgram = false;
            registrationDetails.discountAmount = 0;
            registrationDetails.promotionId = null;
            registrationDetails.offeringId = offerings[0].Id;
            registrationDetails.contacts = contactList;
            registrationDetails.priceBookEntryId = null;
            
            Test.startTest();
            String response = GroupRegistrationCtrl.bulkRegister(registrationDetails);
            Test.stopTest();

            System.assertEquals('Success', response, 'Failed to register learners in CCE Tailored Category.');
        }
    }

    @isTest
    static void opeProgramBulkRegistrationTest(){
        createRecord(RT_ACTIVITY_ID);
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            WebStore webStore = new WebStore();
            webStore.Name = 'Study';
            webStore.DefaultLanguage = 'en_US';
            insert webStore;

            List<Program_Offering__c> offerings = [SELECT Id From Program_Offering__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Contact> contactList = createContactList(3);
            List<PricebookEntry> pbEntryList = [SELECT Id FROM PricebookEntry WITH SECURITY_ENFORCED LIMIT 1];
            GroupRegistrationCtrl.RegistrationDetails registrationDetails = new GroupRegistrationCtrl.RegistrationDetails();
            registrationDetails.prescribedProgram = true;
            registrationDetails.discountAmount = 0;
            registrationDetails.promotionId = null;
            registrationDetails.offeringId = offerings[0].Id;
            registrationDetails.contacts = contactList;
            registrationDetails.priceBookEntryId = pbEntryList[0].Id;

            Test.startTest();
            String response = GroupRegistrationCtrl.bulkRegister(registrationDetails);
            Test.stopTest();

            System.assertEquals('Success', response, 'Failed to register learners.');
        }
    }

    @isTest
    static void cceProgramBulkRegistrationTest(){
        createRecord(RT_ACTIVITY_ID);
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Program_Offering__c> offerings = [SELECT Id From Program_Offering__c WITH SECURITY_ENFORCED LIMIT 1];
            List<Contact> contactList = createContactList(3);

            GroupRegistrationCtrl.RegistrationDetails registrationDetails = new GroupRegistrationCtrl.RegistrationDetails();
            registrationDetails.prescribedProgram = true;
            registrationDetails.discountAmount = 0;
            registrationDetails.promotionId = null;
            registrationDetails.offeringId = offerings[0].Id;
            registrationDetails.contacts = contactList;
            registrationDetails.priceBookEntryId = null;
            
            Test.startTest();
            String response = GroupRegistrationCtrl.bulkRegister(registrationDetails);
            Test.stopTest();

            System.assertEquals('Success', response, 'Failed to register learners in CCE Tailored Category.');
        }
    }

    @isTest
    static void getAvailableSeatTest(){
        createRecord(RT_ACTIVITY_ID);
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<hed__Course_Offering__c> offerings = [SELECT Id From hed__Course_Offering__c WITH SECURITY_ENFORCED LIMIT 1];
            Test.startTest();
            Integer availableSeats = GroupRegistrationCtrl.getAvailableSeat(offerings[0].Id);
            Test.stopTest();
            System.assert(availableSeats!=null, 'Available Seats must not be null');
        }
    }

    @isTest
    static void getMobileLocaleOptions(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<GroupRegistrationHelper.MobileLocaleWrapper> mobileLocaleOptions = GroupRegistrationCtrl.getMobileLocaleOptions();
            Test.stopTest();
            System.assert(mobileLocaleOptions!=null, 'Mobile Locale Options must not be null');
        }
    } 

    private static List<Contact> createContactList(Integer numberOfRecords){
        List<Contact> contactList = TestDataFactory.createTestContactRecords(numberOfRecords);
        Integer counter = 0;
        for(Contact con : contactList){
            con.Email = counter + 'learner@mailinator.com';
            con.Registered_Email__c = counter + 'learner@mailinator.com';
            con.Birthdate = Date.newInstance(1991, 2, 17);
            con.ContactMobile_Locale__c = 'Australia (+61)';
            con.Mobile_No_Locale__c = '12345678';
            con.Accessibility_Requirement__c = 'test';
            con.Dietary_Requirement__c = 'test';
            counter = counter + 1;
        }
        if(Schema.sObjectType.Contact.isCreateable()){
            insert contactList;
        }
        
        return contactList;
    }
    
    private static void createRecord(String productRequestRecordType){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            BuyerGroup bg = new BuyerGroup();
            bg.Name = 'OPE BuyerGroup';
            insert bg;
            
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account account : accounts){
                 account.RecordTypeId = ACCT_UNIV_DEP_ID;
                 account.Organization_Unit_Level__c = '2';
             }
            insert accounts;

            Account act = new Account(Name = 'QUT Experience');
            insert act;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                 productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
            insert courses;

            Pricebook2 priceBook;
            pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
            update pricebook;

            Product2 product = new Product2(Name = courses[0].Name, Course__c = courses[0].Id);
            insert product;

            PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, IsActive = true, Pricebook2Id = priceBook.Id, UnitPrice = 250.00);
            insert pbe;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
            insert terms;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
            insert courseOfferings;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(1);
            for(hed__Program_Plan__c program : programPlans){
                program.Product_Request__c = productRequests[0].Id;
                program.hed__Account__c = accounts[0].Id;
            }
            insert programPlans;

            Product2 productForProgram = new Product2(Name = programPlans[0].Name, Program_Plan__c = programPlans[0].Id);
            insert productForProgram;

            List<Program_Offering__c> programOffs = TestDataFactory.createTestProgramOfferingRecords(1, programPlans);
            insert programOffs;

            List<hed__Course__c> childCourses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
            insert childCourses;

            List<hed__Course_Offering__c> childCourseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, childCourses, terms);
            for(hed__Course_Offering__c childCourseOffering : childCourseOfferings){
                childCourseOffering.Program_Offering__c = programOffs[0].Id;
            }
            insert childCourseOfferings;
        }
    } 

    private static void createCCERecord(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
            insert testWebStore;

            ProductCatalog prodCatalog = new ProductCatalog(Name = 'CCE Catalog');
            insert prodCatalog;

            ProductCategory prodCategCB = new ProductCategory(
            Name = CCE_CATEGORY_CB,
            CatalogId = prodCatalog.Id
            );
            insert prodCategCB;

            Account account = new Account();
            account.Name = 'Test Business Org Account';
            account.RecordTypeId = BUSINESS_ACC_RECTYPEID;
            insert account;

            List<Account> offeringAccount = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : offeringAccount){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert offeringAccount;

            Contact contact = new Contact();
            contact.FirstName = 'Test Partner User Contact';
            contact.LastName = 'Test Lname';
            contact.email = 'testcorporateuser@email.com';
            contact.Work_Email__c = 'workemail@email.com';
            contact.hed__Preferred_Email__c = 'Alternate Email';
            contact.hed__AlternateEmail__c = 'test@email.com';
            contact.Registered_Email__c = 'workemail@email.com';
            contact.AccountId = account.Id;

            Test.startTest();
            insert contact;
            Test.stopTest();
            
            List<AccountContactRelation> acrList = new List<AccountContactRelation>([
                SELECT ContactId 
                FROM AccountContactRelation 
                WHERE AccountId =: account.Id WITH SECURITY_ENFORCED
                LIMIT 1
            ]);
            if(acrList.isEmpty()){
                AccountContactRelation acr = new AccountContactRelation(
                        ContactId = contact.Id,
                        AccountId = account.Id
                );

                insert acr;
            }

            List<Contact> conList = new List<Contact>();
            conList.add(contact);

            List<Opportunity> opp = TestDataFactory.createTestOpportunityRecords(1,account.Id,contact.Id);
            for(Opportunity o : opp){
                o.StageName = 'Closed Won';
                o.Status__c = 'Contract Signed';
                o.CloseDate = Date.today();
                o.Program_Name__c = 'CCE Product Specs';
            }
            insert opp;

            Pricebook2 priceBook;
            pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
            update pricebook;            

            List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();   

            List<Product_Request__c> cbRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c pr : cbRequest){
                pr.RecordTypeId = PR_CORPBUNDLE_RECTYPEID;        
            }
            insert cbRequest;
            
            List<Asset> assetInsert = new List<Asset>();
            assetInsert.add(new Asset(
                Name='Corporate Bundle',
                AccountId = account.Id,
                Product_Request__c = cbRequest[0].Id
            ));
            insert assetInsert;
            
            List<BuyerGroup> bgToInsertList = new List<BuyerGroup>();
            bgToInsertList.add(new BuyerGroup(
                Name = 'Corporate Bundle - ' + account.Name,
                Product_Request__c = cbRequest[0].Id
            ));
            insert bgToInsertList;

            List<Product_Request__c> courseRequest = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c pr : courseRequest){
                pr.RecordTypeId = ACTIVITY_ID;        
            }
            insert courseRequest;

            List<hed__Course__c> courses = new List<hed__Course__c>();
            for(Product_Request__c prC: courseRequest){
            courses.addAll(TestDataFactory.createTestCourseRecords(1,offeringAccount[0].Id,prC.Id));
            }

            for(hed__Course__c c: courses){
            c.RecordTypeId = ACTIVITY_COURSE_ID;
            }
            insert courses;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, offeringAccount[0].Id);

            insert terms;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
            insert courseOfferings;

            Pricebook2 corpPriceBook = [
                SELECT Id
                FROM Pricebook2
                WHERE Name Like 'Corporate%' WITH SECURITY_ENFORCED
            ];

            Product2 productToInsert = new Product2(
                IsActive = true,
                Name = 'Test Asset Product'
            );
            insert productToInsert;

            List<PricebookEntry> pbEToInsert = new List<PricebookEntry>();
            pbEToInsert.add(new PricebookEntry(Pricebook2Id = priceBook.Id, UnitPrice = 12, Product2Id = productToInsert.Id));
            pbEToInsert.add(new PricebookEntry(Pricebook2Id = corpPriceBook.Id, UnitPrice = 12, Product2Id = productToInsert.Id ));
            insert pbEToInsert;
        }

        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator){
            BuyerGroup bg = new BuyerGroup();
            bg.Name = 'OPE BuyerGroup';
            insert bg;

            Contact con = [SELECT Id,Work_Email__c,LastName,FirstName FROM Contact WHERE Work_Email__c =: 'workemail@email.com' WITH SECURITY_ENFORCED Limit 1];
            CCECorporateUserCtrl.enablePortalUser(con.Id, 'Corporate Portal');
        }
    }
}