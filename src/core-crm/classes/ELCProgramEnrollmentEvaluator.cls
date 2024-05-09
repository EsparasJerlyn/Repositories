/**
 * @description Class to be used as an Evaluator Class for Program Enrollment
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | kim.howard.capanas             | May 3, 2024           | DEPP-8488              | Created file                                                |
*/
public with sharing class ELCProgramEnrollmentEvaluator {

    private ELCParser elcParser;
    
    public ELCProgramEnrollmentEvaluator(ELCParser elcParser) {
        this.elcParser = elcParser;
    }

    public Map<Id, List<hed__Program_enrollment__c>> evaluate(Map<Id, Contact> contactMap) {  
        if (!elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().isEmpty() && !isAllChildCriteriaEmpty()) { 

            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());
            List<hed__Program_Enrollment__c> programEnrollments = ProgramEnrollmentsDAO.newInstance().findByCriteria(
                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(), 
                elcParser.getELCContactParser().getContactCriteria(), 
                AccessLevel.SYSTEM_MODE
            );
            
            return groupByContact(programEnrollments);
        }

        return null;
    }
    
    private Map<Id, List<hed__Program_enrollment__c>> groupByContact(List<hed__Program_enrollment__c> programEnrollments) {
        Map<Id, List<hed__Program_enrollment__c>> programEnrollmentByContactMap = new Map<Id, List<hed__Program_enrollment__c>>();

        for(hed__Program_enrollment__c progEnrollment : programEnrollments){
            if(programEnrollmentByContactMap.containsKey(progEnrollment.hed__Contact__c)){
                programEnrollmentByContactMap.get(progEnrollment.hed__Contact__c).add(progEnrollment);
            }else{
                List<hed__Program_enrollment__c> programEnrollmentList = new List<hed__Program_enrollment__c>();
                programEnrollmentList.add(progEnrollment);
                programEnrollmentByContactMap.put(progEnrollment.hed__Contact__c, programEnrollmentList);
            }
        }
        
        return programEnrollmentByContactMap;
    }

    private Boolean isAllChildCriteriaEmpty() {
        return 
            elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().isEmpty() && 
            elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().isEmpty();
    }
}