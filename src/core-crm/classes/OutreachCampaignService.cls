/**
 * @description This class provides services to manage the preview status and attachments for
 * Engagement List Criteria (ELC). It includes methods to update preview status, execute
 * preview batch jobs, abort jobs, and delete attachments.
 * @history
 *    | Developer                 | Date         | JIRA        | Change Summary                                  |
 *    |---------------------------|--------------|-------------|------------------------------------------------|
 *    | roy.nino.s.regala         | May 21, 2024 | DEPP-8744   | Created File                                   |
 */
public with sharing class OutreachCampaignService {
    /**
     * @description Updates the preview status of the given Engagement List Criteria.
     * If the status is 'In Progress', it clears the result attachment ID. If the status is 'Not Generated',
     * it clears the job ID.
     * @param criteria The Engagement List Criteria record to update.
     * @param previewStatus The new preview status to set.
     */
    public static void updatePreviewStatus(
        Engagement_List_Criteria__c criteria,
        String previewStatus
    ) {
        criteria.Preview_Status__c = previewStatus;

        if (previewStatus == EngagementListCriteriasDAO.IN_PROGRESS_PREVIEW_STATUS) {
            criteria.Preview_Result_Attachment_Id__c = null;
        } else if (previewStatus == EngagementListCriteriasDAO.NOT_GENERATED_PREVIEW_STATUS) {
            criteria.Preview_Result_Attachment_Id__c = null;
            criteria.Preview_Job_Id__c = null;
        }

        EngagementListCriteriasDAO.newInstance()
            .updateRecords(
                new List<Engagement_List_Criteria__c>{ criteria },
                true,
                AccessLevel.USER_MODE
            );
    }

    /**
     * @description Executes a batch job for generating the preview of the given Engagement List Criteria.
     * @param criteria The Engagement List Criteria record to process.
     * @param executionDate The date when the batch job should be executed.
     */
    public static void executePreviewBatch(
        Engagement_List_Criteria__c criteria,
        Date executionDate
    ) {
        ELCPreviewBatch previewBatch = new ELCPreviewBatch(criteria, executionDate);
        Database.executeBatch(previewBatch);
    }

    /**
     * @description Deletes the final result attachment associated with the given Engagement List Criteria.
     * @param criteria The Engagement List Criteria record whose attachment needs to be deleted.
     */
    public static void deleteFinalAttachment(Engagement_List_Criteria__c criteria) {
        if (criteria.Preview_Result_Attachment_Id__c != null) {
            AttachmentsDAO.newInstance()
                .deleteRecords(
                    new List<Id>{ criteria.Preview_Result_Attachment_Id__c },
                    true,
                    AccessLevel.USER_MODE
                );
        }
    }

    /**
     * @description Deletes the temporary preview result attachments associated with the given Engagement List Criteria.
     * @param criteria The Engagement List Criteria record whose temporary attachments need to be deleted.
     */
    public static void deleteTempAttachments(Engagement_List_Criteria__c criteria) {
        String elcName = criteria.Name + '_Temp_Preview_Result.csv';
        List<Attachment> attachmentsToDelete = AttachmentsDAO.newInstance()
            .findAttachmentsByNames(new Set<String>{ elcName }, AccessLevel.USER_MODE);
        if (!attachmentsToDelete.isEmpty()) {
            AttachmentsDAO.newInstance()
                .deleteRecords(attachmentsToDelete, true, AccessLevel.USER_MODE);
        }
    }

    /**
     * Generates a contact query string based on the provided criteria from the ELCParser.
     *
     *
     * @param eLCParser an instance of ELCParser containing various criteria parsers
     * @return a contact query string based on the first non-empty criteria found,
     *         or null if no criteria are found
     */
    public static String getQueryLocatorBySubQueryString(ELCParser eLCParser) {
        String contactQuery;

        if (
            !eLCParser.getELCCourseConnectionAssessmentParser()
                .getCourseConnectionAssessmentCriteria()
                .isEmpty()
        ) {
            return new CourseConnectionAssessmentsDAO()
                .getContactQueryByCriteria(
                    eLCParser.getELCCourseConnectionAssessmentParser()
                        .getCourseConnectionAssessmentCriteria(),
                    eLCParser.getELCCourseConnectionParser().getCourseConnectionCriteria(),
                    eLCParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                    eLCParser.getELCContactParser().getContactCriteria()
                );
        }
        if (!eLCParser.getELCCourseConnectionParser().getCourseConnectionCriteria().isEmpty()) {
            return new CourseConnectionsDAO()
                .getContactQueryByCriteria(
                    eLCParser.getELCCourseConnectionParser().getCourseConnectionCriteria(),
                    eLCParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                    eLCParser.getELCContactParser().getContactCriteria()
                );
        }
        if (!eLCParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria().isEmpty()) {
            return new LeaveOfAbsencesDAO()
                .getContactQueryByCriteria(
                    eLCParser.getELCLeaveOfAbsenceParser().getLeaveOfAbsencesCriteria(),
                    eLCParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                    eLCParser.getELCContactParser().getContactCriteria()
                );
        }
        if (
            !eLCParser.getELCProgramEnrollmentBreachParser()
                .getProgramEnrollmentBreachCriteria()
                .isEmpty()
        ) {
            return new ProgramEnrollmentBreachesDAO()
                .getContactQueryByCriteria(
                    eLCParser.getELCProgramEnrollmentBreachParser()
                        .getProgramEnrollmentBreachCriteria(),
                    eLCParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                    eLCParser.getELCContactParser().getContactCriteria()
                );
        }
        if (!eLCParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria().isEmpty()) {
            return new ProgramEnrollmentsDAO()
                .getContactQueryByCriteria(
                    eLCParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(),
                    eLCParser.getELCContactParser().getContactCriteria()
                );
        }
        if (!eLCParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria().isEmpty()) {
            return new CompletedCadencesDAO()
                .getContactQueryByCriteria(
                    eLCParser.getELCCompletedCadenceParser().getCompletedCadenceCriteria(),
                    eLCParser.getELCContactParser().getContactCriteria()
                );
        }

        return contactQuery;
    }

    /**
     * @description Aborts the running batch job associated with the given Engagement List Criteria.
     * @param criteria The Engagement List Criteria record whose job needs to be aborted.
     */
    public static void abortJob(Engagement_List_Criteria__c criteria) {
        if (criteria.Preview_Job_Id__c != null) {
            WithoutSharingInnerClass withoutSharingClass = new WithoutSharingInnerClass();
            withoutSharingClass.abortJobWithoutSharing(criteria.Preview_Job_Id__c);
        }
    }

    /**
     * Inner class without sharing.
     */
    private without sharing class WithoutSharingInnerClass {
        /**
         * @description Aborts the job without enforcing sharing rules.
         * Only users with modify all permission can abort a job
         * @param jobId The ID of the job to be aborted.
         */
        private void abortJobWithoutSharing(Id jobId) {
            System.abortJob(jobId);
        }
    }
}
