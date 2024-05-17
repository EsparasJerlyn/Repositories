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
    public static List<Case> listOfCasesbyStudentIds(List<Id> contactIds){
        system.debug('contactIds ::: ' + contactIds);
        Set<Id> newId = new Set<Id>();
        for (Id ids : contactIds){
            newId.add(ids);
        }
        system.debug('Ids ::: ' + newId);
        List<Case> caseList = CasesDAO.newInstance().getCasesByRecordTypeIds(newId, CasesDAO.OUTREACH_RECTYPE_ID, AccessLevel.SYSTEM_MODE);
        return caseList;
    }

}