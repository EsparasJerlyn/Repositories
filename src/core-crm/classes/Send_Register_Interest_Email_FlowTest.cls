/**
 * @description Test Class for Send Register Interest Email
 *
 * @see ../flows/Send_Register_Interest_Email
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | February 04, 2022     | DEPP-213     | Created file                                |
      |                           |                       |              |                                             | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class Send_Register_Interest_Email_FlowTest{

    @isTest
    private static void sendEmailTest()
    {   
        Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
        insert customEmail;
        
        User portalAccountOwner1 = TestDataFactory.createUserRecords(1,'System Administrator').iterator().next();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        portalAccountOwner1.UserRoleId = portalRole.Id;
        Database.insert(portalAccountOwner1);

        System.runAs ( portalAccountOwner1 ) {

            //Create account
            Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = portalAccountOwner1.Id
            );
            Database.insert(portalAccount1);
            
            //Create contact
            Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);
            
            //Create user
            User portalUser = TestDataFactory.createPortalUserRecords(1,'Corporate Partner User',contact1.Id).iterator().next();
            Database.insert(portalUser);

            Test.startTest();

            List<Product2> products = new List<Product2>();
            List<Expression_of_Interest__c> interests = new List<Expression_of_Interest__c>();

            products = TestDataFactory.createTestProductRecords(25);
            interests = TestDataFactory.createExpressionOfInterest(25,contact1,products);
            insert interests;
            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
            Test.stopTest();
        }
    }
}
