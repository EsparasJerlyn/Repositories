/**
 * @description Tests Controller Class for B2BStoreSearchIndexHandler
 * @see B2BStoreSearchIndexHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | November 22, 2021     | DEPP-131               | Created file                 | 
      |                                |                       |                        |                              | 
 */
@isTest
public class B2BStoreSearchIndexHandlerTest {
    
     @testSetup static void setupMethod() {
        List<Product2> prodList = TestDataFactory.createTestInActiveProductRecords(1);
        Test.startTest();
        insert(prodList);
        Test.stopTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
    }  
    
    
    @isTest
    public static void testBuildSearchIndex() {
    final User PORTAL_SYS_ADMIN = TestDataFactoryUser.selectUserSystemAdministrator;
        System.runAs(PORTAL_SYS_ADMIN) {
            Test.startTest();
            List<Product2> productList = [SELECT Id, isActive FROM Product2 LIMIT 1];
            productList[0].isActive = TRUE;
            update productList;
            Test.stopTest();

            System.assertEquals(1, productList.size(), 'Product list did not match.');  
        }
       
    }
    
      
}