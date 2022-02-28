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
      |                           |                       |              |                                               |
*/
public with sharing class ProductOfferingCtrl {

    private static final String COURSE_OFFERING_API_NAME = hed__Course_Offering__c.SObjectType.getDescribe().getLocalName();
    private static final String STR_QUTEX = 'QUTeX';
    private static final String STR_QUTEX_TERM = STR_QUTEX + ' Term';
    private static final Id FACULTY_REC_TYPE = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Faculty').getRecordTypeId();
     
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
     * @description fetches all available facilitator bios in the org
     * @return list of facilitator bios
    */
    @AuraEnabled(cacheable=true)
    public static List<Facilitator_Bio__c> getAllFacilitatorBio(){
        return [
            SELECT Id, Facilitator__c, Facilitator__r.Name, Facilitator_Professional_Bio__c
            FROM Facilitator_Bio__c
        ];
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
     * @description clones given product offering together with its related
     *              course connection and session records (if not empty)
     * @param objectType - object api name of offering to be created
     * @param productOffering - map of fieldApiName-value pair of offering
     * @param facilitators - list of course connections
     * @param sessions - list of sessions
    */
    @AuraEnabled
    public static void cloneProductOfferingData(
        String objectType,
        Map<String,Object> productOffering,
        List<hed__Course_Enrollment__c> facilitators,
        List<Session__c> sessions
    ){
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectType);
        SObject offering = objType.newSObject();
        for(String fieldApiName : productOffering.keySet()){
            if(fieldApiName.toLowerCase().contains('date')){
                offering.put(fieldApiName,Date.valueOf((String)productOffering.get(fieldApiName)));
            }else{
                offering.put(fieldApiName,productOffering.get(fieldApiName));
            }
        }
        Database.SaveResult srRes = Database.insert(offering, true);

        if(srRes.isSuccess()) {
            Map<Id,Id> contactCourseConnectionMap = new Map<Id,Id>();

            if(!facilitators.isEmpty()){
                Id primaryFacilitatorId;    
                for(hed__Course_Enrollment__c faci : facilitators){
                    faci.hed__Course_Offering__c = srRes.getId();
                }
                insert facilitators;
                //process list after insertion to get id
                for(hed__Course_Enrollment__c faci : facilitators){
                    contactCourseConnectionMap.put(faci.hed__Contact__c,faci.Id);
                    if(faci.hed__Primary__c){
                        primaryFacilitatorId = faci.Id;
                    }
                }
                offering.put('Primary_Facilitator__c',primaryFacilitatorId);
                Database.update(offering);
            }

            if(!sessions.isEmpty()){
                for(Session__c sesh : sessions){
                    sesh.Course_Offering__c = srRes.getId();
                    sesh.Course_Connection__c = contactCourseConnectionMap.get(sesh.Facilitator__c);
                }
                insert sessions;
            }
        }
        else {
            //operation failed, so get all errors                
            for(Database.Error err : srRes.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Product Offering fields that affected this error: ' + err.getFields());
            }
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
        Id parentId = CustomLayoutCtrl.getChildRecordId(
            productRequestId,
            parentInfo.get('field'),
            parentInfo.get('objectType'),
            new Map<String,String>()
        );
        
        List<Id> poIDs = new List<Id>();
        ProductOfferingData poData = new ProductOfferingData();
        poData.relatedFacilitators = new List<hed__Course_Enrollment__c>();
        poData.relatedSessions = new List<Session__c>();
        poData.parentId = parentId;
        poData.productOfferings = Database.query(
            'SELECT ' + childInfo.get('fields') +
            ' FROM ' + childInfo.get('objectType') +
            ' WHERE ' + childInfo.get('conditionField') + 
            ' = \'' + String.escapeSingleQuotes(parentId) + '\''
        );
        for(SObject po : poData.productOfferings){
            poIDs.add( (Id) po.get('Id') );
        }
        if(childInfo.get('objectType') == COURSE_OFFERING_API_NAME){
            poData.relatedFacilitators = [
                SELECT Id, Name, Facilitator_Bio__c, Facilitator_Bio__r.Name, RecordTypeId, hed__Primary__c, 
                        hed__Course_Offering__c, Facilitator_Bio__r.Facilitator_Professional_Bio__c,
                        Facilitator_Bio__r.Facilitator__c,Facilitator_Bio__r.Facilitator__r.Name, hed__Contact__c
                FROM hed__Course_Enrollment__c
                WHERE hed__Course_Offering__c IN :poIDs AND RecordTypeId =: FACULTY_REC_TYPE
            ];
            
            poData.relatedSessions = [
                SELECT Id, Session_Name__c, Session_Type__c,  Course_Connection__c, Course_Connection__r.hed__Contact__c,
                        Course_Connection__r.hed__Contact__r.Name, Course_Offering__c, Facilitator__c,
                        Start_Time__c, End_Time__c, Location__c, Location__r.Name, Location_Detail__c
                FROM Session__c 
                WHERE Course_Offering__c IN :poIDs
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
        public List<SObject> productOfferings;
        @AuraEnabled 
        public List<hed__Course_Enrollment__c> relatedFacilitators;
        @AuraEnabled 
        public List<Session__c> relatedSessions;
    }
}
