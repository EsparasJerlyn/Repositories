/**
 * @description Test Class for ManageCertificateSectionCtrl
 * @see ../class/ManageCertificateSectionCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | April 06, 2022        | DEPP-1560            | Created file                 |
      | roy.nino.s.regala         | May 02, 2022          | DEPP-1478            |                              | 
 */
@isTest
public with sharing class ManageCertificateSectionCtrlTest {
    private static final string STUDENT_RT = System.Label.RT_CourseConnection_Student;
    private static final Id STUDENT_RT_ID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(STUDENT_RT).getRecordTypeId();
    private static final String RT_ACTIVITY = System.Label.RT_ProductRequest_Activity;    
    private static final Id RT_ACTIVITY_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_ACTIVITY).getRecordTypeId();
    private static final String RT_PROG_PLAN = System.Label.RT_ProductRequest_Program;    
    private static final Id RT_PROG_PLAN_ID = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(RT_PROG_PLAN).getRecordTypeId();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    private static Integer numberOfRecords = 100;
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
    static void getRegDetailsForNonProgPlanTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            createRecord(RT_ACTIVITY_ID);
            String offeringId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
            Test.startTest();
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, false);
            Test.stopTest();
            System.assertEquals(numberOfRecords, certificateDetails.size(), 'Incorrect number of records retrieved.');
        }
    }

    @isTest
    static void getRegDetailsForProgPlanTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            createRecord(RT_PROG_PLAN_ID);
            String offeringId = [SELECT Id FROM Program_Offering__c LIMIT 1].Id;
            Test.startTest();
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, true);
            Test.stopTest();
            System.assertEquals(numberOfRecords, certificateDetails.size(), 'Incorrect number of records retrieved.');
        }
    }

    @isTest
    static void sendEmailTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
            insert studyStore;
            createRecord(RT_ACTIVITY_ID);
            String offeringId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
            Test.startTest();
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, false);
            String result = ManageCertificateSectionCtrl.sendEmail(certificateDetails);
            Test.stopTest();
            System.assertEquals('Success', result, result);
        }
    }

    @isTest
    static void previewPDFTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            createRecord(RT_ACTIVITY_ID);
            String offeringId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
            Test.startTest();
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, false);
            Id result = ManageCertificateSectionCtrl.previewPdf(certificateDetails);
            Test.stopTest();
            System.assert(result!=null, 'Unable to retrieve content document ID.');
        }
    }

    @isTest
    static void updateCourseConnDetailsTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            createRecord(RT_ACTIVITY_ID);
            String offeringId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, false);
            for(ManageCertificateSectionCtrl.ManageCertificateDetails certificateDetail : certificateDetails){
                certificateDetail.marks = 90;
            }
            Test.startTest();
            String updateReponse = ManageCertificateSectionCtrl.updateCourseConnDetails(certificateDetails, '');
            Test.stopTest();
            System.assertEquals('Success', updateReponse, 'Update of record failed.');
        }
    }

    private static void createRecord(String productRequestRecordType){
        System.runAs(TestDataFactory.getProgramAdminUser()){
            Id offeringId = null;

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account acc : accounts){
                acc.RecordTypeId = ACCT_UNIV_DEP_ID;
                acc.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(numberOfRecords);
            for(Integer i =0;i<contacts.size();i++){
                contacts[i].Registered_Email__c = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert contacts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;

            List<Program_Offering__c> programOfferings = new List<Program_Offering__c>();
            if(productRequestRecordType == RT_PROG_PLAN_ID){
                List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(1);
                programPlans[0].Certificate_Type__c = EMAIL_TEMPLATE;
                insert programPlans;
    
                programOfferings = TestDataFactory.createTestProgramOfferingRecords(1, programPlans);
                programOfferings[0].Start_Date__c = date.today();
                programOfferings[0].End_Date__c = date.today() + 1;
                insert programOfferings;
    
                List<hed__Course__c> childCourses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
                for(hed__Course__c course : childCourses){
                    course.Certificate_Type__c = EMAIL_TEMPLATE;
                }
                insert childCourses;
    
                List<hed__Term__c> pterms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
                insert pterms;
    
                List<hed__Course_Offering__c> childOfferings = TestDataFactory.createTestCourseOfferingRecord(1, childCourses, pterms);
                childOfferings[0].hed__End_Date__c = date.today() + 2;
                childOfferings[0].Program_Offering__c = programOfferings[0].Id;
                insert childOfferings;
            }

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(1, accounts[0].Id, productRequests[0].Id);
            for(hed__Course__c course : courses){
                course.Certificate_Type__c = EMAIL_TEMPLATE;
            }
            insert courses;

            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(1, accounts[0].Id);
            insert terms;

            List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(1, courses, terms);
            courseOfferings[0].hed__End_Date__c = date.today() + 2;
            insert courseOfferings;

            offeringId = courseOfferings[0].Id;            

            List<hed__Course_Enrollment__c> students = new List<hed__Course_Enrollment__c>();
            for(Contact contact : contacts){
                hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();
                student.hed__Contact__c = contact.Id;
                student.RecordTypeId = STUDENT_RT_ID;
                student.Paid_in_Full__c = 'Yes';
                student.hed__Status__c = 'Active';
                if(productRequestRecordType == RT_PROG_PLAN_ID){
                    student.Program_Offering__c = programOfferings[0].Id;
                }else{
                    student.hed__Course_Offering__c = offeringId;
                }   
                student.Marks__c = 80;
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
                if(productRequestRecordType == RT_PROG_PLAN_ID){
                    questionResp.Program_Offering__c = programOfferings[0].Id;
                }else{
                    questionResp.Course_Offering__c = offeringId;
                }                
                questionnaireResponseList.add(questionResp);
            }
            insert questionnaireResponseList;

            Related_Answer__c mewRelatedAnswer = new Related_Answer__c(Questionnaire__c = questionnaire.Id);
            insert mewRelatedAnswer;
        }
    }
}
