/**
 * @description Batch Class for Manual Import of outreach cases based from qut students imported
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | June 28, 2024         | DEPP-9499              | Created file                 |
 */
public with sharing class AdhocImportOutreachCaseBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Set<String> newOutreachCaseIdsString = new Set<String>();
    private Set<String> existingOutreachCaseIdsString = new Set<String>();

    private List<String> qutStudentIds;
    private Engagement_List_Criteria__c engagementCriteria;
    private Id configurationId;

    public AdhocImportOutreachCaseBatch(List<String> qutStudentIds, Engagement_List_Criteria__c engagementCriteria, Id configurationId) {
        this.qutStudentIds = qutStudentIds;
        this.engagementCriteria = engagementCriteria;
        this.configurationId = configurationId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {  
        return ContactsDAO.newInstance().getQueryLocatorContactByStudentId(qutStudentIds, AccessLevel.SYSTEM_MODE);
    } 

    public void execute(Database.BatchableContext bc, List<Contact> contacts){

        Date executionDate = Date.today();
        ELCParser parser = new ELCParser(engagementCriteria, executionDate);
        List<ELECandidateIngredient> ingredientList = new List<ELECandidateIngredient>();
        Map<List<ELECandidateIngredient>, Contact> ingredientByContactMap = new Map<List<ELECandidateIngredient>, Contact>();
        for(Contact con : contacts){
            ELECandidateIngredient ingredient = new ELECandidateIngredient();
            ingredient.setELCParser(parser);
            ingredient.setContact(con);
            ingredientList.add(ingredient);
            ingredientByContactMap.put(ingredientList, con);
        }
        
        Map<Id, List<Engagement_List_Event__c>> eventsByContactMap = new Map<Id, List<Engagement_List_Event__c>>();
        for(ELECandidateIngredient ingredient : ingredientList){
            ELECandidateGenerator generator = new ELECandidateGenerator();
            List<Engagement_List_Event__c> events = generator.generate(ingredient);
            eventsByContactMap.put(ingredient.getContact().Id, events);
        }
        ELECandidateProcessor processor = new ELECandidateProcessor();
        List<ELECandidateProcessResult> processResult = processor.process(eventsByContactMap, engagementCriteria);
        for (ELECandidateProcessResult result : processResult){
            if(result.getResult() == ELECandidateProcessResult.Outcome.CASE_CREATED){
                newOutreachCaseIdsString.add(result.getCase().Id);
            }else if(result.getResult() == ELECandidateProcessResult.Outcome.EVENT_CREATED){
                existingOutreachCaseIdsString.add(result.getCase().Id);
            }
        }
       
    }

    public void finish(Database.BatchableContext bc) {

        List<Outreach_Case__e> outreachCaseEvents = new List<Outreach_Case__e>();
        String newCaseIdsString;
        String existingCaseIdsString;

        AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobById(bc.getJobId(), AccessLevel.SYSTEM_MODE);
        if(job.NumberOfErrors == 0){
            
            if(!newOutreachCaseIdsString.isEmpty()){
                newCaseIdsString = String.join(new List<String>(newOutreachCaseIdsString), ','); 
            }
            
            if(!existingOutreachCaseIdsString.isEmpty()){
                existingCaseIdsString = String.join(new List<String>(existingOutreachCaseIdsString), ','); 
            }
            
            outreachCaseEvents.add(
                new Outreach_Case__e(
                    Existing_Outreach_Case_Ids__c = existingCaseIdsString,
                    New_Outreach_Case_Ids__c = newCaseIdsString
                )
            );
            
        }else{
            outreachCaseEvents.add(
                new Outreach_Case__e(
                    Has_Error__c = true,
                    Existing_Outreach_Case_Ids__c = existingCaseIdsString,
                    New_Outreach_Case_Ids__c = newCaseIdsString
                )
            );
        }

        if (!outreachCaseEvents.isEmpty()) {
            try {
                EventBus.publish(outreachCaseEvents);
            } catch (Exception e) {
                // prettier-ignore
                NebulaLoggerService.logExceptionDetails('Exception caught in AdhocImportOutreachCaseBatch', e);
            }
        }
        
    }
}