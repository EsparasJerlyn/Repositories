/**
 * @description Controller Class for addProductRequest LWC
 * @see ../lwc/addProductRequest
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                       |
      |---------------------------|-----------------------|----------------------|--------------------------------------|
      | roy.nino.s.regala         | September 28, 2021    | DEPP-40,42           | Created file                         | 
      | angelika.j.s.galang       | December 17, 2021     | DEPP-1088,1096       | Modified to handle OPE records       | 
      | adrian.c.habasa           | January  20, 2022     | DEPP-1471            | Added method to get QUTeX Account Id | 
      | roy.nino.s.regala         | March 10, 2022        | DEPP-1747            | Added search method                  |

 */
public with sharing class AddProductRequestCtrl {

    /**
     * @description get list of users searched 
     * @param filterString - search string for filter
     * @return list of users formatted for customSearch
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getSearchedUsers(String filterString){
        filterString = '%' + filterString + '%';
        List<Map<String,String>> userMap = new List<Map<String,String>>();
        
        for(User usr : [
            SELECT Id, Name, Division
            FROM User
            WHERE (
                Name LIKE :filterString OR
                Name = :filterString
            )
        ]){
            userMap.add(new Map<String,String>{
                'id' => usr.Id,
                'label' => usr.Name,
                'meta' => usr.Division
            });
        }
        return userMap;
    }   

    /**
     * @description get record type settings and field layout settings 
     * @param filterString - search string for filter
     * @param filterPRList - all current children of program
     * @param prodSpecRecordType - recordtype of program
     * @return list product request
     */
    @AuraEnabled(cacheable=true)
    public static List<Product_Request__c> getSearchedCourseProductRequests(String filterString, List<Product_Request__c> filterPRList, String prodSpecRecordType){
        filterString = '%' + filterString + '%';
        
        List<Id> productRequestIds = new List<Id>();

        for(Product2 product: [ SELECT Id, Course__c, Course__r.ProductRequestID__c, IsActive
                                FROM Product2 
                                WHERE (Course__r.Name LIKE :filterString 
                                OR Course__r.Name =:filterString)
                                AND Course__r.ProductRequestID__c NOT IN: filterPRList
                                AND Course__r.ProductRequestID__r.Product_Specification__r.RecordType.DeveloperName =: prodSpecRecordType
                                AND Course__r.ProductRequestID__r.OPE_Program_Plan_Type__c != 'Prescribed Program'
                                AND IsActive = true
                                ]){

            productRequestIds.add(product.Course__r.ProductRequestID__c);
        }
        
        List<Product_Request__c> productRequestResults = new List<Product_Request__c>([SELECT ID,Name,
                                                                                        (SELECT Id, Name FROM Courses__r), RecordType.Name 
                                                                                        FROM Product_Request__c 
                                                                                        WHERE ID IN: productRequestIds]);
        return productRequestResults;
    }

    /**
     * @description get record type settings and field layout settings 
     * @param objectType - object api name of the current record the lwc is at
     * @param filter - id of record types to query
     * @return list of record type mapping
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getRecordTypes(String objectType){
        List<Map<String,String>> recordTypeMap = new List<Map<String,String>>();
        
        for(RecordType rec : [
            SELECT Id, Name, Description
            FROM RecordType
            WHERE SobjectType =: objectType
        ]){
            recordTypeMap.add(new Map<String,String>{
                'label' => rec.Name,
                'description' => rec.Description,
                'value' => rec.Id
            });
        }
        return recordTypeMap;
    }   

    /**
     * @description get record type settings and field layout settings 
     * @param objectString - object api name of the current record the lwc is at
     * @return metadata mapping
     */
    @AuraEnabled(cacheable=true)
    public static MetadataDetails getFieldLayoutSettings(String objectString, Boolean forOpe){
        try {
            MetadataDetails metadata = new MetadataDetails();
            Map<String,List<SectionDetails>> sectionMap = new Map<String,List<SectionDetails>>();
            Map<String,RecordTypeOrderDetails> recordTypeOrderMap = new Map<String,RecordTypeOrderDetails>();
            SectionDetails section;
            List<FieldDetails> colDetails;
            RecordTypeOrderDetails recordTypeOrder;

            for(Field_Layout_Setting__mdt fls:
                [
                    SELECT Record_Type_Setting__r.Object_Type__c, Record_Type_Setting__r.Label, Record_Type_Setting__r.Description__c, 
                    Order__c, Label, Record_Type_Setting__r.Order__c, Left_Column_Long__c, Right_Column_Long__c, Single_Column_Long__c 
                    FROM Field_Layout_Setting__mdt
                    WHERE Record_Type_Setting__r.Object_Type__c =: objectString AND Record_Type_Setting__r.For_OPE__c =: forOpe
                ])
            {
                //setup recordtype details                                    
                recordTypeOrder = new RecordTypeOrderDetails();
                recordTypeOrder.recordTypeName = fls.Record_Type_Setting__r.Label;
                recordTypeOrder.order = Integer.valueOf(fls.Record_Type_Setting__r.Order__c);
                recordTypeOrder.description = fls.Record_Type_Setting__r.Description__c;
                recordTypeOrderMap.put(fls.Record_Type_Setting__r.Label,recordTypeOrder);
                //setup layout/section details
                section = new SectionDetails();
                section.label = fls.Label;
                section.order = Integer.valueOf(fls.Order__c);
                colDetails = new List<FieldDetails>();
                if(fls.Left_Column_Long__c != null){
                    colDetails.addAll((List<FieldDetails>)JSON.deserialize(fls.Left_Column_Long__c,List<FieldDetails>.class));
                }
                section.leftColumn = colDetails;
                colDetails = new List<FieldDetails>();
                if(fls.Right_Column_Long__c != null){
                    colDetails.addAll((List<FieldDetails>)JSON.deserialize(fls.Right_Column_Long__c,List<FieldDetails>.class));
                }
                section.rightColumn = colDetails;
                colDetails = new List<FieldDetails>();
                if(fls.Single_Column_Long__c != null){
                    colDetails.addAll((List<FieldDetails>)JSON.deserialize(fls.Single_Column_Long__c,List<FieldDetails>.class));
                }
                section.singleColumn =  colDetails;
                if(!sectionMap.containsKey(fls.Record_Type_Setting__r.Label)){
                    sectionMap.put(fls.Record_Type_Setting__r.Label, new List<SectionDetails>());
                }
                sectionMap.get(fls.Record_Type_Setting__r.Label).add(section);
            }
           
            metadata.recordTypeOrderedList = recordTypeOrderMap.values();
            metadata.fieldLayoutMap = sectionMap;
            if(!metadata.recordTypeOrderedList.isEmpty() && !metadata.fieldLayoutMap.isEmpty()){
                return metadata;
            }else{
                AuraHandledException auraEx = new AuraHandledException('Error');
                auraEx.setMessage('Error while getting record type and layout mapping.');
                throw auraEx;
            }
        } catch (Exception e) {
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage('Error while getting record type and layout mapping.');
            throw auraEx;
        }
    }

    /**
     * @description holds data map to arange record types and fields on lightning record form
     */
    public class MetadataDetails {
        @AuraEnabled
        public List<RecordTypeOrderDetails> recordTypeOrderedList;
        @AuraEnabled
        public Map<String,List<SectionDetails>> fieldLayoutMap;
    }

    /**
     * @description holds data for the fields on the form
     */
    public class SectionDetails {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public Integer order;
        @AuraEnabled
        public List<FieldDetails> leftColumn;
        @AuraEnabled
        public List<FieldDetails> rightColumn;
        @AuraEnabled
        public List<FieldDetails> singleColumn;
    }

    /**
     * @description holds recordtype details and order
     */
    public class RecordTypeOrderDetails {
        @AuraEnabled
        public String recordTypeName;
        @AuraEnabled
        public Integer order;
        @AuraEnabled
        public String description;

    }

    /**
     * @description holds data for the field details and attributes
     */
    public class FieldDetails {
        @AuraEnabled
        public String field;
        @AuraEnabled
        public Boolean mandatory;
        @AuraEnabled
        public Boolean isrecordtype;
    }

     /**
     * @description gets id of QUTeX Account
     */
    @AuraEnabled(cacheable=true)
    public static String getAccountId(){
      Account acct = [Select Id from Account WHERE Name ='QUTeX Products' LIMIT 1];
      return acct.Id;
   }
}