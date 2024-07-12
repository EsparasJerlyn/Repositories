/**
 * @description Test class for ELCContactParser
 * @ELCContactParser
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | May 2, 2024           | DEPP-7528              | Created file                 |
 */
@isTest
public with sharing class ELCContactParserTest {
    
    @TestSetup
    static void setupMethod(){
        TestDataFactoryUser.generateUserQUTESB();
    }

    @isTest
    static void parseContactCriteriaTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
            engagementListCriteria.Citizenship_Status__c = ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL;

            ELCContactParser parser = new ELCContactParser(engagementListCriteria, Date.today());
            Test.stopTest();

            System.assertEquals(parser.getContactCriteria().getCitizenshipStatus(), ContactsDAO.CITIZENSHIP_STATUS_INTERNATIONAL, 'Incorrect Citizenship Status.');
            System.assertEquals(parser.getContactCriteria().getRecordType(), ContactsDAO.PERSON_RECORDTYPE, 'Record type of contact must be Person.');
            System.assert(parser.getContactCriteria().getIsQUTStudent(), 'Is QUT Student must be true');

        }
    }

    @isTest
    static void parseNoContactCriteriaTest() {
        System.runAs(TestDataFactoryUser.selectUserQUTESB) {

            Test.startTest();
            ELCContactParser parser = new ELCContactParser(new Engagement_List_Criteria__c(), Date.today());
            Test.stopTest();

            System.assertEquals(parser.getContactCriteria().getRecordType(), ContactsDAO.PERSON_RECORDTYPE, 'Record type of contact must be Person.');
            System.assert(parser.getContactCriteria().getIsQUTStudent(), 'Is QUT Student must be true');

        }
    }
}