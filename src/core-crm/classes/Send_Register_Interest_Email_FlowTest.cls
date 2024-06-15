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
@isTest
private class Send_Register_Interest_Email_FlowTest{

    @testSetup
    static void makeData(){
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    private static void sendEmailTest()
    {   
        final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
        insert customEmail;
        
        System.runAs ( PORTAL_SYS_ADMIN ) {

            //Create account
            Account portalAccount1 = new Account(
            Name = 'TestAccount',
            OwnerId = PORTAL_SYS_ADMIN.Id
            );
            Database.insert(portalAccount1);
            
            //Create contact
            Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'test@test.com',
            Registered_Email__c = System.now().millisecond() + 'test@test.com'
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
