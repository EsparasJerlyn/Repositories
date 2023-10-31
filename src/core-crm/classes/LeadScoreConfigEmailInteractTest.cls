/**
 * @description Test class for LeadScoreConfigEmailInteract
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 26, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
@isTest
public with sharing class LeadScoreConfigEmailInteractTest {
    @isTest
    private static void leadScoreConfigEmailInteractTest() {//NOPMD test class for getter setter, user not needed

        LeadScoreConfigEmailInteract data = new LeadScoreConfigEmailInteract();

        data.setHasClickedEmail(10);

        System.assertEquals(10, data.getHasClickedEmail(), 'value did not match');
    }
}
