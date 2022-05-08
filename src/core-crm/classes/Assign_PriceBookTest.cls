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

    private static final String STR_QUTEX = 'QUTeX';
    private static final String STR_PB_NAME = 'Custom Corporate Products & Services';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTEX).iterator().next();  

    @testSetup static void setupMethod() {
        Pricebook2 priceBook = new Pricebook2(Name=STR_PB_NAME,IsActive=true);
        insert priceBook;
        
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        insert acc;
        
        Contact con = TestDataFactory.createTestContactRecords(1).iterator().next();
        insert con;
    } 

    @IsTest
    private static void assignPricebookToOpportunityTest(){
        System.runAs(currentUser){
            Account acc = [SELECT Id From Account LIMIT 1];
            Contact con = [SELECT Id From Contact LIMIT 1];
            
            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(100,acc?.Id,con?.Id);
            
            Test.startTest();
            insert(oppList);
            Test.stopTest();
			
            List<Opportunity> insertedOppList = [SELECT Pricebook2.Name FROM Opportunity LIMIT 100];
            for(Opportunity opp : insertedOppList){
                //System.assertEquals(STR_PB_NAME, opp.Pricebook2.Name,'Pricebook was not assigned as expected');
            }
        }
    }
}