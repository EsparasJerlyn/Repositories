@isTest
public with sharing class MapProductEndDatetoCourseProgramPlanTest {
    private static final Id RT_PS_OPE = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('OPE').getRecordTypeId();
    private static final Id RT_PS_CCE = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get('CCE').getRecordTypeId();
    private static final Id RT_ACC_BUSINESSORG = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId();
    private static final Id RT_ACC_UNIVDEPT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
	@testSetup
    static void setup() {
        // Generate test users.
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        // Create accounts.
        List<Account> accList = new List<Account>();
        // > Test Account [0]
        accList.add(new Account(
        	Name = 'Test Account',
            RecordTypeId = RT_ACC_BUSINESSORG,
            Company_Category__c = 'Corporate'
        ));
        // > Owning Faculty Account [1]
        accList.add(new Account(
        	Name = 'Owning Faculty',
            RecordTypeId = RT_ACC_UNIVDEPT,
            Organization_Unit_Level__c = '2'
        ));
        insert accList;
        // Create contacts.
        Contact con = new Contact(
        	LastName = 'Test'
        );
        insert con;
        // Setup an OPE Product Specification.
        Product_Specification__c psOPE = new Product_Specification__c(
        	RecordTypeId = RT_PS_OPE,
            Requestor_Name__c = con.Id,
            Status__c = 'Design',
            Stage__c = 'Design',
            Requestor_Internal_External__c = 'Internal',
            Existing_Product__c = 'No',
            Financial_Viability__c = 'No',
            Market_Need__c = 'No',
            QUTeX_Capacity__c = 'No',
            QUT_Faculty_Capacity__c = 'No',
            Supporting_Comments__c = 'Lorem Ipsum Dolor Sit Amet.',
            Product_Type__c = 'Program;Module;Short Course;Activity',
            Requires_Director_Endorsement__c = 'Not Required'
        );
        insert psOPE;
        // Setup a CCE Product Specification.
        Opportunity opp = new Opportunity(
        	Name = 'Test Account-',
            StageName = 'Closed Won',
            Status__c = 'Contract Signed',
            Program_Name__c = 'Test Opportunity',
            Description = 'Test opportunity description.',
            Type = 'CCE Corporate Partner',
            CloseDate = System.today()
        );
        insert opp;
        // After an opportunity is inserted, a CCE Product Specification is automatically made.
        // Retrieve the generated CCE Product Specification
        Product_Specification__c psCCE = [SELECT Id FROM Product_Specification__c WHERE RecordType.DeveloperName = 'CCE' LIMIT 1];
        // Set up Product Requests for each specification.
		List<Product_Request__c> prList = new List<Product_Request__c>();
        // > PR OPE [0]
		prList.add(TestDataFactory.createTestProductRequestRecords(1, psOPE.Id)[0]);
        // > PR CCE [1]
        prList.add(TestDataFactory.createTestProductRequestRecords(1, psCCE.Id)[0]);
        insert prList;
        // Create Course record or Program Plan record for either one.
        hed__Course__c crs = TestDataFactory.createTestCourseRecords(1, accList[1].Id, prList[0].Id)[0];
        crs.End_Date__c = System.today() + 30;
        crs.Mark_Design_Stage_as_Complete__c = true; // A product2 record will be automatically created
        hed__Program_Plan__c prp = TestDataFactory.createTestProgramPlanRecords(1)[0];
        prp.hed__End_Date__c = System.today() + 30;
        prp.Product_Request__c = prList[1].Id;
        prp.Mark_Design_Stage_as_Complete__c = true; // A product2 record will be automatically created
        insert crs;
        insert prp;
    }
    
    // With the auto-generation of various records within the setup,
    // this test method is to validate that the setup was successful.
    @isTest
    static void validateSetup() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<Product_Specification__c> psList = [SELECT Id FROM Product_Specification__c];
            List<Product_Request__c> prList = [SELECT Id FROM Product_Request__c];
            List<Product2> ptList = [SELECT Id FROM Product2];
            Test.stopTest();
            System.assert(psList.size() == 2, 'The size of the Product Specifications list is ' + psList.size());
            System.assert(prList.size() == 2, 'The size of the Product Requests list is ' + prList.size());
            System.assert(ptList.size() == 2, 'The size of the Products list is ' + ptList.size());
        }
    }
    
    @isTest
    static void changeProductEndDates() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Product2> ptList = [SELECT Id, End_Date__c, Program_Plan__c, Course__c FROM Product2];
            Id ppId;
            Id crId;
            Test.startTest();
            for(Product2 pt : ptList) {
                pt.End_Date__c = System.today() + 30;
                if(pt.Program_Plan__c != null) 
                    ppId = pt.Program_Plan__c;
                else 
                    crId = pt.Course__c;
            }
            System.assert(
                [SELECT Id, End_Date__c FROM hed__Course__c WHERE Id=:crId LIMIT 1].End_Date__c == System.today() + 30, 
                'The end date on the Design tab was not changed.');
            System.assert(
                [SELECT Id, hed__End_Date__c FROM hed__Program_Plan__c WHERE Id=:ppId LIMIT 1].hed__End_Date__c == System.today() + 30,
                'The end date on the Design tab was not changed.');
        }
    }
}