/**
 * @description Test Class for Stewardship Update - Custom Validation flow
 *
 * @see ../flows/Stewardship Update - Custom Validation
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary         |
      |---------------------------|-----------------------|--------------|------------------------|
      | nicole.genon    	      | March 6, 2024         | DEPP-7922    | Created file           |
*/
@isTest
public with sharing class StewardshipUpdateCustomValidationTest {
    @testSetup
    static void makeData(){
        TestDataFactory.generateTestUsers(new List<String>{'QUT_Advancement_Manager'});
    }
}