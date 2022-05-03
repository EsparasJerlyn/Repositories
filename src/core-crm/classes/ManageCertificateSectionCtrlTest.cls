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
@isTest(SeeAllData=false)
public with sharing class ManageCertificateSectionCtrlTest {
    private static User  currentUser = TestDataFactory.createUserRecords(1,'QUTeX').iterator().next();
    private static string studentRT = System.Label.RT_CourseConnection_Student;
    private static String rtProdRequestActivity = System.Label.RT_ProductRequest_Activity;
    private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
    private static Id opeActProdReqRecType = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(rtProdRequestActivity).getRecordTypeId();
    private static Integer numberOfRecords = 100;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @IsTest
    static void getRegDetailsForNonProgPlanTest(){
        System.runAs(currentUser){
            createRecord(opeActProdReqRecType);
            String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
            String offeringId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
            Test.startTest();
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, false);
            Test.stopTest();
            System.assertEquals(numberOfRecords, certificateDetails.size(), 'Incorrect number of records retrieved.');
        }
    }

    @IsTest
    static void sendEmailTest(){
        System.runAs(currentUser){
            Study_Store_URL_Settings__c studyStore = new Study_Store_URL_Settings__c(Study_Store_Link__c = 'https://studystorelinktest.com/');
            insert studyStore;
            createRecord(opeActProdReqRecType);
            String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
            String offeringId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
            Test.startTest();
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, false);
            String result = ManageCertificateSectionCtrl.sendEmail(certificateDetails);
            Test.stopTest();
            System.assertEquals('Success', result, result);
        }
    }

    @IsTest
    static void previewPDFTest(){
        System.runAs(currentUser){
            createRecord(opeActProdReqRecType);
            String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
            String offeringId = [SELECT Id FROM hed__Course_Offering__c LIMIT 1].Id;
            Test.startTest();
            List<ManageCertificateSectionCtrl.ManageCertificateDetails> certificateDetails = ManageCertificateSectionCtrl.getCertificateDetails(offeringId, false);
            Id result = ManageCertificateSectionCtrl.previewPdf(certificateDetails);
            System.debug('ID: ' + result);
            Test.stopTest();
            System.assert(result!=null, 'Unable to retrieve content document ID.');
        }
    }

    @IsTest
    static void updateCourseConnDetailsTest(){
        System.runAs(currentUser){
            createRecord(opeActProdReqRecType);
            String prodReqId = [SELECT Id FROM Product_Request__c LIMIT 1].Id;
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
            courseOfferings[0].hed__End_Date__c = date.today();
            insert courseOfferings;

            offeringId = courseOfferings[0].Id;

            List<Contact> contacts = TestDataFactory.createTestContactRecords(numberOfRecords);
            for(Integer i =0;i<contacts.size();i++){
                contacts[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
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