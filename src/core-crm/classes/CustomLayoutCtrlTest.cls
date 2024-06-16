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
      | angelika.j.s.galang       | January 26, 2022      | DEPP-838,1299,1407   | Created file                                           |
*/
@isTest
private class CustomLayoutCtrlTest {

    private static final String COURSE_API_NAME = hed__Course__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String COURSE_PR_FIELD = 'ProductRequestID__c';
    private static final String PRODUCT_API_NAME = Product2.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String PRODUCT_COURSE_FIELD = 'Course__c';
    private static final String COMMUNICATION_SCHEDULE_API_NAME = Communication_Schedule__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
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
        course.Diagnostic_Tool_Type__c = 'Group Diagnostic Tool';
        insert course;
        Product2 product = TestDataFactory.createTestProductRecords(1, new List<hed__Course__c>{course}).iterator().next();
        insert product;
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void getChildRecordIdTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            Test.startTest();
            CustomLayoutCtrl.GetRecordFilter filter = new CustomLayoutCtrl.GetRecordFilter();
            filter.parentId = pr?.Id;
            filter.parentField = COURSE_PR_FIELD;
            filter.childObjectType = COURSE_API_NAME;
            filter.grandChildInfo = new Map<String,String>();
            Id courseId = CustomLayoutCtrl.getChildRecordId(filter);
            Test.stopTest();
            System.assertEquals(course?.Id, courseId, 'Course Id did not match expected.');
        }
    }

    @isTest
    private static void getParentRecordTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            hed__Course__c course = [SELECT Id FROM hed__Course__c LIMIT 1];
            Test.startTest();
            CustomLayoutCtrl.GetRecordFilter filter = new CustomLayoutCtrl.GetRecordFilter();
            filter.parentId = pr?.Id;
            filter.parentField = COURSE_PR_FIELD;
            filter.childObjectType = COURSE_API_NAME;
            filter.fields = 'Id ';
            filter.grandChildInfo = new Map<String,String>();
            sObject courseRecord = CustomLayoutCtrl.getParentRecord(filter);

            Test.stopTest();
            System.assertEquals(courseRecord?.Id, course.Id, 'Course did not match expected.');
        }
    }

    @isTest
    private static void getGrandChildRecordIdTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            Product2 product = [SELECT Id FROM Product2 LIMIT 1];
            Map<String,String> grandChild = new Map<String,String>();
            grandChild.put('objectApiName',PRODUCT_API_NAME);
            grandChild.put('conditionField',PRODUCT_COURSE_FIELD);
            Test.startTest();
            CustomLayoutCtrl.GetRecordFilter filter = new CustomLayoutCtrl.GetRecordFilter();
            filter.parentId = pr?.Id;
            filter.parentField = COURSE_PR_FIELD;
            filter.childObjectType = COURSE_API_NAME;
            filter.grandChildInfo = grandChild;
            Id productId = CustomLayoutCtrl.getChildRecordId(filter);
            Test.stopTest();
            System.assertEquals(product?.Id, productId, 'Product Id did not match expected.');
        }
    }

    @isTest
    private static void getGrandParentRecordTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            Product2 product = [SELECT Id FROM Product2 LIMIT 1];
            Map<String,String> grandChild = new Map<String,String>();
            grandChild.put('objectApiName',PRODUCT_API_NAME);
            grandChild.put('conditionField',PRODUCT_COURSE_FIELD);
            Test.startTest();
            CustomLayoutCtrl.GetRecordFilter filter = new CustomLayoutCtrl.GetRecordFilter();
            filter.parentId = pr?.Id;
            filter.parentField = COURSE_PR_FIELD;
            filter.childObjectType = COURSE_API_NAME;
            filter.fields = 'Id ';
            filter.grandChildInfo = grandChild;
            sObject productRecord = CustomLayoutCtrl.getParentRecord(filter);
            Test.stopTest();
            System.assertEquals(productRecord?.Id, product.Id, 'Product Id did not match expected.');
        }
    }

    @isTest
    private static void getLayoutMappingTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            List<Field_Layout_Setting__mdt> fieldLayoutList = CustomLayoutCtrl.getLayoutMapping(COMMUNICATION_SCHEDULE_API_NAME,MDT_COMMUNICATION_SCHEDULE,true);
            Test.stopTest();
            System.assert(fieldLayoutList.size() == 1, 'Field Layout Setting list did not match expected.');
        }
    }

    @isTest
    private static void getLayoutMappingWithFieldTest(){


        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Test.startTest();
            Product_Request__c pr = [SELECT Id FROM Product_Request__c LIMIT 1];
            Map<String,String> objectMap = new Map<String,String>();
            objectMap.put('recordType','Diagnostic_Tool');
            objectMap.put('childObject','hed__Course__c');
            objectMap.put('fieldApiName','Diagnostic_Tool_Type__c');
            objectMap.put('parentField','ProductRequestID__c');
            List<Field_Layout_Setting__mdt> fieldLayoutList = CustomLayoutCtrl.getLayoutMappingWithField(objectMap,pr.Id);
            Test.stopTest();
            System.assert(!fieldLayoutList.isEmpty(), 'Field Layout Setting list did not match expected.');
        }
    }

}
