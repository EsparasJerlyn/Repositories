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
    * @param recordId - recordId of Engagement List Configuration
    * @return List<Case> - List of Cases related to Engagement List Configurations
    */
    @AuraEnabled
    public static List<CaseWrapper> listOfCases(String recordId){
        List<Case> caseList = CasesDAO.newInstance().getCasesByEngagementListConfigurationIds(recordId, AccessLevel.USER_MODE);
        String userTimeZone = UserInfo.getTimeZone().getID();

        Map<Id, CaseWrapper> caseResult = new Map<Id, CaseWrapper>();
        for(Case caseRec : caseList) {
            Datetime gmtDatetime = caseRec.CreatedDate;
            String convertedDatetime = gmtDatetime.format('dd/MM/yyyy', userTimeZone);
            caseResult.put(caseRec.Id, new CaseWrapper(caseRec, convertedDatetime));
        }
        return caseResult.values();
    }

    /**
    * @description Method to validate the Contact through the Student Id
    * @param recordId - recordId of Engagement List Configuration
    * @return List<Case> - List of Cases related to Engagement List Configurations
    */
    @AuraEnabled
    public static List<Case> listOfCasesById(List<String> caseIds){
        Set<Id> newCaseIds = new Set<Id>();
        for (String id : caseIds) {
            newCaseIds.add(id);
        }
        List<Case> caseList = CasesDAO.newInstance().getCasesByIdsImported(newCaseIds, AccessLevel.USER_MODE);
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
    * @return List<OutreachCases> - List of Outreach Cases Created on import
    */
    @AuraEnabled
    public static void listOfCasesByStudentIds(List<String> qutStudentIds, String criteria, Id configurationId){

        Engagement_List_Criteria__c engagementCriteria = createEngagementListCriteria(criteria, configurationId);
        AdhocImportOutreachCaseBatch batch = new AdhocImportOutreachCaseBatch(qutStudentIds, engagementCriteria, configurationId);
        Database.executeBatch(batch);  

    }

    /**
     * Creates Engagement List Criteria based from inputted Title from UI
     * @param String criteria - string that contains title and description
     * @param Id configurationId - configuration Id of the criteria to be created
     */
    private static Engagement_List_Criteria__c createEngagementListCriteria(String criteria, Id configurationId){

        List<String> criteriaFromUi = criteria.split(',');
        Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
        engagementListCriteria.Engagement_List_Configuration__c = configurationId;
        engagementListCriteria.Engagement_List_Criteria_Title__c = criteriaFromUi[0];
        engagementListCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_IMPORTED;
        if (criteriaFromUi.size() == 1) {
            engagementListCriteria.Description__c = '';
        }
        
        List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
        criteriaList.add(engagementListCriteria);
        EngagementListCriteriasDAO.newInstance().insertRecords(criteriaList, false, AccessLevel.USER_MODE);

        Engagement_List_Criteria__c engagementCriteria = EngagementListCriteriasDAO.newInstance().getEntryCriteriaById(criteriaList[0].Id,AccessLevel.USER_MODE);

        return engagementCriteria;

    }

    /**
    * @description Class that wraps the OutreachCases
    */
    public class OutreachCases {
        private String processResultCode;
        private Case caseRec;

        public OutreachCases(Case caseRec, String processResultCode){
            this.caseRec = caseRec;
            this.processResultCode = processResultCode;
        }

        @auraEnabled
        public Case getCase(){
            return caseRec;
        }

        @auraEnabled
        public String getProcessResultCode(){
            return processResultCode;
        }
    }

    public class CaseWrapper {
        private String caseCreatedDate;
        private Case caseRec;

        public CaseWrapper(Case caseRec, String caseCreatedDate){
            this.caseRec = caseRec;
            this.caseCreatedDate = caseCreatedDate;
        }

        @auraEnabled
        public Case getCase(){
            return caseRec;
        }

        @auraEnabled
        public String getCaseCreatedDate(){
            return caseCreatedDate;
        }
    }

}