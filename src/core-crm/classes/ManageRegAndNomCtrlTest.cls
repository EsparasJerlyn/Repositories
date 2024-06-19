/**
 * @description Test Class for ManageRegAndNomCtrl
 * @see ../classes/ManageRegAndNomCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | September 07, 2022    | DEPP-3747            | Created file to .            |
      | julie.jane.alegre         | October 05, 2023      | DEPP-4762            | Update test method           |
      |                           |                       |                      |                              |
*/

@isTest
public with sharing class ManageRegAndNomCtrlTest {

    private static final String CATEGORY_CCE = 'Corporate Portal';
    private final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    private static final String ACCT_BUSINESS_ORG = System.Label.RT_Account_Business_Org;
    private static final Id ACCT_BUSINESS_ORG_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_BUSINESS_ORG).getRecordTypeId();
    
    private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
    private static final Id STUDENT_RT_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(STUDENT_RT).getRecordTypeId();
    private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
    
    private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
    private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RT_CONTACT_PERSON).getRecordTypeId();

    private static Id cceProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    
    private static final Integer NUMBER_OF_RECORDS = 100;

    @testSetup
    static void makeData(){
        BypassTriggers__c bypass = new BypassTriggers__c(Bypass__c = true, SetupOwnerId = UserInfo.getOrganizationId());
        insert bypass;
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
        createRecord();
        
    }

    @isTest
    static void getNominationStatusValuesTest(){  
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){               
            Test.startTest();
            List<String> nominationStatusValues = ManageRegAndNomCtrl.getNominationStatusValues();
            Test.stopTest();
            System.assert(!nominationStatusValues.isEmpty(), 'Nomination Status Values must not be empty.');
        }
    }

    @isTest
    static void updateRegistrationOrNominationStatusTest(){  
        BypassTriggers__c bypass = [SELECT Id, Bypass__c FROM BypassTriggers__c WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH SECURITY_ENFORCED LIMIT 1];
        bypass.Bypass__c = false;
        update bypass;
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){     
            Id businessOrgAcctId = [SELECT Id FROM Account WHERE Name = 'Business Org Account' WITH SECURITY_ENFORCED].Id;
            Test.startTest();
            List<Expression_of_Interest__c> expOfInterestList = [SELECT Id, Name, Pricebook_Entry_ID__c, First_Name__c, Program_Offering__c, Course_Offering__c, Last_Name__c, Email__c, Position__c, Company_Name__c, Birthdate__c,Accessibility_Requirement__c, Dietary_Requirement__c,Mobile__c, Mobile_Locale__c FROM Expression_of_Interest__c WITH SECURITY_ENFORCED];
            ManageRegAndNomCtrl.StudentDetails details = new ManageRegAndNomCtrl.StudentDetails();
            details.id = expOfInterestList[0].Id;
            details.registrationStatus = 'Approved';
            details.isRegistrations = false;
            details.contactInfo = expOfInterestList[0];
            details.mobileNumber = '61412345678';
            details.businessOrgAccount = String.valueOf(businessOrgAcctId);
            ManageRegAndNomCtrl.RegistrationNominationUpdateResponse response = ManageRegAndNomCtrl.updateRegistrationOrNominationStatus(details);
            Test.stopTest();
            System.assert(response.isSuccess, 'Failed to Update Nomination status.');
        }
    }

    @isTest
    static void updateExistingContactNominationStatusTest(){  
        BypassTriggers__c bypass = [SELECT Id, Bypass__c FROM BypassTriggers__c WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH SECURITY_ENFORCED LIMIT 1];
        bypass.Bypass__c = false;
        update bypass;
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){    
            List<hed__Course_Offering__c> cList = [SELECT Id, hed__Course__c FROM hed__Course_Offering__c WITH SECURITY_ENFORCED];
            Expression_of_Interest__c eoi = new Expression_of_Interest__c();
            eoi.First_Name__c = 'Contact';
            eoi.Last_Name__c = 'Record';
            eoi.Birthdate__c = Date.newInstance(1991, 2, 17);
            eoi.Email__c = 'con@rec1.com';
            eoi.Status__c = 'Pending';
            eoi.Course_Offering__c = cList[0].Id;
            insert eoi;
            Id businessOrgAcctId = [SELECT Id FROM Account WHERE Name = 'Business Org Account' WITH SECURITY_ENFORCED].Id;
            ManageRegAndNomCtrl.StudentDetails details = new ManageRegAndNomCtrl.StudentDetails();
            details.id = eoi.Id;
            details.registrationStatus = 'Approved';
            details.isRegistrations = false;
            details.contactInfo = eoi;
            details.mobileNumber = '61412345678';
            details.businessOrgAccount = String.valueOf(businessOrgAcctId);
            Test.startTest();
            ManageRegAndNomCtrl.RegistrationNominationUpdateResponse response = ManageRegAndNomCtrl.updateRegistrationOrNominationStatus(details);
            Test.stopTest();
            System.assert(response.isSuccess, 'Failed to Update Nomination status.');
        }
    }

    @isTest
    static void updateStatusWithExceptionTest(){  
        BypassTriggers__c bypass = [SELECT Id, Bypass__c FROM BypassTriggers__c WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH SECURITY_ENFORCED LIMIT 1];
        bypass.Bypass__c = false;
        update bypass;
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){    
            Test.startTest();
            Id businessOrgAcctId = [SELECT Id FROM Account WHERE Name = 'Business Org Account' WITH SECURITY_ENFORCED].Id;
            List<Expression_of_Interest__c> expOfInterestList = [SELECT Id, Name, Pricebook_Entry_ID__c, First_Name__c, Program_Offering__c, Course_Offering__c, Last_Name__c, Email__c, Birthdate__c,Accessibility_Requirement__c, Dietary_Requirement__c,Mobile__c, Mobile_Locale__c FROM Expression_of_Interest__c WITH SECURITY_ENFORCED];
            ManageRegAndNomCtrl.StudentDetails details = new ManageRegAndNomCtrl.StudentDetails();
            details.id = expOfInterestList[0].Id;
            details.registrationStatus = 'InvalidStatus';
            details.isRegistrations = false;
            details.contactInfo = expOfInterestList[0];
            details.mobileNumber = '61412345678';
            details.businessOrgAccount = String.valueOf(businessOrgAcctId);
            ManageRegAndNomCtrl.RegistrationNominationUpdateResponse response = ManageRegAndNomCtrl.updateRegistrationOrNominationStatus(details);
            Test.stopTest();
            System.assert(!response.isSuccess, 'Should not be able to update record with invalid status.');
        }
    }

    @isTest
    static void updateNotApprovedNominationTest(){  
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){    
            Test.startTest();
            Id businessOrgAcctId = [SELECT Id FROM Account WHERE Name = 'Business Org Account' WITH SECURITY_ENFORCED].Id;
            List<Expression_of_Interest__c> expOfInterestList = [SELECT Id, Name, Pricebook_Entry_ID__c, First_Name__c, Program_Offering__c, Course_Offering__c, Last_Name__c, Email__c, Birthdate__c,Accessibility_Requirement__c, Dietary_Requirement__c,Mobile__c, Mobile_Locale__c FROM Expression_of_Interest__c WITH SECURITY_ENFORCED];
            ManageRegAndNomCtrl.StudentDetails details = new ManageRegAndNomCtrl.StudentDetails();
            details.id = expOfInterestList[0].Id;
            details.registrationStatus = 'Pending';
            details.isRegistrations = false;
            details.contactInfo = expOfInterestList[0];
            details.mobileNumber = '61412345678';
            details.businessOrgAccount = String.valueOf(businessOrgAcctId);
            ManageRegAndNomCtrl.RegistrationNominationUpdateResponse response = ManageRegAndNomCtrl.updateRegistrationOrNominationStatus(details);
            Test.stopTest();
            System.assert(response.isSuccess, 'Failed to Update Nomination status.');
        }
    } 
    
    @isTest
    static void updateExistingContactDiffDetailsTest(){  
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){    
            List<hed__Course_Offering__c> cList = [SELECT Id, hed__Course__c FROM hed__Course_Offering__c WITH SECURITY_ENFORCED];
            Expression_of_Interest__c eoi = new Expression_of_Interest__c();
            eoi.First_Name__c = 'Contact123';
            eoi.Last_Name__c = 'Record123';
            eoi.Birthdate__c = Date.newInstance(1991, 2, 17);
            eoi.Email__c = 'con@rec1.com';
            eoi.Status__c = 'Pending';
            eoi.Course_Offering__c = cList[0].Id;
            insert eoi;
            Id businessOrgAcctId = [SELECT Id FROM Account WHERE Name = 'Business Org Account' WITH SECURITY_ENFORCED].Id;
            ManageRegAndNomCtrl.StudentDetails details = new ManageRegAndNomCtrl.StudentDetails();
            details.id = eoi.Id;
            details.registrationStatus = 'Approved';
            details.isRegistrations = false;
            details.contactInfo = eoi;
            details.mobileNumber = '61412345678';
            details.businessOrgAccount = String.valueOf(businessOrgAcctId);
            Test.startTest();
            ManageRegAndNomCtrl.RegistrationNominationUpdateResponse response = ManageRegAndNomCtrl.updateRegistrationOrNominationStatus(details);
            Test.stopTest();
            System.assert(!response.isSuccess, 'Incorrect validation of contact information.');
        }
    }

    @isTest
    static void updateExistingContactDiffEmailTest(){  
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){    
            Expression_of_Interest__c eoi = new Expression_of_Interest__c();
            eoi.First_Name__c = 'Contact';
            eoi.Last_Name__c = 'Record';
            eoi.Birthdate__c = Date.newInstance(1991, 2, 17);
            eoi.Email__c = 'con@rec123.com';
            eoi.Status__c = 'Pending';
            insert eoi;
            Id businessOrgAcctId = [SELECT Id FROM Account WHERE Name = 'Business Org Account' WITH SECURITY_ENFORCED].Id;
            ManageRegAndNomCtrl.StudentDetails details = new ManageRegAndNomCtrl.StudentDetails();
            details.id = eoi.Id;
            details.registrationStatus = 'Approved';
            details.isRegistrations = false;
            details.contactInfo = eoi;
            details.mobileNumber = '61412345678';
            details.businessOrgAccount = String.valueOf(businessOrgAcctId);
            Test.startTest();
            ManageRegAndNomCtrl.RegistrationNominationUpdateResponse response = ManageRegAndNomCtrl.updateRegistrationOrNominationStatus(details);
            Test.stopTest();
            System.assert(!response.isSuccess, 'Incorrect validation of contact information.');
        }
    }
   

    @isTest
    static void updateRegistrationStatusTest(){  
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){     
            Id businessOrgAcctId = [SELECT Id FROM Account WHERE Name = 'Business Org Account' WITH SECURITY_ENFORCED].Id;
            hed__Course_Enrollment__c learner = [SELECT Id FROM hed__Course_Enrollment__c WITH SECURITY_ENFORCED LIMIT 1];
            ManageRegAndNomCtrl.StudentDetails details = new ManageRegAndNomCtrl.StudentDetails();
            details.id = learner.Id;
            details.registrationStatus = 'Active';
            details.isRegistrations = true;
            details.contactInfo = new Expression_of_Interest__c();
            details.mobileNumber = '';
            details.businessOrgAccount = String.valueOf(businessOrgAcctId);
            Test.startTest();
            ManageRegAndNomCtrl.RegistrationNominationUpdateResponse response = ManageRegAndNomCtrl.updateRegistrationOrNominationStatus(details);
            Test.stopTest();
            System.assert(response.isSuccess, 'Failed to update Registration status.');
        }
    }
    
    @isTest
    static void getRegistrationsAndNominationsTest(){
        Test.startTest();
        Contact contact = [SELECT Id, hed__Primary_Organization__c FROM Contact WHERE FirstName = 'cce contact' WITH SECURITY_ENFORCED LIMIT 1];

        BuyerGroup bg = new BuyerGroup();
        bg.Name = 'OPE BuyerGroup';
        insert bg;

        CCECorporateUserCtrl.CorporateUserDetails userDetails = CCECorporateUserCtrl.enablePortalUser(contact.Id, CATEGORY_CCE);   
        User user = [SELECT Id, Name FROM User WHERE Id =: userDetails.userId WITH SECURITY_ENFORCED LIMIT 1];

        System.runAs(user){
            ManageRegAndNomCtrl.RecordSearchParams params = new ManageRegAndNomCtrl.RecordSearchParams();
            params.isRegistrations = true;
            params.courseName = '';
            params.firstName = '';
            params.lastName = '';
            params.email = '';
            params.mobile = '';
            params.status = '';
            params.birthday = '';
        
            List<ManageRegAndNomCtrl.ManageRegistrationorNominationDetails> registrations = ManageRegAndNomCtrl.getRegistrationsAndNominations(params, contact.hed__Primary_Organization__c); 
            System.assertEquals(1, registrations.size(), 'Incorrect number of records retrieved.');
            params.isRegistrations = false;
            List<ManageRegAndNomCtrl.ManageRegistrationorNominationDetails> nominations = ManageRegAndNomCtrl.getRegistrationsAndNominations(params, contact.hed__Primary_Organization__c); 
            System.assertEquals(1, nominations.size(), 'Incorrect number of records retrieved.');
        }
        Test.stopTest();
    }

    @isTest
    static void formatDateTest(){
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){    
            Test.startTest(); 
            String formattedDateString = ManageRegAndNomCtrl.formatDate(Date.newInstance(1990, 2, 17));
            Test.stopTest();
            System.assert(formattedDateString != '', 'Invalid Date Format');
        }
    }

    @isTest
    static void validateRegistrationEndDate(){  
        BypassTriggers__c bypass = [SELECT Id, Bypass__c FROM BypassTriggers__c WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH SECURITY_ENFORCED LIMIT 1];
        bypass.Bypass__c = false;
        update bypass;
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){     
            Id businessOrgAcctId = [SELECT Id FROM Account WHERE Name = 'Business Org Account' WITH SECURITY_ENFORCED].Id;

            List<hed__Course_Offering__c> courseOfferings = [SELECT Id, Name, hed__Course__c, IsActive__c, Program_Offering__c, Registration_End_Date__c, hed__Capacity__c FROM hed__Course_Offering__c WITH SECURITY_ENFORCED];
            List<hed__Course_Offering__c> courseOfferingsToUpdate = new List<hed__Course_Offering__c>();
            for(hed__Course_Offering__c courseOffering : courseOfferings){
                hed__Course_Offering__c courseOfferingToUpdate = new hed__Course_Offering__c();
                courseOfferingToUpdate.id = courseOffering.id;
                courseOfferingToUpdate.Registration_End_Date__c = Date.today().addDays(-1);
                courseOfferingsToUpdate.add(courseOfferingToUpdate);
            }
            update courseOfferingsToUpdate;

            Test.startTest();
            List<Expression_of_Interest__c> expOfInterestList = [SELECT Id, Name, Pricebook_Entry_ID__c, First_Name__c, Program_Offering__c, Course_Offering__c, Last_Name__c, Email__c, Birthdate__c,Accessibility_Requirement__c, Dietary_Requirement__c,Mobile__c, Mobile_Locale__c FROM Expression_of_Interest__c WITH SECURITY_ENFORCED];
            ManageRegAndNomCtrl.StudentDetails details = new ManageRegAndNomCtrl.StudentDetails();
            details.id = expOfInterestList[0].Id;
            details.registrationStatus = 'Approved';
            details.isRegistrations = false;
            details.contactInfo = expOfInterestList[0];
            details.mobileNumber = '61412345678';
            details.businessOrgAccount = String.valueOf(businessOrgAcctId);
            ManageRegAndNomCtrl.RegistrationNominationUpdateResponse response = ManageRegAndNomCtrl.updateRegistrationOrNominationStatus(details);
            Test.stopTest();
            System.assert(!response.isSuccess, 'Registration should be closed.');
        }
    }

    @isTest
    static void validateCapacity(){  
        BypassTriggers__c bypass = [SELECT Id, Bypass__c FROM BypassTriggers__c WHERE SetupOwnerId =: UserInfo.getOrganizationId() WITH SECURITY_ENFORCED LIMIT 1];
        bypass.Bypass__c = false;
        update bypass;
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){     
            Id businessOrgAcctId = [SELECT Id FROM Account WHERE Name = 'Business Org Account' WITH SECURITY_ENFORCED].Id;

            List<hed__Course_Offering__c> courseOfferings = [SELECT Id, Name, hed__Course__c, IsActive__c, Program_Offering__c, Registration_End_Date__c, hed__Capacity__c FROM hed__Course_Offering__c];
            List<hed__Course_Offering__c> courseOfferingsToUpdate = new List<hed__Course_Offering__c>();
            for(hed__Course_Offering__c courseOffering : courseOfferings){
                hed__Course_Offering__c courseOfferingToUpdate = new hed__Course_Offering__c();
                courseOfferingToUpdate.id = courseOffering.id;
                courseOfferingToUpdate.hed__Capacity__c = 2;
                courseOfferingsToUpdate.add(courseOfferingToUpdate);
            }
            update courseOfferingsToUpdate;
            
            List<hed__Course_Enrollment__c> learners = new List<hed__Course_Enrollment__c>();
            for (Integer i = 0; i < 2; i++) {
                learners.add(new hed__Course_Enrollment__c(hed__Course_Offering__c = courseOfferings[0].Id, hed__Status__c  = 'Active'));
            }
            insert learners;

            Test.startTest();
            List<Expression_of_Interest__c> expOfInterestList = [SELECT Id, Name, Pricebook_Entry_ID__c, First_Name__c, Program_Offering__c, Course_Offering__c, Last_Name__c, Email__c, Birthdate__c,Accessibility_Requirement__c, Dietary_Requirement__c,Mobile__c, Mobile_Locale__c FROM Expression_of_Interest__c WITH SECURITY_ENFORCED];
            ManageRegAndNomCtrl.StudentDetails details = new ManageRegAndNomCtrl.StudentDetails();
            details.id = expOfInterestList[0].Id;
            details.registrationStatus = 'Approved';
            details.isRegistrations = false;
            details.contactInfo = expOfInterestList[0];
            details.mobileNumber = '61412345678';
            details.businessOrgAccount = String.valueOf(businessOrgAcctId);
            ManageRegAndNomCtrl.RegistrationNominationUpdateResponse response = ManageRegAndNomCtrl.updateRegistrationOrNominationStatus(details);
            
            Test.stopTest();
            System.assert(!response.isSuccess, 'Registration already full capacity.');
        }
    }

    private static void createRecord(){
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;      
        System.runAs(PORTAL_SYS_ADMIN){ 
            Account univAccount = new Account(Name='PortalAccount', RecordTypeId = ACCT_UNIV_DEP_ID, Organization_Unit_Level__c = '2');
            Database.insert(univAccount);

            Account portalAccount = new Account(Name='Business Org Account', RecordTypeId = ACCT_BUSINESS_ORG_ID, Organization_Unit_Level__c = '2');
            Database.insert(portalAccount);

            Contact newContact = new Contact(   
            FirstName = 'cce contact', 
            LastName = 'test rec', 
            hed__Primary_Organization__c = portalAccount.Id,                
            Birthdate = Date.newInstance(1990, 2, 17), 
            MobilePhone ='0412345678', 
            ContactMobile_Locale__c = 'Australia (+61)',
            Work_Email__c = 'test@workemail.com',
            hed__Preferred_Email__c = 'Alternate Email',
            hed__AlternateEmail__c = 'testqtest@emailemail.com',
            Position__c = 'Position',
            Company_Name__c = 'Company Name'
            );
            
            insert newContact;
            List<Contact> contactList = new List<Contact>();
            contactList.add(newContact);
                   
            BuyerGroup bg = TestDataFactory.createTestBuyerGroup(true);
            TestDataFactory.createTestBuyerGroupMember(true, portalAccount.Id, bg.Id);
            CommerceEntitlementPolicy commerceEntl = new CommerceEntitlementPolicy(Name = 'Test Entitlement', CanViewProduct = true, CanViewPrice = true, IsActive = true);
            insert commerceEntl;
            CommerceEntitlementBuyerGroup commerceEntbg = new CommerceEntitlementBuyerGroup(BuyerGroupId = bg.Id, PolicyId =commerceEntl.Id);
            insert commerceEntbg;

            
            List<Opportunity> oppList = TestDataFactory.createClosedWonOpportunities(1,portalAccount.Id,newContact.Id);
            insert oppList;

            List<Product_Specification__c> prodSpecList = TestDataFactory.retrieveCCEProductSpecifications();
            
            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1,prodSpecList[0].Id);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = RT_ACTIVITY_ID;
            }
            insert productRequests;
            
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, univAccount.Id, productRequests[0].Id);
            insert courses;

            List<Product2> plist = [SELECT Id, Name, Course__c FROM Product2];

            CommerceEntitlementProduct commerceProduct = new CommerceEntitlementProduct(PolicyId = commerceEntl.Id, ProductId = plist[0].Id);
            insert commerceProduct;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, univAccount.Id);
            insert terms;
            
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
            for(hed__Course_Offering__c c : courseOfferings){
                c.Registration_End_Date__c = Date.today().addDays(5);
            }
            insert courseOfferings;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            for(Integer i =0;i<contacts.size();i++){
                contacts[i].Registered_Email__c = 'testIdeaFormUser'+i+'@maildrop.cc';
            }
            insert contacts;
            
            List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
            for(Contact contact : contacts){
                hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                student.hed__Contact__c = contact.Id;
                student.RecordTypeId = STUDENT_RT_ID;
                student.Paid_in_Full__c = 'No';
                student.Payment_Method__c = 'Invoice';
                student.hed__Course_Offering__c = courseOfferings[0].Id;
                students.add(student);
            }
            insert students;

            Expression_of_Interest__c eoi =  new Expression_of_Interest__c(
                First_Name__c = 'test con 1',
                Last_Name__c = 'rec',
                Email__c = 'testcon1@email.com',
                Position__c = 'Position',
                Company_Name__c = 'Company Name',
                Birthdate__c = Date.newInstance(1990, 2, 17),
                Mobile__c = '0412345678',
                Mobile_Locale__c = 'Australia (+61)',
                Course_Offering__c = courseOfferings[0].Id,
                Type__c = 'Nomination',
                Status__c = 'Pending',
                Account__c = portalAccount.Id
            );

            insert eoi;

            Contact contact = new Contact();
            contact.FirstName = 'Contact';
            contact.LastName = 'Record';
            contact.Email = 'cone@rec1.com'; 
            contact.Work_Email__c = 'con@rec1.com'; 
            contact.Registered_Email__c ='con@rec1.com';
            contact.hed__Preferred_Email__c = 'Alternate Email';
            contact.hed__AlternateEmail__c = 'conpref@rec1.com';
            contact.Position__c = 'Position';
            contact.Company_Name__C = 'Company Name';
            contact.Birthdate = Date.newInstance(1991, 2, 17);
            contact.MobilePhone ='0412345678';
            contact.ContactMobile_Locale__c = 'Australia (+61)';
            contact.RecordTypeId = RT_CONTACT_PERSON_ID;
            insert contact;

            WebStore testWebStore = new WebStore(Name='CCE', DefaultLanguage='en_US');
            insert testWebStore;

            Pricebook2 priceBook;
            pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
            update pricebook;
        }
    } 
}