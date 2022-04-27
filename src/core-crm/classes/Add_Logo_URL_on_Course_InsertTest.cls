/**
 * @description Test Class for Add Logo URL on Course Insert flow
 *
 * @see ../flows/Add_Logo_URL_on_Course_Insert
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | angelika.j.s.galang       | April 21, 2022        | DEPP-1481    | Created file                                | 
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class Add_Logo_URL_on_Course_InsertTest {
    
    private static final String QUTEX = System.Label.QUTeX;
    private static User currentUser = TestDataFactory.createUserRecords(1, QUTEX).iterator().next();

    @IsTest
    private static void addLogoUrlOnCourseInsertTest(){
        System.runAs(currentUser){
            Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
            insert acc;
            Product_Request__c pr = TestDataFactory.createTestProductRequestRecords(1).iterator().next();
            insert pr;
            hed__Course__c course = TestDataFactory.createTestCourseRecords(1,acc?.Id,pr?.Id).iterator().next();
            
            Test.startTest();
            insert course;
            Test.stopTest();
            
            System.assert(
                [
                    SELECT 
                    LogoUrl__c
                    FROM hed__Course__c 
                    WHERE Id =: course.Id
                ].LogoUrl__c != null,
                'Logo URL was not populated as expected'
            );
        }
    }
}
