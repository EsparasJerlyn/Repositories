/**
 * @description Service Class for Publishing DynamicDatatableEvent
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | roy.nino.s.regala              | July 06, 2023         | DEPP-5474              | Created file                   |
 *    | roy.nino.s.regala              | July 11, 2023         | DEPP-5459              | removed dynamicdatatableinput  |
 *    | roy.nino.s.regala              | July 18, 2023         | DEPP-5473              | Added Finance Summary and sort |
 *    | eugene.andrew.abuan            | August 01, 2023       | DEPP-6141              | Added Relationship Manager     |
 *    | ryan.j.a.dela.cruz             | August 10, 2023       | DEPP-6335              | Added Risk                     |
 *    | eugene.andrew.abuan            | August 14, 2023       | DEPP-6331              | Added IP Relationship Mngmnt   |

 */
public with sharing class DynamicDatatableEventService {
    /* Map that defines the object attributes defined in the datatables
     *  Just add new attributes for new objects that will use the dynamicdatatable
     *  Key Value pair are as follows:
     *  ParentFields - Comma separated string that contains the possible parent records(Api Name).
     *  ObjectLabel - Label name of the object, to be used for the success message
     */
    private static final Map<SObjectType, Map<String, String>> OBJECT_TO_EVENT_MAP = new Map<SObjectType, Map<String, String>>{
        Contextual_Role__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Engagement__c,IP_Management__c,Opportunity__c,Opportunity_Outcome__c',
            'ObjectLabel' => 'Contextual Role'
        },
        Document__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Engagement__c,IP_Management__c,Opportunity__c,Opportunity_Outcome__c',
            'ObjectLabel' => 'Document'
        },
        Finance_Summary__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Opportunity_Outcome__c',
            'ObjectLabel' => 'Finance Summary'
        },
        Financial_Split__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Opportunity_Outcome__c,Opportunity__c',
            'ObjectLabel' => 'Financial Split'
        },
        IP_Management_Relationship__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Engagement__c,Opportunity__c,Opportunity_Outcome__c',
            'ObjectLabel' => 'IP Management Relationship'
        },
        Milestone__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Opportunity_Outcome__c',
            'ObjectLabel' => 'Milestone'
        },
        Opportunity.SObjectType => new Map<String, String>{
            'ParentFields' => 'Engagement__c',
            'ObjectLabel' => 'Opportunity'
        },
        Opportunity_Outcome__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Opportunity__c',
            'ObjectLabel' => 'Opportunity Outcome'
        },
        Relationship_Manager__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Account__c,Contact__c',
            'ObjectLabel' => 'Relationship Manager'
        },
        Risk__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Opportunity_Outcome__c',
            'ObjectLabel' => 'Risk'
        },
        Expense__c.SObjectType => new Map<String, String>{
            'ParentFields' => 'Opportunity_Outcome__c',
            'ObjectLabel' => 'Expense'
        }
    };

    /**
     * Setups the data and publish the platform event
     * @param recordObjectType - Object type of the record to be processed
     *        newRecords - List of SObject Records to be processed
     *        isNew - boolean that tells if trigger is create or update
     */
    public static void publishPlatformEvent(
        SObjectType recordObjectType,
        List<sObject> newRecords,
        boolean isNew
    ) {
        List<Dynamic_Datatable_Event__e> eventRecords = new List<Dynamic_Datatable_Event__e>();
        //checks record size
        //only publish an event when 1 record is created/updated
        //this event is only used for the dynamicdatatable
        if (newRecords.size() == 1) {
            sObject newRecord = newRecords[0];
            //loop through all the parent fields of the record
            for (
                String parentField : OBJECT_TO_EVENT_MAP.get(recordObjectType)
                    .get('ParentFields')
                    .split(',')
            ) {
                //if parent field is populated
                //publish the event
                if ((String) newRecord.get(parentField) != null) {
                    eventRecords.add(
                        new Dynamic_Datatable_Event__e(
                            Message__c = setMessage(
                                (String) newRecord.get('Name'),
                                OBJECT_TO_EVENT_MAP.get(recordObjectType).get('ObjectLabel'),
                                isNew
                            ),
                            Parent_Id__c = (String) newRecord.get(parentField)
                        )
                    );

                    break;
                }
            }
            //should only contain 1 event because of break
            //but still bulkified
            if (!eventRecords.isEmpty()) {
                try {
                    EventBus.publish(eventRecords);
                } catch (Exception e) {
                    // prettier-ignore
                    NebulaLoggerService.logExceptionDetails('Exception caught in DynamicDatatableEventService.cls',e);
                }
            }
        }
    }

    /**
     * Constructs the message on the platform event
     * @param name - Name of the record
     *        objectLabel - object label name
     *        isNew - boolean that tells if trigger is create or update
     */
    private static String setMessage(String name, String objectLabel, boolean isNew) {
        String message = objectLabel + ' "' + name + '" ';
        message += isNew ? 'was created' : 'was saved';
        return message;
    }
}