/**
 * @description UserInfoService testclass
 * @see ../class/UserInfoService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | roy.nino.s.regala              | June 14, 2023         | DEPP-5391              | Created file                   |
 */
@isTest
private class UserInfoServiceTest {

    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserIndustryPartnershipManager();
    }

    @isTest
    private static void getCurrentUserNavigationTypeTest() {
        
        System.runAs(TestDataFactoryUser.selectUserIndustryPartnershipManager) {
            Test.startTest();
            System.assert(UserInfoService.getCurrentUserNavigationType() != null, 'Was not able to get user navigation type');
            Test.stopTest();
        }
    }
}
