/**
 * @description Test Class for LeadScoreDetailWithoutSharingServiceTest
 * @see ..LeadScoreDetailWithoutSharingService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | roy.nino.s.regala              | Feb 5, 2023           | DEPP-7742              | Created file                                   |
 */

 @isTest
 @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
 //PMD ApexUnitTestClassShouldHaveRunAs is bypassed for service class methods 
 //because these methods are reusable, test method is mocked, and user access tests are performed on the caller
 public without sharing class LeadScoreDetailWithoutSharingServiceTest {

   @isTest
   public static void updateContactRecordsWithoutSharingTest(){
      ImplementationSelector.DAO.setMock(new ContactsDAOMock());
      List<Contact> contactList = TestDataFactory.createTestContactRecords(1);
      ContactsDAO.newInstance().insertRecords(contactList, false, AccessLevel.USER_MODE);
      contactList[0].FirstName = 'updated';
      System.assertEquals(true, LeadScoreDetailWithoutSharingService.updateContactRecordsWithoutSharing(contactList)[0].isSuccess(),'Contact was not updated successfuly');
   }

 }