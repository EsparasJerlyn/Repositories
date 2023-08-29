/**
 * @description Test Class for Update Product Code Flow
 *
 * @see ../flows/Update Max Score for Parent Lead Scoring Configuration

 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | julie.jane.alegre         | August 29, 2023       | DEPP-6315    | Created file                                |
      |                           |                       |              |                                             |
      |                           |                       |              |                                             |
*/
@isTest
public class UpdateLeadScoringConfigurationFlowTest {
    
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void updateMaxScoreOnParentConfigurationTest() {
        System.runAs(TestDataFactory.getProgramAdminUser()){
            
        }
    }
}
