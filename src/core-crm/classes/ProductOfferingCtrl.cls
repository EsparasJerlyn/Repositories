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
*/
public with sharing class ProductOfferingCtrl {
    
    private static final String COURSE_OFFERING_API_NAME = hed__Course_Offering__c.SObjectType.getDescribe().getLocalName();
    private static final String COURSE_OFFERING_LABEL = hed__Course_Offering__c.sObjectType.getDescribe().getLabelPlural();
    private static final String PROGRAM_OFFERING_API_NAME = Program_Offering__c.SObjectType.getDescribe().getLocalName();
    private static final String PROGRAM_OFFERING_LABEL = Program_Offering__c.sObjectType.getDescribe().getLabelPlural();
    private static final String STR_QUTEX = 'QUTeX';
    private static final String STR_QUTEX_TERM = STR_QUTEX + ' Term';
    private static final String STR_ALL_OPE = 'All_OPE_';//metadata is named as All_OPE_<Object_Plural_Label>
    private static final Id FACULTY_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Faculty').getRecordTypeId();
    
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
        filterString = '%' + filterString + '%';
        List<Map<String,String>> contactMap = new List<Map<String,String>>();
        
        for(Contact con : [
            SELECT Id, Name, Email
            FROM Contact
            WHERE (
                Name LIKE :filterString OR
                Name = :filterString
            )
            LIMIT 15
        ]){
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
     * @description fetches related offerings, course connections, and sessions 
     *              of a product request
     * @param productRequestId - id of product request
     * @param parentInfo - map containing condition field and object api name of parent
     * @param childInfo - map contaning fileds, object api name, and condition field of child
     * @return custom ProductOfferingData wrapper
    */
    @AuraEnabled(cacheable=true)
    public static ProductOfferingData getProductOfferingData(
        String productRequestId,
        Map<String,String> parentInfo,
        Map<String,String> childInfo
    ){
        
        String fields = 'Id, Maximum_Participants__c, Minimum_Participants__c ';
        sObject parentRecord = CustomLayoutCtrl.getParentRecord(
            productRequestId,
            parentInfo.get('field'),
            parentInfo.get('objectType'),
            fields,
            new Map<String,String>()
        );

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
                        Facilitator_Bio__r.Facilitator__c,Facilitator_Bio__r.Facilitator__r.Name, hed__Contact__c,
                        IsActive__c,CreatedDate
                FROM hed__Course_Enrollment__c
                WHERE hed__Course_Offering__c IN :poIDs AND RecordTypeId =: FACULTY_REC_TYPE
                ORDER BY IsActive__c DESC,CreatedDate
            ];
            
            poData.relatedSessions = [
                SELECT Id, Name, Session_Type__c,  Course_Connection__c, Course_Connection__r.hed__Contact__c,
                        Course_Connection__r.hed__Contact__r.Name, Course_Offering__c, Facilitator__c,
                        Date__c, Start_Time_v2__c, End_Time_v2__c, Location__c, Location__r.Name, Location_Detail_v2__c,
                        IsActive__c,CreatedDate
                FROM Session__c 
                WHERE Course_Offering__c IN :poIDs
                ORDER BY IsActive__c DESC,CreatedDate
            ];
        }
        
        return poData;
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
        public List<hed__Course_Enrollment__c> relatedFacilitators;
        @AuraEnabled 
        public List<Session__c> relatedSessions;
    }
}