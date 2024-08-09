/**
 * @description test class for contactsdao.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | john.aldric.s.seril            | July 23, 2024       | DEPP-9834              | Created file                              |
*/
@isTest
public class OperatingHoursDAOTest {
	@testSetup
    static void testSetup() {
    TestDataFactoryUser.generateUserSystemAdministrator();
    }
    
    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            System.assert(
                new OperatingHoursDAO().getSObjectType() == OperatingHours.SObjectType,
                'SObject is not Operating Hours'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void queryLocatorGetVoiceOperatingHoursTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            System.assert(
                OperatingHoursDAO.newInstance().queryLocatorGetVoiceOperatingHours() != null,
                'Operating hours retrieved is null'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getOperatingHoursByIdAndChannelTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            Test.startTest();
            System.assert(
                OperatingHoursDAO.newInstance().getOperatingHoursByIdAndChannel(
                    new Set<Id>(),
                    OperatingHoursDAO.TYPE_VOICE,
                    AccessLevel.SYSTEM_MODE
                ) != null,
                'Operating hours list should not be null.'
            );
            Test.stopTest();
        }
    }

}