/**
 * @description test class for ProductLedgerEndedBatch
 * @see ProductLedgerEndedBatch
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Aug 25, 2022          | DEPP-3482              | Created file                 |
      |                                |                       |                        |                              |
 */

@isTest
private class ProductLedgerEndedBatchTest{

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
    private static final Id STUDENT_RT_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(STUDENT_RT).getRecordTypeId();
    private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;
     private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();

    @testSetup 
    static void setupMethod() {

        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Id offeringId = null;
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
                productRequest.RecordTypeId = RT_ACTIVITY_ID;
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
            for(hed__Course_Offering__c courseOffering: courseOfferings){
                courseOffering.hed__Start_Date__c = System.Today() - 2;
                courseOffering.hed__End_Date__c = System.Today() - 1;
            }
            insert courseOfferings;
    
            offeringId = courseOfferings[0].Id;
    
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            for(Integer i =0;i<contacts.size();i++){
                contacts[i].Registered_Email__c = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert contacts;
    
            
            List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
            for(Contact contact : contacts){
                hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                student.hed__Contact__c = contact.Id;
                student.RecordTypeId = STUDENT_RT_ID;
                student.Paid_in_Full__c = 'No';
                student.Payment_Method__c = 'Invoice';
                student.hed__Course_Offering__c = offeringId;
                student.Amount__c = 123;
                students.add(student);
            }
            insert students;
    
            List<Product_Ledger__c> productLedgerListToInsert = new List<Product_Ledger__c>();
            Product_Ledger__c productLedger;
            Asset newAsset = new Asset(Name = 'Test Asset', AccountId = accounts[0].Id);
            insert newAsset;
            for(hed__Course_Enrollment__c student: students){
                productLedger = new Product_Ledger__c(Course_Connection__c = student.Id, Purchased_Price_v2__c = student.Amount__c, Asset__c = newAsset.Id);
                productLedgerListToInsert.add(productLedger);
            }
    
            if(!productLedgerListToInsert.isEmpty()){
                insert productLedgerListToInsert;
            }
        }
    }

    @isTest
    static void productLedgerBatchTest(){

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
    
            Test.startTest();
    
            ProductLedgerEndedBatch batch = new ProductLedgerEndedBatch();
            Database.executeBatch(batch);

            Test.stopTest();

            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'ProductLedgerEndedBatch'].isEmpty() , 'ProductLedgerEndedBatch Job was not executed');
            System.assert(![SELECT Id FROM Product_Ledger__c WHERE Offering_Ended__c = true LIMIT 1].isEmpty(), 'product ledger not updated');
        }
        
    }   
}