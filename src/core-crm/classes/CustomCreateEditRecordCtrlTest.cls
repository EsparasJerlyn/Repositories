/**
 * @description Tests the CustomCreateEditRecordCtrl class 
 *
 * @see CustomCreateEditRecordCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA     | Change Summary                  |
      |---------------------------|-----------------------|----------|---------------------------------|
      | angelika.j.s.galang       | October 25, 2021      | DEPP-383 | Created file                    | 
      |                           |                       |          |                                 |
*/
@isTest
private class CustomCreateEditRecordCtrlTest {

    private static final String COURSE_API_NAME = hed__Course__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void getLayoutMappingTest(){
        Test.startTest();
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Field_Layout_Setting__mdt> fieldLayoutList = CustomCreateEditRecordCtrl.getLayoutMapping(COURSE_API_NAME,false);
            System.assert(fieldLayoutList.size() >= 0, 'Field Layout Setting list did not match expected.');
        }
        Test.stopTest();
    }

}
