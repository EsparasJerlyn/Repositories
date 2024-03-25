/**
 * @description Test class for DesignationTriggerHandler.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                         |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------------------------|
      | eugene.andrew.abuan            | March 20, 2023        | DEPP-8200              | Created file                                                           |
      | neil.s.h.lesidan               | March 25, 2024        | DEPP-8210              | Change method and variable naming to Designation                       |
 */
@isTest
public with sharing class DesignationTriggerHandlerTest {
	@testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Donor_Engagement_Manager' });
        Designation_Code_Auto_Number__c designationCodeAutoNum = designationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        designationCodeAutoNum.Designation__c = 1;
        designationCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
            false,
            AccessLevel.USER_MODE
            );
    }
    
    @isTest
    private static void createDesignationCodeTest() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            Test.startTest();
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(100);

            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);

            Designation_Code_Auto_Number__c designationCodeAutoNum = designationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();

            Integer count = 1;

            for (Designation__c dc : DesignationsDAO.newInstance().getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),AccessLevel.USER_MODE)
            ) {
                System.assert(String.isNotBlank(dc.Designation_Code__c), 'Blank ADVDC code on record.');
                System.assertEquals('ADVDC:' + String.valueOf(count).leftPad(5, '0'), dc.Designation_Code__c,'Incorrect ADVDC Code');
                count++;
            }
            System.assertEquals(101, designationCodeAutoNum.Designation__c, 'Incorrect latest ADVDC code auto-number value.');

        }
    }
}
