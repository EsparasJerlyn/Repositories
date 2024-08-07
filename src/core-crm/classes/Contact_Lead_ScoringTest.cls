/**
 * @description Test Class for Lead_Alert
 * @see ..
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                | Date                  | JIRA                   | Change Summary                     |
      |--------------------------|-----------------------|------------------------|------------------------------------|
      | w.li                     | June 15, 2022         | DEPP-1489              | Created file                       |
      | alexander.cadalin        | February 20, 2023     | PMD                    | ApexUnitTestClassShouldHaveAsserts |
 */

@isTest
public without sharing class Contact_Lead_ScoringTest {

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    public static void testInternationalLeadAlert() {
        List<Contact> contacts = new List<Contact>();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            contacts = TestDataFactory.createTestContactRecords(1);
            Database.SaveResult[] saveResultList = Database.insert(contacts);
            Test.stopTest();
            for(Database.SaveResult saveResult : saveResultList) {
            	System.assert(saveResult.isSuccess(), 'A contact record was not saved successfully.');
            }
        }
    }
 }