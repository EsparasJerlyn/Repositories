/**
 * @description Controller class for Registration Confirmation Email Template
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | April 4, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class RegistrationConfirmationEmailCtrl {
  private static final String STR_QUTEX = 'QUTeX';
  private static final String REGISTRATION_CONFIRMATION_EMAIL_TEMPLATE = 'Registration Confirmation Email Template';

  @InvocableMethod(
    label='Registration Confirmation Email Generator'
    description='Generates Email for Registration Confirmation'
  )
  public static void generateAndSendEmail(
    List<List<String>> courseConnectionParams
  ) {
    List<String> courseConnections = courseConnectionParams[0];
    String recordId;
    String name;
    String paidInFull;
    String firstName;
    String lastName;
    String amount;
    String email;
    String toAddress;
    /**
     * Set course connection fields in the email templates
     **/
    if (courseConnectionParams.size() > 0) {
      recordId = courseConnections[0];
      name = courseConnections[1];
      paidInFull = courseConnections[2];
      firstName = courseConnections[3];
      lastName = courseConnections[4];
      amount = courseConnections[5];
      toAddress = courseConnections[6];
    }

    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
      REGISTRATION_CONFIRMATION_EMAIL_TEMPLATE
    );
    String subject = STR_QUTEX + ' ' + name;

    if (emailTemplate != null) {
      Map<String, String> emailParams = new Map<String, String>{
        '{fullname}' => firstName +
        ' ' +
        lastName,
        '{name}' => name,
        '{paid}' => paidInFull,
        '{amount}' => amount
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