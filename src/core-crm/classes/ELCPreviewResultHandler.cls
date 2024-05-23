/**
 * @description This class handles the preview results for Engagement List Criteria (ELC).
 * It generates CSV attachments based on candidate ingredients and manages the success and failure
 * of asynchronous batch jobs related to ELC preview generation.
 * @history
 *    | Developer                 | Date         | JIRA        | Change Summary                                  |
 *    |---------------------------|--------------|-------------|------------------------------------------------|
 *    | roy.nino.s.regala         | May 21, 2024 | DEPP-8744   | Created File                                   |
 */
public inherited sharing class ELCPreviewResultHandler {
    private Engagement_List_Criteria__c criteria;
    private Date executionDate;

    /**
     * @description Constructor to initialize ELCPreviewResultHandler with criteria and execution date.
     * @param criteria The Engagement List Criteria record.
     * @param executionDate The date of execution for the handler.
     */
    public ELCPreviewResultHandler(Engagement_List_Criteria__c criteria, Date executionDate) {
        this.criteria = criteria;
        this.executionDate = executionDate;
    }

    /**
     * @description Handles the candidate ingredients by generating a temporary CSV attachment.
     * @param candidateIngredients A list of ELECandidateIngredient records.
     */
    public void handle(List<ELECandidateIngredient> candidateIngredients) {
        if (candidateIngredients.isEmpty()) {
            return;
        }

        String csvContent = '';
        for (ELECandidateIngredient candidateIngredient : candidateIngredients) {
            Contact student = candidateIngredient.getContact();

            csvContent +=
                '"' +
                (student.QUT_Student_Id__c != null ? student.QUT_Student_Id__c : '') +
                '","' +
                (student.Name != null ? student.Name : '') +
                '","' +
                (student.Email != null ? student.Email : '') +
                '","' +
                (student.MobilePhone != null ? student.MobilePhone : '') +
                '"\n';
        }

        createAttachment(criteria.Name + '_Temp_Preview_Result.csv', csvContent);
    }

    /**
     * @description Handles the asynchronous job by checking its status and calling appropriate methods for success or failure.
     * @param jobId The ID of the asynchronous Apex job.
     */
    public void handle(Id jobId, Set<String> errorMessageSet) {
        AsyncApexJob job = AsyncApexJobsDAO.newInstance()
            .findAsyncApexJobById(jobId, AccessLevel.USER_MODE);

        if (errorMessageSet.isEmpty() && job.NumberOfErrors == 0) {
            handleSuccess();
        } else {
            handleFailure(job, errorMessageSet);
        }
    }

    /**
     * @description Handles the success of the asynchronous job by generating the final CSV and updating the preview status.
     */
    private void handleSuccess() {
        generateCSV();
        OutreachCampaignService.updatePreviewStatus(
            criteria,
            EngagementListCriteriasDAO.COMPLETED_PREVIEW_STATUS
        );
        // Construct the base URL for your Salesforce instance
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        // Append the object type and record Id to the base URL
        String recordUrl = baseUrl + '/' + criteria.Id;
        // Send notification email
        sendEmailNotification(
            'Preview Generated Success Email',
            new Map<String, String>{
                '{elcURL}' => recordUrl,
                '{criteriaTitle}' => criteria.Engagement_List_Criteria_Title__c
            }
        );
    }

    /**
     * @description Handles the failure of the asynchronous job by logging the error and updating the preview status.
     * @param job The asynchronous Apex job that failed.
     */
    public void handleFailure(AsyncApexJob job, Set<String> errorMessageSet) {
        OutreachCampaignService.updatePreviewStatus(
            criteria,
            EngagementListCriteriasDAO.FAILED_PREVIEW_STATUS
        );
        String fullError = '';
        Boolean first = true;

        if (job.ExtendedStatus != null) {
            String logMessage =
                'ELCPreviewBatch job failed. Job ID: ' +
                job.Id +
                ', Execution Date: ' +
                String.valueOf(executionDate) +
                ', Extended Status: ' +
                job.ExtendedStatus;
            Logger.error(logMessage, criteria.Id);

            errorMessageSet.add(job.ExtendedStatus);
        }

        for (String errorMessage : errorMessageSet) {
            if (first) {
                first = false;
            } else {
                fullError += '<br />';
            }
            fullError += errorMessage;
        }
        // Send notification email
        sendEmailNotification(
            'Preview Generated Error Email',
            new Map<String, String>{ '{errors}' => fullError }
        );
    }

    /**
     * @description Generates the final CSV from the temporary CSV attachments and updates the criteria with the attachment ID.
     */
    private void generateCSV() {
        String finalCsvContent = 'Student ID,Full Name,Primary Email,Mobile\n'; // Header row

        List<Attachment> tempAttachments = AttachmentsDAO.newInstance()
            .findAttachmentsByName(
                criteria.Name + '_Temp_Preview_Result.csv',
                AccessLevel.USER_MODE
            );

        for (Attachment tempAttachment : tempAttachments) {
            finalCsvContent += tempAttachment.Body.toString();
        }

        // Delete temporary CSV attachments created by running job
        if (!tempAttachments.isEmpty()) {
            AttachmentsDAO.newInstance()
                .deleteRecords(tempAttachments, true, AccessLevel.USER_MODE);
        }

        criteria.Preview_Result_Attachment_Id__c = createAttachment(
                criteria.Name + '_Preview_Result.csv',
                finalCsvContent
            )
            .Id;
    }

    /**
     * @description Creates an attachment with the given file name and CSV content, and attaches it to the criteria.
     * @param fileName The name of the CSV file.
     * @param csvContent The content of the CSV file.
     * @return The created Attachment record.
     */
    private Attachment createAttachment(String fileName, String csvContent) {
        Attachment csvAttachment = new Attachment();
        csvAttachment.ParentId = criteria.Id;
        csvAttachment.Name = fileName;
        csvAttachment.Body = Blob.valueOf(csvContent);
        csvAttachment.ContentType = 'text/csv';

        AttachmentsDAO.newInstance()
            .insertRecords(new List<Attachment>{ csvAttachment }, true, AccessLevel.USER_MODE);
        return csvAttachment;
    }

    /**
     * @description Sends a notification email to the current user using a predefined email template.
     * The email template includes merge fields that are replaced with values from the `emailParams` map.
     * @param templateName The name of the email template to use.
     * @param emailParams A map of placeholders and their corresponding values to replace in the email template.
     */
    private void sendEmailNotification(String templateName, Map<String, String> emailParams) {
        // Fetch the current user
        User currentUser = UsersDAO.newInstance()
            .getUsersById(new Set<Id>{ UserInfo.getUserId() }, AccessLevel.USER_MODE)[0];

        // Fetch the email template by name
        EmailTemplate emailTemplate = EmailTemplatesDAO.newInstance()
            .getEmailTemplatesByNameSet(new Set<String>{ templateName }, AccessLevel.USER_MODE)[0];

        // Fetch the org-wide email address for sending the email
        OrgWideEmailAddress owea = OrgWideEmailAddressesDAO.newInstance()
            .getOrgWideEmailAddressByDisplayName(
                new Set<String>{ OrgWideEmailAddressesDAO.ORG_WIDE_EMAIL_STUDENT_SUCCESS },
                AccessLevel.USER_MODE
            )[0];
        // Add the current user's first name to the email parameters
        emailParams.put('{firstName}', currentUser.FirstName);

        // Create the email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ currentUser.Email }); // Use the email address of the current user
        email.setTemplateId(emailTemplate.Id); // Set the email template ID
        email.setSubject(
            criteria.Engagement_List_Criteria_Title__c + ' - ' + emailTemplate.Subject
        );
        email.setHtmlBody(EmailHelper.setBodyValues(emailTemplate.HtmlValue, emailParams, false));
        email.setOrgWideEmailAddressId(owea.Id);
        email.setSaveAsActivity(true); // Save as activity
        email.setWhatId(criteria.Id);
        // Send the email
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email }, false);
    }
}