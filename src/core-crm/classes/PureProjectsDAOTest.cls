/**
 * @description test class for PureProjectsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                       |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------------|
 *    | ryan.j.a.dela.cruz             | July 03, 2023         | DEPP-5390              | Created file                                         |
 *    | ryan.j.a.dela.cruz             | July 19, 2023         | DEPP-5457/DEPP-5468    | Added getOpportunityPureProjectRecordsTest method    |
 */
@isTest
private class PureProjectsDAOTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            System.assert(
                PureProjectsDAO.newInstance() != null,
                'PureProjectsDAO instance should not be null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            System.assert(
                new PureProjectsDAO().getSObjectType() == Pure_Project__c.SObjectType,
                'SObject should be Pure_Project__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getOpportunityPureProjectRecordsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            List<Pure_Project__c> pureProjects = PureProjectsDAO.newInstance().getOpportunityPureProjectRecords(new Set<Id>());
            System.assert(pureProjects != null, 'Pure Projects not found');
        }
        Test.stopTest(); 
    }
}
