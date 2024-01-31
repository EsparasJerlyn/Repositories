/**
 * @description ObjectFieldService Test Class
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------|
      | roy.nino.s.regala              | Jan 11, 2024          | DEPP-7142              | Created File                                              |
 */

@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
//PMD ApexUnitTestClassShouldHaveRunAs is bypassed for service class methods 
//because user access test methods are done on the caller
public with sharing class ObjectFieldServiceTest {

    @isTest
    private static void isOneOftheFieldsUpdatedTestTrue() {
        Contact newRecord = new Contact(FirstName = 'Test1');
        Contact oldRecord = new Contact(FirstName = 'Test2');
        System.assertEquals(
            true,
            ObjectFieldService.isOneOftheFieldsUpdated(
                new Set<String>{ 'FirstName' },
                newRecord,
                oldRecord
            ),
            'result must be true since field values are different'
        );
    }

    @isTest
    private static void isOneOftheFieldsUpdatedTestFalse() {
        Contact newRecord = new Contact(FirstName = 'Test1');
        Contact oldRecord = new Contact(FirstName = 'Test1');
        System.assertEquals(
            false,
            ObjectFieldService.isOneOftheFieldsUpdated(
                new Set<String>{ 'FirstName' },
                newRecord,
                oldRecord
            ),
            'result must be false since field values are similar'
        );
    }

    @isTest
    private static void isOneOfTheFieldsNotBlankAndNotBooleanFalseTestTrue() {
        Contact newRecord = new Contact(FirstName = 'Test1');
        System.assertEquals(
            true,
            ObjectFieldService.isOneOfTheFieldsNotBlankAndNotBooleanFalse(
                new Set<String>{ 'FirstName' },
                newRecord
            ),
            'result must be true since field has a value'
        );
    }

    @isTest
    private static void isOneOfTheFieldsNotBlankAndNotBooleanFalseTestFalse() {
        Contact newRecord = new Contact(FirstName = null);
        System.assertEquals(
            false,
            ObjectFieldService.isOneOfTheFieldsNotBlankAndNotBooleanFalse(
                new Set<String>{ 'FirstName' },
                newRecord
            ),
            'result must be false since field has no value'
        );
    }
}
