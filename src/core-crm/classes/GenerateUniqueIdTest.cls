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

@isTest
public with sharing class GenerateUniqueIdTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }


    @isTest
    static void getUUIDTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            String externalId = GenerateUniqueId.getUUID();
            System.assert(externalId !=null ,  'External Id is empty');
        }
        Test.stopTest();

    }
}
