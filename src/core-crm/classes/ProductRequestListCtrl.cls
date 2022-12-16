/**
 * @description Controller Class for productRequestList LWC
 * @see ../lwc/productRequestList
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | angelika.j.s.galang       | September 30, 2021    | DEPP-40,42           | Created file                 |
      | roy.nino.s.regala         | March 10, 2022        | DEPP-1747            | Updated to suit new datamodel| 
      | eccarius.karl.munoz       | March 23, 2022        | DEPP-1888            | Added update method for      |
      |                           |                       |                      | Not Proceeding               | 
      | john.m.tambasen           | July 05, 2022         | DEPP-2590            | SOA product request          |
      | eccarius.karl.munoz       | July 11, 2022         | DEPP-2035            | Added Educational Consultancy|
      | john.m.tambasen           | July 26, 2022         | DEPP-2590            | added corporate bundle       |
*/
public with sharing class ProductRequestListCtrl {
    private static string PR_PROGRAM = System.Label.RT_ProductRequest_Program;
    
    /**
     * @description do callout to loqate
     * @param productSpecificationId - id of productSpecification
     * @return parent and child product requests
     */
    @AuraEnabled(cacheable=true)    
    public static ProductRequestData getProductRequests(Id productSpecificationId){
        AuraHandledException auraEx = new AuraHandledException('Error Message');  
        auraEx.setMessage('Error while getting product requests.');
        try{

            ProductRequestData finalProductRequests = new ProductRequestData();
            List<TableData> finalTableData = new List<TableData>();
            String productSpecStage;

            Set<Id> allRPRParentIds = new Set<Id>();
            Set<Id> allRPRChildIds = new Set<Id>();
            Set<Id> childPRIds = new Set<Id>();
            Map<Id, List<Product_Request__c>> parentChildPRMap = new Map<Id, List<Product_Request__c>>();
            Map<Id, List<Product_Request__c>> childGrandchildPRMap = new Map<Id, List<Product_Request__c>>();

            //get all related product request records where it is related to the product specification
            List<Related_Product_Request__c> allRelatedProductRequestList = new List<Related_Product_Request__c>(
                [
                    SELECT Id, Program__c, Course__c
                    FROM Related_Product_Request__c
                    WHERE Program__r.Product_Specification__c =: productSpecificationId
                    ORDER BY LastModifiedDate asc
                ]
            );

            //loop to get all the parent only
            for(Related_Product_Request__c currentRPR: allRelatedProductRequestList){
                allRPRChildIds.add(currentRPR.Course__c);
            }

            //get all product request related to the product specification
            Map<Id, Product_Request__c> allProductRequestMap = new Map<Id, Product_Request__c>(
                [
                    SELECT Id, Name, RecordType.Name, Product_Request_Name__c, Not_Proceeding_Comments__c,
                           Product_Request_Status__c,RecordType.DeveloperName,  
                           Product_Specification__c, OwnerId, Owner.Name, 
                           Product_Specification__r.RecordType.DeveloperName,
                           Product_Specification__r.Stage__c,
                           (SELECT Id, Name, Program_Delivery_Structure__c FROM Program_Plans__r),
                           (SELECT Id, Name FROM Courses__r),
                           (SELECT Id, Name FROM Buyer_Groups__r),
                           (SELECT Id, Name FROM Consultancies__r),
                           (SELECT Id, Name FROM Assets__r)
                    FROM Product_Request__c
                    WHERE Product_Specification__c =: productSpecificationId
                    OR Id In: allRPRChildIds
                    ORDER BY LastModifiedDate asc
                ]
            );

            //get all related product request records for Parent-Child relationship only
            List<Related_Product_Request__c> parentChildRPRList = new List<Related_Product_Request__c>(
                [
                    SELECT Id, Program__c, Course__c
                    FROM Related_Product_Request__c
                    WHERE Program__r.Product_Specification__c =: productSpecificationId
                    AND Program__c NOT IN :allRPRChildIds
                    ORDER BY LastModifiedDate asc
                ]
            );

            //loop to get all the child only
            for(Related_Product_Request__c currentRPR: parentChildRPRList){
                allRPRParentIds.add(currentRPR.Id);
            }

            //get all related product request records for Child-Grandchild relationship only
            List<Related_Product_Request__c> childGrandchildRPRList = new List<Related_Product_Request__c>(
                [
                    SELECT Id, Program__c, Course__c
                    FROM Related_Product_Request__c
                    WHERE Program__r.Product_Specification__c =: productSpecificationId
                    AND Id NOT IN :allRPRParentIds
                    ORDER BY LastModifiedDate asc
                ]
            );

            //loop to create a map for all the Parent-Child only
            for(Related_Product_Request__c currentRPR: parentChildRPRList){

                //create a map if it doesnt exist yet
                if(!parentChildPRMap.containsKey(currentRPR.Program__c)){
                    parentChildPRMap.put(currentRPR.Program__c, new List<Product_Request__c>());
                }

                //add child to the list
                parentChildPRMap.get(currentRPR.Program__c).add(allProductRequestMap.get(currentRPR.Course__c));

                //add to Set of Ids to skip when generating a table for parents
                childPRIds.add(currentRPR.Course__c);
            }

            //loop to create a map for all the Child-Grandchild only
            for(Related_Product_Request__c currentRPR: childGrandchildRPRList){

                //create a map if it doesnt exist yet
                if(!childGrandchildPRMap.containsKey(currentRPR.Program__c)){
                    childGrandchildPRMap.put(currentRPR.Program__c, new List<Product_Request__c>());
                }

                //add child to the list
                childGrandchildPRMap.get(currentRPR.Program__c).add(allProductRequestMap.get(currentRPR.Course__c));

                //add to Set of Ids to skip when generating a table for parents
                childPRIds.add(currentRPR.Course__c);
            }

            //loop on all the product requests related to the current specification
            for(Product_Request__c currentPR: allProductRequestMap.values()){

                //set the value for stage if nto set yet
                if(productSpecStage == null){
                    productSpecStage = currentPR.Product_Specification__r.Stage__c;
                }

                Boolean goNext = false;

                //check all the child if current PR is there, skip loop since we are going to add this PR under the parent
                for(Id currentPRId : childPRIds){
                    if(currentPR.Id == currentPRId){
                        goNext = true;
                        break;
                    }
                }

                //skip current iteration
                if(goNext){
                    continue;
                }

                TableData tableDataTemp = new TableData();

                //check if current Product Request is in not in the map, meaning need to add the data without the child
                if(!parentChildPRMap.containsKey(currentPR.Id) && !childGrandchildPRMap.containsKey(currentPR.Id)){
                    tableDataTemp.recordId = currentPR.Id;
                    tableDataTemp.id = currentPR.Name;
                    tableDataTemp.idUrl = '/' + currentPR.Id;
                    tableDataTemp.recordType = currentPR.RecordType.Name;
                    tableDataTemp.owner = currentPR.Owner.Name;
                    tableDataTemp.ownerUrl = '/' + currentPR.OwnerId;
                    tableDataTemp.stage = currentPR.Product_Request_Status__c;
                    tableDataTemp.notProceedingComments = currentPR.Not_Proceeding_Comments__c;

                    //set product name based on the record type
                    if(!currentPR.Courses__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Courses__r[0].Name;

                    } else if(!currentPR.Program_Plans__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Program_Plans__r[0].Name;

                        //set prescribed or flexible for program
                        if(currentPR.Program_Plans__r[0].Program_Delivery_Structure__c == 'Flexible Program'){
                            tableDataTemp.isFlexibleProgram = true;

                        } else if(currentPR.Program_Plans__r[0].Program_Delivery_Structure__c == 'Prescribed Program'){
                            tableDataTemp.isPrescribedProgram = true;
                        }
                    } else if(!currentPR.Assets__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Assets__r[0].Name;

                    } else if(!currentPR.Buyer_Groups__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Buyer_Groups__r[0].Name;

                        tableDataTemp.isSOA = true;

                    } else if(!currentPR.Consultancies__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Consultancies__r[0].Name;

                        tableDataTemp.isEducCons = true;

                    } else {
                        tableDataTemp.productName = currentPR.Product_Request_Name__c;
                    }

                // if the current product request is mapped with a Child
                } else if(parentChildPRMap.containsKey(currentPR.Id)){

                    tableDataTemp.recordId = currentPR.Id;
                    tableDataTemp.id = currentPR.Name;
                    tableDataTemp.idUrl = '/' + currentPR.Id;
                    tableDataTemp.recordType = currentPR.RecordType.Name;
                    tableDataTemp.owner = currentPR.Owner.Name;
                    tableDataTemp.ownerUrl = '/' + currentPR.OwnerId;
                    tableDataTemp.stage = currentPR.Product_Request_Status__c;
                    tableDataTemp.notProceedingComments = currentPR.Not_Proceeding_Comments__c;

                    //set product name based on the record type
                    if(!currentPR.Courses__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Courses__r[0].Name;

                    } else if(!currentPR.Program_Plans__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Program_Plans__r[0].Name;

                        //set prescribed or flexible for program
                        if(currentPR.Program_Plans__r[0].Program_Delivery_Structure__c == 'Flexible Program'){
                            tableDataTemp.isFlexibleProgram = true;

                        } else if(currentPR.Program_Plans__r[0].Program_Delivery_Structure__c == 'Prescribed Program'){
                            tableDataTemp.isPrescribedProgram = true;
                        }

                    } else if(!currentPR.Buyer_Groups__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Buyer_Groups__r[0].Name;

                        tableDataTemp.isSOA = true;

                    } else if(!currentPR.Consultancies__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Consultancies__r[0].Name;

                        tableDataTemp.isEducCons = true;

                    } else if(!currentPR.Assets__r.isEmpty()){
                        tableDataTemp.productName = currentPR.Assets__r[0].Name;

                    } else {
                        tableDataTemp.productName = currentPR.Product_Request_Name__c;
                    }

                    //get all the child of the current product request
                    List<Product_Request__c> childList = parentChildPRMap.get(currentPR.Id);
                    List<TableData> tableDataChildList = new List<TableData>();

                     //loop on all the child product requests related to the current specification
                    for(Product_Request__c currentChildPR: childList){
                        if(currentChildPR == null){ continue; }
                        
                        TableData tableDataChildTemp = new TableData();

                        tableDataChildTemp.recordId = currentChildPR.Id;
                        tableDataChildTemp.id = currentChildPR.Name;
                        tableDataChildTemp.idUrl = '/' + currentChildPR.Id;
                        tableDataChildTemp.recordType = currentChildPR.RecordType.Name;
                        tableDataChildTemp.owner = currentChildPR.Owner.Name;
                        tableDataChildTemp.ownerUrl = '/' + currentChildPR.OwnerId;
                        tableDataChildTemp.stage = currentChildPR.Product_Request_Status__c;
                        tableDataChildTemp.notProceedingComments = currentChildPR.Not_Proceeding_Comments__c;

                        //set product name based on the record type
                        if(!currentChildPR.Courses__r.isEmpty()){
                            tableDataChildTemp.productName = currentChildPR.Courses__r[0].Name;

                        } else if(!currentChildPR.Program_Plans__r.isEmpty()){
                            tableDataChildTemp.productName = currentChildPR.Program_Plans__r[0].Name;

                            //set prescribed or flexible for program
                            if(currentChildPR.Program_Plans__r[0].Program_Delivery_Structure__c == 'Flexible Program'){
                                tableDataChildTemp.isFlexibleProgram = true;

                            } else if(currentChildPR.Program_Plans__r[0].Program_Delivery_Structure__c == 'Prescribed Program'){
                                tableDataChildTemp.isPrescribedProgram = true;
                            }

                        } else if(!currentChildPR.Buyer_Groups__r.isEmpty()){
                            tableDataChildTemp.productName = currentChildPR.Buyer_Groups__r[0].Name;

                            tableDataChildTemp.isSOA = true;

                        } else if(!currentChildPR.Consultancies__r.isEmpty()){
                            tableDataChildTemp.productName = currentChildPR.Consultancies__r[0].Name;

                            tableDataChildTemp.isEducCons = true;

                        } else if(!currentPR.Assets__r.isEmpty()){
                            tableDataChildTemp.productName = currentPR.Assets__r[0].Name;

                        } else {
                            tableDataChildTemp.productName = currentChildPR.Product_Request_Name__c;
                        }


                        //add grand child if exits
                        if(childGrandchildPRMap.containsKey(currentChildPR.Id)){

                            //get all the grand child of the current product request
                            List<Product_Request__c> grandchildList = childGrandchildPRMap.get(currentChildPR.Id);
                            List<TableData> tableDataGrandchildList = new List<TableData>();

                            //loop on all the product requests related to the current specification allProductRequestMap
                            for(Product_Request__c currentGrandchildPR: grandchildList){

                                TableData tableDataGrandchildTemp = new TableData();

                                tableDataGrandchildTemp.recordId = currentGrandchildPR.Id;
                                tableDataGrandchildTemp.id = currentGrandchildPR.Name;
                                tableDataGrandchildTemp.idUrl = '/' + currentGrandchildPR.Id;
                                tableDataGrandchildTemp.recordType = currentGrandchildPR.RecordType.Name;
                                tableDataGrandchildTemp.owner = currentGrandchildPR.Owner.Name;
                                tableDataGrandchildTemp.ownerUrl = '/' + currentGrandchildPR.OwnerId;
                                tableDataGrandchildTemp.stage = currentGrandchildPR.Product_Request_Status__c;
                                tableDataGrandchildTemp.notProceedingComments = currentGrandchildPR.Not_Proceeding_Comments__c;

                                //set product name based on the record type
                                if(!currentGrandchildPR.Courses__r.isEmpty()){
                                    tableDataGrandchildTemp.productName = currentGrandchildPR.Courses__r[0].Name;

                                } else if(!currentGrandchildPR.Program_Plans__r.isEmpty()){
                                    tableDataGrandchildTemp.productName = currentGrandchildPR.Program_Plans__r[0].Name;

                                    //set prescribed or flexible for program
                                    if(currentGrandchildPR.Program_Plans__r[0].Program_Delivery_Structure__c == 'Flexible Program'){
                                        tableDataGrandchildTemp.isFlexibleProgram = true;

                                    } else if(currentGrandchildPR.Program_Plans__r[0].Program_Delivery_Structure__c == 'Prescribed Program'){
                                        tableDataGrandchildTemp.isPrescribedProgram = true;
                                    }

                                } else if(!currentGrandchildPR.Buyer_Groups__r.isEmpty()){
                                    tableDataGrandchildTemp.productName = currentGrandchildPR.Buyer_Groups__r[0].Name;

                                    tableDataGrandchildTemp.isSOA = true;

                                } else if(!currentGrandchildPR.Consultancies__r.isEmpty()){
                                    tableDataGrandchildTemp.productName = currentGrandchildPR.Consultancies__r[0].Name;

                                    tableDataGrandchildTemp.isEducCons = true;

                                } else if(!currentPR.Assets__r.isEmpty()){
                                    tableDataGrandchildTemp.productName = currentPR.Assets__r[0].Name;

                                } else {
                                    tableDataGrandchildTemp.productName = currentGrandchildPR.Product_Request_Name__c;
                                }

                                tableDataGrandchildList.add(tableDataGrandchildTemp);
                            }

                            tableDataChildTemp.children = tableDataGrandchildList;
                        }

                        tableDataChildList.add(tableDataChildTemp);
                    }

                    tableDataTemp.children = tableDataChildList;
                }

                finalTableData.add(tableDataTemp);
            }

            finalProductRequests.productRequestData = finalTableData;
            finalProductRequests.parentChildPRMap = parentChildPRMap;
            finalProductRequests.childGrandchildPRMap = childGrandchildPRMap;
            finalProductRequests.productSpecStage = productSpecStage;

            return finalProductRequests;

        }catch(Exception e){ throw auraEx; }
    }
    
    /**
     * @description Updates Registration details of students
    * @param id - id of product request selected
    * @param recordType - record type of product request selected
    * @param notProceedingComments - not proceeding comments inputted from modal
    * @param ifFlexibleProgram - determines flexible program
    * @return String
    */
    @AuraEnabled
    public static String updateProdReqToNotProceeding(String id, String recordType, String notProceedingComment, Boolean ifFlexibleProgram){
        String response='';
        List<Product_Request__c> productRequestsToUpdate = new List<Product_Request__c>();    
        Product_Request__c productRequest = new Product_Request__c();
        productRequest.id = id;
        productRequest.Not_Proceeding_Comments__c = notProceedingComment;
        productRequest.Product_Request_Status__c = 'Not Proceeding';
        productRequestsToUpdate.add(productRequest);

        if(recordType == PR_PROGRAM && !ifFlexibleProgram){
            List<Related_Product_Request__c> relatedProducts = [SELECT Id, Course__c FROM Related_Product_Request__c where Program__c =: id];            
            for(Related_Product_Request__c relatedProduct : relatedProducts){
                Product_Request__c prodReq = new Product_Request__c();
                prodReq.Id = relatedProduct.Course__c;
                prodReq.Product_Request_Status__c = 'Not Proceeding';
                prodReq.Not_Proceeding_Comments__c = notProceedingComment;
                productRequestsToUpdate.add(prodReq);
            }
        }

        try{
            update productRequestsToUpdate;
            response = 'Success';
        }catch(Exception e){
            response = 'The following exception has occurred: ' + e.getMessage();
        }

        return response;
    }
    
    /**
     * @description wrapper that contains table grid data to be shown in front end
     */
    public class ProductRequestData{
        @AuraEnabled public List<TableData> productRequestData;
        @AuraEnabled public Map<Id,List<Product_Request__c>> parentChildPRMap;
        @AuraEnabled public Map<Id,List<Product_Request__c>> childGrandchildPRMap;
        @AuraEnabled public String productSpecStage;
    }

    /**
     * @description wrapper that contains table grid data to be shown in front end
     */
    public class TableData{
        @AuraEnabled public String recordId;
        @AuraEnabled public String id;
        @AuraEnabled public String idUrl;
        @AuraEnabled public String recordType;
        @AuraEnabled public String owner;
        @AuraEnabled public String ownerUrl;
        @AuraEnabled public String stage;
        @AuraEnabled public String notProceedingComments;
        @AuraEnabled public String productName;
        @AuraEnabled public Boolean isFlexibleProgram = false;
        @AuraEnabled public Boolean isPrescribedProgram = false;
        @AuraEnabled public Boolean isSOA = false;
        @AuraEnabled public Boolean isEducCons = false;
        // @AuraEnabled public String courseName;
        @AuraEnabled public String productSpecStage;
        @AuraEnabled public List<TableData> children;
    }
}
