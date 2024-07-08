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
@isTest
private class OPE_Design_Complete_FlowTest{

    private static final String PR_MODULE = System.Label.RT_ProductRequest_Module;
    private static final String C_MODULE = System.Label.RT_Course_Module;
    private static final string PR_SHORTCOURSE = System.Label.RT_ProductRequest_ShortCourse;
    private static final string C_SHORTCOURSE = System.Label.RT_Course_ShortCourse;
    private static final string PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final string C_ACTIVITY = System.Label.RT_Course_Activity;
    private static final string PR_UNIT = System.Label.RT_ProductRequest_Unit;
    private static final string C_UNIT = System.Label.RT_ProductRequest_Unit; 
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;    
    
    private static final Id opeActProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static final Id opeActivityId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_ACTIVITY).getRecordTypeId();
    private static final Id opeShortProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_SHORTCOURSE).getRecordTypeId();
    private static final Id opeShortCourseId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_SHORTCOURSE).getRecordTypeId();
    private static final Id opeModuleProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_MODULE).getRecordTypeId();
    private static final Id opeModuleId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_MODULE).getRecordTypeId();
    private static final Id opeUnitProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_UNIT).getRecordTypeId();
    private static final Id opeUnitId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_UNIT).getRecordTypeId();
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();
    
    private static final Integer numberOfRecords = 100;

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void updateActivityCourseTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Integer opeDesignCompleteCounter = 0;

            createCourseWithCommonFields(opeShortProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){
                course.RecordTypeId = opeShortCourseId;
                course.Implementation_Year__c = String.valueOf(Date.today().year());
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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
                course.Implementation_Year__c = String.valueOf(Date.today().year());
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            Integer opeDesignCompleteCounter = 0;
            createCourseWithCommonFields(opeModuleProdReqId);

            Test.startTest();
            List<hed__Course__c> coursesToUpdate = [SELECT id, OPE_Design_Complete__c FROM hed__Course__c LIMIT 100];
            for(hed__Course__c course : coursesToUpdate){
                course.RecordTypeId = opeModuleId;                
                course.Implementation_Year__c = String.valueOf(Date.today().year());
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
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
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
        facility.Name = 'Externals';
        insert facility;
        return facility;
    }

    private static void createCourseWithCommonFields(String productRequestRecordType){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){

            hed__Facility__c facility = createFacility();

            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account account : accounts){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Account> accountsForOwningSchool = TestDataFactory.createTestAccountRecords(1);
            for(Account account : accountsForOwningSchool){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '3';
            }
            insert accountsForOwningSchool;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(1);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;           

            Date startDate = date.today().addDays(1);
            Date endDate = startDate.addDays(1);

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(numberOfRecords, accounts[0].Id, productRequests[0].Id);
            Integer i = 0;
            for(hed__Course__c course : courses){
                course.Course_Code__c = 'test' + i++;
                course.Start_Date__c = startDate;
                course.End_Date__c = endDate;
                course.Volume_of_Learning_hours__c = 2;
                course.Certificate_Type__c = 'Certificate of Achievement';
                course.Delivery_Type__c = 'Face to Face';
                course.Description__c = 'test';
                course.Primary_Delivery_Platform__c = 'QUT Canvas';
                course.Owning_Faculty__c = accounts[0].Id;
                course.Owning_School_Discipline_Area__c = accountsForOwningSchool[0].Id;
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