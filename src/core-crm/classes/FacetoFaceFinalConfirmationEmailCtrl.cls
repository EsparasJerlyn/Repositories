/**
 * @description Controller class for Face to Face Final Confirmation Email Template
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | April 4, 2022         | DEPP-1479              | Created file                 |
      | rhea.b.torres                  | June 22, 2022         | DEPP-3188              | Get sessions with Date__c is |
      |                                |                       |                        | tomorrow                     |
 */
public with sharing class FacetoFaceFinalConfirmationEmailCtrl {
  private static final String STR_QUTEX = 'QUTeX';
  private static final String FILE_NAME = 'Face-to-Face(Final Confirmation).pdf';
  private static final String FACE2FACE_CONFIRMATION_EMAIL_TEMPLATE = 'Face-Face Final Confirmation Email';
  public hed__Course_Enrollment__c courseConnect { get; set; }
  public List<Session__c> sessions { get; set; }

  public facetoFaceFinalConfirmationEmailCtrl() {
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
        Paid_in_Full__c
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
        WHERE Course_Connection__c = :courseConnectionId AND Date__c =:Date.today()+1
      ];
    }
  }

  @InvocableMethod(
    label='Face to Face Final Confirmation Email Generator'
    description='Generates Email for Face to Face Final Confirmation Email'
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
      '/apex/FacetoFaceFinalConfirmationPDFView?courseConnectionId=' + recordId
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
      FACE2FACE_CONFIRMATION_EMAIL_TEMPLATE
    );

    String subject = STR_QUTEX + ' ' + name;

    if (emailTemplate != null) {
      Map<String, String> emailParams = new Map<String, String>{
        '{fullname}' => firstName +
        ' ' +
        lastName,
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