/**
 * @description Tests the Designation Update - Custom Validation Flow
 *
 * @see Designation_Update_Custom_Validation_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA        | Change Summary                  |
      |---------------------------|-----------------------|-------------|---------------------------------|
      | kenneth.f.alsay           | April 05, 2024        | DEPP-8399   | Created file                    | 
      |                           |                       |             |                                 |
*/
@isTest
public class DesignationUpdateValidationFlowTest {
    // * Description: This method is used to create initial data for the test methods
    @TestSetup
    public static void testSetup(){
        Test.startTest();
        TestDataFactoryUser.generateUserAdvancementManager();
        Test.stopTest();

        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            List<Designation__C> designationList = TestDataFactory.createDesignationRecords(
                100,
                DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );
            for(Designation__C designation : designationList){
                designation.Is_For_Public_Giving__c = 'Yes';
                designation.QA_Completed__c = true;
                designation.Public_Giving_Publish_Start_Date__c = Date.today();
            }
            DesignationsDAO.newInstance().insertRecords(designationList, false, AccessLevel.USER_MODE);
            List<Distribution_Management__c> distributionMgtList = TestDataFactory.createDistributionManagementRecords(100, 'Define');
            for(Integer i = 0; i<100; i++){
                distributionMgtList[0].Designation__c = designationList[0].Id;
            }
            DistributionManagementsDAO.newInstance().insertRecords(distributionMgtList, false, AccessLevel.USER_MODE);
        }
    }
    
    @isTest
    public static void checkProductDescription(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            List<Designation__c> designationList = DesignationsDAO.newInstance().getDesignationsByNameStart('Test Designation', AccessLevel.USER_MODE);
            List<Product2> products = ProductsDAO.newInstance().getProductByDesignationId(new Map<Id,SObject>(designationList).keySet(), AccessLevel.USER_MODE);
            
            Test.startTest();
            for(Product2 product : products){
                product.Description__c = '';
                product.Title_Image_URL__c = 'test.com';
            }
            
            for(Designation__c designation : designationList){
                designation.Ready_For_Publishing__c = true;
            }
            
            ProductsDAO.newInstance().updateRecords(products, false, AccessLevel.USER_MODE);
            DesignationsDAO.newInstance().updateRecords(designationList, false, AccessLevel.USER_MODE);
            
            List<Designation__c> designationsToCheck = DesignationsDAO.newInstance().getDesignationsBySetRecordIds(new Map<Id,SObject>(designationList).keySet(), AccessLevel.USER_MODE);
            if(!products.isEmpty()){
                for(Designation__c designation : designationsToCheck){
                    System.Assert(designation.Ready_For_Publishing__c == false, 'Designation was updated.');
                }                
            }else{
                for(Designation__c designation : designationsToCheck){
                    System.Assert(designation.Ready_For_Publishing__c == true, 'Designation was not updated.');
                }
            }
            Test.stopTest();
        }
    }
    
    @isTest
    public static void checkProductTitleImageURL(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            List<Designation__c> designationList = DesignationsDAO.newInstance().getDesignationsByNameStart('Test Designation', AccessLevel.USER_MODE);
            List<Product2> products = ProductsDAO.newInstance().getProductByDesignationId(new Map<Id,SObject>(designationList).keySet(), AccessLevel.USER_MODE);        
            
            Test.startTest();
            for(Product2 product : products){
                product.Description__c = 'Test Description';
            }
                            
                
            for(Designation__c designation : designationList){
                designation.Ready_For_Publishing__c = true;
            }
            DesignationsDAO.newInstance().updateRecords(designationList, false, AccessLevel.USER_MODE);
            List<Designation__c> designationsToCheck = DesignationsDAO.newInstance().getDesignationsBySetRecordIds(new Map<Id,SObject>(designationList).keySet(), AccessLevel.USER_MODE);
            if(!products.isEmpty()){
                for(Designation__c designation : designationsToCheck){
                    System.Assert(designation.Ready_For_Publishing__c == false, 'Designation was updated.');
                }                
            }else{
                for(Designation__c designation : designationsToCheck){
                    System.Assert(designation.Ready_For_Publishing__c == true, 'Designation was not updated.');
                }
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void checkProductSection1Heading(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            List<Designation__c> designationList = DesignationsDAO.newInstance().getDesignationsByNameStart('Test Designation', AccessLevel.USER_MODE);
            List<Product2> products = ProductsDAO.newInstance().getProductByDesignationId(new Map<Id,SObject>(designationList).keySet(), AccessLevel.USER_MODE);        
                       
            Test.startTest();
            for(Product2 product : products){
                product.Description__c = 'Test Description';
                product.Title_Image_URL__c = 'imageurl.com';
                product.Has_Detail_Page__c = true;
                product.Section_1_Content__c = 'Test Content';
            }
            for(Designation__c designation : designationList){
                designation.Ready_For_Publishing__c = true;
            }
            DesignationsDAO.newInstance().updateRecords(designationList, false, AccessLevel.USER_MODE);
            List<Designation__c> designationsToCheck = DesignationsDAO.newInstance().getDesignationsBySetRecordIds(new Map<Id,SObject>(designationList).keySet(), AccessLevel.USER_MODE);
            if(!products.isEmpty()){
                for(Designation__c designation : designationsToCheck){
                    System.Assert(designation.Ready_For_Publishing__c == false, 'Designation was updated.');
                }                
            }else{
                for(Designation__c designation : designationsToCheck){
                    System.Assert(designation.Ready_For_Publishing__c == true, 'Designation was not updated.');
                }
            }
            Test.stopTest();
        }
    }
    
    @isTest
    public static void checkProductSection1Content(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            List<Designation__c> designationList = DesignationsDAO.newInstance().getDesignationsByNameStart('Test Designation', AccessLevel.USER_MODE);
            List<Product2> products = ProductsDAO.newInstance().getProductByDesignationId(new Map<Id,SObject>(designationList).keySet(), AccessLevel.USER_MODE);        
            
            Test.startTest();
            for(Product2 product : products){
                product.Description__c = 'Test Description';
                product.Title_Image_URL__c = 'imageurl.com';
                product.Has_Detail_Page__c = true;
                product.Section_1_Heading__c = 'Test Heading';
            }
            for(Designation__c designation : designationList){
                designation.Ready_For_Publishing__c = true;
            }
            DesignationsDAO.newInstance().updateRecords(designationList, false, AccessLevel.USER_MODE);
            List<Designation__c> designationsToCheck = DesignationsDAO.newInstance().getDesignationsBySetRecordIds(new Map<Id,SObject>(designationList).keySet(), AccessLevel.USER_MODE);
            System.debug(designationsToCheck);
            if(!products.isEmpty()){
                for(Designation__c designation : designationsToCheck){
                    System.Assert(designation.Ready_For_Publishing__c == false, 'Designation was updated.');
                }                
            }else{
                for(Designation__c designation : designationsToCheck){
                    System.Assert(designation.Ready_For_Publishing__c == true, 'Designation was not updated.');
                }
            }
            Test.stopTest();
        }
    }
    
    @isTest
    public static void checkActiveChildDistributionManagements(){
        System.runAs(TestDataFactoryUser.selectUserAdvancementManager){
            Test.startTest();
            List<Designation__c> designationList = DesignationsDAO.newInstance().getDesignationsByNameStart('Test Designation', AccessLevel.USER_MODE);
            for(Designation__c designation : designationList){
                designation.RecordTypeId = DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID;
                designation.Ready_For_Publishing__c = true;
            }
            
            DesignationsDAO.newInstance().updateRecords(designationList, false, AccessLevel.USER_MODE);
            List<Designation__c> designationsToCheck = DesignationsDAO.newInstance().getDesignationsBySetRecordIds(new Map<Id,SObject>(designationList).keySet(), AccessLevel.USER_MODE);
            for(Designation__c designation : designationsToCheck){
                System.Assert(designation.Ready_For_Publishing__c == false, 'Designation was updated.');
            } 
            Test.stopTest();
        }
    }
}