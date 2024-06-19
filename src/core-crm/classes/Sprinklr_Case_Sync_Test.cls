/**
 * @description Test class for Sprinklr Case Sync flow
 * Note that this test class if for coverage and does not effectively test functionality.
 * @see flows/Sprinklr_Case_Sync.flow-meta.xml
 * @author Accenture
 * @history
 * | Developer                    | Date         | JIRA      | Description
 * |------------------------------|--------------|-----------|---------------------------
 * | alexander.cadalin            | Sep 29, 2023 | DEPP-6769 | Created file.
 */
@isTest
public with sharing class Sprinklr_Case_Sync_Test {
    @testSetup
    static void setup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }
    
    @isTest
    static void testSprinklrCaseNotMofifiedByIntegration() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            Contact contact = TestDataFactory.createTestContact(true, null);
            List<Case> sprinklrCases = TestDataFactory.createTestSprinklrCaseRecords(10, contact.Id);
            for(Case cases : sprinklrCases){
                cases.Case_Type__c = CasesDAO.CASE_TYPE_DOMESTIC;
            }
            CasesDAO.newInstance().insertRecords(sprinklrCases, false, AccessLevel.USER_MODE);
            Test.stopTest();
            for(Case sprinklrCase : sprinklrCases) {
                System.assert(sprinklrCase.Id != null, 'A Sprinklr case was not inserted successfully.');
            }
        }
    }
}