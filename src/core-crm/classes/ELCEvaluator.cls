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
    public Map<Id, ELECandidateIngredient> evaluate(List<Contact> contacts) {
        
        if(contacts.isEmpty()){
            return null;
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);       
        Set<Id> contactIdSetIntersection = new Set<Id>();
        Map<Id, ELECandidateIngredient> eleCandidateIngredientMap = new Map<Id, ELECandidateIngredient>();
        
        //Contact Evaluator
        Set<Id> contactIds = contactMap?.keySet();       
        
		//Program Enrollment Evaluator
        ELCProgramEnrollmentEvaluator programEnrollmentEvaluator = new ELCProgramEnrollmentEvaluator(elcParser);
        Map<Id, List<hed__Program_enrollment__c>> programEnrollmentsByContact = programEnrollmentEvaluator.evaluate(contactMap);
        Set<Id> programEnrollmentContactIds = programEnrollmentsByContact?.keySet();
        
        //Course Enrollment Evaluator
        ELCCourseEnrollmentEvaluator courseEnrollmentEvaluator = new ELCCourseEnrollmentEvaluator(elcParser);
        Map<Id, List<hed__Course_Enrollment__c>> courseEnrollmentsByContact = courseEnrollmentEvaluator.evaluate(contactMap);
        Set<Id> courseEnrollmentContactIds = courseEnrollmentsByContact?.keySet();
        
        //Course Connection Assessment Evaluator
        ELCCourseConnectionAssessmentEvaluator courseConnectionAssessmentEvaluator = new ELCCourseConnectionAssessmentEvaluator(elcParser);
        Map<Id, List<Course_Connection_Assessment__c>> courseConnectionAssessmentsByContact = courseConnectionAssessmentEvaluator.evaluate(contactMap);
        Set<Id> courseConnectionsIds = courseConnectionAssessmentsByContact?.keySet();
        
        //Leave of Absence Evaluator
        ELCLeaveOfAbsenceEvaluator leaveOfAbsenceEvaluator = new ELCLeaveOfAbsenceEvaluator(elcParser);
        Map<Id, List<Leave_of_Absence__c>> leaveOfAbsenceByContact = leaveOfAbsenceEvaluator.evaluate(contactMap);
        Set<Id> leaveOfAbsenceIds = leaveOfAbsenceByContact?.keySet();
        
        //Completed Cadence Evaluator
        ELCCompletedCadenceEvaluator completedCadenceEvaluator = new ELCCompletedCadenceEvaluator(elcParser);
        Map<Id, List<Completed_Cadence__c>> completedCadenceByContact = completedCadenceEvaluator.evaluate(contactMap);
        Set<Id> completedCadenceIds = completedCadenceByContact?.keySet();

        //Program Enrollment Breach Evaluator
        ELCProgramEnrollmentBreachEvaluator programEnrollmentBreachEvaluator = new ELCProgramEnrollmentBreachEvaluator(elcParser);
        Map<Id, List<Program_Enrollment_Breach__c>> programEnrollmentBreachByContact = programEnrollmentBreachEvaluator.evaluate(contactMap);
        Set<Id> programEnrollmentBreachIds = programEnrollmentBreachByContact?.keySet();        
        
        
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
                
        for (Id contactId : contactIdSetIntersection) {
            
            ELECandidateIngredient eleIngredient = new ELECandidateIngredient();           
            eleIngredient.setELCParser(elcParser);
            
            if(contactMap !=null && contactMap.containsKey(contactId)){
                Contact con = contactMap.get(contactId);
                eleIngredient.setContact(con);                
            }
            
            if(programEnrollmentsByContact !=null && programEnrollmentsByContact.containsKey(contactId)){
                eleIngredient.setProgramEnrollments(programEnrollmentsByContact.get(contactId));
            }
                        
            if(courseEnrollmentsByContact !=null && courseEnrollmentsByContact.containsKey(contactId)){
                eleIngredient.setCourseEnrollments(courseEnrollmentsByContact.get(contactId));
            }
            
            if(courseConnectionAssessmentsByContact !=null && courseConnectionAssessmentsByContact.containsKey(contactId)){
                eleIngredient.setCourseConnectionAssessments(courseConnectionAssessmentsByContact.get(contactId));
            }
            
            if(leaveOfAbsenceByContact !=null && leaveOfAbsenceByContact.containsKey(contactId)){
                eleIngredient.setLeaveOfAbsences(leaveOfAbsenceByContact.get(contactId));
            }
            
            if(completedCadenceByContact !=null && completedCadenceByContact.containsKey(contactId)){
                eleIngredient.setCompletedCadences(completedCadenceByContact.get(contactId));
            }
            
            if(programEnrollmentBreachByContact !=null && programEnrollmentBreachByContact.containsKey(contactId)){
                eleIngredient.setProgramEnrollmentBreaches(programEnrollmentBreachByContact.get(contactId));
            }
            // Add the ELECandidateIngredient to the existing map using contact Id
            eleCandidateIngredientMap.put(contactId,eleIngredient);
            
        }

        return eleCandidateIngredientMap;       
    }
}
