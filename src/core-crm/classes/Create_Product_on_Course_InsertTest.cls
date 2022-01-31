/**
 * @description Test Class for Create Product on Course Insert flow
 *
 * @see ../flows/Create_Product_on_Course_Insert
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | January 28, 2022      | DEPP-1407    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class Create_Product_on_Course_InsertTest {

    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static Id opeActivity = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('OPE_Activity').getRecordTypeId();
    
    @IsTest
    private static void createProductOnCourseInsertTest(){
        System.runAs(currentUser){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acc;
            Product_Request__c pr = TestDataFactory.createTestProductRequestRecords(1).iterator().next();
            insert pr;
            hed__Course__c course = TestDataFactory.createTestCourseRecords(1,acc?.Id,pr?.Id).iterator().next();
            course.RecordTypeId = opeActivity;
            
            Test.startTest();
            insert course;
            Test.stopTest();
            
            Product2 product = [SELECT Name, Course__c, Family, IsActive FROM Product2 LIMIT 1];
            System.assertEquals(course.Name, product.Name, 'Name did not match expected: '+course.Name);
            System.assertEquals(course.Id, product.Course__c, 'Course ID did not match expected: '+course.Id);
            System.assertEquals('Education', product.Family, 'Family did not match expected: Education');
            System.assertEquals(true, product.IsActive, 'IsActive did not match expected: true');
        }
    }
}
