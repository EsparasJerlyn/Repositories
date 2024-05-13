/**
 * 
 */
public with sharing class ELCEvaluatorBatch implements Database.Batchable<sObject>{
    
    private List<ELCEvaluationJob> eLCEvaluationJobs;
    private ELCParser eLCParser;

    public ELCEvaluatorBatch(List<ELCEvaluationJob> eLCEvaluationJobs) {
        this.eLCEvaluationJobs = eLCEvaluationJobs;

        // Only focus on first ELCEvaluationJob
        ELCEvaluationJob eLCEvaluationJob = eLCEvaluationJobs[0];
        elcParser = new ELCParser(
            eLCEvaluationJob.getCriteria(), 
            eLCEvaluationJob.getExecutionDate()
        );
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Starting fom the leave of each brranch in the cirterion hierarchy, so that it inherit as much parent's criteria as possible.
        String contactQuery;

        if (!eLCParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria().isEmpty()) {
            contactQuery = new CourseConnectionAssessmentsDAO().getContactQueryByCriteria(
                eLCParser.getELCCourseConnectionAssessmentParser().getCourseConnectionAssessmentCriteria(),
                eLCParser.getELCCourseConnectionParser().getCourseConnectionCriteria(),
                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                elcParser.getELCContactParser().getContactCriteria()
            );
        } else if (!eLCParser.getELCCourseConnectionParser().getCourseConnectionCriteria().isEmpty()) {
            contactQuery = new CourseConnectionsDAO().getContactQueryByCriteria(
                eLCParser.getELCCourseConnectionParser().getCourseConnectionCriteria(),
                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                elcParser.getELCContactParser().getContactCriteria()
            );
        } else if(!eLCParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().isEmpty()){
            contactQuery = new LeaveOfAbsencesDAO().getContactQueryByCriteria(
                eLCParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria(),
                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                elcParser.getELCContactParser().getContactCriteria()
            );
        } else if(!eLCParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().isEmpty()){
            contactQuery = new ProgramEnrollmentBreachesDAO().getContactQueryByCriteria(
                eLCParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria(),
                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                elcParser.getELCContactParser().getContactCriteria()
            );
        } else if (!eLCParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().isEmpty()) {
            contactQuery = new ProgramEnrollmentsDAO().getContactQueryByCriteria(
                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                elcParser.getELCContactParser().getContactCriteria()
            );
        } else if(!eLCParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().isEmpty()){
            contactQuery = new CompletedCadencesDAO().getContactQueryByCriteria(
                elcParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria(),
                elcParser.getELCContactParser().getContactCriteria()
            );
        }

        //check if for subquery
        if (contactQuery != null) {
            ContactsDAO contactsDAO = new ContactsDAO();
            return contactsDAO.getQueryLocatorBySubquery(eLCParser.getELCContactParser().getContactCriteria());
        }

        return new ContactsDAO().getQueryLocatorByCriteria(eLCParser.getELCContactParser().getContactCriteria()); //need pa ba to?
    }

    public void execute(Database.BatchableContext bc, List<Contact> contacts){
        System.debug(contacts);
        //execute(contacts);
    }

    /* public void execute(List<Contact> contacts) {
        ELCEvaluator eLCEvaluator = new ELCEvaluator(elcParser);
        Map<Id, List<ELECandidateIngrident>> eleCandidateIngridentMap = eLCEvaluator.evaluate(contacts);
        List<Engagement_List_Event__c> engagementListEvents = new List<Engagement_List_Event__c>();
        ELECandidateGenerator eLECandidateGenerator = new ELECandidateGenerator();
        for (ELECandidateIngrident eLECandidateIngrident : eleCandidateIngridentMap.values()) {
          engagementListEvents.add(eLECandidateGenerator.generate(eLECandidateIngrident));
        }
        ELECandidateProcessor eLECandidateProcessor = new ELECandidateProcessor();
        eLECandidateProcessor.process(engagementListEvents);
    } */

    public void finish(Database.BatchableContext bc) {
      // log error with job id and ExtendedStatus if NumberOfErrors != 0 
        if (eLCEvaluationJobs.size() > 1) {
            eLCEvaluationJobs.remove(0);
            // Process the next Engagement_Lis_Criteria__c
            Database.executeBatch(new ELCEvaluatorBatch(eLCEvaluationJobs));
        }
    }
    
}