/**
 * @description Tests Helper Class for FlowLookupHelper
 * @see ../classes/FlowLookupHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | ryan.j.a.dela.cruz             | June 7, 2023          | DEPP-5385              | Created file                   |
 */
@isTest
public without sharing class FlowLookupHelperTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'Industry_Operations_Manager' });
    }

    @isTest
    public static void getNameFieldTest() {
        System.runAs(TestDataFactory.getOperationsManager()){
        String nameField = FlowLookupHelper.getNameField('Account');
        
        System.assertNotEquals(null, nameField, 'Name field should not be null');
        }
    }

    @isTest
    public static void getFieldMapTest() {
        System.runAs(TestDataFactory.getOperationsManager()){
        Map<String, Schema.SObjectField> fieldMap = FlowLookupHelper.getFieldMap('Account');
        
        System.assertNotEquals(null, fieldMap, 'Field map should not be null');
        System.assertNotEquals(0, fieldMap.size(), 'Field map should not be empty');
        }
    }

    @isTest
    public static void splitAndTrimTestNoDelimiter() {
        System.runAs(TestDataFactory.getOperationsManager()){
            String testString = 'test1,test2,test3';
            List<String> splitStrings = FlowLookupHelper.splitAndTrim(testString);
            
            System.assertEquals(3, splitStrings.size(), 'Three split strings are expected');
            System.assertEquals('test1', splitStrings[0], 'First split string should match');
            System.assertEquals('test2', splitStrings[1], 'Second split string should match');
            System.assertEquals('test3', splitStrings[2], 'Third split string should match');
        }
    }

    @isTest
    public static void splitAndTrimTestDelimiter() {
        String testString = 'test1,test2,test3';
        System.runAs(TestDataFactory.getOperationsManager()){
            List<String> splitStrings = FlowLookupHelper.splitAndTrim(testString, ',');
            
            System.assertEquals(3, splitStrings.size(), 'Three split strings are expected');
            System.assertEquals('test1', splitStrings[0], 'First split string should match');
            System.assertEquals('test2', splitStrings[1], 'Second split string should match');
            System.assertEquals('test3', splitStrings[2], 'Third split string should match');
        }
    }
}
