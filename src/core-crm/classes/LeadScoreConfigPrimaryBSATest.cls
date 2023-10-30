/**
 * @description Test class for LeadScoreConfigPrimaryBSA
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | October 06, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
private class LeadScoreConfigPrimaryBSATest {
    @isTest
    private static void leadScoreConfigTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigPrimaryBSA data = new LeadScoreConfigPrimaryBSA();

        data.setIsBlank(10);
        data.setIsNotBlank(10);
        data.setIsUnsure(10);

        System.assertEquals(10, data.getIsBlank(), 'value did not match');
        System.assertEquals(10, data.getIsNotBlank(), 'value did not match');
        System.assertEquals(10, data.getIsUnsure(), 'value did not match');
    }
}
