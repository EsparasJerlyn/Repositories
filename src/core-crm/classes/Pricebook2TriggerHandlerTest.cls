/**
 * @description Test class for Pricebook2 Trigger Handler
 * @see Pricebook2TriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kathy.cornejo                  | June 03, 2022         | DEPP-2664              | Created file                 |
 */
@IsTest(SeeAllData = false)
public with sharing class Pricebook2TriggerHandlerTest {
    
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static final String NAME = 'NAME';
    
    @TestSetUp
    static void setUpMethod(){
    	Pricebook2 pb = new Pricebook2();
        pb.Name = 'TestPb';
        insert pb;
    }
    
    @IsTest
    static void checkPbName(){
        System.runAs(currentUser) {
            Test.startTest();
            
            List<Pricebook2> pricebooks = new List<Pricebook2>();
            Pricebook2 pbToAdd = TestDataFactory.createTestPricebook2(false);
            pricebooks.add(pbToAdd);
            insert(pbToAdd);
            
            Set<String> setPricebook2Name = new Set<String>();
      
      		for(Pricebook2 pbName: [Select Name from Pricebook2])
				setPricebook2Name.add(pbName.Name); 
            
            Pricebook2DuplicatesHelper.detectPricebook2Duplicates(pricebooks, setPricebook2Name);  
            
            List<Pricebook2> pbList = [Select Id From Pricebook2 Where Name = 'Test Pricebook2'];
            system.debug('check ' + pbList.size());
            
            Test.stopTest();
            
            system.assertEquals(1, pbList.size(), 'Pricebook with duplicate name is invalid'); 
        }

    }

}