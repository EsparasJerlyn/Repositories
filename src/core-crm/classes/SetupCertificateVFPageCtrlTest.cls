/**
 * @description Test Class for SetupCertificateVFPageCtrlTest
 * @see ../class/SetupCertificateVFPageCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | May 02, 2022          | DEPP-1478            | CreatedFile                  |
      | alexander.cadalin         | September 07, 2022    |                      | Test Error Fixes             | 
 */
@isTest
public with sharing class SetupCertificateVFPageCtrlTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static string studentRT = System.Label.RT_CourseConnection_Student;
    private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
    private static string facultyRT = System.Label.RT_CourseConnection_Faculty;
    private static String rtProdRequestActivity = System.Label.RT_ProductRequest_Activity;
    private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
    private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();
    private static Id facultyRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(facultyRT).getRecordTypeId();
    private static Id opeActProdReqRecType = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(rtProdRequestActivity).getRecordTypeId();
    private static Integer numberOfRecords = 100;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static final String FACULTY_CONTACT_FNAME = 'test firstname faculty';
    private static final String FACULTY_CONTACT_LNAME = 'test lastname';
    @testSetup
    static void setup(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Contact facultyContact = new Contact(Salutation = 'DR', FirstName = FACULTY_CONTACT_FNAME, LastName = FACULTY_CONTACT_LNAME);
            insert facultyContact;

            hed__Course_Enrollment__c faculty = new hed__Course_Enrollment__c();
            faculty.hed__Contact__c = facultyContact.Id;
            faculty.RecordTypeId = facultyRecTypeId;
            insert faculty;
        }
        
    }

    @isTest
    static void testSetupCertificateCourse(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            createCourseRecord(opeActProdReqRecType);
            List<hed__Course_Enrollment__c> courseConnections = [SELECT Id, hed__Course_Offering__c 
                                                                FROM hed__Course_Enrollment__c 
                                                                WHERE RecordType.DeveloperName =: studentRT 
                                                                AND hed__Course_Offering__c != NULL LIMIT 1];
            PageReference pageRef = Page.CertificateOfParticipationPDFView;

            Test.setCurrentPage(pageRef);
            ApexPages.currentPage()
            .getParameters()
            .put('courseConnectionId', courseConnections[0].Id);
            SetupCertificateVFPageCtrl testCtrl = new SetupCertificateVFPageCtrl();
            System.assert(testCtrl.product !=null, 'Product is null');
            Test.stopTest();
        }
    }


    @isTest
    static void testSetupCertificateProgram(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            createProgramRecord();
            List<hed__Course_Enrollment__c> courseConnections = [SELECT Id, Program_Offering__c 
                                                                FROM hed__Course_Enrollment__c 
                                                                WHERE RecordType.DeveloperName =: studentProgramRT 
                                                                AND Program_Offering__c != NULL LIMIT 1];
            PageReference pageRef = Page.CertificateOfParticipationPDFView;

            Test.setCurrentPage(pageRef);
            ApexPages.currentPage()
            .getParameters()
            .put('courseConnectionId', courseConnections[0].Id);
            SetupCertificateVFPageCtrl testCtrl = new SetupCertificateVFPageCtrl();
            System.assert(testCtrl.product !=null, 'Product is null');
            Test.stopTest();
            
        }
    }

    private static void createProgramRecord(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Id offeringId = null;

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;
            
            List<hed__Program_Plan__c> program = TestDataFactory.createTestProgramPlanRecords(1);
            program[0].Left_Signature__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            program[0].Right_Signature__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            program[0].Partner_Logo__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            program[0].Name_Left_Indented__c = 'test';
            program[0].Name_Right_Indented__c = 'test';
            program[0].Position_Left_Indented__c = 'test';
            program[0].Position_Right_Indented__c = 'test';
            program[0].Department_Left_Indented__c = 'test';
            program[0].Department_Right_Indented__c = 'test';
            program[0].Facilitated_By__c = 'test';
            program[0].Certificate_Type__c = 'Certificate of Achievement';
            insert program;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(numberOfRecords);
            for(Integer i =0;i<contacts.size();i++){
                contacts[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert contacts;

            List<Program_Offering__c> programOffering = TestDataFactory.createTestProgramOfferingRecords(1,program);
            programOffering[0].End_Date__c = system.today() + 2;
            insert programOffering;

            offeringId = programOffering[0].Id;

            List<hed__Course_Enrollment__c> studentPrograms = new List<hed__Course_Enrollment__c>();
            for(Contact contact : contacts){
                hed__Course_Enrollment__c studentProgram = new hed__Course_Enrollment__c();
                studentProgram.hed__Contact__c = contact.Id;
                studentProgram.RecordTypeId = studentProgramRecTypeId;
                studentProgram.Paid_in_Full__c = 'Yes';
                studentProgram.Program_Offering__c = offeringId;
                studentProgram.Marks__c = 80;
                studentProgram.hed__Status__c = 'Active';
                studentPrograms.add(studentProgram);
            }
            insert studentPrograms;
        }
    }

    private static void createCourseRecord(String productRequestRecordType){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Id offeringId = null;

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;
                        
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
            courses[0].Left_Signature__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            courses[0].Right_Signature__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            courses[0].Partner_Logo__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            courses[0].Name_Left_Indented__c = 'test';
            courses[0].Name_Right_Indented__c = 'test';
            courses[0].Position_Left_Indented__c = 'test';
            courses[0].Position_Right_Indented__c = 'test';
            courses[0].Department_Left_Indented__c = 'test';
            courses[0].Department_Right_Indented__c = 'test';
            courses[0].Certificate_Type__c = 'Certificate of Achievement';
            insert courses;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
            insert terms;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(numberOfRecords);
            for(Integer i =0;i<contacts.size();i++){
                contacts[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert contacts;
                        
            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
            courseOfferings[0].hed__Start_Date__c = date.today() + 1;
            courseOfferings[0].hed__End_Date__c = date.today() + 2;
            courseOfferings[0].Primary_Facilitator__c = [SELECT Id FROM hed__Course_Enrollment__c WHERE hed__Contact__r.FirstName =: FACULTY_CONTACT_FNAME].Id;
            
            insert courseOfferings;

            offeringId = courseOfferings[0].Id;

            List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
            for(Contact contact : contacts){
                if(contact.FirstName == FACULTY_CONTACT_FNAME) { continue; }
                hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                student.hed__Contact__c = contact.Id;
                student.RecordTypeId = studentRecTypeId;
                student.Paid_in_Full__c = 'Yes';
                student.hed__Course_Offering__c = offeringId;
                student.Marks__c = 80;
                student.hed__Status__c = 'Active';
                students.add(student);
            }
            insert students;
        }
    }
    
     @isTest
     private static void getFontSizeXSmallTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
         Test.startTest();
         
		 SetupCertificateVFPageCtrl.getFontSize(122);
         
  		 Test.stopTest();
		 System.assert(TRUE, 'x-small-font'); 
        }
    }
    
     @isTest
     private static void getFontSizeSmallTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
         Test.startTest();
         
		 SetupCertificateVFPageCtrl.getFontSize(120);
         
  		 Test.stopTest();
		 System.assert(TRUE, 'small-font'); 
        }
    }
    
    @isTest
     private static void getFontSizeMediumTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
         Test.startTest();
         
		 SetupCertificateVFPageCtrl.getFontSize(32);
         
  		 Test.stopTest();
		 System.assert(TRUE, 'medium-font'); 
        }
    }
    
     @isTest
     private static void getFontSizeLargeTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
         Test.startTest();
         
		 SetupCertificateVFPageCtrl.getFontSize(30);
         
  		 Test.stopTest();
		 System.assert(TRUE, 'big-font'); 
        }
    }
}