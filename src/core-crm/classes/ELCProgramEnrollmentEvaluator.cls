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

    // Return null if query not executed
    public Map<Id, List<hed__Program_enrollment__c>> evaluate(Map<Id, Contact> contactMap) {  
        if (!elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().isEmpty() && isAllChildCriteriaEmpty()) {
            // if none of the child or grand child criteria defined, fire query and inherit parent / grand parent criteria
            //elcParser.getContactCriteria().contactIdSet.addAll(contactMap.keySet());

            elcParser.getELCContactParser().getContactCriteria().contactIdSet = contactMap.keySet();

            //add contact id set into soql
            List<hed__Program_Enrollment__c> programEnrollments = ProgramEnrollmentsDAO.newInstance().findByCriteria(elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(), elcParser.getELCContactParser().getContactCriteria());
            return groupByContact(programEnrollments);
        }
        // if any of the child or grandchild criteria defined, only run the query in the child or grandchild
        return null;
    }

    private Boolean isAllChildCriteriaEmpty() {
        return 
            elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().isEmpty() && 
            elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().isEmpty();
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
}