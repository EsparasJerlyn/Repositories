@isTest
public with sharing class TimeSlotsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                new TimeSlotsDAO().getSObjectType() == TimeSlot.SObjectType,
                'SObject is not Time Slot'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getTimeSlotRecordsTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            System.assert(
                TimeSlotsDAO.newInstance().getTimeSlotRecords(
                    new List<OperatingHours>(),
                    AccessLevel.SYSTEM_MODE
                ) != null,
                'Time Slot list should not be null.'
            );
            Test.stopTest();
        }
    }
}
