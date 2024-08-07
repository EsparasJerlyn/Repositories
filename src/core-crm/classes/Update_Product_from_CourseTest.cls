/**
 * @description Test Class for Update Product from Course Flow
 *
 * @see ../flows/Update_Product_from_Course
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | eccarius.munoz            | January 28, 2022      | DEPP-1472    | Created File                                |
      | justine.javier            | March 22, 2022        | DEPP-2086    | Added MMark_Design_Stage_as_Complete__c     |
*/
@isTest
private class Update_Product_from_CourseTest{

    private static final string PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static final string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final string COURSE_ACTIVITY = System.Label.RT_Course_Activity;
    private static final string PP_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;   

    private static final Id opeActProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static final Id opeActivityId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(COURSE_ACTIVITY).getRecordTypeId();
    private static final Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static final Id opeProgPlanId = Schema.SObjectType.hed__Program_Plan__c.getRecordTypeInfosByDeveloperName().get(PP_PROGRAM).getRecordTypeId();
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    private static final Integer numberOfRecords = 100;
    private static Date startDate = date.today().addDays(1);
    private static Date endDate = startDate.addDays(1);

    @TestSetup
    static void makeData(){
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
    }

    @isTest
    private static void createProductFromCourseTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            createCourse(opeActProdReqId);
            List<hed__Course__c> courses = [SELECT id, ProductRequestID__c, Core_Conceptsv2__c,
                                                Description__c, End_Date__c, More_Detailsv2__c,
                                                Name, Overviewv2__c, Start_Date__c, Who_Should_Participatev2__c,
                                                Evolve_with_QUTeXv2__c
                                            FROM hed__Course__c LIMIT 100];

            for(hed__Course__c course : courses){
                course.Start_Date__c = startDate;
                course.End_Date__c = endDate;
            }
            update courses;

            Test.startTest();
            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 100];
            for(Product_Request__c productRequest : productRequests){
                productRequest.Product_Request_Status__c = 'Release';
            }
            update productRequests;

            List<Product2> products = [SELECT Id, Core_Concepts__c, Description, End_Date__c, More_Details__c,
                    Name, Overview__c, Start_Date__c, Who_Should_Participate__c, Evolve_with_QUTeX__c
                    FROM Product2 LIMIT 100];

            Test.stopTest();
            System.assertEquals(courses.size(), products.size(), 'Product record must be created upon release of course in product request.');
            for(Integer i=0; i<numberOfRecords; i++){
                System.assertEquals(courses[i].Core_Conceptsv2__c, products[i].Core_Concepts__c, 'Core Concept must be the same.');
                System.assertEquals(courses[i].Description__c, products[i].Description, 'Description must be the same.');
                System.assertEquals(courses[i].More_Detailsv2__c, products[i].More_Details__c, 'More Details must be the same.');
                System.assertEquals(courses[i].Name, products[i].Name, 'Name must be the same.');
                System.assertEquals(courses[i].Overviewv2__c, products[i].Overview__c, 'Overview must be the same.');
                System.assertEquals(courses[i].Who_Should_Participatev2__c, products[i].Who_Should_Participate__c, 'Who Should Participate must be the same.');
                System.assertEquals(courses[i].Evolve_with_QUTeXv2__c, products[i].Evolve_with_QUTeX__c, 'Evolve with QUTeX must be the same.');
                System.assertEquals(courses[i].Start_Date__c, products[i].Start_Date__c, 'Start Date must be the same.');
                System.assertEquals(courses[i].End_Date__c, products[i].End_Date__c, 'End Date must be the same.');

            }
        }
    }

    @isTest
    private static void createProductFromProgramPlanTest(){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            createProgramPlan(opeProgProdReqId);
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account account : accounts){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            Test.startTest();

            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 100];


            List<hed__Program_Plan__c> programPlansToUpdate = [SELECT Id, Product_Request__c, Core_Conceptsv2__c,
                                                                    Description__c, hed__End_Date__c, More_Detailsv2__c,
                                                                    Name, Overviewv2__c, hed__Start_Date__c, Who_Should_Participatev2__c,
                                                                    Evolve_with_QUTeXv2__c
                                                                    FROM hed__Program_Plan__c LIMIT 100];
            hed__Facility__c facility = new hed__Facility__c();
            facility.Name = 'Externals';
            insert facility;

            for(Integer i = 0 ; i < programPlansToUpdate.size() ; i++){
                programPlansToUpdate[i].Name = 'test' + i;
                programPlansToUpdate[i].Product_Request__c  = productRequests[i].Id;
                programPlansToUpdate[i].Code__c = 'test' + i;
                programPlansToUpdate[i].Program_Type__c  = 'Award Course';
                programPlansToUpdate[i].Owning_Faculty__c  = accounts[0].Id;
                programPlansToUpdate[i].hed__Start_Date__c  = startDate;
                programPlansToUpdate[i].hed__End_Date__c  = endDate;
                programPlansToUpdate[i].Overviewv2__c  = 'test' + i;
                programPlansToUpdate[i].Core_Conceptsv2__c  = 'test' + i;
                programPlansToUpdate[i].Courseloop_Full_URL__c  = 'test' + i;
                programPlansToUpdate[i].PP_Is_curriculum_approved__c  = true;
                programPlansToUpdate[i].Mark_Design_Stage_as_Complete__c=true;
                programPlansToUpdate[i].Description__c='sdfdsfsdfsd';
                programPlansToUpdate[i].Implementation_Year__c='2040';
                programPlansToUpdate[i].Location__c=facility.Id;
            }
            update programPlansToUpdate;

            for(Product_Request__c productRequest : productRequests){
                productRequest.Product_Request_Status__c = 'Release';
            }
            update productRequests;

            List<Product2> products = [SELECT Id, Core_Concepts__c, Description, End_Date__c, More_Details__c,
                                            Name, Overview__c, Start_Date__c, Who_Should_Participate__c,
                                            Evolve_with_QUTeX__c

                                        FROM Product2 LIMIT 100];

            Test.stopTest();

            System.assertEquals(programPlansToUpdate.size(), products.size(), 'Product record must be created upon release of course in product request.');
            for(Integer i=0; i<numberOfRecords; i++){
                System.assertEquals(programPlansToUpdate[i].Core_Conceptsv2__c, products[i].Core_Concepts__c, 'Core Concept must be the same.');
                System.assertEquals(programPlansToUpdate[i].Description__c, products[i].Description, 'Description must be the same.');
                System.assertEquals(programPlansToUpdate[i].More_Detailsv2__c, products[i].More_Details__c, 'More Details must be the same.');
                System.assertEquals(programPlansToUpdate[i].Name, products[i].Name, 'Name must be the same.');
                System.assertEquals(programPlansToUpdate[i].Overviewv2__c, products[i].Overview__c, 'Overview must be the same.');
                System.assertEquals(programPlansToUpdate[i].Who_Should_Participatev2__c, products[i].Who_Should_Participate__c, 'Who Should Participate must be the same.');
                System.assertEquals(programPlansToUpdate[i].Evolve_with_QUTeXv2__c, products[i].Evolve_with_QUTeX__c, 'Evolve with QUTeX must be the same.');
                System.assertEquals(programPlansToUpdate[i].hed__End_Date__c, products[i].End_Date__c, 'End Date must be the same.');
                System.assertEquals(programPlansToUpdate[i].hed__Start_Date__c, products[i].Start_Date__c, 'Start Date must be the same.');
            }
        }
    }

    private static void createCourse(String productRequestRecordType){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            for(Account account : accounts){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert accounts;

            List<Account> owningSchoolAccounts = TestDataFactory.createTestAccountRecords(1);
            for(Account account : owningSchoolAccounts){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '3';
            }
            insert owningSchoolAccounts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(numberOfRecords);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;

            hed__Facility__c facility = new hed__Facility__c();
            facility.Name = 'Externals';
            insert facility;

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(numberOfRecords, accounts[0].Id, productRequests[0].Id);
            for(Integer i = 0 ; i < courses.size() ; i++){
                courses[i].ProductRequestID__c = productRequests[i].Id;
                courses[i].RecordTypeId = opeActivityId;
                courses[i].Course_Code__c = 'test' + i;
                courses[i].Volume_of_Learning_hours__c = 2;
                courses[i].Certificate_Type__c = 'Certificate of Achievement';
                courses[i].Delivery_Type__c = 'Face to Face';
                courses[i].Description__c = 'test';
                courses[i].Primary_Delivery_Platform__c = 'QUT Canvas';
                courses[i].Owning_Faculty__c = accounts[0].Id;
                courses[i].Owning_School_Discipline_Area__c = owningSchoolAccounts[0].Id;
                courses[i].Overviewv2__c = 'test';
                courses[i].Location__c = facility.Id;
                courses[i].Location_Details__c = 'test';
                courses[i].Minimum_Participants__c = 1;
                courses[i].Maximum_Participants__c = 10;
                courses[i].Implementation_Year__c = String.valueOf(Date.today().year());
                courses[i].Unit_Type__c = 'Unit';
                courses[i].Unit_Category__c = 'Undergraduate Honours Unit';
                courses[i].Field_of_Education__c = 'test';
                courses[i].Credits__c = 1;
                courses[i].hed__Credit_Hours__c = 3;
                courses[i].CourseLoop_Initial_Proposal_URL__c = 'test';
                courses[i].Is_Curriculum_Approved__c = true;
                courses[i].CourseLoop_Full_Proposal_URL__c = 'test';
                courses[i].Mark_Design_Stage_as_Complete__c = true;
            }
            insert courses;
        }
    }

    private static void createProgramPlan(String productRequestRecordType){
        System.runAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(numberOfRecords);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = productRequestRecordType;
                productRequest.Product_Request_Status__c = 'Design';
            }
            insert productRequests;

            List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(numberOfRecords);
            for(hed__Program_Plan__c programPlan : programPlans){
                programPlan.RecordTypeId = opeProgPlanId;
            }
            insert programPlans;
        }
    }
}