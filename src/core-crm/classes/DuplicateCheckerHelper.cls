/**
 * @description helper class for all duplicate record checking
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        |DEPP-5567               | Created File                 | 
 */
public with sharing class DuplicateCheckerHelper {
    public static Map<String, Integer> newItemsMatchCount;
    //map of object type to the field api names of the fields to be matched
    private static final Map<SObjectType, List<String>> OBJECT_MAP = new Map<SObjectType, List<String>>{
        Lead.SObjectType => new List<String>{ 'Email', 'Work_Email__c' },
        Contact.SObjectType => new List<String>{
            'Email',
            'Work_Email__c',
            'QUT_Learner_Email__c',
            'QUT_Staff_Email__c'
        }
    };
    //map of field api name to error message against the field
    private static final Map<String, String> ERROR_MSG_MAP = new Map<String, String>{
        'Email' => 'Email must be unique across the organization and this batch.',
        'Work_Email__c' => 'Work Email must be unique across the organization and this batch.',
        'QUT_Learner_Email__c' => 'Student Email must be unique across the organization.',
        'QUT_Staff_Email__c' => 'Staff Email must be unique across the organization.'
    };

    public static void countUniqueFieldsToMap(sObject record, SObjectType recordObjectType) {
        //loop through the fields to be match by record object type
        for (String field : OBJECT_MAP.get(recordObjectType)) {
            if (String.isNotBlank((String) record.get(field))) {
                //counts the number of time the field exists in the batch
                if (newItemsMatchCount.containsKey((String) record.get(field))) {
                    newItemsMatchCount.put(
                        (String) record.get(field),
                        newItemsMatchCount.get((String) record.get(field)) + 1
                    );
                } else {
                    newItemsMatchCount.put((String) record.get(field), 1);
                }
            }
        }
    }

    public static void processBatchChecking(SObject newRecord, SObjectType recordObjectType) {
        // Within batch checking
        // throws error if field exist more than once in the batch
        for (String field : OBJECT_MAP.get(recordObjectType)) {
            if (newItemsMatchCount?.get((String) newRecord.get(field)) > 1) {
                newRecord.addError(field, ERROR_MSG_MAP.get(field));
            }
        }
    }

    public static void processWithOrgChecking(
        SObject newRecord,
        List<SObject> existingRecordMatches,
        SObjectType recordObjectType
    ) {
        // Within organization checking
        Set<String> nonBlankFields = new Set<String>();
        //collect the api name of the fields that are populated on the new record
        for (String field : OBJECT_MAP.get(recordObjectType)) {
            if (String.isNotBlank((String) newRecord.get(field))) {
                nonBlankFields.add(field);
            }
        }

        //loop through all the records that has matched with the new records
        for (SObject existingRecord : existingRecordMatches) {
            Set<String> existingRecordValues = new Set<String>();
            //loop through the fields to be compared
            for (String fieldToCompare : OBJECT_MAP.get(recordObjectType)) {
                String value = (String) existingRecord.get(fieldToCompare);
                if (String.isNotBlank(value)) {
                    //store the existing record's field matches that has values
                    existingRecordValues.add(value.toLowerCase());
                }
            }
            //loop through the fields that are populated on the new record
            for (String field : nonBlankFields) {
                String value = ((String) newRecord.get(field)).toLowerCase();
                //check if the field on the new record matches with the existing record values
                //if match throw an error
                if (existingRecordValues.contains(value)) {
                    newRecord.addError(field, ERROR_MSG_MAP.get(field));
                }
            }
        }
    }

    public static Boolean checkFieldChange(
        SObject newItem,
        Map<Id, SObject> oldItems,
        SObjectType recordObjectType
    ) {
        Boolean hasChange = false;

        if (oldItems == null) {
            return hasChange;
        }

        SObject oldObject = oldItems.get((Id) newItem.get('Id'));
        //loop through the fields to be matched by object type
        for (String field : OBJECT_MAP.get(recordObjectType)) {
            //return true if atleast 1 field is updated
            if ((String) oldObject.get(field) != (String) newItem.get(field)) {
                hasChange = true;
                break;
            }
        }
        return hasChange;
    }
}
