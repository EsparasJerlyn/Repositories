/**
 * @description Batch class that updates related Product Request
 *              to In Delivery when one of related Offerings' Start Date <= Today
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | angelika.j.s.galang		       | March 15, 2022        | DEPP-1890              | Created file                 | 
      |                                |                       |                        |                              | 
 */
public class OfferingStartDateBatch implements Database.Batchable<sObject>{

    private static final String COURSE_OFFERING_API_NAME = hed__Course_Offering__c.SObjectType.getDescribe().getLocalName();
    private static final String PROGRAM_OFFERING_API_NAME = Program_Offering__c.SObjectType.getDescribe().getLocalName();
    private static final String PR_RELEASE = System.Label.PL_ProductRequest_Release;
    private static final String PR_IN_DELIVERY = System.Label.PL_ProductRequest_InDelivery;
    private static final Map<String,Map<String,String>> OFFERING_MAP = new Map<String,Map<String,String>>
        {
            COURSE_OFFERING_API_NAME => new Map<String,String>{
                'fields' => 'hed__Course__r.ProductRequestID__c',
                'startDate' => 'hed__Start_Date__c',
                'parent' => 'hed__Course__r',
                'productRequest' => 'ProductRequestID__c',
                'status' => 'hed__Course__r.ProductRequestID__r.Product_Request_Status__c'
            },
            PROGRAM_OFFERING_API_NAME => new Map<String,String>{
                'fields' => 'hed_Program_Plan__r.Product_Request__c',
                'startDate' => 'Start_Date__c',
                'parent' => 'hed_Program_Plan__r',
                'productRequest' => 'Product_Request__c',
                'status' => 'hed_Program_Plan__r.Product_Request__r.Product_Request_Status__c'
            }
        };

    private String offeringType;
    private Map<String,String> queryMapping; 

    /**
    * @description constructor for batch class
    * @param objectType - either course offering or program offering api name
    */
    public OfferingStartDateBatch(String objectType){
        offeringType = objectType;
        queryMapping = OFFERING_MAP.get(objectType);
    }

    /**
    * @description Method to query the product offering records
    * @param bc - BatchableContext
    * @return query - filtered query of product offering records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 
            'SELECT ' + queryMapping.get('fields') +
            ' FROM ' + offeringType +
            ' WHERE ' + queryMapping.get('startDate') + ' <= TODAY' +
            ' AND ' + queryMapping.get('status') + ' = \'' + PR_RELEASE + '\' ';
        return Database.getQueryLocator(query);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param offeringList - List of product offerings
    * @return query - filtered query of product offering records
    */
    public void execute(Database.BatchableContext bc, List<sObject> offeringList){
        try{ 
            Set<Id> productRequestIDs = new Set<Id>();
            for(SObject offering : offeringList){
                productRequestIDs.add( (Id)
                    offering.getSObject(
                        queryMapping.get('parent')
                    ).get(
                        queryMapping.get('productRequest')
                    )
                );
            }
            List<Product_Request__c> productRequestList = new List<Product_Request__c>(
                [
                    SELECT Id 
                    FROM Product_Request__c
                    WHERE Id IN :productRequestIDs
                ]
            );     
            
            if(!productRequestList.isEmpty()){
                //Setting Product Request Status to In Delivery
                for(Product_Request__c productRequest : productRequestList){
                    productRequest.Product_Request_Status__c = PR_IN_DELIVERY;
                }
                update(productRequestList);
            }
        }catch(Exception e){
           System.debug(LoggingLevel.DEBUG, 'OfferingStartDateBatch Error: ' + e.getMessage());//NOPMD
        }
    }

    public void finish(Database.BatchableContext bc) {}//NOPMD
}
