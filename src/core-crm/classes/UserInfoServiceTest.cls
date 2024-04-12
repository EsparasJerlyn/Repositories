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
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_IE_Partnership_Manager' });
    }

    @isTest
    private static void getCurrentUserNavigationTypeTest() {
        
        System.runAs(TestDataFactory.getQUTIEPartnershipManager()) {
            Test.startTest();
            System.assert(UserInfoService.getCurrentUserNavigationType() != null, 'Was not able to get user navigation type');
            Test.stopTest();
        }
    }
}
