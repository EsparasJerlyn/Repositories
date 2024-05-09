/**
 * @description ELCEvaluator
 * @ELCEvaluator
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 |                       | DEPP-8488              | Created file                 |
 */
public with sharing class ELCEvaluator {
    
    private ELCParser elcParser;
    
    public ELCEvaluator(ELCParser elcParser) {
        this.elcParser = elcParser;
    }
    // return a map of ELECandidateIngredient by contact id
    public Map<Id, List<ELECandidateIngredient>> evaluate(List<Contact> contacts) {
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);       
        Map<Id, List<ELECandidateIngredient>> mapELECandidateIngredient = new Map<Id, List<ELECandidateIngredient>>();
        Set<Id> contactIdSetIntersection = new Set<Id>();
        
        //Contact Evaluator
        ELCContactEvaluator contactEvaluator = new ELCContactEvaluator(elcParser);
        Map<Id, List<Contact>> contactListMap = contactEvaluator.evaluate(contactMap);
        Set<Id> contactIds = contactListMap.keySet();        
        
		//Program Enrollment Evaluator
        ELCProgramEnrollmentEvaluator programEnrollmentEvaluator = new ELCProgramEnrollmentEvaluator(elcParser);
        Map<Id, List<hed__Program_enrollment__c>> programEnrollmentsByContact = programEnrollmentEvaluator.evaluate(contactMap);
        Set<Id> programEnrollmentContactIds = programEnrollmentsByContact.keySet();
        
        //Course Enrollment Evaluator
        ELCCourseEnrollmentEvaluator courseEnrollmentEvaluator = new ELCCourseEnrollmentEvaluator(elcParser);
        Map<Id, List<hed__Course_Enrollment__c>> courseEnrollmentsByContact = courseEnrollmentEvaluator.evaluate(contactMap);
        Set<Id> courseEnrollmentContactIds = courseEnrollmentsByContact.keySet();
        
        //Course Connection Assessment Evaluator
        ELCCourseConnectionAssessmentEvaluator courseConnectionAssessmentEvaluator = new ELCCourseConnectionAssessmentEvaluator(elcParser);
        Map<Id, List<Course_Connection_Assessment__c>> courseConnectionAssessmentsByContact = courseConnectionAssessmentEvaluator.evaluate(contactMap);
        Set<Id> courseConnectionsIds = courseConnectionAssessmentsByContact.keySet();
        
        //Leave of Absence Evaluator
        ELCLeaveOfAbsenceEvaluator leaveOfAbsenceEvaluator = new ELCLeaveOfAbsenceEvaluator(elcParser);
        Map<Id, List<Leave_of_Absence__c>> leaveOfAbsenceByContact = leaveOfAbsenceEvaluator.evaluate(contactMap);
        Set<Id> leaveOfAbsenceIds = leaveOfAbsenceByContact.keySet();
        
        //Completed Cadence Evaluator
        ELCCompletedCadenceEvaluator completedCadenceEvaluator = new ELCCompletedCadenceEvaluator(elcParser);
        Map<Id, List<Completed_Cadence__c>> completedCadenceByContact = completedCadenceEvaluator.evaluate(contactMap);
        Set<Id> completedCadenceIds = completedCadenceByContact.keySet();

        //Program Enrollment Breach Evaluator
        ELCProgramEnrollmentBreachEvaluator programEnrollmentBreachEvaluator = new ELCProgramEnrollmentBreachEvaluator(elcParser);
        Map<Id, List<Program_Enrollment_Breach__c>> programEnrollmentBreachByContact = programEnrollmentBreachEvaluator.evaluate(contactMap);
        Set<Id> programEnrollmentBreachIds = programEnrollmentBreachByContact.keySet();        
        
        
        if(contactIds !=null){
            contactIdSetIntersection = contactIds.clone();
        }
        
        if(programEnrollmentContactIds !=null){
            contactIdSetIntersection.retainAll(programEnrollmentContactIds);
        }
        
        if(courseEnrollmentContactIds !=null){
            contactIdSetIntersection.retainAll(courseEnrollmentContactIds);
        }
        
        if(courseConnectionsIds !=null){
            contactIdSetIntersection.retainAll(courseConnectionsIds);
        }
        
        if(leaveOfAbsenceIds !=null){
            contactIdSetIntersection.retainAll(leaveOfAbsenceIds);
        }
        
        if(completedCadenceIds !=null){
            contactIdSetIntersection.retainAll(completedCadenceIds);
        }
        
        if(programEnrollmentBreachIds !=null){
            contactIdSetIntersection.retainAll(programEnrollmentBreachIds);
        }
        
        Map<Id, List<ELECandidateIngredient>> eleCandidateIngredientMap = new Map<Id, List<ELECandidateIngredient>>();
        
        for (Id contactId : contactIdSetIntersection) {
            
            String uniqueKey = contactId;
            // If the unique key value is not already a key in the map, create a new list for it
            if (!eleCandidateIngredientMap.containsKey(uniqueKey)) {
                eleCandidateIngredientMap.put(
                    uniqueKey,
                    new List<ELECandidateIngredient>()
                );
            }
            ELECandidateIngredient eleIngredient = new ELECandidateIngredient(); 
            
            eleIngredient.setELCParser(elcParser);
            
            if(contactListMap.containsKey(contactId)){
                Contact con = contactListMap.get(contactId).iterator().next();
                eleIngredient.setContact(con);                
            }
            
            if(programEnrollmentsByContact.containsKey(contactId)){
                eleIngredient.setProgramEnrollments(programEnrollmentsByContact.get(contactId));
            }
                        
            if(courseEnrollmentsByContact.containsKey(contactId)){
                eleIngredient.setCourseEnrollments(courseEnrollmentsByContact.get(contactId));
            }
            
            if(courseConnectionAssessmentsByContact.containsKey(contactId)){
                eleIngredient.setCourseConnectionAssessments(courseConnectionAssessmentsByContact.get(contactId));
            }
            
            if(leaveOfAbsenceByContact.containsKey(contactId)){
                eleIngredient.setLeaveOfAbsences(leaveOfAbsenceByContact.get(contactId));
            }
            
            if(completedCadenceByContact.containsKey(contactId)){
                eleIngredient.setCompletedCadences(completedCadenceByContact.get(contactId));
            }
            
            if(programEnrollmentBreachByContact.containsKey(contactId)){
                eleIngredient.setProgramEnrollmentBreaches(programEnrollmentBreachByContact.get(contactId));
            }
            // Add the ELECandidateIngredient to the existing map using unique key
            eleCandidateIngredientMap.get(uniqueKey).add(eleIngredient);
            
        }

        return mapELECandidateIngredient;       
    }
}