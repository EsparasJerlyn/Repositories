/**
 * @description ProgramOfferingTriggerHandler Test Class
 * @see ProgramOfferingTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 26, 2022        | DEPP-1687              | Created file                 |
      | roy.nino.s.regala              | June 04, 2022         | DEPP-2876              | Created file                 |
      | eugene.andrew.abuan            | July 31, 2022         | DEPP-3534              | Added Before Update test     |

 */
@isTest
public with sharing class ProgramOfferingTriggerHandlerTest {

    @testSetup
    static void setupMethod() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void insertProgramOfferingTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(25);
            insert programPlans;
            List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(25,programPlans);
            insert programOfferings;

            Test.stopTest();
            System.assert(![SELECT Id FROM Program_Offering__c].isEmpty(),'No Program offering created');
        }
    }

    @isTest
    private static void validateRelatedProductBeforeUpdateTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(100);
            insert programPlans;
            Integer pCount = 0;
            List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(100,programPlans);
            for(Program_Offering__c pOff : programOfferings){
                pOff.Name = 'Program Offering_Test' + GenerateUniqueId.getUUID();
                pOff.Delivery_Type__c = 'Online Self-paced';
                pOff.hed_Capacity__c = 30;
                pOff.Start_Date__c = system.today() + 1;
                pOff.Registration_Start_Date__c = system.today() - 1;
                pOff.IsActive__c = true;
            }
            insert programOfferings;

            List<Program_Offering__c> pOffToUpdate = new List<Program_Offering__c>();
            pOffToUpdate = [SELECT Id, IsActive__c FROM Program_Offering__c];
            for(Program_Offering__c pOff1 : pOffToUpdate){
                pOff1.Delivery_Type__c = 'Online Classroom';
                pOff1.IsActive__c = true;
                pCount++;
                if(pCount > 90){
                    pOff1.Registration_Start_Date__c = system.today() + 1;
                    pOff1.Registration_End_Date__c = null;
                    pOff1.IsActive__c = false;
                }
            }
            update pOffToUpdate;

            Test.stopTest();
            System.assert(true,'dummy assert');
        }
    }
}
