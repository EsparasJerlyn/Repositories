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
    * @param studentIds - List of Student Id based on the given csv
    * @return List<ValidationResult> - List of Student Id with the corresponding Validation Result
    */
    @AuraEnabled
    public static List<StudentIdValidator.ValidationResult> listOfStudents(List<String> studentIds){
        List<StudentIdValidator.ValidationResult> studentIdValidator = StudentIdValidator.validate(studentIds);
        return studentIdValidator;
    }

    /**
    * @description Method to validate the Contact through the Student Id
    * @param studentIds - List of Student Id based on the given csv
    * @return List<ValidationResult> - List of Student Id with the corresponding Validation Result
    */
    @AuraEnabled
    public static List<ELECandidateProcessResult> listOfCasesbyStudentIds(List<Id> contactIds, String criteriaTitle, String criteriaDescription, String configurationId){
        List<String> studentIds = new List<String>();
        for (Id ids : contactIds){
            String id;
            id = (String)ids;
            studentIds.add(id);
        }

        List<Contact> contacts = ContactsDAO.newInstance().getContactByStudentId(studentIds, AccessLevel.SYSTEM_MODE);
        Engagement_List_Criteria__c engagementListCriteria = new Engagement_List_Criteria__c();
        engagementListCriteria.Engagement_List_Configuration__c = configurationId;
        engagementListCriteria.Engagement_List_Criteria_Title__c = criteriaTitle;
        engagementListCriteria.Description__c = criteriaDescription;
        engagementListCriteria.RecordTypeId = EngagementListCriteriasDAO.RECORD_TYPE_ID_IMPORTED;

        
        List<Engagement_List_Criteria__c> criteriaList = new List<Engagement_List_Criteria__c>();
        criteriaList.add(engagementListCriteria);
        EngagementListCriteriasDAO.newInstance().createRecords(criteriaList, false, AccessLevel.SYSTEM_MODE);
 
        ELCParser parser = new ELCParser(engagementListCriteria);
        List<ELECandidateIngredient> ingredientList = new List<ELECandidateIngredient>();
        Map<List<ELECandidateIngredient>, Contact> eventsByContactMap = new Map<List<ELECandidateIngredient>, Contact>();
        for(Contact con : contacts){
            ELECandidateIngredient ingredient = new ELECandidateIngredient();
            ingredient.setELCParser(parser);
            ingredient.setContact(con);
            ingredientList.add(ingredient);
            ingByContactMap.put(ing, con);
        }
    
        Map<Id, List<Engagement_List_Event__c>> eventsByContactMap = new Map<Id, List<Engagement_List_Event__c>>();
        for(ELECandidateIngredient ingredient : ingredientList){
            ELECandidateGenerator generator = new ELECandidateGenerator();
            List<Engagement_List_Event__c> events = generator.generate(ingredient);
            eventsByContactMap.put(ingredient.getContact(), events);
        }
    
        ELECandidateProcessor processor = new ELECandidateProcessor();
        List<ELECandidateProcessResult> processResult = processor.process(eventsByContactMap, engagementListCriteria);
    
        return processResult; 
    }

}