/**
 * @description Test class for EngagementTriggerHandler.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 24, 2023          | DEPP-5594              | created file
 */
@isTest
public with sharing class EngagementTriggerHandlerTest {
	@testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Partnership_Manager' });
        Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        engCodeAutoNum.Commercialisation__c = 1;
        engCodeAutoNum.Research_Partnership__c = 1;
        EngagementCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Engagement_Code_Auto_Number__c>{engCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
    }
    
    @isTest
    private static void createRCERecord() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            EngagementsDAO.newInstance().
                insertRecords(
                    TestDataFactory.createTestEngagementRecords(1, 'Commercialisation Sample', EngagementsDAO.COMMERCIALISATION_RECTYPE_ID),
                    false, 
                    AccessLevel.USER_MODE
                );
            Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            Engagement__c engFinal = EngagementsDAO.newInstance().getRecordsSortByEngagementCodeAsc()[0];
            System.assert(String.isNotBlank(engFinal.Engagement_Code__c), 'Blank RCE code on record.');
            System.assertEquals('RCE:00001', engFinal.Engagement_Code__c, 'Incorrect RCE code on record.');
            System.assertEquals(2.0, engCodeAutoNum.Commercialisation__c, 'Incorrect latest RCE code auto-number value.');
        }
    }
    
    @isTest
    private static void createRCERecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            EngagementsDAO.newInstance().
                insertRecords(
                    TestDataFactory.createTestEngagementRecords(100, 'Commercialisation Sample', EngagementsDAO.COMMERCIALISATION_RECTYPE_ID),
                    false, 
                    AccessLevel.USER_MODE
                );
            Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            List<Engagement__c> engsFinal = EngagementsDAO.newInstance().getRecordsSortByEngagementCodeAsc();
            Integer counter = 1;
            for(Engagement__c engFinal : engsFinal) {
                System.assert(String.isNotBlank(engFinal.Engagement_Code__c), 'Blank RCE code on record #' + counter + '.');
                System.assertEquals('RCE:' + String.valueOf(counter).leftPad(5, '0'), engFinal.Engagement_Code__c, 'Incorrect RCE code on record #' + counter + '.');
                counter++;
            }
            System.assertEquals(101.0, engCodeAutoNum.Commercialisation__c, 'Incorrect latest RCE code auto-number value.');
        }
    }
    
    @isTest
    private static void createRPERecord() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            EngagementsDAO.newInstance().
                insertRecords(
                    TestDataFactory.createTestEngagementRecords(1, 'Research Partnership Sample', EngagementsDAO.RESEARCHPARTNERSHIP_RECTYPE_ID),
                    false, 
                    AccessLevel.USER_MODE
                );
            Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            Engagement__c engFinal = EngagementsDAO.newInstance().getRecordsSortByEngagementCodeAsc()[0];
            System.assert(String.isNotBlank(engFinal.Engagement_Code__c), 'Blank RPE code on record.');
            System.assertEquals('RPE:00001', engFinal.Engagement_Code__c, 'Incorrect RPE code on record.');
            System.assertEquals(2.0, engCodeAutoNum.Research_Partnership__c, 'Incorrect latest RPE code auto-number value.');
        }
    }
    
    @isTest
    private static void createRPERecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            EngagementsDAO.newInstance().
                insertRecords(
                    TestDataFactory.createTestEngagementRecords(100, 'Research Partnership Sample', EngagementsDAO.RESEARCHPARTNERSHIP_RECTYPE_ID),
                    false, 
                    AccessLevel.USER_MODE
                );
            Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            List<Engagement__c> engsFinal = EngagementsDAO.newInstance().getRecordsSortByEngagementCodeAsc();
            Integer counter = 1;
            for(Engagement__c engFinal : engsFinal) {
                System.assert(String.isNotBlank(engFinal.Engagement_Code__c), 'Blank RPE code on record #' + counter + '.');
                System.assertEquals('RPE:' + String.valueOf(counter).leftPad(5, '0'), engFinal.Engagement_Code__c, 'Incorrect RPE code on record #' + counter + '.');
                counter++;
            }
            System.assertEquals(101.0, engCodeAutoNum.Research_Partnership__c, 'Incorrect latest RPE code auto-number value.');
        }
    }
    
    @isTest
    private static void createComboRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Engagement__c> engs = new List<Engagement__c>();
            engs.addAll(TestDataFactory.createTestEngagementRecords(30, 'RCE - ', EngagementsDAO.COMMERCIALISATION_RECTYPE_ID));
            engs.addAll(TestDataFactory.createTestEngagementRecords(40, 'RPE - ', EngagementsDAO.RESEARCHPARTNERSHIP_RECTYPE_ID));
            Test.startTest();
            EngagementsDAO.newInstance().insertRecords(engs, false, AccessLevel.USER_MODE);
            Engagement_Code_Auto_Number__c engCodeAutoNum = EngagementCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();
            List<Engagement__c> engsRCEFinal = EngagementsDAO.newInstance().getRecordsWithLikeEngagementCodeSortAsc('RCE:_____');
            List<Engagement__c> engsRPEFinal = EngagementsDAO.newInstance().getRecordsWithLikeEngagementCodeSortAsc('RPE:_____');
            Integer counter = 1;
            for(Engagement__c engRCEFinal : engsRCEFinal) {
                System.assert(String.isNotBlank(engRCEFinal.Engagement_Code__c), 'Blank RCE code on RCE record #' + counter + '.');
                System.assertEquals('RCE:' + String.valueOf(counter).leftPad(5, '0'), engRCEFinal.Engagement_Code__c, 'Incorrect RCE code on RCE record #' + counter + '.');
                counter++;
            }
            counter = 1;
            for(Engagement__c engRPEFinal : engsRPEFinal) {
                System.assert(String.isNotBlank(engRPEFinal.Engagement_Code__c), 'Blank RPE code on RPE record #' + counter + '.');
                System.assertEquals('RPE:' + String.valueOf(counter).leftPad(5, '0'), engRPEFinal.Engagement_Code__c, 'Incorrect RPE code on RPE record #' + counter + '.');
                counter++;
            }
            System.assertEquals(31, engCodeAutoNum.Commercialisation__c, 'Incorrect latest RCE code auto-number value.');
            System.assertEquals(41, engCodeAutoNum.Research_Partnership__c, 'Incorrect latest RPE code auto-number value.');
        }
    }
}