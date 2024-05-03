
public with sharing class ELCProgramEnrollmentEvaluator {

    private ELCParser elcParser;
    
    public ELCProgramEnrollmentEvaluator(ELCParser elcParser) {
        this.elcParser = elcParser;
    }

    // Return null if query not executed
    public Map<Id, List<hed__Program_enrollment__c>> evaluate(Map<Id, Contact> contactMap) {  
        if (!elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().isEmpty() && isAllChildCriteriaEmpty()) {
            // if none of the child or grand child criteria defined, fire query and inherit parent / grand parent criteria
            elcParser.getContactCriteria().setContactIdSet(contactMap.keySet());
            //elcParser.getContactCriteria().contactIdSet.addAll(contactMap.keySet());

            //add contact id set into soql
            List<hed__Program_enrollment__c> programEnrollments = ProgramEnrollmentsDAO.findByCriteria(elcParser.getProgramEnrollmentCriteria(), elcParser.getContactCriteria());
            return groupByContact(programEnrollments);
        }
        // if any of the child or grandchild criteria defined, only run the query in the child or grandchild
        return null;
    }

    private Boolean isAllChildCriteriaEmpty() {
        return 
            elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsenceCriteria().isEmpty() && 
            elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionParser().getCourseEnrollmentCriteria().isEmpty() && 
            elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().isEmpty();
    }

    private Map<Id, List<hed__Program_enrollment__c>> groupByContact(List<hed__Program_enrollment__c> programEnrollments) {
        Map<Id, List<hed__Program_enrollment__c>> programEnrollmentByContactMap = new Map<Id, List<hed__Program_enrollment__c>>();

        for(hed__Program_enrollment__c progEnrollment : programEnrollments){
            if(programEnrollmentByContactMap.containsKey(progEnrollment.Contact__c)){
                programEnrollmentByContactMap.get(progEnrollment.Contact__c).add(progEnrollment);
            }else{
                List<hed__Program_enrollment__c> programEnrollmentList = new List<hed__Program_enrollment__c>();
                programEnrollmentByContactMap.put(progEnrollment.Contact__c, programEnrollmentList.add(progEnrollment));
            }
        }
        
        return programEnrollmentByContactMap;
    }
}