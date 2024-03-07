/**
 * @description Batch class for LeadSourceCanNurtureFlagBatch
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | arsenio.jr.dayrit              | March 05, 2024        | DEPP-8069              | Created file                 |
      |                                |                       |                        |                              |
 */

public with sharing class LeadSourceCanNurtureFlagBatch implements Database.Batchable<sObject>{
    
    private static date afterThreeYears = System.today().addYears(-3);
    private static final Set<String> PARTNER_SOURCED = NurtureTrackConfigurationsDAO.INTERNATIONAL_PARTNER_SOURCED;
    /**
    * @description Retrieve scheduled communication queue that is created/last modified by communication automation user
    * @param bc - BatchableContext
    * @return query - filtered query of scheduled communication queue
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryFilter =  'SELECT Id,Lead__c,Lead__r.Calculated_Cadence__c, Lead__r.Lead_Source_Category__c, Lead__r.Can_Nurture__c, CreatedDate ' +
                              'FROM Completed_Cadence__c ' + 
                              'WHERE Lead__c != NULL ' +
                              'AND Lead__r.Can_Nurture__c = TRUE ' +
            				  'AND Lead__r.Calculated_Cadence__c =: PARTNER_SOURCED ' +
            				  'AND CreatedDate <: afterThreeYears ';
        return Database.getQueryLocator(queryFilter);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param completedCadenceList - List of Completed Cadence
    */
    public void execute(Database.BatchableContext bc, List<Completed_Cadence__c> completedCadenceList){
        try{ 
            
            Set<Id> leadIds = new Set<Id>();
            Set<Id> leadsWithSubmittedApplication = new Set<Id>();
            Map<Id,Lead> leadListToUpdateMap = new Map<Id,Lead>();

            for(Completed_Cadence__c completeCadence : completedCadenceList){
                leadIds.add(completeCadence.Lead__c);
            }

            List<hed__Application__c> applicationList = ApplicationsDAO.newInstance().getApplicationsByLeadIds(leadIds, 'SYSTEM_MODE');
            For(hed__Application__c app : applicationList){
                if(app.Application_Status__c == ApplicationsDAO.STATUS_SUBMITTED){
                    leadsWithSubmittedApplication.add(app.Lead__c);
                }
            }
            
            for(Completed_Cadence__c completedCadenceToProcess : completedCadenceList){
                if(!leadsWithSubmittedApplication.contains(completedCadenceToProcess.Lead__c)){
                    leadListToUpdateMap.put(completedCadenceToProcess.Lead__c,
                    new Lead(
                            id = completedCadenceToProcess.Lead__c,
                            Can_Nurture__c = false
                        )
                    );
                }
            }
            if(!leadListToUpdateMap.values().isEmpty()){
                LeadsDAO.newInstance().updateRecords(leadListToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
            }
           

        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class EmailTriggerSalesCadenceBatch.').setExceptionDetails(e);
        } 
        finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    } 

    /**
    * @description chain current batch job to Complete Cadence job
    * @param bc - BatchableContext
    */
    public void finish(Database.BatchableContext bc) {}//NOPMD
}