/**
 * @description Test Class for OPE Design Completion Flow
 *
 * @see ../flows/OPE_Design_Completion
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | January 20, 2022      | DEPP-1344    | Created File                                |
      |                           |                       |              |                                             |
*/
@IsTest(SeeAllData = false)
private class OPE_Design_Complete_FlowTest{

    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static String rtProdRequestMmodule = System.Label.RT_ProductRequest_Module;
    private static String rtCourseMmodule = System.Label.RT_Course_Module;
    private static Id opeActProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static Id opeActivityId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Activity').getRecordTypeId();
    private static Id opeShortProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get('Short_Course').getRecordTypeId();
    private static Id opeShortCourseId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get('Short_Course').getRecordTypeId();
    private static Id opeModuleProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(rtProdRequestMmodule).getRecordTypeId();
    private static Id opeModuleProdId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(rtCourseMmodule).getRecordTypeId();
    private static Integer numberOfRecords = 100;

    @isTest
    private static void updateOPEActivityTest(){
        System.runAs(currentUser){
            Integer opeDesignCompleteCounter = 0;
            hed__Facility__c facility = createFacility();
            createCourse(opeActProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){
                course.RecordTypeId = opeActivityId;
                course.External_Organisation__c = 'test';
                course.Resource_Details__c = 'test';
                course.Delivery_Comments__c = 'test';
                course.Location__c = facility.Id;
                course.Location_Details__c = 'test';
            }
            update coursesToUpdate;

            List<hed__Course__c> getCourses = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];

            for(hed__Course__c course : getCourses){
                if(course.OPE_Design_Complete__c == true){
                    opeDesignCompleteCounter++;
                }
            }
            Test.stopTest();
            System.assertEquals(numberOfRecords, opeDesignCompleteCounter,'Required fields must be completed.');
        }
    }

    @isTest
    private static void updateShortCourseTest(){
        System.runAs(currentUser){
            Integer opeDesignCompleteCounter = 0;
            hed__Facility__c facility = createFacility();
            createCourse(opeShortProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){
                course.RecordTypeId = opeShortCourseId;
                course.Proposal_Title__c = 'Short1';
                course.Previously_Developed_Content__c = 'Yes';
                course.External_Organisation__c = 'test';
                course.Resource_Details__c = 'test';
                course.Delivery_Comments__c = 'test';
                course.Location__c = facility.Id;
                course.Location_Details__c = 'test';
            }
            update coursesToUpdate;

            List<hed__Course__c> getCourses = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];

            for(hed__Course__c course : getCourses){
                if(course.OPE_Design_Complete__c == true){
                    opeDesignCompleteCounter++;
                }
            }
            Test.stopTest();
            System.assertEquals(numberOfRecords, opeDesignCompleteCounter,'Required fields must be completed.');
        }
    }

    @isTest
    private static void updateSingleProductTest(){
        System.runAs(currentUser){
            Integer opeDesignCompleteCounter = 0;
            hed__Facility__c facility = createFacility();
            createCourse(opeModuleProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){    
                course.RecordTypeId = opeModuleProdId;
                course.Proposal_Title__c = 'test';
                course.Is_Curriculum_Approved__c = true;
                course.CourseLoop_Full_Proposal_URL__c = 'test';
                course.External_Organisation__c = 'test';
                course.Resource_Details__c = 'test';
                course.Delivery_Comments__c = 'test';
                course.Location__c = facility.Id;
                course.Location_Details__c = 'test';
            }
            update coursesToUpdate;

            List<hed__Course__c> getCourses = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];

            for(hed__Course__c course : getCourses){
                if(course.OPE_Design_Complete__c == true){
                    opeDesignCompleteCounter++;
                }
            }
            Test.stopTest();
            System.assertEquals(numberOfRecords, opeDesignCompleteCounter,'Required fields must be completed.');
        }
    }

    @isTest
    private static void updateIncompleteDesignTest(){
        System.runAs(currentUser){
            Integer opeDesignCompleteCounter = 0;
            hed__Facility__c facility = createFacility();
            createCourse(opeActProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){
                course.Location_Details__c = 'test';
            }
            update coursesToUpdate;

            List<hed__Course__c> getCourses = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];

            for(hed__Course__c course : getCourses){
                if(course.OPE_Design_Complete__c == true){
                    opeDesignCompleteCounter++;
                }
            }

            Test.stopTest();
            System.assertEquals(0, opeDesignCompleteCounter,'Required fields must be completed.');
        }
    }

    private static hed__Facility__c createFacility(){
        hed__Facility__c facility = new hed__Facility__c();
        facility.Name = 'test';
        insert facility;
        return facility;
    }

    private static void createCourse(String productRequestRecordType){
        System.runAs(currentUser){
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(numberOfRecords, accounts[0].Id, productRequests[0].Id);
            for(hed__Course__c course : courses){
                course.Delivery_Type__c = 'Face to Face';
                course.hed__Description__c = 'test';
                course.Certificate_Type__c = 'Certificate of Achievement';
                course.Collaboration_with_External_Organisation__c = 'Yes';
                course.Content__c = 'test';
                course.Minimum_Participants__c = 1;
                course.Maximum_Participants__c = 100;
                course.Delivery_Support__c = 'Others';
                course.Overview__c = 'test';
                course.Core_Concepts__c ='test';
                course.Start_Date__c = Date.newInstance(2022, 01, 20);
                course.End_Date__c = Date.newInstance(2022, 02, 20);
                course.Owning_Faculty__c = accounts[0].Id;
            }
            insert courses;
        }
    }
}