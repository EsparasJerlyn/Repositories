/**
 * @description Controller class that handles the retrieval of details about related records
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 05, 2024       | DEPP-10058             | Created file                 |
 */
public with sharing class ObjectDetailsSideComponentCtrl {

    /**
     * Retrieves details about a related record based on the provided parameters.
     * 
     * @param params A map containing the following keys:
     *               - 'parentRecordId': The Id of the parent record.
     *               - 'parentRecord': The API name of the parent object's SObject type.
     *               - 'relatedField': The API name of the field on the parent object that contains the related record Id.
     *               - 'relatedRecord': The API name of the related object's SObject type.
     *               - 'relatedRecordHeader': The field on the related record that will be used for the header.
     *               - 'relatedRecordFields': A JSON string representing a list of fields to retrieve from the related record.
     * @return A JSON string representing an ObjectDetailsSideComponentWrapper with details about the related record.
     */
    @AuraEnabled(cacheable=true)
    public static String getObjectDetailsMapping(Map<String, String> params) {

        String response;

        try {
            // Extract parameters from the map
            String parentRecordId = params.get('parentRecordId');
            String parentRecord = params.get('parentRecord');
            String relatedField = params.get('relatedField');
            String relatedRecord = params.get('relatedRecord');
            String relatedRecordHeader = params.get('relatedRecordHeader');
            List<String> fieldNames = (List<String>) JSON.deserialize(params.get('relatedRecordFields'), List<String>.class);
            
            // Retrieve the related record Id and header value from the parent record
            List<SObject> objectList = (List<SObject>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(
                    new Set<Id>{parentRecordId},
                    getSObjectType(parentRecord),
                    new List<String>{relatedField, relatedRecordHeader}
                ),
                AccessLevel.USER_MODE
            );

            // Parse the related record header field to get the object label and related field label
            String[] relationshipFieldList = relatedRecordHeader.split('\\.');
            if (relationshipFieldList.size() != 2) {
                throw new AuraHandledException('Invalid related record header format.');
            }
            String relatedObjectLabel = relationshipFieldList[0];
            String headerFieldLabel = relationshipFieldList[1];

            // Extract related record Id and header value
            Id relatedRecordId;
            String relatedRecordHeaderValue;
            for (SObject sObj : objectList) {
                relatedRecordId = (Id) sObj.get(relatedField);
                relatedRecordHeaderValue = (String) sObj.getSobject(relatedObjectLabel).get(headerFieldLabel);
            }

            // Retrieve related record fields
            List<SObject> relatedRecordFieldList = (List<SObject>) DynamicQueryService.getRecordsWithFieldsByIdSet(
                new DynamicQueryService.FilterWrapper(
                    new Set<Id>{relatedRecordId},
                    getSObjectType(relatedRecord),
                    fieldNames
                ),
                AccessLevel.USER_MODE
            );

            // Build response object
            ObjectDetailsSideComponentWrapper objectDetails = new ObjectDetailsSideComponentWrapper();
            objectDetails.relatedRecordId = relatedRecordId;
            objectDetails.relatedRecordObjectTypeStr = relatedRecord;
            objectDetails.relatedField = relatedField;
            objectDetails.componentHeader = relatedRecordHeaderValue;
            objectDetails.relatedRecordFields = relatedRecordFieldList;

            response = JSON.serialize(objectDetails);

        } catch (Exception ex) {
            Logger.error('Error while getting field mapping.').setExceptionDetails(ex);
            throw new AuraHandledException('Error while getting field mapping: ' + ex.getMessage());
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }

        return response;
    }

    /**
     * Retrieves the SObjectType for a given SObject name.
     * 
     * @param objectName The API name of the SObject.
     * @return The Schema.SObjectType corresponding to the provided object name.
     */
    private static Schema.SObjectType getSObjectType(String objectName) {
        return Schema.getGlobalDescribe().get(objectName);
    }

    /**
     * Wrapper class for holding details about the related record.
     */
    public class ObjectDetailsSideComponentWrapper {
        @AuraEnabled
        public Id relatedRecordId { get; set; }

        @AuraEnabled
        public String relatedRecordObjectTypeStr { get; set; }

        @AuraEnabled
        public String relatedField { get; set; }

        @AuraEnabled
        public List<SObject> relatedRecordFields { get; set; }

        @AuraEnabled
        public String componentHeader { get; set; }
    }
}
