/**
 * @description ELECandidateGenerator
 * @ELECandidateGenerator
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 13, 2024          | DEPP-8483              | Created file                 |
 */
public with sharing class ELECandidateGenerator {

   /**
    * @description Generate engagement list event candidate by computing cartesian product
    * @param ELECandidateIngredient eLECandidateIngredient
    * @return - List<Engagement_List_Event__c> - Returns List of Engagement List Events to be created
    */  
    public List<Engagement_List_Event__c> generate(ELECandidateIngredient eLECandidateIngredient) {        
        List<Engagement_List_Event__c> engagementListEvents = new List<Engagement_List_Event__c>();
        //Generate Engagement List Event from Contact based on eLECandidateIngredient
        engagementListEvents = generate(eLECandidateIngredient.getContact(),eLECandidateIngredient.getELCParser());
        //Generate Engagement List Event from Program Enrollment based on eLECandidateIngredient
        engagementListEvents = generate(engagementListEvents, eLECandidateIngredient.getProgramEnrollments(), eLECandidateIngredient.getELCParser());
        //Generate Engagement List Event from Completed Cadence based on eLECandidateIngredient
        engagementListEvents = generate(engagementListEvents, eLECandidateIngredient.getCompletedCadences(), eLECandidateIngredient.getELCParser());        
        //Generate Engagement List Event from Course Enrollment based on eLECandidateIngredient
        engagementListEvents = generate(engagementListEvents, eLECandidateIngredient.getCourseEnrollments(), eLECandidateIngredient.getELCParser());       
        //Generate Engagement List Event from Leave of Absences based on eLECandidateIngredient
        engagementListEvents = generate(engagementListEvents, eLECandidateIngredient.getLeaveOfAbsences(), eLECandidateIngredient.getELCParser());
        //Generate Engagement List Event from Program Enrollment Breach based on eLECandidateIngredient
        engagementListEvents = generate(engagementListEvents, eLECandidateIngredient.getProgramEnrollmentBreaches(), eLECandidateIngredient.getELCParser());
        //Generate Engagement List Event from Course Connection Assessment based on eLECandidateIngredient
        engagementListEvents = generate(engagementListEvents, eLECandidateIngredient.getCourseConnectionAssessments(), eLECandidateIngredient.getELCParser()); 
        
        return engagementListEvents;
    }
    
   /**
    * @description Generate engagement list event candidate from contact details
    * @param Contact contact
    * @param ELCParser elcParser
    * @return - List<Engagement_List_Event__c> - Returns List of Engagement List Events to be created including criteria Id
    */ 
    private List<Engagement_List_Event__c> generate(Contact contact, ELCParser elcParser) {
        List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        events.add(new Engagement_List_Event__c(
            Engagement_List_Criteria__c = elcParser.getEngagementListCriteria().Id
        ));
        return events;
    }
    
   /**
    * @description Compute cartesian product of engagement list event list from program enrollment list event list to generate a new engagement list event list
    * @param List<Engagement_List_Event__c> engagemenListEvents - engagement list event to be generated
    * @param List<hed__program_enrollment__c> programEnrollments - available program enrollment record of contact
    * @param ELCParser elcParser - criteria parser value   
    * @return - List<Engagement_List_Event__c> - Returns List of Engagement List Events to be created
    */ 
    private List<Engagement_List_Event__c> generate(List<Engagement_List_Event__c> engagemenListEvents, List<hed__program_enrollment__c> programEnrollments, ELCParser elcParser) {
        if (programEnrollments == null) {
            // Skip computation and return the original engagemenListEvents
            return engagemenListEvents;
        }
        if (programEnrollments.size() == 0) {
            // if any of the list is empty, cartesian product will be empty set
            return new List<Engagement_List_Event__c>();
        }
        List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        for (Engagement_List_Event__c event : engagemenListEvents) {
            for (hed__program_enrollment__c programEnrollment : programEnrollments) {
                
                Engagement_List_Event__c newEvent = event.clone();             
                
                if (!elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().isEmpty()) {
                    newEvent.program_enrollment__c = programEnrollment.id;
                    if(programEnrollment.Academic_Status__c != null){
                        newEvent.Academic_Status__c = programEnrollment.Academic_Status__c;
                    }
                    if(programEnrollment.Previous_Academic_Status__c != null){
                        newEvent.Previous_Academic_Status__c = programEnrollment.Previous_Academic_Status__c;
                    }
                    newEvent.Program_Enrollment_Status__c = programEnrollment.Enrollment_Status__c;
                }

                if (elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().getAcademicStatusDateFrom() != null ||
                    elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().getAcademicStatusDateTo() != null) {
                    newEvent.Key_Date__c = programEnrollment.Academic_Status_Date__c;
                }

                events.add(newEvent);               
            }
        }
        
        return events;
    }

   /**
    * @description Compute cartesian product of engagement list event list from course enrollment to generate a new engagement list event list
    * @param List<Engagement_List_Event__c> engagemenListEvents - engagement list event to be generated
    * @param List<hed__course_enrollment__c> courseEnrollments - available course enrollment record of contact
    * @param ELCParser elcParser - criteria parser value   
    * @return - List<Engagement_List_Event__c> - Returns List of Engagement List Events to be created
    */    
    private List<Engagement_List_Event__c> generate(List<Engagement_List_Event__c> engagemenListEvents, List<hed__course_enrollment__c> courseEnrollments, ELCParser elcParser){
        if (courseEnrollments == null) {
            // Skip computation and return the original engagemenListEvents
            return engagemenListEvents;
        }
        if (courseEnrollments.size() == 0) {
            // if any of the list is empty, cartesian product will be empty set
            return new List<Engagement_List_Event__c>();
        }
        List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        for (Engagement_List_Event__c event : engagemenListEvents) {
            for (hed__course_enrollment__c courseEnrollment : courseEnrollments) {               
                
                Engagement_List_Event__c newEvent = event.clone();                
                
                if (!elcParser.getELCCourseConnectionParser().getCourseConnectionCriteria().isEmpty()) {
                    newEvent.Course_Connection__c  = courseEnrollment.Id;
                    newEvent.Course_Enrollment_Status__c = courseEnrollment.Enrollment_Status__c;
                }
                               
                events.add(newEvent);
            }
        }
        
        return events;
    }

   /**
    * @description Compute cartesian product of engagement list event list from course connection assessment to generate a new engagement list event list
    * @param List<Engagement_List_Event__c> engagemenListEvents - engagement list event to be generated
    * @param List<Course_Connection_Assessment__c> courseConnectionAssessments - available Course_Connection_Assessment__c record 
    * @param ELCParser elcParser - criteria parser value   
    * @return - List<Engagement_List_Event__c> - Returns List of Engagement List Events to be created
    */ 
    private List<Engagement_List_Event__c> generate(List<Engagement_List_Event__c> engagemenListEvents, List<Course_Connection_Assessment__c> courseConnectionAssessments, ELCParser elcParser){
        
        if (courseConnectionAssessments == null) {
            // Skip computation and return the original engagemenListEvents
            return engagemenListEvents;
        }
        if (courseConnectionAssessments.size() == 0) {
            // if any of the list is empty, cartesian product will be empty set
            return new List<Engagement_List_Event__c>();
        }
        
        List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        for (Engagement_List_Event__c event : engagemenListEvents) {
            for (Course_Connection_Assessment__c courseConnectionAssessment : courseConnectionAssessments) {               
                Engagement_List_Event__c newEvent = event.clone();

                if (!elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().isEmpty()) {
                    newEvent.Course_Connection_Assessment__c   = courseConnectionAssessment.Id;                  
                }

                if (elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().getDueDateFrom() != null ||
                    elcParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().getDueDateTo() != null) {
                    newEvent.Key_Date__c = courseConnectionAssessment.Assessment_Name__r.Due_Date__c;
                }

                events.add(newEvent);
            }
        }
  
        return events;
    }

   /**
    * @description Compute cartesian product of engagement list event list from Leave of Absence to generate a new engagement list event list
    * @param List<Engagement_List_Event__c> engagemenListEvents - engagement list event to be generated
    * @param List<Leave_of_Absence__c> leaveOfAbsences - available Leave_of_Absence__c record of contacts
    * @param ELCParser elcParser - criteria parser value   
    * @return - List<Engagement_List_Event__c> - Returns List of Engagement List Events to be created
    */ 
    private List<Engagement_List_Event__c> generate(List<Engagement_List_Event__c> engagemenListEvents, List<Leave_of_Absence__c> leaveOfAbsences, ELCParser elcParser){
        
        if (leaveOfAbsences == null) {
            // Skip computation and return the original engagemenListEvents
            return engagemenListEvents;
        }
        if (leaveOfAbsences.size() == 0) {
            // if any of the list is empty, cartesian product will be empty set
            return new List<Engagement_List_Event__c>();
        }
                
        List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        for (Engagement_List_Event__c event : engagemenListEvents) {
            for (Leave_of_Absence__c leaveOfAbsence : leaveOfAbsences) {               
                
                Engagement_List_Event__c newEvent = event.clone();
                
                if (!elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().isEmpty()) {
                    newEvent.Leave_of_Absence__c = leaveOfAbsence.Id;
                }
                
                if (elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().getEndDateFrom() != null ||
                    elcParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().getEndDateTo() != null) {
                    newEvent.Key_Date__c = leaveOfAbsence.End_Date__c;
                }

                events.add(newEvent);
            }
        }
        
        return events;
    }

   /**
    * @description Compute cartesian product of engagement list event list from Program Enrollment Breach to generate a new engagement list event list
    * @param List<Engagement_List_Event__c> engagemenListEvents - engagement list event to be generated
    * @param List<Program_Enrollment_Breach__c> programEnrollmentBreaches - available program enrollment breach record of contacts
    * @param ELCParser elcParser - criteria parser value   
    * @return - List<Engagement_List_Event__c> - Returns List of Engagement List Events to be created
    */ 
    private List<Engagement_List_Event__c> generate(List<Engagement_List_Event__c> engagemenListEvents, List<Program_Enrollment_Breach__c> programEnrollmentBreaches, ELCParser elcParser){
        
        if (programEnrollmentBreaches == null) {
            // Skip computation and return the original engagemenListEvents
            return engagemenListEvents;
        }
        if (programEnrollmentBreaches.size() == 0) {
            // if any of the list is empty, cartesian product will be empty set
            return new List<Engagement_List_Event__c>();
        }
        
        List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        for (Engagement_List_Event__c event : engagemenListEvents) {
            for (Program_Enrollment_Breach__c programEnrollmentBreach : programEnrollmentBreaches) {               
                
                Engagement_List_Event__c newEvent = event.clone();
                
                if (!elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().isEmpty()) {
                    newEvent.Program_Enrollment_Breach__c  = programEnrollmentBreach.Id;    
                }

                if (elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().getBreachDateFrom() != null ||
                    elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().getBreachDateTo() != null) {
                    newEvent.Key_Date__c = programEnrollmentBreach.Breach_Date__c;
                }

                events.add(newEvent);
            }
        }
        
        return events;
    }

   /**
    * @description Compute cartesian product of engagement list event list from Completed Cadence to generate a new engagement list event list
    * @param List<Engagement_List_Event__c> engagemenListEvents - engagement list event to be generated
    * @param List<Completed_Cadence__c> completedCadences - available completed cadence of contact record
    * @param ELCParser elcParser - criteria parser value   
    * @return - List<Engagement_List_Event__c> - Returns List of Engagement List Events to be created
    */ 
    private List<Engagement_List_Event__c> generate(List<Engagement_List_Event__c> engagemenListEvents, List<Completed_Cadence__c> completedCadences, ELCParser elcParser){

        if (completedCadences == null) {
            // Skip computation and return the original engagemenListEvents
            return engagemenListEvents;
        }
        if (completedCadences.size() == 0) {
            // if any of the list is empty, cartesian product will be empty set
            return new List<Engagement_List_Event__c>();
        }
		List<Engagement_List_Event__c> events = new List<Engagement_List_Event__c>();
        for (Engagement_List_Event__c event : engagemenListEvents) {
            for (Completed_Cadence__c completedCadence : completedCadences) {
                
                Engagement_List_Event__c newEvent = event.clone();
                
                if (!elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().isEmpty()) {
                    newEvent.Completed_Cadence__c  = completedCadence.Id;
                }
                
                if (elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().getCompletedCadanceDateFrom() != null ||
                    elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().getCompletedCadanceDateTo() != null) {
                    newEvent.Key_Date__c = completedCadence.LastModifiedDate;
                }

                events.add(newEvent);
            }   
        }
        return events;       
    }

}