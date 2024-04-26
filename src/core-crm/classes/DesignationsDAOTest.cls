/**
 * @description test class for DesignationsDAOTest.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | March 15, 2023      | DEPP-8210              | Created file                              |
 */
@isTest
private class DesignationsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(
            new List<String>{ 'QUT_Donor_Engagement_Manager' }
        );
    }
    @isTest
    private static void queryLocatorGetDesignationsForStageUpdateTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            System.assert(DesignationsDAO.newInstance().queryLocatorGetDesignationsForStageUpdate() != null, 'SOQL should not be null');
        }
    }

    @isTest
    private static void getDesignationsBySetRecordIdsTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            Test.startTest();
            MockIdGenerator mockIdGen = new MockIdGenerator(Designation__c.SObjectType);
            List<Designation__c> designationList = DesignationsDAO.newInstance()
                .getDesignationsBySetRecordIds(
                    new Set<Id>{mockIdGen.getMockId()},
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(designationList.isEmpty(), 'designationList should be empty.');
        }
    }

    @isTest
    private static void getDesignationsBySetRecordIdsEmptyTest(){
        System.runAs(TestDataFactory.getDonorEngagementManager()){
            Test.startTest();
            List<Designation__c> designationList = DesignationsDAO.newInstance()
                .getDesignationsBySetRecordIds(
                    new Set<Id>(),
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(designationList.isEmpty(), 'designationList should be empty.');
        }
    }
    
    @isTest
    private static void getDesignationsByNameStartTest(){
		System.runAs(TestDataFactory.getDonorEngagementManager()){
            Test.startTest();
            List<Designation__c> designationList = DesignationsDAO.newInstance()
                .getDesignationsByNameStart(
                    'Test Designation',
                    AccessLevel.USER_MODE
                );
            Test.stopTest();
            System.assert(designationList.isEmpty(), 'designationList should be empty.');
        }    
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            System.assert(DesignationsDAO.newInstance() != null, 'DesignationsDAO instance is null');
        }
        Test.stopTest();
    }
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getDonorEngagementManager()) {
            System.assert(
                new DesignationsDAO().getSObjectType() == Designation__c.SObjectType,
                'SObject is not Designation__c'
            );
        }
        Test.stopTest();
    }

}