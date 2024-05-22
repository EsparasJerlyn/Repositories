/**
 * @description Class to validate Student Id based on the Manual Import of CSV
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kim.howard.capanas             | May 16, 2024          | DEPP-7526              | Created file                 |
 */
public with sharing class OutreachCaseImportCtrl {

    /**
    * @description Method to validate the Contact through the Student Id
    * @param caseId - List of Student Id based on the given csv
    * @return List<StudentIdValidator.ValidationResult> - List of Student Id with the corresponding Validation Result
    */
    @AuraEnabled
    public static List<Case> listOfCases(List<Id> caseId){
        Set<Id> caseIds = new Set<Id>();
        for (Id ids : caseId){
            caseIds.add(ids);
        }
        
        List<Case> caseList = CasesDAO.newInstance().getCasesByRecordTypeIds(caseIds, CasesDAO.OUTREACH_RECTYPE_ID, AccessLevel.SYSTEM_MODE);
        return caseList;
    }
    
    /**
    * @description Method to validate the Contact through the Student Id
    * @param studentIds - List of Student Id based on the given csv
    * @return List<StudentIdValidator.ValidationResult> - List of Student Id with the corresponding Validation Result
    */
    @AuraEnabled
    public static List<StudentIdValidator.ValidationResult> listOfStudents(List<String> studentIds){
        List<StudentIdValidator.ValidationResult> studentIdValidator = StudentIdValidator.validate(studentIds);
        return studentIdValidator;
    }

    /**
    * @description Method to validate the Contact through the Student Id
    * @param contactIds - List of Student Id based on the given csv
    * @param criteria - String value of Engagement List Criteria Title and Description
    * @param configurationId - Engagement List Congifuration recordId
    * @return List<OutreachCases> - List of Student Id with the corresponding Validation Result
    */
    @AuraEnabled
    public static List<OutreachCases> listOfCasesbyStudentIds(List<String> QutStudentIds, String criteria, String configurationId){
        Date executionDate = Date.today();
        List<String> criteriaFromUi = criteria.split(',');

        List<Contact> contacts = ContactsDAO.newInstance().getContactByStudentId(QutStudentIds, AccessLevel.SYSTEM_MODE);
        Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
        engagementListCriteria.Engagement_List_Configuration__c = configurationId;
        engagementListCriteria.Engagement_List_Criteria_Title__c = criteriaFromUi[0];
        engagementListCriteria.Description__c = criteriaFromUi[1];
        engagementListCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_IMPORTED;
        // engagementListCriteria.Status = 'Active';
        
        List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
        criteriaList.add(engagementListCriteria);
        EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, false, AccessLevel.SYSTEM_MODE);
 
        ELCParser parser = new ELCParser(engagementListCriteria, executionDate);
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
        List<ELECandidateProcessResult> processResult = processor.process(eventsByContactMap, engagementListCriteria);

        Map<Id, String> mapper = new Map<Id, String>();
        for (ELECandidateProcessResult result : processResult){
            if (!mapper.containsKey(result.getCase().Id)) {
                mapper.put(result.getCase().Id, result.getResult().name());
            }
        }
        List<Case> caseList = CasesDAO.newInstance().getCasesByRecordTypeIds(mapper.keySet(), CasesDAO.OUTREACH_RECTYPE_ID, AccessLevel.SYSTEM_MODE);
        List<OutreachCases> outreachCaseList = new List<OutreachCases>();
        for (Case caseRecord : caseList){
            if (mapper.containsKey(caseRecord.Id)){
                outreachCaseList.add(new OutreachCases(caseRecord, mapper.get(caseRecord.Id)));
            }
        }
        return outreachCaseList; 
    }

    /**
    * @description Class that wraps the OutreachCases
    */
    public class OutreachCases {
        private String processResultCode;
        private Case caseList;

        public OutreachCases(Case caseList, String processResultCode){
            this.caseList = caseList;
            this.processResultCode = processResultCode;
        }

        @auraEnabled
        public Case getCase(){
            return caseList;
        }

        @auraEnabled
        public String getProcessResultCode(){
            return processResultCode;
        }
    }

}