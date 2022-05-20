/**
 * @description Controller class for Post Course Completion Email Template
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | April 4, 2022         | DEPP-1479              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class PostCourseCompletionEmailCtrl {
  private static final String STR_QUTEX = 'QUTeX';
  private static final String POST_COURSE_COMPLETION_EMAIL_TEMPLATE = 'Post Course Completion Email';

  @InvocableMethod(
    label='Post Course Completion Email Generator'
    description='Generates Email for Post Course Completion'
  )
  public static void generateAndSendEmail(
    List<List<String>> courseConnectionParams
  ) {
    List<String> courseConnections = courseConnectionParams[0];
    String recordId;
    String name;
    String firstName;
    String toAddress;
    /**
     * Set course connection fields in the email templates
     **/
    if (courseConnectionParams.size() > 0) {
      recordId = courseConnections[0];
      name = courseConnections[1];
      firstName = courseConnections[2];
      toAddress = courseConnections[3];
    }

    EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
      POST_COURSE_COMPLETION_EMAIL_TEMPLATE
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

      // Send the email
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
  }
}