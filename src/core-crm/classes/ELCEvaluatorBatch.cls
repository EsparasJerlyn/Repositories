/**
 * @description  class for ELCEvaluatorBatch
 * @ELCEvaluator
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | May 14, 2024          | DEPP-8490              | Created file                 |
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
        // Starting fom the leave of each branch in the cirterion hierarchy, so that it inherit as much parent's criteria as possible.
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

        // check if for subquery
        if (contactQuery != null) {
            ContactsDAO contactsDAO = new ContactsDAO();
            return contactsDAO.getQueryLocatorBySubquery(contactQuery);
        }

        return new ContactsDAO().getQueryLocatorByCriteria(eLCParser.getELCContactParser().getContactCriteria());
    }

    public void execute(Database.BatchableContext bc, List<Contact> contacts){
        try {
            execute(contacts);
        } catch (Exception e) {
            Logger.error(
                'Exception caught in method finish in class ELCEvaluatorBatch. Job ID: ' + bc.getJobId() + '. Execution Date: ' + String.valueOf(Date.today())
                , eLCParser.getEngagementListCriteria().Id
            )
            .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    public void execute(List<Contact> contacts) {
        ELCEvaluator eLCEvaluator = new ELCEvaluator(elcParser);
        Map<Id, ELECandidateIngredient> eLECandidateIngredientByContact = eLCEvaluator.evaluate(contacts);
        Map<Id,List<Engagement_List_Event__c>> engagementListMapEvents = new Map<Id,List<Engagement_List_Event__c>>();

        for (ELECandidateIngredient eLECandidateIngredient : eLECandidateIngredientByContact.values()) { 
            ELECandidateGenerator eLECandidateGenerator = new ELECandidateGenerator();
            List<Engagement_List_Event__c> engagementList = eLECandidateGenerator.generate(eLECandidateIngredient);
            Id contactId = eLECandidateIngredient.getContact().Id;
            engagementListMapEvents.put(contactId,engagementList);
        }

        ELECandidateProcessor processor = new ELECandidateProcessor();
        processor.process(engagementListMapEvents, eLCParser.getEngagementListCriteria());
    }

    public void finish(Database.BatchableContext bc) {
        // log error with job id and ExtendedStatus if NumberOfErrors != 0 
        AsyncApexJob job = AsyncApexJobsDAO.newInstance().findAsyncApexJobById(bc.getJobId(), AccessLevel.SYSTEM_MODE);
 
        if (job.NumberOfErrors != 0) {
            String logMessage = 'ELCEvaluatorBatch job failed. Job ID: ' + job.Id + ', Execution Date: ' + String.valueOf(Date.today()) + ', Extended Status: ' + job.ExtendedStatus;
            Logger.error(logMessage, eLCParser.getEngagementListCriteria().Id);
        }
        if (eLCEvaluationJobs.size() > 1) {
            eLCEvaluationJobs.remove(0);
            // Process the next Engagement_Lis_Criteria__c
            Database.executeBatch(new ELCEvaluatorBatch(eLCEvaluationJobs));
        }
    }
    
}