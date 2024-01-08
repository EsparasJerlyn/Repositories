/**
 * @description Controller class for Employee-Self Registration Email
 *
 * @see ../lwc/productDetailsDisplay
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                         |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------------|
      | eugene.andrew.abuan       | July 21, 2022         | DEPP-2730            | Created file                                           |
      | alexander.cadalin         | Sep 29, 2022          | DEPP-4464            | Fixed formating for Employee_Self_Registration_Email   | 
*/

public without sharing class EmployeeSelfRegistrationCtrl {
	private static final String EMPLOYEE_SELF_REGISTRATION_EMAIL = 'Employee Self-Registration Email';
	private static final String DISPLAY_NAME = 'QUTeX';
   /**
   * @description Sends email when Employee Self Registration is Selected in CCE Detail page
   * @param userId - Id of the logged user
   * @param productId - Id of product selected in CCE Detail Page
   * @param selectedOffering - Id of the selected Product Offering (Course/Program Offering)
   */
    @AuraEnabled
    public static String sendEmployeeRegistrationEmail(SelfRegistrationParams selfRegistrationParams, String accountSelected){
		
		// Query Contact based on the user Id
		List<User> u = UsersDAO.newInstance().getUsersById(new Set<Id>{selfRegistrationParams.userId}, AccessLevel.SYSTEM_MODE);

		//Query Product Details for the email detials
		List<Product2> p = ProductsDAO.newInstance().getProductById(new Set<Id>{selfRegistrationParams.productId}, AccessLevel.SYSTEM_MODE);

    	// Get Org Wide Email Address
		List<OrgWideEmailAddress> owea = OrgWideEmailAddressesDAO.newInstance().getOrgWideEmailAddressByDisplayName(new Set<String>{DISPLAY_NAME}, AccessLevel.SYSTEM_MODE);

		// Get Email Template
		List<EmailTemplate> emailTemplate = EmailTemplatesDAO.newInstance().getEmailTemplatesByNameSet(new Set<String>{EMPLOYEE_SELF_REGISTRATION_EMAIL}, AccessLevel.SYSTEM_MODE);

		//Get Form URL Custom Setting
		EmployeeSelfRegistrationForm__c employeeSelfRegistrationSettings = EmployeeSelfRegistrationForm__c.getOrgDefaults();

		String response;
		// Process
		if(
			!u.isEmpty() && 
			!p.isEmpty() &&
			!emailTemplate.isEmpty()
		) {
			String subject = p[0].Name;
			String fullName = u[0].Contact.Name;
			String title = 'Title';
			String titleValue = p[0].Name;
			String description = 'Description';
			String descriptionValue = p[0].Description;
			String overview = 'Overview';
			String overviewValue = removeImgElementsFromHtml(p[0].Overview__c);
			overviewValue = insertInlineStyleToHtmlElement(overviewValue, 'p', 'margin:0');
			String evolve = 'Evolve with QUTeX';
			String evolveValue = removeImgElementsFromHtml(p[0].Evolve_with_QUTeX__c);
			evolveValue = insertInlineStyleToHtmlElement(evolveValue, 'p', 'margin:0');
			String participate = 'Who Should Participate?';
			String participateValue = removeImgElementsFromHtml(p[0].Who_Should_Participate__c);
			participateValue = insertInlineStyleToHtmlElement(participateValue, 'p', 'margin:0');
			String concepts = 'Core Concepts';
			String conceptsValue = removeImgElementsFromHtml(p[0].Core_Concepts__c);
			conceptsValue = insertInlineStyleToHtmlElement(conceptsValue, 'p', 'margin:0');
	
			// Set Email Params
			Map<String, String> emailParams = new Map<String, String>{
				'{fullname}' => fullName,
				'{title}' => String.isEmpty(titleValue)? '' : title,
				'{title_value}' => String.isEmpty(titleValue)? '' : titleValue,
				'{description}'=> String.isEmpty(descriptionValue)? '' : description,	
				'{description_value}' =>  String.isEmpty(descriptionValue)? '' : descriptionValue,
				'{overview}' => String.isEmpty(overviewValue)? '' : overview,
				'{overview_value}' => String.isEmpty(overviewValue)? '': overviewValue,
				'{evolve}'=> String.isEmpty(evolveValue)? '': evolve,
				'{evolve_value}'=> String.isEmpty(evolveValue)? '': evolveValue,
				'{participate}' => String.isEmpty(participateValue)? '': participate,	
				'{participate_value}' => String.isEmpty(participateValue)? '': participateValue,
				'{concepts}' => String.isEmpty(conceptsValue)? '': concepts,
				'{concepts_value}' => String.isEmpty(conceptsValue)? '': conceptsValue,
				'{employeeSelfRegistrationEmailLink}' => employeeSelfRegistrationSettings.EmployeeSelfRegistrationLink__c != null ? 
														String.valueOf(employeeSelfRegistrationSettings.EmployeeSelfRegistrationLink__c) 
														+ '?id=' + String.valueOf(selfRegistrationParams.selectedOffering) 
														+ '&pb-id=' + String.valueOf(selfRegistrationParams.pricebookEntryId) 
														+ '&acct-id=' + String.valueOf(accountSelected) : ''
			};
	
			// Build the Email
			Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
			msg.setToAddresses(new String[]{u[0].Contact.Work_Email__c});
			msg.setSubject(subject);
			msg.setHtmlBody(EmailHelper.setBodyValues(emailTemplate[0].HtmlValue, emailParams, true));
			msg.setOrgWideEmailAddressId(owea[0]?.Id);
			msg.setSaveAsActivity(true);
			msg.setTreatTargetObjectAsRecipient(false);
			msg.setUseSignature(false);

			// Add Email to List
			List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
			sendEmailList.add(msg);
			
			// Send Email List
			Messaging.SendEmailResult[] serList = Messaging.sendEmail(sendEmailList);

			if(serList[0].isSuccess()) {
				response = 'success';
			} else {
				response = serList[0].getErrors()[0].getMessage();
			}
		}
		return response;
    }

	/**
	 * @function
	 * @param {String} html The html code with elements you want to insert inline styling to.
	 * @param {String} insertTo The HTML element tag that you want to insert to style to. Remove the < and > symbols (e.g., '<p>' -> 'p')
	 * @param {String} styleToInsert The CSS style code you want to insert (e.g., 'font:12px Arial,Helvetica,sans-serif')
	 * @return {String}
	 * @description Insert inline style to an HTML element in a given HTML stored in a string.
	 */
	private static String insertInlineStyleToHtmlElement(String html, String insertTo, String styleToInsert) {
		String result = '';

		// if html is blank, skip everything and return empty string
		if(!String.isBlank(html) && !String.isBlank(insertTo) && !String.isBlank(styleToInsert)) {
			String splitAt = '<' + insertTo;
			styleToInsert = 'style="' + styleToInsert + '"';
			List<String> choppedHtml = html.split(splitAt);
			Boolean isFirstElement = html.substring(0, splitAt.length() - 1) == splitAt;
			for(Integer i = 0; i < choppedHtml.size(); i++) {
				if(i == 0 && !isFirstElement) {
					result = choppedHtml[i];
					continue;
				}
				result += splitAt + ' ' + styleToInsert + ' ' + choppedHtml[i];
			}
		} else {
			result = html;
		}
		return result;
	}

	/**
	 * @function
	 * @param {String} html The html code with elements you want to insert inline styling to.
	 * @return {String}
	 * @description Remove any img elements in the html passed in as a string
	 */
	private static String removeImgElementsFromHtml(String html) {
		if(String.isNotBlank(html)) {
			html = html.replaceAll('<img(.*?)>', ''); // remove img elements
			html = html.replaceAll('</img>', ''); // remove img end tags in case html string is using it
		}
		return html;
	}

	public class SelfRegistrationParams{
        @AuraEnabled
        public Id userId{ get; set; }
        @AuraEnabled
        public String productId{ get; set; }
        @AuraEnabled
        public Id selectedOffering{ get; set; }
        @AuraEnabled
        public String pricebookEntryId{ get; set; }
    }
}
