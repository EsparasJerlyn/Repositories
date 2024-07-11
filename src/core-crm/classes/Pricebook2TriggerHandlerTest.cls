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
@isTest
public with sharing class Pricebook2TriggerHandlerTest {

    @testSetup
    static void setUpMethod(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    	Pricebook2 pb = new Pricebook2();
        pb.Name = 'TestPb';
        insert pb;
    }
    
    @isTest
    static void checkPbName(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            Test.startTest();
            
            Set<String> pricebooks = new Set<String>();
            Pricebook2 pbToAdd = TestDataFactory.createTestPricebook2(false);
            pricebooks.add(pbToAdd.Name);
            insert(pbToAdd);
            
            List<Pricebook2> setPricebook2Name = new List<Pricebook2>();
      
            for(Pricebook2 pbName: [Select Name from Pricebook2 Where Name IN : pricebooks]){
				setPricebook2Name.add(pbName); 
            }
            
            Pricebook2DuplicatesHelper.detectPricebook2Duplicates(pricebooks, setPricebook2Name);  
            
            List<Pricebook2> pbList = [Select Id From Pricebook2 Where Name = 'Test Pricebook2'];
                        
            Test.stopTest();
            
            System.assertEquals(1, pbList.size(), 'Pricebook with duplicate name is invalid'); 
        }

    }

}