/**
 * @description Controller class for Pre-Session Reminder Email Template
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | April 4, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class PreSessionReminderEmailCtrl {
  private static final String STR_QUTEX = 'QUTeX';
  private static final String FILE_NAME = 'Pre-Session Reminder.pdf';
  private static final String PRE_SESSION_EMAIL_TEMPLATE = 'Pre-Session Reminder Email';
  public hed__Course_Enrollment__c courseConnect { get; set; }
  public hed__Course_Offering__c courseOffering { get; set; }
  public List<Session__c> sessions { get; set; }

  public preSessionReminderEmailCtrl() {
    String courseConnectionId = ApexPages.currentPage()
      .getParameters()
      .get('courseConnectionId');
    this.courseConnect = [
      SELECT
        Id,
        hed__Course_Offering__c,
        Amount__c,
        hed__Contact__r.FirstName,
        hed__Contact__r.LastName,
        Course_Offering_Name__c,
        Paid_in_Full__c,
        hed__Course_Offering__r.hed__Course__c
      FROM hed__Course_Enrollment__c
      WHERE Id = :courseConnectionId
      LIMIT 1
    ];

    if (this.courseConnect != null) {
      this.sessions = [
        SELECT
          Id,
          Course_Connection__c,
          Course_Offering__c,
          Course_Connection__r.Name,
          Name,
          Date__c,
          Start_Time_v2__c,
          End_Time_v2__c,
          Location__c,
          Location_Name__c,
          Location_Detail_v2__c
        FROM Session__c
        WHERE Date__c =:Date.today()+1
            AND Course_Offering__r.hed__Course__c = :courseConnect.hed__Course_Offering__r.hed__Course__c
      ];
    }
  }

  @InvocableMethod(
    label='Pre-Session Reminder Confirmation Email Generator'
    description='Generates Email for Pre-Session Reminder Confirmation Email'
  )
  public static void generatePDFandSendEmail(
    List<List<String>> courseConnectionParams
  ) {
    List<String> courseConnections = courseConnectionParams[0];
    String recordId;
    String name;
    String firstName;
    String lastName;
    String toAddress;
    /**
     * Set course connection fields in the email templates
     **/
    if (courseConnectionParams.size() > 0) {
      recordId = courseConnections[0];
      name = courseConnections[1];
      firstName = courseConnections[2];
      lastName = courseConnections[3];
      toAddress = courseConnections[4];
    }

    PageReference pdf = new PageReference(
      '/apex/SessionSchedulePDFView?courseConnectionId=' + recordId
    );
    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    attachment.setContentType('application/pdf');
    attachment.setFileName(FILE_NAME);
    if (Test.isRunningTest()) {
      attachment.body = blob.valueOf('Unit.Test');
    } else {
      attachment.body = pdf.getContent();
    }
    attachment.setInline(false);

    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
      PRE_SESSION_EMAIL_TEMPLATE
    );

    String subject = STR_QUTEX + ' ' + name;

    if (emailTemplate != null) {
      Map<String, String> emailParams = new Map<String, String>{
        '{firstname}' => firstName,
        '{name}' => name
      };

      //Build the email
      Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
        toAddress,
        subject,
        emailTemplate.HtmlValue,
        emailParams
      );

      // Send the email with attachment
      mail.setFileAttachments(
        new List<Messaging.EmailFileAttachment>{ attachment }
      );
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
  }
}