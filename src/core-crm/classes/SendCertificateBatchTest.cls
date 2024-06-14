/**
 * @description Test Class for SendCertificateBatchTest
 * @see ../class/SendCertificateBatch
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
public with sharing class SendCertificateBatchTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static string studentRT = System.Label.RT_CourseConnection_Student;
    private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
    private static string facultyRT = System.Label.RT_CourseConnection_Faculty;
    private static String rtProdRequestActivity = System.Label.RT_ProductRequest_Activity;
    private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
    private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();
    private static Id opeActProdReqRecType = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(rtProdRequestActivity).getRecordTypeId();
    private static Integer numberOfRecords = 100;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
	private static final String EMAIL_TEMPLATE = 'Certificate of Participation';
    private static final String COVER_TEMPLATE = 'Send Certificate';

    @testSetup
    static void makeData(){
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<EmailTemplate> templates = TestDataFactory.createTestEmailTemplateRecords(2,new Map<String,String>{
                EMAIL_TEMPLATE => 'Test Email Subject',
                COVER_TEMPLATE => 'Send Certificate'});
            insert templates;
        }
    }
    
    @isTest
    static void sendEmailCourseTest(){
        System.runAs(currentUser){
            Test.startTest();
            Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
            insert studyStore;
            createCourseRecord(opeActProdReqRecType);
            String offeringId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, false);
            String result = ManageCertificateSectionCtrl.sendEmail(certificateDetails);
            Test.stopTest();
            System.assertEquals('Success', result, result);
        }
    }

    @isTest
    static void sendEmailProgramTest(){
        System.runAs(currentUser){
            Test.startTest();
            Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
            insert studyStore;
            createProgramRecord();
            String offeringId = [SELECT Id FROM Program_Offering__c LIMIT 1].Id;
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, true);
            String result = ManageCertificateSectionCtrl.sendEmail(certificateDetails);
            Test.stopTest();
            System.assertEquals('Success', result, result);
        }
    }

    private static void createProgramRecord(){
        System.runAs(currentUser){
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
                contacts[i].Registered_Email__c = 'testIdeaFormUser'+i+'@mailinator.com';
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
        System.runAs(currentUser){
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
            insert courses;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
            insert terms;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
            courseOfferings[0].hed__End_Date__c = date.today() + 2;
            insert courseOfferings;

            offeringId = courseOfferings[0].Id;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(numberOfRecords);
            for(Integer i =0;i<contacts.size();i++){
                contacts[i].Registered_Email__c = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert contacts;

            List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
            for(Contact contact : contacts){
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

            Questionnaire__c questionnaire = new Questionnaire__c();
            questionnaire.Questionnaire_Type__c = 'Registration Questions';
            questionnaire.Parent_Record_ID__c = productRequests[0].Id;
            insert questionnaire;

            List<Questionnaire_Response_Summary__c> questionnaireResponseList = new List<Questionnaire_Response_Summary__c>();
            for(Contact contact : contacts){
                Questionnaire_Response_Summary__c questionResp = new Questionnaire_Response_Summary__c();
                questionResp.Contact__c = contact.Id;
                questionResp.Registration_Status__c = 'Confirmed';
                questionResp.Questionnaire__c =  questionnaire.Id;
                questionResp.Course_Offering__c = offeringId;
                questionnaireResponseList.add(questionResp);
            }
            insert questionnaireResponseList;

            Related_Answer__c mewRelatedAnswer = new Related_Answer__c(Questionnaire__c = questionnaire.Id);
            insert mewRelatedAnswer;
        }
    }
}