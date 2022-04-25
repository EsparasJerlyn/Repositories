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
      | eccarius.munoz            | March 14, 2022        | DEPP-2066    | Updated Required fields                     |
      |                           |                       |              |                                             |
*/
@IsTest(SeeAllData = false)
private class OPE_Design_Complete_FlowTest{

    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static String PR_MODULE = System.Label.RT_ProductRequest_Module;
    private static String C_MODULE = System.Label.RT_Course_Module;
    private static string PR_SHORTCOURSE = System.Label.RT_ProductRequest_ShortCourse;
    private static string C_SHORTCOURSE = System.Label.RT_Course_ShortCourse;
    private static string PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static string C_ACTIVITY = System.Label.RT_Course_Activity;
    private static string PR_UNIT = System.Label.RT_ProductRequest_Unit;
    private static string C_UNIT = System.Label.RT_ProductRequest_Unit; 
    
    private static Id opeActProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static Id opeActivityId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_ACTIVITY).getRecordTypeId();
    private static Id opeShortProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_SHORTCOURSE).getRecordTypeId();
    private static Id opeShortCourseId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_SHORTCOURSE).getRecordTypeId();
    private static Id opeModuleProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_MODULE).getRecordTypeId();
    private static Id opeModuleId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_MODULE).getRecordTypeId();
    private static Id opeUnitProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_UNIT).getRecordTypeId();
    private static Id opeUnitId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_UNIT).getRecordTypeId();
    private static Integer numberOfRecords = 100;

    @isTest
    private static void updateActivityCourseTest(){
        System.runAs(currentUser){
            Integer opeDesignCompleteCounter = 0;

            createCourseWithCommonFields(opeActProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){
                course.RecordTypeId = opeActivityId;
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

            createCourseWithCommonFields(opeShortProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){
                course.RecordTypeId = opeShortCourseId;
                course.Implementation_Year__c = '2022';
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
    private static void updateUnitCourseTest(){
        System.runAs(currentUser){
            Integer opeDesignCompleteCounter = 0;
            
            createCourseWithCommonFields(opeUnitProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){
                course.RecordTypeId = opeUnitId;
                course.Unit_Type__c = 'Unit';
                course.Unit_Category__c = 'Undergraduate Honours Unit';
                course.Field_of_Education__c = 'test';
                course.Credits__c = 1;
                course.hed__Credit_Hours__c = 3;
                course.Implementation_Year__c = '2022';
                course.CourseLoop_Initial_Proposal_URL__c = 'test';
                course.Is_Curriculum_Approved__c = true;
                course.CourseLoop_Full_Proposal_URL__c = 'test';
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
    private static void updateModuleCourseTest(){
        System.runAs(currentUser){
            Integer opeDesignCompleteCounter = 0;
            createCourseWithCommonFields(opeModuleProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){
                course.RecordTypeId = opeModuleId;                
                course.Implementation_Year__c = '2022';
                course.CourseLoop_Initial_Proposal_URL__c = 'test';
                course.Is_Curriculum_Approved__c = true;
                course.CourseLoop_Full_Proposal_URL__c = 'test';
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
            createCourseWithCommonFields(opeActProdReqId);

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

    private static void createCourseWithCommonFields(String productRequestRecordType){
        System.runAs(currentUser){

            hed__Facility__c facility = createFacility();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;           

            Date startDate = date.today().addDays(1);
            Date endDate = startDate.addDays(1);

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(numberOfRecords, accounts[0].Id, productRequests[0].Id);
            for(hed__Course__c course : courses){
                course.Course_Code__c = 'test';
                course.Start_Date__c = startDate;
                course.End_Date__c = endDate;
                course.Volume_of_Learning_hours__c = 2;
                course.Certificate_Type__c = 'Certificate of Achievement';
                course.Delivery_Type__c = 'Face to Face';
                course.Description__c = 'test';
                course.Primary_Delivery_Platform__c = 'Blackboard';
                course.Owning_Faculty__c = accounts[0].Id;
                course.Owning_School_Discipline_Area__c = accounts[0].Id;
                course.Overviewv2__c = 'test';  
                course.Minimum_Participants__c = 1;
                course.Maximum_Participants__c = 10;
                course.Location__c = facility.Id;
                course.Location_Details__c = 'test';                              
            }
            insert courses;
        }
    }
}