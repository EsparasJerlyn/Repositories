/**
 * @description test class for productrequestdao
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file                 |
 */
@isTest
private class ProductRequestsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    static void getProductRequestsBySetNamesTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            List<Product_Request__c> productRequestList = ProductRequestsDAO.newInstance()
                .getProductRequestsBySetNames(new Set<String>());
            System.assert(productRequestList.isEmpty(), 'productRequestList is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator) {
            System.assert(
                new ProductRequestsDAO().getSObjectType() == Product_Request__c.SObjectType,
                'SObject is not Product_Request__c'
            );
        }
        Test.stopTest();
    }
}
