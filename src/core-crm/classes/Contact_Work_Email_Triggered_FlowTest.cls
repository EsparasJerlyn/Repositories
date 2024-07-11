/**
 * @description Test Class for Contact_Work_Email_Triggered_Flow
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | Adam Best                      | June 15, 2022         | DEPP-3067              | Created file                 |

 */
@isTest
public with sharing class Contact_Work_Email_Triggered_FlowTest {

    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0]
            .Contact_Image__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            insert contacts;
        }
    }

    @isTest
    private static void insertContact() {
        List<Contact> cons = TestDataFactory.createTestContactRecords(1);

        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            cons[0].FirstName = 'Contact FN 4';
            cons[0].LastName = 'Contact LN 4';
            cons[0].Email = 'test@email.com';
            cons[0].Work_Email__c = 'test_work@email.com';
            cons[0].QUT_Staff_Email__c = 'test_staff@email.com';
            cons[0].QUT_Learner_Email__c = 'test_learner@email.com';
            cons[0].hed__Preferred_Email__c = 'Alternate Email';
            cons[0].hed__AlternateEmail__c = 'test@email.com';
            insert cons;
            Test.stopTest();
        }

        System.assertEquals(
                1,
                [Select Id from Contact WHERE Work_Email__c = 'test_work@email.com'].size(),
                'Contact was not inserted'
            );
    }

}