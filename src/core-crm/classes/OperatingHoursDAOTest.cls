/**
 * @description test class for contactsdao.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                | JIRA                   | Change Summary                            |
 *    |--------------------------------|---------------------|------------------------|-------------------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023      | DEPP-5567              | Created file                              |
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
    
}