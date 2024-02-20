/**
 * @description Controller class for Product Offering LWC
 *
 * @see ../lwc/productOffering
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                |
      |---------------------------|-----------------------|--------------|-----------------------------------------------|
      | angelika.j.s.galang       | February 8, 2022      | DEPP-1258    | Created file                                  | 
      | roy.nino.s.regala         | April 20, 2022        | DEPP-2138    | Updated to enable user to search contacts     |
      | john.m.tambasen           | August, 16 2022       | DEPP-1946    | Single/Group Coaching changes                 |
      | sebastianne.k.trias       | February 16, 2024     | DEPP-7750    | Fixed issue on searching contact name         |
*/
public with sharing class ProductOfferingCtrl {
    
    private static final String COURSE_OFFERING_API_NAME = hed__Course_Offering__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String COURSE_OFFERING_LABEL = hed__Course_Offering__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLabelPlural();
    private static final String PROGRAM_OFFERING_API_NAME = Program_Offering__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String PROGRAM_OFFERING_LABEL = Program_Offering__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLabelPlural();
    private static final String STR_QUTEX = 'QUTeX Products';
    private static final String STR_QUTEX_TERM = STR_QUTEX + ' Term';
    private static final String STR_ALL_OPE = 'All_OPE_';//metadata is named as All_OPE_<Object_Plural_Label>
    private static final Id FACULTY_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Faculty').getRecordTypeId();
    private static final Id PERSON_RECORDTYPE_ID = ContactsDAO.PERSON_RECORDTYPE_ID;
    /**
     * @description get the parent program product request id
     * @param productRequestId - id of product request
     * @return id of parent program
     */
    @AuraEnabled(cacheable=true)    
    public static Id getParentProgram(Id productRequestId){
        return
            [
                SELECT Program__c 
                FROM Related_Product_Request__c 
                WHERE Course__c =: productRequestId
                LIMIT 1
            ]?.Program__c;
    }

    /**
     * @description fetches all available facilitator bios in the org
     * @return list of facilitator bios
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,List<Field_Layout_Setting__mdt>> getOfferingLayout(){
        Map<String,List<Field_Layout_Setting__mdt>> layoutMap = new Map<String,List<Field_Layout_Setting__mdt>>();
        layoutMap.put(
            COURSE_OFFERING_API_NAME,
            CustomLayoutCtrl.getLayoutMapping(
                COURSE_OFFERING_API_NAME,
                STR_ALL_OPE + COURSE_OFFERING_LABEL.replace(' ','_'),
                true
            )
        );
        layoutMap.put(
            PROGRAM_OFFERING_API_NAME,
            CustomLayoutCtrl.getLayoutMapping(
                PROGRAM_OFFERING_API_NAME,
                STR_ALL_OPE + PROGRAM_OFFERING_LABEL.replace(' ','_'),
                true
            )
        );
        return layoutMap;
    }

    /**
     * @description fetches id of term named 'QUTeX Term' if existing; creates one if not
     * @return id of QUTeX Term
    */
    @AuraEnabled
    public static String getTermId(){
        String existingTerm = [Select Id From hed__Term__c Where Name =: STR_QUTEX_TERM Limit 1]?.Id;
        if(!String.isBlank(existingTerm)){
            return existingTerm;
        }else{
            Id qutexAccountId = [Select Id From Account Where Name =: STR_QUTEX Limit 1]?.Id;
            hed__Term__c term = new hed__Term__c(
                Name = STR_QUTEX_TERM,
                hed__Account__c = qutexAccountId
            );
            insert term;
            return term?.Id;
        }
    }

    /**
     * @description get list of facilitators searched 
     * @param filterString - search string for filter
     * @return list of facilitators formatted for customSearch
    */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getSearchedFacilitator(String filterString, List<Id> addedFacilitators){
        filterString = '%' + filterString + '%';
        List<Map<String,String>> facilitatorMap = new List<Map<String,String>>();

        for(Facilitator_Bio__c faciBio : [
            SELECT Id, Facilitator__c, Facilitator__r.Name, Professional_Bio__c
            FROM Facilitator_Bio__c
            WHERE Id NOT IN :addedFacilitators
            AND (
                Facilitator__r.Name LIKE :filterString OR
                Facilitator__r.Name = :filterString
            )
            ORDER BY Facilitator__r.Name
        ]){
            facilitatorMap.add(new Map<String,String>{
                'id' => faciBio.Id,
                'label' => faciBio.Facilitator__r.Name,
                'meta' => faciBio.Professional_Bio__c,
                'relatedContact' => faciBio.Facilitator__c
            });
        }

        return facilitatorMap;
    }

    /**
     * @description get list of contact searched 
     * @param filterString - search string for filter
     * @return list of contacts formatted for customSearch
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getSearchContacts(String filterString){
        List<Map<String,String>> contactMap = new List<Map<String,String>>();
        for(Contact con : ContactsDAO.newInstance().getPersonContactsByNameUsingSOSL(filterString)){
            contactMap.add(new Map<String,String>{
                'id' => con.Id,
                'label' => con.Name,
                'meta' => con.Email
            });
        }
        return contactMap;
    }

    /**
     * @description updates list of session records
     * @param sessionData - list of course connections
    */
    @AuraEnabled
    public static void updateSessionData(List<Session__c> sessionData){
        if(!sessionData.isEmpty()){
            update sessionData;
        }
    }

    /**
    * @description Updates Course Connection and Facilitator Bio records
    * @param facilitatorData - map of facilitator data
    */
    @AuraEnabled
    public static void updateFacilitatorData(Map<String,List<SObject>> facilitatorData){  
        updateCourseConnections(
            (List<hed__Course_Enrollment__c>)facilitatorData
            .get('courseConnections')
        );

        List<Facilitator_Bio__c> facilitatorBios = 
            (List<Facilitator_Bio__c>)facilitatorData
            .get('facilitatorBios');
        if(!facilitatorBios.isEmpty()){
            update facilitatorBios;
        }
    }

    /**
     * @description updates list of course connection records
     * @param courseConnections - list of course connections
    */
    @AuraEnabled
    public static void updateCourseConnections(List<hed__Course_Enrollment__c> courseConnections){
        if(!courseConnections.isEmpty()){
            update courseConnections;
        }
    }

    /**
     * @description updates list of course offering records
     * @param courseOfferings - list of course offerings
    */
    @AuraEnabled
    public static void updateCourseOfferings(List<hed__Course_Offering__c> courseOfferings){
        if(!courseOfferings.isEmpty()){
            update courseOfferings;
        }
    }

    /**
     * @description fetches related offerings, course connections, and sessions 
     *              of a product request
     * @param productRequestId - id of product request
     * @param parentInfo - map containing condition field and object api name of parent
     * @param childInfo - map containing fields, object api name, and condition field of child
     * @return custom ProductOfferingData wrapper
    */
    @AuraEnabled(cacheable=true)
    public static ProductOfferingData getProductOfferingData(
        String productRequestId,
        Map<String,String> parentInfo,
        Map<String,String> childInfo
    ){
        
        String fields = 'Id, Name, Maximum_Participants__c, Minimum_Participants__c ';
        CustomLayoutCtrl.GetRecordFilter filter = new CustomLayoutCtrl.GetRecordFilter();
        filter.parentId = productRequestId;
        filter.parentField = parentInfo.get('field');
        filter.childObjectType = parentInfo.get('objectType');
        filter.fields = fields;
        filter.grandChildInfo = new Map<String,String>();
        sObject parentRecord = CustomLayoutCtrl.getParentRecord(filter);

        Id parentId = parentRecord?.Id;

        List<Id> poIDs = new List<Id>();
        ProductOfferingData poData = new ProductOfferingData();
        poData.relatedFacilitators = new List<hed__Course_Enrollment__c>();
        poData.relatedSessions = new List<Session__c>();
        poData.parentId = parentId;
        poData.parentRecord = parentRecord;
        poData.productOfferings = Database.query(
            'SELECT ' + childInfo.get('fields') +
            ' FROM ' + childInfo.get('objectType') +
            ' WHERE ' + childInfo.get('conditionField') + 
            ' = \'' + String.escapeSingleQuotes(parentId) + 
            '\' ORDER BY IsActive__c DESC,CreatedDate'
        );
        for(SObject po : poData.productOfferings){
            poIDs.add( (Id) po.get('Id') );
        }
        if(childInfo.get('objectType') == COURSE_OFFERING_API_NAME){
            poData.relatedFacilitators = [
                SELECT Id, Name, Facilitator_Bio__c, Facilitator_Bio__r.Name, RecordTypeId, hed__Primary__c, 
                        hed__Course_Offering__c, Facilitator_Bio__r.Professional_Bio__c,
                        Facilitator_Bio__r.Facilitator__c,Facilitator_Bio__r.Facilitator__r.Name, 
                        Facilitator_Bio__r.Bio_Title__c, hed__Contact__c,
                        IsActive__c,CreatedDate
                FROM hed__Course_Enrollment__c
                WHERE hed__Course_Offering__c IN :poIDs AND RecordTypeId =: FACULTY_REC_TYPE
                ORDER BY IsActive__c DESC,CreatedDate
            ];

            //create a list of course connections
            List<hed__Course_Enrollment__c> courseConnList = [
                SELECT 
                    Id, Name, hed__Contact__c, hed__Course_Offering__c, hed__Status__c
                FROM 
                    hed__Course_Enrollment__c
                WHERE 
                    hed__Course_Offering__c IN :poIDs AND hed__Status__c != 'Cancelled' AND RecordTypeId !=: FACULTY_REC_TYPE
            ];

            //create set for contact IDs
            Set<Id> nonCancelledLearnerIds = new Set<Id>();
            for(hed__Course_Enrollment__c currentConn: courseConnList){
                nonCancelledLearnerIds.add(currentConn.hed__Contact__c);
            }

            poData.relatedSessions = [
                SELECT Id, Name, Session_Type__c,  Course_Connection__c, Course_Connection__r.hed__Contact__c,
                        Course_Connection__r.hed__Contact__r.Name, Course_Offering__c, Facilitator__c,
                        Date__c, Start_Time_v2__c, End_Time_v2__c, Location__c, Location__r.Name, Location_Detail_v2__c,
                        IsActive__c,CreatedDate, Learner__c, Learner__r.Name, Session_Status__c, RecordType.DeveloperName
                FROM Session__c 
                WHERE Course_Offering__c IN :poIDs AND (Learner__c IN :nonCancelledLearnerIds OR Learner__c = null)
                ORDER BY IsActive__c DESC,CreatedDate, Name
            ];

            //get the number of sessions for single/group sessions
            poData.noOfSessions = [SELECT Id, Name, No_Of_Coaching_Sessions__c FROM hed__Course__c WHERE ProductRequestID__c =: productRequestId LIMIT 1].No_Of_Coaching_Sessions__c; 
        }
        if(childInfo.get('objectType') == PROGRAM_OFFERING_API_NAME){
            poData.childCourseOfferings = [
                SELECT Id, hed__Course__c, hed__Course__r.ProductRequestID__c, hed__Course__r.Name, Program_Offering__c
                FROM hed__Course_Offering__c
                WHERE Program_Offering__c IN :poIDs
            ];
        }

        List<Product_Request__c> prodReqList = [SELECT RecordType.Id, RecordType.DeveloperName FROM Product_Request__c WHERE Id =: productRequestId LIMIT 1];
        for(Product_Request__c pr : prodReqList){
            poData.recordTypeName = pr.RecordType.DeveloperName;
        }

        List<Product2> productDetails = [SELECT Id, Name, Product_Category__c FROM Product2 WHERE Course__r.ProductRequestID__c  =: productRequestId OR Program_Plan__r.Product_Request__c  =: productRequestId];
        for(Product2 product : productDetails){
            poData.productCategory = product.Product_Category__c;
        }

        List<hed__Course_Offering__c> courseOffers = [SELECT Id, hed__Capacity__c FROM hed__Course_Offering__c WHERE hed__Course__r.ProductRequestID__c  =: productRequestId];
        for(hed__Course_Offering__c co : courseOffers){
            poData.capacity = co.hed__Capacity__c;
        }

        List<Program_Offering__c> progOffers = [SELECT Id, hed_Capacity__c FROM Program_Offering__c WHERE hed_Program_Plan__r.Product_Request__c  =: productRequestId];
        for(Program_Offering__c po : progOffers){
            poData.capacity = po.hed_Capacity__c;
        }
        return poData;
    }

    @AuraEnabled
    public static List<Facilitator_Bio__c> getFacilitatorBios(Id contactId, List<Id> addedFacilitators) {
        return [
            SELECT Id, Bio_Title__c, Professional_Bio__c 
            FROM Facilitator_Bio__c 
            WHERE 
                Id NOT IN :addedFacilitators AND
                Facilitator__c = :contactId
            WITH SECURITY_ENFORCED];
    }

    @AuraEnabled
    public static Integer isNewFacilitator(Id offeringId, Id contactId) {
        return [
            SELECT Id
            FROM hed__Course_Enrollment__c 
            WHERE 
                hed__Course_Offering__c = :offeringId AND
                hed__Contact__c = :contactId
            WITH SECURITY_ENFORCED]
            .size();
    }

    @AuraEnabled
    public static void updateCourseConnection(Id offeringId, Id contactId, Id facilitatorBioId) {
        hed__Course_Enrollment__c cenrToUpdate = [
            SELECT Id, Facilitator_Bio__c, hed__Contact__c, hed__Course_Offering__c 
            FROM hed__Course_Enrollment__c 
            WHERE 
                hed__Course_Offering__c = :offeringId AND 
                hed__Contact__c = :contactId
            WITH SECURITY_ENFORCED
            LIMIT 1];
        cenrToUpdate.Facilitator_Bio__c = facilitatorBioId;
        update cenrToUpdate;
    }
    /**
     * @description custom wrapper for related offerings, course connections,
     *              parentId (either Course/Program Plan ID) and sessions 
    */
    public class ProductOfferingData{
        @AuraEnabled 
        public Id parentId;
        @AuraEnabled 
        public sObject parentRecord;
        @AuraEnabled
        public List<SObject> productOfferings;
        @AuraEnabled
        public List<hed__Course_Offering__c> childCourseOfferings;
        @AuraEnabled 
        public List<hed__Course_Enrollment__c> relatedFacilitators;
        @AuraEnabled 
        public List<Session__c> relatedSessions;
        @AuraEnabled 
        public String recordTypeName;
        @AuraEnabled 
        public Double noOfSessions = 0;
        @AuraEnabled 
        public String productCategory;
        @AuraEnabled 
        public Decimal capacity;
    }
}