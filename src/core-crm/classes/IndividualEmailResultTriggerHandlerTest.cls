/**
 * @description Test Class for Lead Scoring
 * @see ..
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------|------------------------------|
      | w.li                     | June 15, 2022         | DEPP-1058              | Created file                 |
 */

@IsTest(SeeAllData=false)
public without sharing class IndividualEmailResultTriggerHandlerTest {

    @IsTest
    public static void testInsertIER() {
        Test.startTest();
        et4ae5__SendDefinition__c sendDefinition = new et4ae5__SendDefinition__c();
        insert sendDefinition;

        et4ae5__IndividualEmailResult__c individualEmailResult = new et4ae5__IndividualEmailResult__c();
        individualEmailResult.Name = 'Test';
        individualEmailResult.et4ae5__SendDefinition__c = sendDefinition.Id;
        insert individualEmailResult;
        Test.stopTest();
    }

    @IsTest
    public static void testUpdateIER() {
        et4ae5__SendDefinition__c sendDefinition = new et4ae5__SendDefinition__c();
        insert sendDefinition;

        et4ae5__IndividualEmailResult__c individualEmailResult = new et4ae5__IndividualEmailResult__c();
        individualEmailResult.Name = 'Test';
        individualEmailResult.et4ae5__SendDefinition__c = sendDefinition.Id;
        insert individualEmailResult;

        Test.startTest();
		List<et4ae5__IndividualEmailResult__c> IER = [SELECT Id FROM et4ae5__IndividualEmailResult__c];
        update IER;
        Test.stopTest();
    }
 }