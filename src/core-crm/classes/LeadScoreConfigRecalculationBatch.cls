/**
  * @description Batch class to recalculate lead score when lead score config is updated
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | November 04, 2023     | DEPP-5866              | Created file to handle lead score calculation  |
  */
public with sharing class LeadScoreConfigRecalculationBatch implements Database.Batchable<sObject> {

    private Set<Id> leadScoreConfigIds;

    public LeadScoreConfigRecalculationBatch(Set<Id> leadScoreConfigIds){
        this.leadScoreConfigIds = leadScoreConfigIds;
    }

    /**
    * @description Retrieves lead score config that was updated from previous day
    * @param bc - BatchableContext
    * @return query - filtered query of lead score config
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        return LeadScoreConfigurationDAO.newInstance().getUpdatedLeadScoreConfigs(leadScoreConfigIds);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreConfigList - List of Lead_Score_Configuration__c
    */
    public void execute(Database.BatchableContext bc, List<Lead_Score_Configuration__c> leadScoreConfigList){
        try{ 
            Set<String> citizenshipStatusSet = new Set<String>();
            Set<String> primaryStudyLevelSet = new Set<String>();

            Boolean isForContactAndLead = false;
            Boolean isForMktgInteraction = false;
            Boolean isForMktgSegmentation = false;                
            Boolean isForProgEnrollment = false;
            Boolean isForIndivEmailEmail = false;
            Boolean isForCase = false;

            for(Lead_Score_Configuration__c config : leadScoreConfigList){
                citizenshipStatusSet.add(config.Domestic_International__c);
                primaryStudyLevelSet.add(config.Study_Level__c);

                if(config.Name == 'Event Registration and Attendance' || config.Name == 'Downloaded PDF' || config.Name == 'Match My Skills'){
                    isForMktgInteraction = true;
                }
                else if(config.Name == 'Enquiries'){
                    isForCase = true;
                }
                else if(
                    config.Name == 'Funding' ||
                    config.Name == 'Primary BSA' || 
                    config.Name == 'Primary NSA' ||
                    config.Name == 'Country Tier' ||
                    config.Name == 'Residency' ||
                    config.Name == 'Interested in Double Degrees' ||
                    config.Name == 'Interested in English Pathway Programs' ||
                    config.Name == 'Preferred Intake' ||
                    config.Name == 'Course Level'
                ){
                    isForMktgSegmentation = true;         
                }
                else if(config.Name == 'Marketing consent'){
                    isForContactAndLead = true;
                }
                else if(config.Name == 'Proram Engagemegnt'){
                    isForProgEnrollment = true;
                }
                else if(config.Name == 'Email Interaction'){
                    isForIndivEmailEmail = true;
                }

            }   

            Set<Id> contactIdSet = new Set<Id>();
            Set<Id> leadIdSet = new Set<Id>();
            List<Lead_Score_Detail__c> leadScoreDetails = LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsByCitizenshipAndStudyLevel(citizenshipStatusSet, primaryStudyLevelSet, AccessLevel.SYSTEM_MODE);
            for(Lead_Score_Detail__c leadScoreDtl : leadScoreDetails){
                if(leadScoreDtl.Contact__c != null){
                    contactIdSet.add(leadScoreDtl.Contact__c);
                }else if(leadScoreDtl.Lead__c != null){
                    leadIdSet.add(leadScoreDtl.Lead__c);
                }
            }
            
            LeadScoreCalculatorService.processMarketingInterActions(contactIdSet, leadIdSet, isForMktgInteraction);
            LeadScoreCalculatorService.processMarketingSegmentation(contactIdSet, isForMktgSegmentation);
            LeadScoreCalculatorService.processContact(contactIdSet, isForContactAndLead);
            LeadScoreCalculatorService.processLead(leadIdSet, isForContactAndLead);
            LeadScoreCalculatorService.processCase(contactIdSet, leadIdSet, isForCase);
            LeadScoreCalculatorService.processProgramEngagement(contactIdSet, isForProgEnrollment);
            LeadScoreCalculatorService.processIndivEmailResults(contactIdSet, leadIdSet, isForIndivEmailEmail);

        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreConfigBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    } 

    public void finish(Database.BatchableContext bc) {} //NOPMD
}