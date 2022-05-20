/**
 * @description Controller class for Online Self-paced Final Confirmation Email Template
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | April 4, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class OnlineSelfPacedConfirmationEmailCtrl {
  private static final String STR_QUTEX = 'QUTeX';
  private static final String ONLINE_SELF_PACED_CONFIRMATION_EMAIL_TEMPLATE = 'Online Self-paced Final Confirmation Email';

  @InvocableMethod(
    label='Online Self-paced Confirmation Email Generator'
    description='Generates Email for Online Self-paced Confirmation'
  )
  public static void generateAndSendEmail(
    List<List<String>> courseConnectionParams
  ) {
    List<String> courseConnections = courseConnectionParams[0];
    String recordId;
    String name;
    String firstName;
    String lastName;
    String startDate;
    String toAddress;
    /**
     * Set course connection fields in the email templates
     **/
    if (courseConnectionParams.size() > 0) {
      recordId = courseConnections[0];
      name = courseConnections[1];
      firstName = courseConnections[2];
      lastName = courseConnections[3];
      startDate = courseConnections[4];
      toAddress = courseConnections[5];
    }

    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
      ONLINE_SELF_PACED_CONFIRMATION_EMAIL_TEMPLATE
    );
    String subject = STR_QUTEX + ' ' + name;

    if (emailTemplate != null) {
      Map<String, String> emailParams = new Map<String, String>{
        '{firstname}' => firstName,
        '{name}' => name,
        '{startdate }' => startDate
      };

      //Build the email
      Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
        toAddress,
        subject,
        emailTemplate.HtmlValue,
        emailParams
      );

      // Send the email
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
  }
}