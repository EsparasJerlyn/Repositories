/**
 * @description  trigger for product request
 * @see ProductRequestTrigger
 *
 * @author Accenture
 *
  * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                              |
      |---------------------------|-----------------------|-----------|---------------------------------------------|
      | roy.nino.s.regala         | June 02, 2022         | DEPP-2863 | Created file                                |
      | arsenio.jr.dayrit         | June 24, 2022         | DEPP-3246 | Added Method for Update Course and Program  |
      | rhea.b.torres             | February 16, 2023     | DEPP-5182 | Implemented Logger and used Database.update |
*/

public without sharing class ProductRequestTriggerHandler implements Disableable, AfterUpdate {


    private static final String PR_COMPLETED = System.Label.PL_ProductRequest_Completed;
    private static final String PR_NOT_PROCEEDING = System.Label.PL_ProductRequest_Not_Proceeding;
    
    /**
     * @description call method to validate related Facilitator Contacts if Image is uploaded on Contact Image
     * @param newItems - List of Product2.Trigger.new
     * @param oldItems - List of Product2.Trigger.old
     */
    public void AfterUpdate(
        Map<Id, SObject> newItems,
        Map<Id, SObject> oldItems
        ) {

        Map<Id, Product2> productToUpdateMap = new Map<Id,Product2>();
        Map<Id, Product2> productToDeactivate = new Map<Id,Product2>();
        Map<Id, hed__Course__c> courseToUpdate = new Map<Id,hed__Course__c>();
        Map<Id, hed__Program_Plan__c> programToUpdate = new Map<Id,hed__Program_Plan__c>();


        Map<Id, Product_Request__c> prodReqNew = (Map<Id, Product_Request__c>)newItems;
        Map<Id, Product_Request__c> prodReqOld = (Map<Id, Product_Request__c>)oldItems;

        List<Id> completedOrNotProceedingPRs = new List<Id>();  

        //check if status is updated and is not proceeding or completed
        for(Id prId: prodReqNew.keySet()){
            if(prodReqNew.get(prId).Product_Request_Status__c != prodReqOld.get(prId).Product_Request_Status__c 
                && (prodReqNew.get(prId).Product_Request_Status__c == PR_NOT_PROCEEDING || 
                prodReqNew.get(prId).Product_Request_Status__c == PR_COMPLETED)){
                    //store all productrequests that are updated to completed or not completed
                    completedOrNotProceedingPRs.add(prId);
                }
        } 

        if(!completedOrNotProceedingPRs.isEmpty()){
            productToDeactivate.putALL(deactivateRelatedProduct(
                completedOrNotProceedingPRs
            ));
            
            courseToUpdate.putALL(updateRelatedCourse(
                completedOrNotProceedingPRs
            ));

            programToUpdate.putALL(updateRelatedProg(
                completedOrNotProceedingPRs
            ));
        

        }
        
        if(!productToDeactivate.keySet().isEmpty()){
            productToUpdateMap.putALL(productToDeactivate);
        }

        if(!productToUpdateMap.keySet().isEmpty()){
            Database.SaveResult[] srList=  Database.update(productToUpdateMap.values(), false);
            for (Database.SaveResult sr : srList) {
                if(!sr.isSuccess()){
                    Logger.error('Method ProductRequestTriggerHandler.AfterUpdate() updating Product records: ').setDatabaseResult(sr);
                }
            }
        }

        if(!courseToUpdate.keySet().isEmpty()){
            Database.SaveResult[] srList=  Database.update(courseToUpdate.values(),false);
            for (Database.SaveResult sr : srList) {
                if(!sr.isSuccess()){
                    Logger.error('Method ProductRequestTriggerHandler.AfterUpdate() updating Course records: ').setDatabaseResult(sr);
                }
            }
        }

        if(!programToUpdate.keySet().isEmpty()){
            Database.SaveResult[] srList=  Database.update(programToUpdate.values(),false);
            for (Database.SaveResult sr : srList) {
                if(!sr.isSuccess()){
                    Logger.error('Method ProductRequestTriggerHandler.AfterUpdate() updating Program Plan records: ').setDatabaseResult(sr);
                }
            }
        }

        if(Logger.getBufferSize() > 0){
            Logger.saveLog();
        }
    }

    /**
     * @description deactive related products
     * @param completedOrNotProceedingPRs - ids of completed and not proceeding PRs
     * @return map of products to be deactivated
     */
    public static Map<Id, Product2> deactivateRelatedProduct(
        List<Id> completedOrNotProceedingPRs 
        ){

        Map<Id,Product2> relatedProductMap = new Map<Id,Product2>();  
        List<Product2> productsList = new List<Product2>();

        //query products to be deactivated
        if(!completedOrNotProceedingPRs.isEmpty()){
            productsList =  [   
                    SELECT Id, Course__r.ProductRequestID__r.Product_Request_Status__c, 
                    Program_Plan__r.Product_Request__r.Product_Request_Status__c
                    FROM Product2 
                    WHERE IsActive = true 
                    AND (Course__r.ProductRequestID__c IN: completedOrNotProceedingPRs 
                    OR Program_Plan__r.Product_Request__c IN: completedOrNotProceedingPRs) 
                    ];
        }

        //deactivate products
        for(Product2 prod: productsList){
            prod.IsActive = false;
            if(    (prod.Course__c != null && 
                    prod.Course__r.ProductRequestID__c != null && 
                    prod.Course__r.ProductRequestID__r.Product_Request_Status__c == PR_NOT_PROCEEDING) ||
                    (prod.Program_Plan__c != null && 
                    prod.Program_Plan__r.Product_Request__c != null && 
                    prod.Program_Plan__r.Product_Request__r.Product_Request_Status__c == PR_NOT_PROCEEDING)
            ){
                prod.End_Date__c = date.Today();
            }
            relatedProductMap.put(prod.Id,prod);
        }

        return relatedProductMap;


    }


    public static Map<Id, hed__Course__c> updateRelatedCourse(
        List<Id> completedOrNotProceedingPRs 
        ){
            Map<Id,hed__Course__c> relatedCourseMap = new Map<Id,hed__Course__c>();
            List<hed__Course__c> courseList = new List<hed__Course__c>();
        
           
            if(!completedOrNotProceedingPRs.isEmpty()){
                courseList =  [   
                        SELECT Id, ProductRequestID__r.Product_Request_Status__c, End_Date__c
                        FROM hed__Course__c 
                        WHERE ProductRequestID__c IN: completedOrNotProceedingPRs
                        ];
            }
    
            for(hed__Course__c cours: courseList){
                if(cours.ProductRequestID__r.Product_Request_Status__c == PR_NOT_PROCEEDING || cours.ProductRequestID__r.Product_Request_Status__c == 'Completed'){
                    cours.End_Date__c = date.Today();
                }
                relatedCourseMap.put(cours.Id,cours);
            }

            return relatedCourseMap;

        }

        public static Map<Id, hed__Program_Plan__c> updateRelatedProg(
            List<Id> completedOrNotProceedingPRs 
            ){
          
                Map<Id,hed__Program_Plan__c> relatedProgramMap = new Map<Id,hed__Program_Plan__c>();
                List<hed__Program_Plan__c> progList = new List<hed__Program_Plan__c>();
    
        
                if(!completedOrNotProceedingPRs.isEmpty()){
                    progList =  [   
                            SELECT Id, Product_Request__r.Product_Request_Status__c , hed__End_Date__c
                            FROM hed__Program_Plan__c 
                            WHERE Product_Request__c IN: completedOrNotProceedingPRs
                            ];
                }
        
                for(hed__Program_Plan__c prog: progList){
                    if(prog.Product_Request__r.Product_Request_Status__c == PR_NOT_PROCEEDING || prog.Product_Request__r.Product_Request_Status__c == 'Completed'){
                        prog.hed__End_Date__c = date.Today();
                    }
                    relatedProgramMap.put(prog.Id,prog);
                }

                return relatedProgramMap;
            }
        
      
    /**
     * @description indicates it the trigger is disabled
     * @return disabled bypass
     */
      public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
      }
      
    }