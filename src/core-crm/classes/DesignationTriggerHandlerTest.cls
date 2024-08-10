/**
 * @description Test class for DesignationTriggerHandler.cls
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 20, 2023        | DEPP-8200              | Created file                 |
      | eugene.andrew.abuan            | April 17, 2024        | DEPP-8340              | Added Designation Endowment  |

 */

@isTest
public with sharing class DesignationTriggerHandlerTest {
	@testSetup
    static void setup() {
        TestDataFactoryUser.generateUserAdvancementManager();
        Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
        designationCodeAutoNum.Giving_To_Cause__c = 1;
        designationCodeAutoNum.Endowment__c = 1;

        DesignationCodeAutoNumbersDAO.newInstance().upsertRecords(
            new List<Designation_Code_Auto_Number__c>{designationCodeAutoNum}, 
            false, 
            AccessLevel.USER_MODE
            );
    }
    
    @isTest
    private static void createDesignationCodeGivingToCauseTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
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


    @isTest
    private static void createDesignationCodeEndowmentTest() {
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager) {
            Test.startTest();
            List<Designation__c> designationList = TestDataFactory.createDesignationRecords(100, DesignationsDAO.ENDOWNMENT_RECTYPE_ID);
            for(Designation__c d : designationList){
                d.Endowment_Account_Type__c = DesignationsDAO.ENDOWMENT_ACCOUNT_TYPE_PERPETUAL;
            }
            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);

            Designation_Code_Auto_Number__c designationCodeAutoNum = DesignationCodeAutoNumbersDAO.newInstance().getOrganizationalDefaults();
            Test.stopTest();

            Integer count = 1;

            for (Designation__c dc : DesignationsDAO.newInstance().getDesignationsBySetRecordIds(
                        (new Map<Id, Designation__c>(designationList)).keySet(),AccessLevel.USER_MODE)
            ) {
                System.assert(String.isNotBlank(dc.Designation_Code__c), 'Blank ADVEDW code on record.');
                System.assertEquals('ADVEDW:' + String.valueOf(count).leftPad(5, '0'), dc.Designation_Code__c,'Incorrect ADVEDW Code');
                count++;
            }
            System.assertEquals(101, designationCodeAutoNum.Endowment__c, 'Incorrect latest ADVEDW code auto-number value.');

        }
    }
}
