/**
 * @description Test Class for StewardshipTriggerHandler. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | May 17, 2024          | DEPP-8789              | Created file                 |
 */
@isTest
public with sharing class StewardshipTriggerHandlerTest {
    @testSetup
    static void setup() {
        TestDataFactoryUser.generateUserDonorEngagementManager();
    }
    
    @isTest
    private static void testPlatformEventInsertAndUpdate() {
        System.runAs(TestDataFactoryUser.selectUserDonorEngagementManager) {
            List<Stewardship__c> stewardshipList = TestDataFactory.createStewardshipRecords(StewardshipsDAO.INDIVIDUAL_STEWARDSHIP_RECTYPE_ID,1);
            
            Test.startTest();
            System.assert(
                StewardshipsDAO.newInstance()
                    .insertRecords(stewardshipList, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Stewardship is not created'
            );
            
            stewardshipList[0].Objective__c = 'test update title';
            
            System.assert(
                StewardshipsDAO.newInstance()
                    .updateRecords(stewardshipList, false, AccessLevel.USER_MODE)[0]
                    .isSuccess(),
                'Stewardship is not updated'
            );
            Test.stopTest();
        }
    }
}