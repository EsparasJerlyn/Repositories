/**
 * @description Test Class for Expression of Interest Inactive
 *
 * @see ../flows/Expression_of_Interest_Inactive
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | February 04, 2022     | DEPP-213     | Created file                                |
      | justine.javier@qut.edu.au | February 25, 2022     | DEPP-1819    | Removed Program_Offering__c logic           |                                             |
      |                           |                       |              |                                             |
*/
@IsTest(SeeAllData = false)
private class Expression_of_Interest_Inactive_FlowTest{

    @isTest
    private static void setToInactiveTest()
    {

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

            List<Account> accounts;
            List<hed__Term__c> terms;
            List<Product_Request__c> prodRequest;
            List<hed__Course_Offering__c> courseOfferings;
            List<hed__Course__c> courses;
            List<hed__Program_Plan__c> programPlans;
            List<Program_Offering__c> programOfferings;
            List<Product2> products;
            List<Expression_of_Interest__c> interests;
            List<hed__Course_Enrollment__c> courseConnections;
            Pricebook2 priceBook;
            PricebookEntry priceBookEntry;


            accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;
            terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
            insert terms;
            prodRequest = TestDataFactory.createTestProductRequestRecords(1);
            insert prodRequest;
            courses = TestDataFactory.createTestCourseRecords(25,accounts[0].Id,prodRequest[0].Id);
            insert courses;
            programPlans = TestDataFactory.createTestProgramPlanRecords(25);
            insert programPlans;
            programOfferings = TestDataFactory.createTestProgramOfferingRecords(25, programPlans);
            insert programOfferings;
            products = TestDataFactory.createTestProductRecords(25,courses);
            for (Integer i = 0; i < products.size(); i++) {
                products[i].Program_Plan__c = programPlans[i].Id;
            }
            insert products;
            pricebook = new Pricebook2(isActive = true, id = Test.getStandardPricebookId());
            update pricebook;
            priceBookEntry = new PricebookEntry(pricebook2id = pricebook.Id, UnitPrice = 12, product2Id = products[0].Id, isActive = true);
            insert priceBookEntry;
            courseOfferings = TestDataFactory.createTestCourseOfferingRecord(25,courses,terms);
            insert courseOfferings;
            interests = TestDataFactory.createExpressionOfInterest(25,contact1,products);
            insert interests;

            Test.startTest();
            courseConnections = TestDataFactory.createTestCourseConnectionRecord(25,portalUser.contactId,courseofferings);
            for(hed__Course_Enrollment__c cc: courseConnections){
                cc.hed__Status__c = 'Current';
            }
            insert courseConnections;
            System.assertEquals(true,![SELECT Id from Expression_of_interest__c].isEmpty(),'Expression of interest status was not set to inactive');
            Test.stopTest();
        }


    }
}