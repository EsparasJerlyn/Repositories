/**
 * @description ObjectFieldService Test Class
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                          |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------|
 *    | eugene.andrew.abuan            | March 25, 2024        | DEPP-8203              | Created File                            |
 */

 @isTest

public class ObjectDataSourceTest {

    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Sys_Admin' });
    }

    @isTest
    static void getDefaultValueTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
             // Create an instance of the ObjectDataSource class
            ObjectDataSource objDataSource = new ObjectDataSource();
            
            // Call the getDefaultValue() method
            VisualEditor.DataRow defaultValue = objDataSource.getDefaultValue();
            
            // Verify that the default value is not null and has the expected values
            System.assertNotEquals(null, defaultValue, 'Default value should not be null');
            System.assertEquals('1', defaultValue.getValue(),'Data Row Value should be 1');
            System.assertEquals('1', defaultValue.getLabel(), 'Data Row Label should be 1');
        }
        Test.stopTest();
       
    }
    
    @isTest
    static void getValuesTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getPortalSysAdminUser()) {
            // Create an instance of the ObjectDataSource class
            ObjectDataSource objDataSource = new ObjectDataSource();
                    
            // Call the getValues() method
            VisualEditor.DynamicPickListRows pickListRows = objDataSource.getValues();

            // Verify that the picklist rows are not null and contain the expected values
            System.assertNotEquals(null, pickListRows, 'Picklist Values should not be null');
            System.assertEquals(true, pickListRows.containsAllRows(),'All rows should have a value');
            
            // Check the values of each picklist row
            System.assertEquals('1', pickListRows.get(0).getValue(),'Data Row Value should be 1');
            System.assertEquals('1', pickListRows.get(0).getLabel(),'Data Row Label should be 1');
            System.assertEquals('2', pickListRows.get(1).getValue(),'Data Row Value should be 2');
            System.assertEquals('2', pickListRows.get(1).getLabel(),'Data Row Label should be 2');
        }
        Test.stopTest();
       
    }
}