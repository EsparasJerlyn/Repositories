/**
 * @description Test Class for Lead Scoring
 * @see ..
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                | Date                  | JIRA                   | Change Summary               |
      |--------------------------|-----------------------|------------------------|------------------------------|
      | w.li                     | June 15, 2022         | DEPP-1058              | Created file                 |
      | alexander.cadalin        | February 20, 2023     | PMD                    | ApexUnitTestClassShouldHaveAsserts
 */

@isTest
public without sharing class IndividualEmailResultTriggerHandlerTest {

    @isTest
    public static void testInsertIER() {
        Test.startTest();
        et4ae5__SendDefinition__c sendDefinition = new et4ae5__SendDefinition__c();
        insert sendDefinition;

        et4ae5__IndividualEmailResult__c individualEmailResult = new et4ae5__IndividualEmailResult__c();
        individualEmailResult.Name = 'Test';
        individualEmailResult.et4ae5__SendDefinition__c = sendDefinition.Id;
        Database.SaveResult saveResult =  Database.insert(individualEmailResult);
        Test.stopTest();
        System.assert(saveResult.isSuccess(), 'The record was not successfully inserted.');
    }

    @isTest
    public static void testUpdateIER() {
        et4ae5__SendDefinition__c sendDefinition = new et4ae5__SendDefinition__c();
        insert sendDefinition;

        et4ae5__IndividualEmailResult__c individualEmailResult = new et4ae5__IndividualEmailResult__c();
        individualEmailResult.Name = 'Test';
        individualEmailResult.et4ae5__SendDefinition__c = sendDefinition.Id;
        insert individualEmailResult;

        Test.startTest();
		List<et4ae5__IndividualEmailResult__c> IER = [SELECT Id FROM et4ae5__IndividualEmailResult__c];
        Database.SaveResult[] saveResultList = Database.update(IER);
        Test.stopTest();
        for(Database.SaveResult saveResult : saveResultList) {
            System.assert(saveResult.isSuccess(), 'A record was not successfully updated.');
        }
    }
}