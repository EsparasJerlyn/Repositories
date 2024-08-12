/**
 * @description MDM Callout Event Handler class
 * @see MDMCalloutEventListener
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 12, 2024       | DEPP-10490             | Created file                 |
 */

public with sharing class MDMCalloutEvenHandler {
    
    private List<MDM_Callout_Event__e> mdmCalloutEventList;
    
    public MDMCalloutEvenHandler(List<MDM_Callout_Event__e> mdmCalloutEventList) {
        this.mdmCalloutEventList = mdmCalloutEventList;
    }

    /**
     * Handles the MDM callout events
     */
    public void handle() {

        Set<Id> contactIds = new Set<Id>();
        Set<Id> courseConnectionIds = new Set<Id>();

        try{            

            for(MDM_Callout_Event__e mdmCalloutEvent : mdmCalloutEventList){
                switch on mdmCalloutEvent.Triggering_Record__c{
                    when 'Contact'{
                        if(mdmCalloutEvent.Contact_Id__c != null){
                            contactIds.add(mdmCalloutEvent.Contact_Id__c);
                        }
                    }
                    when 'hed__Course_Enrollment__c'{
                        if(mdmCalloutEvent.Course_Connection_Id__c != null){
                            courseConnectionIds.add(mdmCalloutEvent.Course_Connection_Id__c);
                        }
                    }
                }
            }

            //If there are Contact IDs to process, execute MDMStudentCalloutBatch
            if(!contactIds.isEmpty()){
                MDMStudentCalloutBatch mdmStudentCalloutBatch = new MDMStudentCalloutBatch(contactIds);
                Database.executeBatch(mdmStudentCalloutBatch);
            }

            //If there are Course Connection IDs to process, execute MDMStudentEnrollmentCalloutBatch
            if(!courseConnectionIds.isEmpty()){
                MDMStudentEnrollmentCalloutBatch mdmStudentEnrollmentCalloutBatch = new MDMStudentEnrollmentCalloutBatch(contactIds);
                Database.executeBatch(mdmStudentEnrollmentCalloutBatch);
            }

        } catch(Exception e){
            NebulaLoggerService.logExceptionDetails('Exception caught in handle method.', e);
        }
        
    }

}