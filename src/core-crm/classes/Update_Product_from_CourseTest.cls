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
      |                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class Update_Product_from_CourseTest{

    private static string PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    private static string COURSE_ACTIVITY = System.Label.RT_Course_Activity;
    private static string PP_PROGRAM = System.Label.RT_ProductRequest_Program;


    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    
    private static Id opeActProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static Id opeActivityId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(COURSE_ACTIVITY).getRecordTypeId();
    private static Id opeProgProdReqId =  Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_PROGRAM).getRecordTypeId();
    private static Id opeProgPlanId = Schema.SObjectType.hed__Program_Plan__c.getRecordTypeInfosByDeveloperName().get(PP_PROGRAM).getRecordTypeId();
    private static Integer numberOfRecords = 100;         

    @isTest
    private static void createProductFromCourseTest(){
        System.runAs(currentUser){              
            createCourse(opeActProdReqId);
            List<hed__Course__c> courses = [SELECT id, OPE_Design_Complete__c, ProductRequestID__c, Core_Concepts__c, 
                                                hed__Description__c, End_Date__c, More_Details__c, 
                                                Name, Overview__c, Start_Date__c, Who_Should_Participate__c 
                                            FROM hed__Course__c LIMIT 100];

            for(hed__Course__c course : courses){                    
                course.Start_Date__c = Date.newInstance(2022, 01, 20);
                course.End_Date__c = Date.newInstance(2022, 02, 20);       
            }
            update courses;                
            
            Test.startTest();
            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 100];
            for(Product_Request__c productRequest : productRequests){
                productRequest.Product_Request_Status__c = 'Release';
            }
            update productRequests;

            List<Product2> products = [SELECT Id, Core_Concepts__c, Description, End_Date__c, More_Details__c, 
                    Name, Overview__c, Start_Date__c, Who_Should_Participate__c 
                    FROM Product2 LIMIT 100];      
         
            Test.stopTest();
            System.assertEquals(courses.size(), products.size(), 'Product record must be created upon release of course in product request.');
            for(Integer i=0; i<numberOfRecords; i++){
                System.assertEquals(courses[i].Core_Concepts__c, products[i].Core_Concepts__c, 'Core Concept must be the same.');
                System.assertEquals(courses[i].hed__Description__c, products[i].Description, 'Description must be the same.');
                System.assertEquals(courses[i].More_Details__c, products[i].More_Details__c, 'More Details must be the same.');
                System.assertEquals(courses[i].Name, products[i].Name, 'Name must be the same.');
                System.assertEquals(courses[i].Overview__c, products[i].Overview__c, 'Overview must be the same.');
                System.assertEquals(courses[i].Who_Should_Participate__c, products[i].Who_Should_Participate__c, 'Who Should Participate must be the same.');
            }    
        }
    }  

    @isTest
    private static void createProductFromProgramPlanTest(){
        System.runAs(currentUser){                 
            createProgramPlan(opeProgProdReqId);
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;

            Test.startTest();

            List<Product_Request__c> productRequests = [SELECT Id, Product_Request_Status__c FROM Product_Request__c LIMIT 100];

            
            List<hed__Program_Plan__c> programPlansToUpdate = [SELECT Id, OPE_Design_Complete__c, Product_Request__c, Core_Concepts__c, 
                                                                    hed__Description__c, hed__End_Date__c, More_Details__c, 
                                                                    Name, Overview__c, hed__Start_Date__c, Who_Should_Participate__c  
                                                                FROM hed__Program_Plan__c LIMIT 100];

            for(Integer i = 0 ; i < programPlansToUpdate.size() ; i++){
                programPlansToUpdate[i].Name = 'test' + i;
                programPlansToUpdate[i].Product_Request__c  = productRequests[i].Id;
                programPlansToUpdate[i].Code__c = 'test' + i;
                programPlansToUpdate[i].Program_Type__c  = 'Prescribed Program';
                programPlansToUpdate[i].Owning_Faculty__c  = accounts[0].Id;
                programPlansToUpdate[i].hed__Start_Date__c  = Date.newInstance(2022, 01, 20);
                programPlansToUpdate[i].hed__End_Date__c  = Date.newInstance(2022, 02, 20);
                programPlansToUpdate[i].Overview__c  = 'test' + i;
                programPlansToUpdate[i].Core_Concepts__c  = 'test' + i;
                programPlansToUpdate[i].Courseloop_Full_URL__c  = 'test' + i;
                programPlansToUpdate[i].PP_Is_curriculum_approved__c  = true;
            }
            update programPlansToUpdate;
           
            for(Product_Request__c productRequest : productRequests){
                productRequest.Product_Request_Status__c = 'Release';         
            }
            update productRequests;

            List<Product2> products = [SELECT Id, Core_Concepts__c, Description, End_Date__c, More_Details__c, 
                                            Name, Overview__c, Start_Date__c, Who_Should_Participate__c 
                                        FROM Product2 LIMIT 100];
                                  
            Test.stopTest();

            System.assertEquals(programPlansToUpdate.size(), products.size(), 'Product record must be created upon release of course in product request.');
            for(Integer i=0; i<numberOfRecords; i++){
                System.assertEquals(programPlansToUpdate[i].Core_Concepts__c, products[i].Core_Concepts__c, 'Core Concept must be the same.');
                System.assertEquals(programPlansToUpdate[i].hed__Description__c, products[i].Description, 'Description must be the same.');
                System.assertEquals(programPlansToUpdate[i].More_Details__c, products[i].More_Details__c, 'More Details must be the same.');
                System.assertEquals(programPlansToUpdate[i].Name, products[i].Name, 'Name must be the same.');
                System.assertEquals(programPlansToUpdate[i].Overview__c, products[i].Overview__c, 'Overview must be the same.');
                System.assertEquals(programPlansToUpdate[i].Who_Should_Participate__c, products[i].Who_Should_Participate__c, 'Who Should Participate must be the same.');
            }
        }
    }

    private static void createCourse(String productRequestRecordType){
        System.runAs(currentUser){
            List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
            insert accounts;

            List<Product_Request__c> productRequests = TestDataFactory.createTestProductRequestRecords(numberOfRecords);
            for(Product_Request__c productRequest : productRequests){
                productRequest.RecordTypeId = productRequestRecordType;
            }
            insert productRequests;

            hed__Facility__c facility = new hed__Facility__c();
            facility.Name = 'test';
            insert facility;                

            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(numberOfRecords, accounts[0].Id, productRequests[0].Id);
            for(Integer i = 0 ; i < courses.size() ; i++){
                courses[i].ProductRequestID__c = productRequests[i].Id;
                courses[i].RecordTypeId = opeActivityId;
                courses[i].Delivery_Type__c = 'Face to Face';
                courses[i].Location__c = facility.Id;
                courses[i].Location_Details__c = 'test';                    
                courses[i].hed__Description__c = 'test';
                courses[i].Certificate_Type__c = 'Certificate of Achievement';
                courses[i].Collaboration_with_External_Organisation__c = 'Yes';
                courses[i].External_Organisation__c = 'test';
                courses[i].Content__c = 'test';     
                courses[i].Resource_Details__c = 'test';   
                courses[i].Minimum_Participants__c = 1;
                courses[i].Maximum_Participants__c = 100;                    
                courses[i].Delivery_Support__c = 'Others';                
                courses[i].Delivery_Comments__c = 'test';
                courses[i].Core_Concepts__c = 'test';
                courses[i].Overview__c = 'test';
                courses[i].Owning_Faculty__c = accounts[0].Id;                
            }
            insert courses;
        }
    }    

    private static void createProgramPlan(String productRequestRecordType){
        System.runAs(currentUser){
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