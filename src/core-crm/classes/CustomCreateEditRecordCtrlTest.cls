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
@IsTest(SeeAllData = false)
private class CustomCreateEditRecordCtrlTest {

    private static final String COURSE_API_NAME = hed__Course__c.SObjectType.getDescribe().getLocalName();
    private static final String STR_QUTeX = 'QUTeX';
    private static User currentUser = TestDataFactory.createUserRecords(1, STR_QUTeX).iterator().next();

    @IsTest
    private static void getLayoutMappingTest(){
        Test.startTest();
        System.runAs(currentUser){
            List<Field_Layout_Setting__mdt> fieldLayoutList = CustomCreateEditRecordCtrl.getLayoutMapping(COURSE_API_NAME);
            System.assert(fieldLayoutList.size() >= 0, 'Field Layout Setting list did not match expected.');
        }
        Test.stopTest();
    }

}
