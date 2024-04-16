/**
 * @description Test class for DesignationTriggerHandler.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 20, 2023        | DEPP-8200              | Created file                 |
 */
@isTest
public with sharing class DesignationTriggerHandlerTest {
	@testSetup
    static void setup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Donor_Engagement_Manager' });
        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        designationCodeAutoNum.Giving_To_Cause__c = 1;
        DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
    }
    
    @isTest
    private static void createDesignationCodeTest() {
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            Test.startTest();
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(100, DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID);

            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);

            Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();

        Integer count = 1;

            for (Designation__c dc : DesignationsDAO.newInstance().getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),AccessLevel.USER_MODE)
            ) {
                System.assert(String.isNotBlank(dc.Designation_Code__c), 'Blank ADVGC code on record.');
                System.assertEquals('ADVGC:' + String.valueOf(count).leftPad(5, '0'), dc.Designation_Code__c,'Incorrect ADVGC Code');
                count++;
            }
            System.assertEquals(101, designationCodeAutoNum.Giving_To_Cause__c, 'Incorrect latest ADVGC code auto-number value.');

        }
    }
}
