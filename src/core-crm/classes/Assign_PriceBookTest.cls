/**
* @description Test Class for Assign PriceBook flow
*
* @see ../flows/Assign_PriceBook
*
* @author Accenture
*
* @history
*    | Developer                 | Date                  | JIRA         | Change Summary                              |
|---------------------------|-----------------------|--------------|---------------------------------------------|
| angelika.j.s.galang       | November 3, 2021      | DEPP-733     | Created file                                |
|                           |                       |              |                                             |
*/
@IsTest(SeeAllData = false)
private class Assign_PriceBookTest {

    private static final String STR_PB_NAME = 'Custom Corporate Products & Services';

    @testSetup static void setupMethod() {
        Pricebook2 priceBook = new Pricebook2(Name=STR_PB_NAME,IsActive=true);
        insert priceBook;

        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        insert acc;

        List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
        contacts[0].email = 'testContact@testmail.com';
        insert contacts;
    }

    @IsTest
    private static void assignPricebookToOpportunityTest(){

        Account acc = [SELECT Id From Account LIMIT 1];
        Contact con = [SELECT Id From Contact LIMIT 1];
        Id cceRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('QUTex CCE').getRecordTypeId();
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(100,acc?.Id,con?.Id);
        for(Opportunity oppty : oppList){
            oppty.recordTypeId = cceRecTypeId;
        }

        Test.startTest();
        insert(oppList);
        Test.stopTest();

        List<Opportunity> insertedOppList = [SELECT Pricebook2.Name FROM Opportunity LIMIT 100];
        for(Opportunity opp : insertedOppList){
            System.assertEquals(STR_PB_NAME, opp.Pricebook2.Name,'Pricebook was not assigned as expected');
        }
    }
}