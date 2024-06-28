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

    private List<OutreachCaseImportCtrl.OutreachCases> outreachCaseList = new List<OutreachCaseImportCtrl.OutreachCases>();

    private List<String> qutStudentIds;
    private Engagement_List_Criteria__c engagementCriteria;
    private Id configurationId;

    public AdhocImportOutreachCaseBatch(List<String> qutStudentIds, Engagement_List_Criteria__c engagementCriteria, Id configurationId) {
        this.qutStudentIds = qutStudentIds;
        this.engagementCriteria = engagementCriteria;
        this.configurationId = configurationId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {  
        return ContactsDAO.newInstance().getQueryLocatorContactByStudentId(qutStudentIds, AccessLevel.USER_MODE);
    } 

    public void execute(Database.BatchableContext bc, List<Contact> contacts){
        try {
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

            Map<Id, String> mapper = new Map<Id, String>();
            for (ELECandidateProcessResult result : processResult){
                if (!mapper.containsKey(result.getCase().Id)) {
                    mapper.put(result.getCase().Id, result.getResult().name());
                }
            }
            
            List<Case> caseList = CasesDAO.newInstance().getCasesByIdsImported(mapper.keySet(), AccessLevel.USER_MODE);
            List<Case> updatedCaseList = new List<Case>();

            
            for (Case caseRecord : caseList){
                if (mapper.containsKey(caseRecord.Id)){
                    outreachCaseList.add(new OutreachCaseImportCtrl.OutreachCases(caseRecord, mapper.get(caseRecord.Id)));
                    caseRecord.Engagement_List_Configuration__c = configurationId;
                    updatedCaseList.add(caseRecord);
                }
            } 

        } catch (Exception e) {
            Logger.error(
                'Exception caught in method finish in class AdhocImportOutreachCaseBatch.'
            )
            .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<Outreach_Case__e> outreachCaseEvents = new List<Outreach_Case__e>();
        for(OutreachCaseImportCtrl.OutreachCases outreacCaseWrapper : outreachCaseList){

            outreachCaseEvents.add(
                new Outreach_Case__e(
                    Case_Id__c = outreacCaseWrapper.getCase().Id,
                    Case_No__c = outreacCaseWrapper.getCase().CaseNumber,
                    /* Case_No__c = outreacCaseWrapper.getCase().CaseNumber,
                    Contact_Id__c = outreacCaseWrapper.getCase().ContactId,
                    Contact_Name__c = outreacCaseWrapper.getCase().Contact.Name,
                    Mobile__c = outreacCaseWrapper.getCase().Contact.MobilePhone,
                    QUT_Learner_Email__c = outreacCaseWrapper.getCase().Contact.QUT_Learner_Email__c,
                    QUT_Student_Id__c = outreacCaseWrapper.getCase().Contact.QUT_Student_Id__c, */
                    Result__c = outreacCaseWrapper.getProcessResultCode()
                )
            );
            
        }
        
        if (!outreachCaseEvents.isEmpty()) {
            try {
                Logger.info('publishing outreachCaseEvents.... ' + JSON.serialize(outreachCaseEvents));
                EventBus.publish(outreachCaseEvents);
                Logger.info('Napublish naman');
                Logger.saveLog();
            } catch (Exception e) {
                // prettier-ignore
                NebulaLoggerService.logExceptionDetails('Exception caught in AdhocImportOutreachCaseBatch', e);
            }
        }

    }
}