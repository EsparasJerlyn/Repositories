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

   /**
   * @description Sends email when Employee Self Registration is Selected in CCE Detail page
   * @param userId - Id of the logged user
   * @param productId - Id of product selected in CCE Detail Page
   * @param selectedOffering - Id of the selected Product Offering (Course/Program Offering)
   */
    @AuraEnabled
    public static String sendEmployeeRegistrationEmail(Id userId, String productId, Id selectedOffering, String pricebookEntryId){
		
		// Query Contact based on the user Id
		User u = [
			SELECT
				Id,
				Contact.Work_Email__c,
				Contact.Name
			FROM User
			WHERE Id = :userId
			LIMIT 1
		];

		//Query Product Details for the email detials
		List<Product2> p = [
			SELECT
				Id,
				Name,
				Description, 
				Overview__c, 
				Evolve_with_QUTeX__c, 
				Who_Should_Participate__c,
				Core_Concepts__c, 
				More_Details__c
			FROM Product2
			WHERE Id = :productId
			LIMIT 1
		];

    	// Get Org Wide Email Address
		List<OrgWideEmailAddress> owea = [
			SELECT Id, Address, DisplayName
			FROM OrgWideEmailAddress
			WHERE DisplayName = 'QUTeX'
			LIMIT 1
		];

		// Get Email Template
		EmailTemplate emailTemplate = EmailTemplateSelector.getEmailTemplate(
			EMPLOYEE_SELF_REGISTRATION_EMAIL
		);

		//Get Form URL Custom Setting
		EmployeeSelfRegistrationForm__c employeeSelfRegistrationSettings = EmployeeSelfRegistrationForm__c.getOrgDefaults();

		String response;
		// Process
		if(
			u != null && 
			!p.isEmpty() &&
			emailTemplate != null
		) {
			String subject = p[0].Name;
			String fullName = u.Contact.Name;
			String title = 'Title';
			String titleValue = p[0].Name;
			String description = 'Description';
			String descriptionValue = p[0].Description;
			String overview = 'Overview';
			String overviewValue = insertInlineStyleToHtmlElement(p[0].Overview__c, 'img', 'width:100%');
			overviewValue = insertInlineStyleToHtmlElement(overviewValue, 'p', 'margin:0');
			String evolve = 'Evolve with QUTeX';
			String evolveValue = insertInlineStyleToHtmlElement(p[0].Evolve_with_QUTeX__c, 'img', 'width:100%');
			evolveValue = insertInlineStyleToHtmlElement(evolveValue, 'p', 'margin:0');
			String participate = 'Who Should Participate?';
			String participateValue = insertInlineStyleToHtmlElement(p[0].Who_Should_Participate__c, 'img', 'width:100%');
			participateValue = insertInlineStyleToHtmlElement(participateValue, 'p', 'margin:0');
			String concepts = 'Core Concepts';
			String conceptsValue = insertInlineStyleToHtmlElement(p[0].Core_Concepts__c, 'img', 'width:100%');
			conceptsValue = insertInlineStyleToHtmlElement(conceptsValue, 'p', 'margin:0');
			String moredetails = 'More Details';
			String moredetailsValue = insertInlineStyleToHtmlElement(p[0].More_Details__c, 'img', 'width:100%');
			moredetailsValue = insertInlineStyleToHtmlElement(moredetailsValue, 'p', 'margin:0');
	
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
				'{moredetails}'	=> String.isEmpty(moredetailsValue)? '': moredetails,
				'{moredetails_value}' => String.isEmpty(moredetailsValue)? '': moredetailsValue,
				'{employeeSelfRegistrationEmailLink}' => employeeSelfRegistrationSettings.EmployeeSelfRegistrationLink__c != null ? 
														String.valueOf(employeeSelfRegistrationSettings.EmployeeSelfRegistrationLink__c) 
														+ '?id=' + String.valueOf(selectedOffering) 
														+ '&pb-id=' + String.valueOf(pricebookEntryId) : ''
			};
	
			// Build the Email
			Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
				u.Contact.Work_Email__c,
				subject,
				emailTemplate.HtmlValue,
				emailParams
			);

			// Set Org Wide Email Address
			if (!owea.isEmpty()) {
				mail.setOrgWideEmailAddressId(owea[0].Id);
			}
			
			// Add Email to List
			List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
			sendEmailList.add(mail);
			
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
		if(!String.isBlank(html)) {
			// if insertTo and styletoInsert is blank, skip everything and return html as is
			if(!String.isBlank(insertTo) && !String.isBlank(styleToInsert)) {
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
		}
		return result;
	}
}
