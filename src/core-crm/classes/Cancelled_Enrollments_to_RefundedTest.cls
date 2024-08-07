/**
 * @description Cancelled_Enrollments_to_Refunded flow Test Class
 * @see Cancelled_Enrollments_to_Refunded flow 
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------|
      | roy.nino.s.regala              | Nov 15, 2022          | DEPP-4721              | Created file                               |
      | arsenio.jr.dayrit              | Dec 20, 2022          | DEPP-4995              | Updated methods                            |
      | kenneth.f.alsay                | June 21, 2024         | DEPP-9221              | Updated OPE Catalogue to QUT Experience    |

 */
@isTest
public  class Cancelled_Enrollments_to_RefundedTest {
 
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
    }

    @isTest
    private static void cancellRegistrationTestRefunded() {
        
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
                student.Paid_in_Full__c = 'Yes';
                student.Payment_Method__c = 'Invoice';
                student.hed__Course_Offering__c = offeringId;
                student.Amount__c = 123;
                students.add(student);
            }
            insert students;
    

            Test.startTest();

                for(hed__Course_Enrollment__c student: students){
                    student.hed__Status__c = 'Cancelled';
                }

                update students;

                System.assert(![SELECT Id, Paid_in_Full__c FROM hed__Course_Enrollment__c WHERE Paid_in_Full__c = 'Refunded'].isEmpty(),'enrolments not updated');
                
            Test.stopTest();
        }
    }

    @isTest
    private static void cancellRegistrationTestNotPaid() {
        
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
    

            Test.startTest();

                for(hed__Course_Enrollment__c student: students){
                    student.hed__Status__c = 'Cancelled';
                }

                update students;

                System.assert(![SELECT Id, Paid_in_Full__c FROM hed__Course_Enrollment__c WHERE Paid_in_Full__c = 'No'].isEmpty(),'enrolments not updated');
                
            Test.stopTest();
        }
    }
}