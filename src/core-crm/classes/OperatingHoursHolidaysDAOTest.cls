/**
 * @description test class for OperatingHoursHolidayDAO.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | john.aldric.s.seril            | Aug 12, 2024        | DEPP-9834              | Created file                              |
*/
@isTest
public with sharing class OperatingHoursHolidaysDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                new OperatingHoursHolidaysDAO().getSObjectType() == OperatingHoursHoliday.SObjectType,
                'SObject is not Operating Hours Holidays'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getOperatingHoursHolidayRecordsTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            System.assert(
                OperatingHoursHolidaysDAO.newInstance().getOperatingHoursHolidayRecords(
                    new List<OperatingHours>(),
                    AccessLevel.SYSTEM_MODE
                ) != null,
                'Operating Hours Holiday list should not be null.'
            );
            Test.stopTest();
        }
    }
}