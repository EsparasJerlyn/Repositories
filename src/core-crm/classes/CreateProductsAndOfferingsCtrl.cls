/**
 * @description Controller Class for createProductsAndOfferings LWC
 * @see ../lwc/createProductsAndOfferings
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                            |
      |---------------------------|-----------------------|----------------------|-------------------------------------------|
      | adrian.c.habasa           | October 18, 2021      | DEPP-476             | Created file                              | 
      | eugene.andrew.abuan       | November 9, 2021      | DEPP-35              | Added getProductRequests method to        |   
      |                           |                       |                      | Retrive all Product Request with Parent   | 
      | roy.nino.s.reagla         | November 15, 2021     | DEPP-362,38,37,35    | Added logic for program request           |                                                               
 */
public with sharing class CreateProductsAndOfferingsCtrl {

    private static String programRequest = 'Program';

    /**`
     * @description get List of courses, products, and course offerings related to a ProductRequest
     * @param Product Request Record Id
     * @return list of course, Map of Course offerings and Map of Products
     */
    @AuraEnabled(cacheable=true)
    public static CourseWithOfferings getRelatedCourse(Id productRequestId)
    {   AuraHandledException auraEx = new AuraHandledException('Error Message');  
        auraEx.setMessage('Error while getting Data.');
            try{
                CourseWithOfferings allCourseData = new CourseWithOfferings();
                
                Map<Id,List<hed__Course_Offering__c>> coursesWithOffering = new Map<Id,List<hed__Course_Offering__c>>();
                Map<Id,List<Product2>> coursesWithProduct = new Map<Id,List<Product2>>();
                Map<Id,List<Product2>> programPlanWithProduct = new Map<Id,List<Product2>>();
                List<Product_Request__c> childAndParentProdRequestList = new List<Product_Request__c>();
                Map<Id,Product_Request__c> childAndParentProdRequestMap = new Map<Id,Product_Request__c>([SELECT Id, Name, RecordType.DeveloperName, RecordTypeId, Product_Request_Status__c, 
                                                                                                    Parent_Product_Request__c, Parent_Product_Request__r.Name, Product_Request_Name__c, 
                                                                                                    Create_Offering_Complete__c, Create_Product_Complete__c, Program_Structure_Complete__c
                                                                                                    FROM Product_Request__c
                                                                                                    WHERE Id =: productRequestId 
                                                                                                    OR Parent_Product_Request__c =: productRequestId]);
                                                                                            
                List<hed__Program_Plan__c> programPlanWithOfferingList = new List<hed__Program_Plan__c>([SELECT Id, Name, Program_Type__c, hed__Start_Date__c, hed__End_Date__c, 
                                                                                                        (SELECT Id, Name, Start_Date__c, End_Date__c, hed_Program_Plan__c,hed_Capacity__c,Facility__c from Program_Offering__r)
                                                                                                        FROM hed__Program_Plan__c WHERE Product_Request__c =: productRequestId]);

                if(childAndParentProdRequestMap.get(productRequestId).RecordType.DeveloperName == programRequest){
                    childAndParentProdRequestList = childAndParentProdRequestMap.values();
                }else{
                    childAndParentProdRequestList.add(childAndParentProdRequestMap.get(productRequestId));
                } 

                List<hed__Course__c> coursesList =new List<hed__Course__c>([SELECT Id,Name,RecordType.Name, Start_Date__c, End_Date__c,
                                                                        (SELECT Id, hed__Sequence__c, hed__Category__c from hed__Plan_Requirements__r)
                                                                        FROM hed__Course__c 
                                                                        WHERE ProductRequestID__c in:childAndParentProdRequestList]);

                List<hed__Course_Offering__c> offeringlist = new List<hed__Course_Offering__c>([SELECT Id,Name,hed__Start_Date__c,hed__End_Date__c,
                                                                        hed__Course__c,hed__Course__r.Name,hed__Course__r.RecordType.Name,hed__Term__c,
                                                                        hed__Section_ID__c,hed__Capacity__c,hed__Time_Block__c, hed__Faculty__c
                                                                        FROM hed__Course_Offering__c
                                                                        WHERE hed__Course__c in:coursesList]);

                List<Product2> productlist = new List<Product2>([SELECT Id,Name,Course__c, Program_Plan__c, Start_Date__c, End_Date__c, Description, IsActive, ProductCode, Family,
                                                                (SELECT UnitPrice FROM PricebookEntries WHERE Pricebook2.IsStandard = true AND IsActive = true)  
                                                                FROM Product2 WHERE Course__c in:coursesList OR Program_Plan__c in:programPlanWithOfferingList]);

               
                for(hed__Course_Offering__c offering :offeringlist)
                {
                    if(!coursesWithOffering.containsKey(offering.hed__Course__c))
                    {
                        coursesWithOffering.put(offering.hed__Course__c,new List<hed__Course_Offering__c>());
                    }
                    coursesWithOffering.get(offering.hed__Course__c).add(offering);
                }
                

                for(Product2 product : productlist)
                {   
                    if(product.Program_Plan__c != null){
                        if(!programPlanWithProduct.containsKey(product.Program_Plan__c)){
                            programPlanWithProduct.put(product.Program_Plan__c, new List<Product2>());
                        }
                        programPlanWithProduct.get(product.Program_Plan__c).add(product);
                    }
                    
                    if(product.Course__c != null){
                        if(!coursesWithProduct.containsKey(product.Course__c))
                        {
                            coursesWithProduct.put(product.Course__c,new List<Product2>());
                        }
                        coursesWithProduct.get(product.Course__c).add(product);
                    }
                }

                allCourseData.courseList = coursesList;
                allCourseData.offeringMap = coursesWithOffering;
                allCourseData.productMap = coursesWithProduct;
                allCourseData.productRequestList = childAndParentProdRequestList;
                allCourseData.programPlanList = programPlanWithOfferingList;
                allCourseData.programPlanProductMap = programPlanWithProduct;
                return allCourseData;

            }catch(Exception e){ throw auraEx; }
    }

    /**
     * @description update Product Request records
     * @param prToInsert - product request list to update
     */
    @AuraEnabled
    public static void updateProductRequests(List<Product_Request__c> prToUpdate){
        if(!prToUpdate.isEmpty()){
            update(prToUpdate);
        }
    }

    /**
     * @description insert Plan Requirement records
     * @param planRequirementToUpdate - plan requirement list to update
     */
    @AuraEnabled
    public static void upsertProgramPlanAndPlanRequirement(List<hed__Plan_Requirement__c> recordsToUpsert, hed__Program_Plan__c recordToUpdate){
        if(!recordsToUpsert.isEmpty()){
            upsert(recordsToUpsert);
        }
        if(recordToUpdate != null){
            update(recordToUpdate);
        }
    }

    //wrapper class, Holds List of Courses, Map of Offerings and Map of Products
    public class CourseWithOfferings{
        @AuraEnabled
        public List<hed__Course__c> courseList;
        @AuraEnabled
        public Map<Id,List<hed__Course_Offering__c>> offeringMap;
        @AuraEnabled
        public Map<Id,List<Product2>> productMap;
        @AuraEnabled
        public List<Product_Request__c> productRequestList;
        @AuraEnabled
        public List<hed__Program_Plan__c> programPlanList;
        @AuraEnabled
        public Map<Id,List<Product2>> programPlanProductMap;
    }
}