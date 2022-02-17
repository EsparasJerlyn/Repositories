/**
 * @description Test class for CustomPageLayoutCtrl
 *
 * @see CustomPageLayoutCtrlTest.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                         |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | January 26, 2022      | DEPP-838,1299,1407   | Created file                                           |                           | 
*/
@IsTest(SeeAllData = false)
private class CustomPageLayoutCtrlTest {
    
    private static final String COURSE_API_NAME = hed__Course__c.SObjectType.getDescribe().getLocalName();
    private static final String COURSE_PR_FIELD = 'ProductRequestID__c';
    private static final String PRODUCT_API_NAME = Product2.SObjectType.getDescribe().getLocalName();
    private static final String PRODUCT_COURSE_FIELD = 'Course__c';
    private static final String OPE_ACTIVITY = 'Activity';
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();

    @testSetup static void setupMethod() {
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        insert acc;
        Product_Request__c pr = TestDataFactory.createTestProductRequestRecords(1).iterator().next();
        insert pr;
        hed__Course__c course = TestDataFactory.createTestCourseRecords(1,acc?.Id,pr?.Id).iterator().next();
        insert course;
        Product2 product = TestDataFactory.createTestProductRecords(1, new List<hed__Course__c>{course}).iterator().next();
        insert product;
    }

    @IsTest
    private static void getChildRecordIdTest(){
        System.runAs(currentUser){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            Test.startTest();
            Id courseId = CustomPageLayoutCtrl.getChildRecordId(pr?.Id, COURSE_PR_FIELD, COURSE_API_NAME, new Map<String,String>());
            Test.stopTest();
            System.assertEquals(course?.Id, courseId, 'Course Id did not match expected.');
        }
    }

    @IsTest
    private static void getGrandChildRecordIdTest(){
        System.runAs(currentUser){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            Product2 product = [SELECT Id FROM Product2 LIMIT 1];
            Map<String,String> grandChild = new Map<String,String>();
            grandChild.put('objectApiName',PRODUCT_API_NAME);
            grandChild.put('conditionField',PRODUCT_COURSE_FIELD);
            Test.startTest();
            Id productId = CustomPageLayoutCtrl.getChildRecordId(pr?.Id, COURSE_PR_FIELD, COURSE_API_NAME, grandChild);
            Test.stopTest();
            System.assertEquals(product?.Id, productId, 'Product Id did not match expected.');
        }
    }

    @IsTest
    private static void getLayoutMappingTest(){
        System.runAs(currentUser){
            Test.startTest();
            List<Field_Layout_Setting__mdt> fieldLayoutList = CustomPageLayoutCtrl.getLayoutMapping(COURSE_API_NAME,OPE_ACTIVITY,true);
            Test.stopTest();
            System.assert(fieldLayoutList.size() == 3, 'Field Layout Setting list did not match expected.');
        }
    }

}
