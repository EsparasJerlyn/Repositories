/**
* @description Helper Class ContactTriggerHanlder when QUT_Identity_ID__c and QUT_Student_Username__c is populated
* @see .. ContactTriggerHanlder
*
* @author Accenture
*
* @history
*
| Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
|--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
| eugene.andrew.abuan            | June 29, 2022         | DEPP-3339              | Created File                                                                  |
| eugene.andrew.abuan            | July 04, 2022         | DEPP-3387              | Updated Email to Registered Email                                             |
|                                |                       |                        |                                                                               |

*/
public without sharing class ContactUserNameCreatedHelper {
	private static final String SEND_QUT_USERNAME_EMAIL = 'Send QUT Username Email';

   /**
   * @description send Email to Contact when QUT_Identity_ID__c & QUT_Student_Username__c is populated
   * @param contactIdSet - List of Contact.Trigger.new
   */
    public static String sendEmailUsernameCreated(Set<Id> contactIdSet) {
		
		// Query Contact Detials
		List<Contact> opeContact = [
			SELECT
			  Id,
			  QUT_Identity_ID__c,
			  QUT_Student_Username__c,
			  FirstName,
			  Registered_Email__c
			FROM Contact
			WHERE Id IN :contactIdSet
		 ];
    	// Get Org Wide Email Address
		List<OrgWideEmailAddress> owea = [
			SELECT Id, Address, DisplayName
			FROM OrgWideEmailAddress
			WHERE DisplayName = 'QUTeX'
			LIMIT 1
			];

		// Get Email Template
		EmailTemplate emailTemplate = [Select Id,Name,Subject,HtmlValue,Body from EmailTemplate where name=:SEND_QUT_USERNAME_EMAIL LIMIT 1];

		// Get Study Store URL Custom Setting
		Study_Store_URL_Settings__c storeLinkSettings = Study_Store_URL_Settings__c.getOrgDefaults();

		// Process
		List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
		if (emailTemplate != null) {
			for (Contact c : opeContact) {
				if (String.IsNotBlank(c.Registered_Email__c)){
					// Set Email values
					String subject = 'QUTeX Professional & Executive Education';
					String firstName = c.FirstName;
					String username = c.QUT_Student_Username__c;

					// Set Email Params
					Map<String, String> emailParams = new Map<String, String>{
						'{firstName}' => firstName,
						'{username}' => username,
						'{storeLink}' => storeLinkSettings.Study_Store_Link__c != null
							? String.valueOf(storeLinkSettings.Study_Store_Link__c)
							: ''
					};

					// Build the Email
					Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
					msg.setToAddresses(new String[]{c.Registered_Email__c});
					msg.setSubject(subject);
					msg.setHtmlBody(EmailHelper.setBodyValues(emailTemplate.HtmlValue, emailParams, true));
					msg.setOrgWideEmailAddressId(owea[0]?.Id);
					msg.setTargetObjectId(c.Id);
					msg.setSaveAsActivity(true);
					msg.setTreatTargetObjectAsRecipient(false);
					msg.setUseSignature(false);
					// Add Email to List
					sendEmailList.add(msg);
				}
			}

			// Send Email only when list it's not empty
			if(!sendEmailList.isEmpty()){
				Messaging.sendEmail(sendEmailList);
			}
		}
		return 'success';
    }
}
