/**
 * @description Test class for CustomLayoutCtrl
 *
 * @see CustomLayoutCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                         |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | January 26, 2022      | DEPP-838,1299,1407   | Created file                                           |                           |
*/
@IsTest(SeeAllData = false)
private class CustomLayoutCtrlTest {

    private static final String COURSE_API_NAME = hed__Course__c.SObjectType.getDescribe().getLocalName();
    private static final String COURSE_PR_FIELD = 'ProductRequestID__c';
    private static final String PRODUCT_API_NAME = Product2.SObjectType.getDescribe().getLocalName();
    private static final String PRODUCT_COURSE_FIELD = 'Course__c';
    private static final String COMMUNICATION_SCHEDULE_API_NAME = Communication_Schedule__c.SObjectType.getDescribe().getLocalName();
    private static final String MDT_COMMUNICATION_SCHEDULE = 'All_OPE_Communication_Schedules';
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @testSetup static void setupMethod() {
        Account acc = TestDataFactory.createTestAccountRecords(1).iterator().next();
        acc.RecordTypeId = ACCT_UNIV_DEP_ID;
        acc.Organization_Unit_Level__c = '2';
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
            Id courseId = CustomLayoutCtrl.getChildRecordId(pr?.Id, COURSE_PR_FIELD, COURSE_API_NAME, new Map<String,String>());
            Test.stopTest();
            System.assertEquals(course?.Id, courseId, 'Course Id did not match expected.');
        }
    }

    @IsTest
    private static void getParentRecordTest(){
        System.runAs(currentUser){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            Test.startTest();
            sObject courseRecord = CustomLayoutCtrl.getParentRecord(pr?.Id, COURSE_PR_FIELD, COURSE_API_NAME, 'Id ', new Map<String,String>());

            Test.stopTest();
            System.assertEquals(courseRecord?.Id, course.Id, 'Course did not match expected.');
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
            Id productId = CustomLayoutCtrl.getChildRecordId(pr?.Id, COURSE_PR_FIELD, COURSE_API_NAME, grandChild);
            Test.stopTest();
            System.assertEquals(product?.Id, productId, 'Product Id did not match expected.');
        }
    }

    @IsTest
    private static void getGrandParentRecordTest(){
        System.runAs(currentUser){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            Product2 product = [SELECT Id FROM Product2 LIMIT 1];
            Map<String,String> grandChild = new Map<String,String>();
            grandChild.put('objectApiName',PRODUCT_API_NAME);
            grandChild.put('conditionField',PRODUCT_COURSE_FIELD);
            Test.startTest();
            sObject productRecord = CustomLayoutCtrl.getParentRecord(pr?.Id, COURSE_PR_FIELD, COURSE_API_NAME,'Id ', grandChild);
            Test.stopTest();
            System.assertEquals(productRecord?.Id, product.Id, 'Product Id did not match expected.');
        }
    }

    @IsTest
    private static void getLayoutMappingTest(){
        System.runAs(currentUser){
            Test.startTest();
            List<Field_Layout_Setting__mdt> fieldLayoutList = CustomLayoutCtrl.getLayoutMapping(COMMUNICATION_SCHEDULE_API_NAME,MDT_COMMUNICATION_SCHEDULE,true);
            Test.stopTest();
            System.assert(fieldLayoutList.size() == 1, 'Field Layout Setting list did not match expected.');
        }
    }

}
