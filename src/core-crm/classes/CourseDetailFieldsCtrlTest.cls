/**
 * @description Test class for CourseDetailFieldsCtrl
 *
 * @see CourseDetailFields.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA            | Change Summary                                         |
      |---------------------------|-----------------------|-----------------|--------------------------------------------------------|
      | angelika.j.s.galang       | December 21, 2021     | DEPP-838,1299   | Created file                                           |
      |                           |                       |                 |                                                        | 
*/
@IsTest(SeeAllData = false)
private class CourseDetailFieldsCtrlTest {
    
    private static final String COURSE_API_NAME = hed__Course__c.SObjectType.getDescribe().getLocalName();
    private static final String OPE_ACTIVITY = 'OPE Activity Request';
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();

    @IsTest
    private static void getCourseIdTest(){
        System.runAs(currentUser){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acc;
            Product_Request__c pr = TestDataFactory.createTestProductRequestRecords(1).iterator().next();
            insert pr;
            hed__Course__c course = TestDataFactory.createTestCourseRecords(1,acc?.Id,pr?.Id).iterator().next();
            insert course;

            Test.startTest();
            Id courseId = CourseDetailFieldsCtrl.getCourseId(pr?.Id);
            Test.stopTest();
            System.assertEquals(course?.Id, courseId, 'Course Id did not match expected.');
        }
    }

    @IsTest
    private static void getLayoutMappingTest(){
        System.runAs(currentUser){
            Test.startTest();
            List<Field_Layout_Setting__mdt> fieldLayoutList = CourseDetailFieldsCtrl.getLayoutMapping(COURSE_API_NAME,OPE_ACTIVITY);
            Test.stopTest();
            System.assert(fieldLayoutList.size() == 3, 'Field Layout Setting list did not match expected.');
        }
    }

}
