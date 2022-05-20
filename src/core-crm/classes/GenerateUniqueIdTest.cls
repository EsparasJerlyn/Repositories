/**
 * @description Test Class for GenerateUniqueId
 * @see GenerateUniqueId
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Created file                 |
      |                                |                       |                        |                              |
 */

@isTest(SeeAllData=false)
public with sharing class GenerateUniqueIdTest {
    private static final String STR_QUTEX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTEX).iterator().next();


    @IsTest
    static void getUUIDTest() {
        Test.startTest();
        System.runAs(currentUser){
            String externalId = GenerateUniqueId.getUUID();
            System.assert(externalId !=null ,  'External Id is empty');
        }
        Test.stopTest();

    }
}
