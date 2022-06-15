/**
 * @description Test Class for Lead_Alert
 * @see ..
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------|------------------------------|
      | w.li                     | June 15, 2022         | DEPP-1489              | Created file                 |
 */

@IsTest(SeeAllData=false)
public without sharing class Contact_Lead_ScoringTest {

    private static final String STR_QUTEX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTeX).iterator().next();

    @IsTest
    public static void testInternationalLeadAlert() {
        List<Contact> contacts = new List<Contact>();
        System.runAs(currentUser){
            Test.startTest();
            contacts = TestDataFactory.createTestContactRecords(1);
            insert contacts;
            Test.stopTest();
        }
    }

 }