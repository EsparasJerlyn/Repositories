/**
 * @description test class for LogEntriesDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 30, 2023        | DEPP-7984              | Created file
 */
@isTest
private class LogEntriesDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(LogEntriesDAO.newInstance() != null, 'LogEntriesDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                new LogEntriesDAO().getSObjectType() == LogEntry__c.SObjectType,
                'SObject is not LogEntry__c'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getLogEntriesByRelatedRecordIdTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
			MockIdGenerator mockIdGen = new MockIdGenerator(LogEntry__c.SObjectType);
            System.assert(
                LogEntriesDAO.newInstance()
                .getLogEntriesByRelatedRecordId(
                    new Set<Id>{mockIdGen.getMockId()}, 
                    AccessLevel.USER_MODE
                ) != null,
                'Return should not be null'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getLogEntriesByRelatedRecordIdTestEmpty(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                LogEntriesDAO.newInstance()
                .getLogEntriesByRelatedRecordId(
                    new Set<Id>(), 
                    AccessLevel.USER_MODE
                ) != null,
                'Return should not be null'
            );
        }
        Test.stopTest();
    }

	@isTest
    static void getLogEntriesByMessageTestEmpty(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                LogEntriesDAO.newInstance()
                .getLogEntriesByMessage(
                    new Set<String>(), 
                    AccessLevel.USER_MODE
                ) != null,
                'Return should not be null'
            );
        }
        Test.stopTest();
    }

	@isTest
    static void getLogEntriesByMessageTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {
            System.assert(
                LogEntriesDAO.newInstance()
                .getLogEntriesByMessage(
                    new Set<String>{'Test'}, 
                    AccessLevel.USER_MODE
                ) != null,
                'Return should not be null'
            );
        }
        Test.stopTest();
    }
    
}
