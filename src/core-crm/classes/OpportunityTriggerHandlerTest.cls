/**
 * @description Test class for OpportunityTriggerHandler.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 22, 2023          | DEPP-5594              | created file
 */
@isTest
public with sharing class OpportunityTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
        Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
            .getOrganizationalDefaults();
        opptyCodeAutoNum.Commercialisation__c = 1;
        opptyCodeAutoNum.International_Projects_Unit__c = 1;
        opptyCodeAutoNum.Research_Partnership__c = 1;
        OpportunityCodeAutoNumbersDAO.newInstance()
            .upsertRecords(
                new List<Opportunity_Code_Auto_Number__c>{ opptyCodeAutoNum },
                false,
                AccessLevel.USER_MODE
            );
    }

    /**
     * TEST START: CodeGeneratorService.generateOpportunityOpportuntityCode()
     * Various test cases of differing record types and record counts per transaction
     */
    @isTest
    private static void createRCORecord() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunitiesDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestOpportunityRecords(
                        1,
                        'Commercialisation Sample',
                        OpportunitiesDAO.COMMERCIALIZATION_RECTYPE_ID
                    ),
                    false,
                    AccessLevel.USER_MODE
                );
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
                .getOrganizationalDefaults();
            Test.stopTest();
            Opportunity opptyFinal = OpportunitiesDAO.newInstance()
                .getRecordsSortByOpportunityCodeAsc()[0];
            System.assert(
                String.isNotBlank(opptyFinal.Opportunity_Code__c),
                'Blank RCO code on record.'
            );
            System.assertEquals(
                'RCO:00001',
                opptyFinal.Opportunity_Code__c,
                'Incorrect RCO code on record.'
            );
            System.assertEquals(
                2.0,
                opptyCodeAutoNum.Commercialisation__c,
                'Incorrect latest RCO code auto-number value.'
            );
        }
    }

    @isTest
    private static void createRCORecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunitiesDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestOpportunityRecords(
                        100,
                        'Commercialisation Sample',
                        OpportunitiesDAO.COMMERCIALIZATION_RECTYPE_ID
                    ),
                    false,
                    AccessLevel.USER_MODE
                );
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
                .getOrganizationalDefaults();
            Test.stopTest();
            List<Opportunity> opptiesFinal = OpportunitiesDAO.newInstance()
                .getRecordsSortByOpportunityCodeAsc();
            Integer counter = 1;
            for (Opportunity opptyFinal : opptiesFinal) {
                System.assert(
                    String.isNotBlank(opptyFinal.Opportunity_Code__c),
                    'Blank RCO code on record #' + counter + '.'
                );
                System.assertEquals(
                    'RCO:' + String.valueOf(counter).leftPad(5, '0'),
                    opptyFinal.Opportunity_Code__c,
                    'Incorrect RCO code on record #' + counter + '.'
                );
                counter++;
            }
            System.assertEquals(
                101.0,
                opptyCodeAutoNum.Commercialisation__c,
                'Incorrect latest RCO code auto-number value.'
            );
        }
    }

    @isTest
    private static void createINPORecord() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunitiesDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestOpportunityRecords(
                        1,
                        'Commercialisation Sample',
                        OpportunitiesDAO.INTERNATIONALPROJECTSUNIT_RECTYPE_ID
                    ),
                    false,
                    AccessLevel.USER_MODE
                );
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
                .getOrganizationalDefaults();
            Test.stopTest();
            Opportunity opptyFinal = OpportunitiesDAO.newInstance()
                .getRecordsSortByOpportunityCodeAsc()[0];
            System.assert(
                String.isNotBlank(opptyFinal.Opportunity_Code__c),
                'Blank INPO code on record.'
            );
            System.assertEquals(
                'INPO:00001',
                opptyFinal.Opportunity_Code__c,
                'Incorrect INPO code on record.'
            );
            System.assertEquals(
                2.0,
                opptyCodeAutoNum.International_Projects_Unit__c,
                'Incorrect latest INPO code auto-number value.'
            );
        }
    }

    @isTest
    private static void createINPORecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunitiesDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestOpportunityRecords(
                        100,
                        'Commercialisation Sample',
                        OpportunitiesDAO.INTERNATIONALPROJECTSUNIT_RECTYPE_ID
                    ),
                    false,
                    AccessLevel.USER_MODE
                );
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
                .getOrganizationalDefaults();
            Test.stopTest();
            List<Opportunity> opptiesFinal = OpportunitiesDAO.newInstance()
                .getRecordsSortByOpportunityCodeAsc();
            Integer counter = 1;
            for (Opportunity opptyFinal : opptiesFinal) {
                System.assert(
                    String.isNotBlank(opptyFinal.Opportunity_Code__c),
                    'Blank INPO code on record #' + counter + '.'
                );
                System.assertEquals(
                    'INPO:' + String.valueOf(counter).leftPad(5, '0'),
                    opptyFinal.Opportunity_Code__c,
                    'Incorrect INPO code on record #' + counter + '.'
                );
                counter++;
            }
            System.assertEquals(
                101.0,
                opptyCodeAutoNum.International_Projects_Unit__c,
                'Incorrect latest INPO code auto-number value.'
            );
        }
    }

    @isTest
    private static void createRPORecord() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunitiesDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestOpportunityRecords(
                        1,
                        'Commercialisation Sample',
                        OpportunitiesDAO.RESEARCHPARTNERSHIP_RECTYPE_ID
                    ),
                    false,
                    AccessLevel.USER_MODE
                );
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
                .getOrganizationalDefaults();
            Test.stopTest();
            Opportunity opptyFinal = OpportunitiesDAO.newInstance()
                .getRecordsSortByOpportunityCodeAsc()[0];
            System.assert(
                String.isNotBlank(opptyFinal.Opportunity_Code__c),
                'Blank RPO code on record.'
            );
            System.assertEquals(
                'RPO:00001',
                opptyFinal.Opportunity_Code__c,
                'Incorrect RPO code on record.'
            );
            System.assertEquals(
                2.0,
                opptyCodeAutoNum.Research_Partnership__c,
                'Incorrect latest RPO code auto-number value.'
            );
        }
    }

    @isTest
    private static void createRPORecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunitiesDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestOpportunityRecords(
                        100,
                        'Commercialisation Sample',
                        OpportunitiesDAO.RESEARCHPARTNERSHIP_RECTYPE_ID
                    ),
                    false,
                    AccessLevel.USER_MODE
                );
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
                .getOrganizationalDefaults();
            Test.stopTest();
            List<Opportunity> opptiesFinal = OpportunitiesDAO.newInstance()
                .getRecordsSortByOpportunityCodeAsc();
            Integer counter = 1;
            for (Opportunity opptyFinal : opptiesFinal) {
                System.assert(
                    String.isNotBlank(opptyFinal.Opportunity_Code__c),
                    'Blank RPO code on record #' + counter + '.'
                );
                System.assertEquals(
                    'RPO:' + String.valueOf(counter).leftPad(5, '0'),
                    opptyFinal.Opportunity_Code__c,
                    'Incorrect RPO code on record #' + counter + '.'
                );
                counter++;
            }
            System.assertEquals(
                101.0,
                opptyCodeAutoNum.Research_Partnership__c,
                'Incorrect latest RPO code auto-number value.'
            );
        }
    }

    @isTest
    private static void testAfterUpdate() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            OpportunitiesDAO.newInstance()
                .insertRecords(
                    TestDataFactory.createTestOpportunityRecords(
                        1,
                        'Commercialisation Sample',
                        OpportunitiesDAO.RESEARCHPARTNERSHIP_RECTYPE_ID
                    ),
                    false,
                    AccessLevel.USER_MODE
                );

            List<Opportunity> opptiesFinal = OpportunitiesDAO.newInstance()
                .getRecordsSortByOpportunityCodeAsc();
            for (Opportunity opptyFinal : opptiesFinal) {
                opptyFinal.Name = 'TestUpdate';
            }

            Test.stopTest();
            System.assert(
                OpportunitiesDAO.newInstance()
                        .updateRecords(opptiesFinal, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Opportunity is not updated'
            );
        }
    }

    @isTest
    private static void createComboRecords() {
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Opportunity> oppties = new List<Opportunity>();
            oppties.addAll(
                TestDataFactory.createTestOpportunityRecords(
                    30,
                    'RCO - ',
                    OpportunitiesDAO.COMMERCIALIZATION_RECTYPE_ID
                )
            );
            oppties.addAll(
                TestDataFactory.createTestOpportunityRecords(
                    35,
                    'INPO - ',
                    OpportunitiesDAO.INTERNATIONALPROJECTSUNIT_RECTYPE_ID
                )
            );
            oppties.addAll(
                TestDataFactory.createTestOpportunityRecords(
                    40,
                    'RPO - ',
                    OpportunitiesDAO.RESEARCHPARTNERSHIP_RECTYPE_ID
                )
            );
            // Randomizing the list would make this test more interesting.
            Test.startTest();
            OpportunitiesDAO.newInstance().insertRecords(oppties, false, AccessLevel.USER_MODE);
            Opportunity_Code_Auto_Number__c opptyCodeAutoNum = OpportunityCodeAutoNumbersDAO.newInstance()
                .getOrganizationalDefaults();
            Test.stopTest();
            List<Opportunity> opptiesRCOFinal = OpportunitiesDAO.newInstance()
                .getRecordsWithLikeOpportunityCodeSortAsc('RCO:_____');
            List<Opportunity> opptiesINPOFinal = OpportunitiesDAO.newInstance()
                .getRecordsWithLikeOpportunityCodeSortAsc('INPO:_____');
            List<Opportunity> opptiesRPOFinal = OpportunitiesDAO.newInstance()
                .getRecordsWithLikeOpportunityCodeSortAsc('RPO:_____');
            Integer counter = 1;
            for (Opportunity opptyRCOFinal : opptiesRCOFinal) {
                System.assert(
                    String.isNotBlank(opptyRCOFinal.Opportunity_Code__c),
                    'Blank RCO code on RCO record #' + counter + '.'
                );
                System.assertEquals(
                    'RCO:' + String.valueOf(counter).leftPad(5, '0'),
                    opptyRCOFinal.Opportunity_Code__c,
                    'Incorrect RCO code on RCO record #' + counter + '.'
                );
                counter++;
            }
            counter = 1;
            for (Opportunity opptyINPOFinal : opptiesINPOFinal) {
                System.assert(
                    String.isNotBlank(opptyINPOFinal.Opportunity_Code__c),
                    'Blank INPO code on INPO record #' + counter + '.'
                );
                System.assertEquals(
                    'INPO:' + String.valueOf(counter).leftPad(5, '0'),
                    opptyINPOFinal.Opportunity_Code__c,
                    'Incorrect INPO code on INPO record #' + counter + '.'
                );
                counter++;
            }
            counter = 1;
            for (Opportunity opptyRPOFinal : opptiesRPOFinal) {
                System.assert(
                    String.isNotBlank(opptyRPOFinal.Opportunity_Code__c),
                    'Blank RPO code on RPO record #' + counter + '.'
                );
                System.assertEquals(
                    'RPO:' + String.valueOf(counter).leftPad(5, '0'),
                    opptyRPOFinal.Opportunity_Code__c,
                    'Incorrect RPO code on RPO record #' + counter + '.'
                );
                counter++;
            }
            System.assertEquals(
                31,
                opptyCodeAutoNum.Commercialisation__c,
                'Incorrect latest RCO code auto-number value.'
            );
            System.assertEquals(
                36,
                opptyCodeAutoNum.International_Projects_Unit__c,
                'Incorrect latest INPO code auto-number value.'
            );
            System.assertEquals(
                41,
                opptyCodeAutoNum.Research_Partnership__c,
                'Incorrect latest RPO code auto-number value.'
            );
        }
    }
    /**
     * TEST STOP: CodeGeneratorService.generateOpportunityCodeForOpportunityRecords()
     */
}
