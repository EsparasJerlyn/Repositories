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
@isTest(SeeAllData=false)
public with sharing class Contact_Work_Email_Triggered_FlowTest {
    
    private static User currentUser = TestDataFactory.createUserRecords(
        1,
        'QUTeX'
      )
      .iterator()
      .next(); 

    @TestSetup
    static void testSetup() {
        System.runAs(currentUser) {
            Test.startTest();
            List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
            contacts[0]
            .Contact_Image__c = '<p><img src="https://www.w3schools.com/w3css/img_lights.jpg" alt="test.jpg"></img></p>';
            insert contacts;
        }
    }

    @isTest
    private static void insertContact() {
        User currUsr = [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'QUTeX' AND Email = 'testuser@mailinator.com'
            LIMIT 1
        ];

        List<Contact> cons = TestDataFactory.createTestContactRecords(1);

        System.runAs(currUsr) {
            Test.startTest();
            cons[0].FirstName = 'Contact FN 4';
            cons[0].LastName = 'Contact LN 4';
            cons[0].Email = 'test@email.com';
            cons[0].Work_Email__c = 'test_work@email.com';
            cons[0].QUT_Staff_Email__c = 'test_staff@email.com';
            cons[0].QUT_Learner_Email__c = 'test_learner@email.com';
            cons[0].hed__Preferred_Email__c = 'Work Email';
            cons[0].hed__WorkEmail__c = 'test_work@email.com';
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