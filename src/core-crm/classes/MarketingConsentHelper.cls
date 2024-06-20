/**
* @description Helper Class to update marketing segmentation records for marketing consent
* @see .. ContactTriggerHanlder
*
* @author Accenture
*
* @history
*
| Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
|--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
| roy.nino.s.regala              | Feb 06, 2023          | DEPP-4866              | Created File                                                                  |
| roy.nino.s.regala              | Feb 20, 2023          | DEPP-5221              | added opt out and in dates                                                    |
| roy.nino.s.regala              | Oct 31, 2023          | DEPP-7060              | made sure to email opt in date to now only if it is not directly updated      |
|								 |                       |                        | this happens on lead convert or case creation                                 |
| johanna.a.gibas                | Jan 04, 2024          | ApexCRUDViolationFix   | Fixed CRUD Violation                                                          |
| sebastianne.k.trias            | June 06, 2024         | DEPP-8474              | Modify method setOptOutAndInDates                                             |
*/
public without sharing class MarketingConsentHelper {

	public static Map<Id, Boolean> runSetOptOutAndInDates = new Map<Id, Boolean>();

	private static final Map<String,Map<String,String>> setOptOutAndInFields = new Map<String,Map<String,String>>{
		'hasOptOutEmail' => new Map<String,String>{
			'optedOutField' => 'HasOptedOutOfEmail',
			'optInDateTimeField' => 'Email_Opt_In_DateTime__c',
			'optOutDateTimeField' => 'Email_Opt_Out_DateTime__c'
		},
		'smsOptOut' => new Map<String,String>{
			'optedOutField' => 'hed__SMS_Opt_Out__c',
			'optInDateTimeField' => 'SMS_Opt_In_DateTime__c',
			'optOutDateTimeField' => 'SMS_Opt_Out_DateTime__c'
		},
		'workSMSOptOut' => new Map<String,String>{
			'optedOutField' => 'Work_SMS_Opt_Out__c',
			'optInDateTimeField' => 'Work_SMS_Opt_In_DateTime__c',
			'optOutDateTimeField' => 'Work_SMS_Opt_Out_DateTime__c'
		}
	};

	public static void setOptOutAndInDates(List<SObject> newItems, Map<Id, SObject> oldMap, String objectName ) {
		Boolean isInsert = oldMap == null;

		Map<String, Boolean> booleanParams = new Map<String, Boolean>();
		Map<String, Datetime> dateTimeFieldsValue = new Map<String, Datetime>();

		for (SObject item : newItems) {

			booleanParams.put('isInsert', isInsert);

			if(objectName == 'Contact'){
				item = (Contact) item;
			}
			else if(objectName == 'Lead'){
				item = (Lead) item;
			}

			if( !isInsert && runSetOptOutAndInDates.containsKey((Id) item.get('Id'))){
				continue;
			}

			else{
				if( !isInsert && !runSetOptOutAndInDates.containsKey((Id) item.get('Id')) ){
					runSetOptOutAndInDates.put((Id) item.get('Id'), false);
				}
				
				for(Map<String,String> optOutFields : setOptOutAndInFields.values()){
					if( isInsert && item.get(optOutFields.get('optedOutField')) == false && item.get(optOutFields.get('optInDateTimeField')) == null ){
						continue;
					}
					boolean isHasOptedOutOfEmailChanged = !isInsert && ( item.get(optOutFields.get('optedOutField')) != oldMap.get( (Id) item.get('Id') ).get(optOutFields.get('optedOutField')) );
					booleanParams.put('isFieldOptOutOfEmailChanged', isHasOptedOutOfEmailChanged); // to get if hasoptedout is changed
					booleanParams.put('optedOutOfEmailNewValue', (Boolean) item.get(optOutFields.get('optedOutField'))); // to get the new value of optedoutofemail field
	
					dateTimeFieldsValue.put('newOptInValue', (Datetime) item.get(optOutFields.get('optInDateTimeField')) );
					dateTimeFieldsValue.put('newOptOutValue', (Datetime) item.get(optOutFields.get('optOutDateTimeField')) );
					
					if(!isInsert){
						dateTimeFieldsValue.put('oldOptInValue', (Datetime) oldMap.get( (Id) item.get('Id') ).get(optOutFields.get('optInDateTimeField')) );
						dateTimeFieldsValue.put('oldOptOutValue', (Datetime) oldMap.get( (Id) item.get('Id') ).get(optOutFields.get('optOutDateTimeField')) );
					}
	
					item.put(optOutFields.get('optInDateTimeField'), validateOptOutAndInFields(booleanParams, dateTimeFieldsValue).get('optInValue'));
					item.put(optOutFields.get('optOutDateTimeField'), validateOptOutAndInFields(booleanParams, dateTimeFieldsValue).get('optOutValue'));
				}
			}
		}
    }

	public static void processMarketingConsent(List<Contact> newItems, Map<Id,Contact> oldMap){

		Map<String, Contact> emailToContactMap = new Map<String,Contact>();
		Map<String, List<Marketing_Segmentation__c>> marketingSegMap =  new Map<String,List<Marketing_Segmentation__c>>();

		for(Contact con: newItems){
			//only process contacts with below condition
			//registered email is populated
			//from study portal     
			if( con.Registered_Email__c != null && con.Consent_Source_Category__c == 'Study Application' && ((oldMap == null && con.HasOptedOutOfEmail == false) || 
			(oldMap != null && (oldMap.get(con.Id).Email_Opt_In_DateTime__c != con.Email_Opt_In_DateTime__c || oldMap.get(con.Id).HasOptedOutOfEmail != con.HasOptedOutOfEmail)))){
				//contact is new or old that is opt in -> opt in or opt out -> opt in or opt in -> opt out
				emailToContactMap.put(con.Registered_Email__c,con);
				marketingSegMap.put(con.Registered_Email__c,new List<Marketing_Segmentation__c>());
			}
		}

		upsertMarketingSegmentation(getExistingMarketingSegmentations(marketingSegMap,emailToContactMap),emailToContactMap);

	}

	private static Map<String, Datetime> validateOptOutAndInFields(
		Map<String, Boolean> booleanParams,
		Map<String, Datetime> datetimeValues
	){
		Map<String, Datetime> returnValues = new Map<String, Datetime>();
		Boolean isInsert = booleanParams.get('isInsert');
		Boolean isFieldOptOutOfEmailChanged = booleanParams.get('isFieldOptOutOfEmailChanged');
		Boolean optedOutOfEmailValue = booleanParams.get('optedOutOfEmailNewValue');

		Datetime newOptInValue = datetimeValues.get('newOptInValue');
		Datetime oldOptInValue = datetimeValues.containsKey('oldOptInValue') ? datetimeValues.get('oldOptInValue') : null;

		Datetime newOptOutValue = datetimeValues.get('newOptOutValue');
		Datetime oldOptOutValue = datetimeValues.containsKey('oldOptOutValue') ? datetimeValues.get('oldOptOutValue') : null;

		Boolean isOptInDatetimeChanged = !isInsert && newOptInValue != oldOptInValue;
		Boolean isOptOutDatetimeChanged = !isInsert && newOptOutValue != oldOptOutValue;

		Datetime emailOptInDateTimeValue = null;
		Datetime emailOptOutDateTimeValue = null;

		if( isInsert && optedOutOfEmailValue == false && newOptInValue != null ){
			emailOptInDateTimeValue = newOptInValue;
			emailOptOutDateTimeValue = null;
		}
		else if( isInsert && optedOutOfEmailValue == true && newOptOutValue != null ){
			emailOptInDateTimeValue = null;
			emailOptOutDateTimeValue = newOptOutValue;
		}

		if( !isInsert && !isFieldOptOutOfEmailChanged ){
			emailOptInDateTimeValue = oldOptInValue;
			emailOptOutDateTimeValue = oldOptOutValue;
		}
		else if ( optedOutOfEmailValue == false && isFieldOptOutOfEmailChanged && isOptInDatetimeChanged ){
			emailOptInDateTimeValue = newOptInValue;
			emailOptOutDateTimeValue = oldOptOutValue;
		}
		else if ( optedOutOfEmailValue == true && isFieldOptOutOfEmailChanged && isOptOutDatetimeChanged ){
			emailOptInDateTimeValue = oldOptInValue;
			emailOptOutDateTimeValue = newOptOutValue;
		}
		else if( optedOutOfEmailValue == false && isFieldOptOutOfEmailChanged && !isOptInDatetimeChanged ){
			emailOptInDateTimeValue = System.now();
			emailOptOutDateTimeValue = oldOptOutValue;
		}
		else if( optedOutOfEmailValue == true && isFieldOptOutOfEmailChanged && !isOptOutDatetimeChanged ){
			emailOptInDateTimeValue = oldOptInValue;
			emailOptOutDateTimeValue = System.now();
		}

		returnValues.put('optInValue', emailOptInDateTimeValue);
		returnValues.put('optOutValue', emailOptOutDateTimeValue);

		return returnValues;
	}

	private static Map<String, List<Marketing_Segmentation__c>> getExistingMarketingSegmentations(Map<String, List<Marketing_Segmentation__c>> marketingSegMap, Map<String, Contact> emailToContactMap ){

		if(!emailToContactMap.keySet().isEmpty()){
			
			for(Marketing_Segmentation__c marSeg: MarketingSegmentationsDAO.newInstance().getExistingMarketingSegmentations(emailToContactMap,AccessLevel.SYSTEM_MODE)){

				//create email to marketing segmentation map
				//this groups marketing segmentation agains a person and mc persona with the same registered email
				if(emailToContactMap.containsKey(marSeg.Contact__r.Email)){
					marketingSegMap.get(marSeg.Contact__r.Email).add(marSeg);
				}else if(emailToContactMap.containsKey(marSeg.Contact__r.Work_Email__c)){
					marketingSegMap.get(marSeg.Contact__r.Work_Email__c).add(marSeg);
				}else if(emailToContactMap.containsKey(marSeg.Contact__r.QUT_Staff_Email__c)){
					marketingSegMap.get(marSeg.Contact__r.QUT_Staff_Email__c).add(marSeg);
				}else if(emailToContactMap.containsKey(marSeg.Contact__r.QUT_Learner_Email__c)){
					marketingSegMap.get(marSeg.Contact__r.QUT_Learner_Email__c).add(marSeg);
				}
			}
		}
		

		return marketingSegMap;

	}

	private static void upsertMarketingSegmentation(Map<String,List<Marketing_Segmentation__c>> marketingSegMap, Map<String,Contact> emailToContactMap){

		Marketing_Segmentation__c newMarketingSeg;
		List<Marketing_Segmentation__c> segmentationsToUpsert = new List<Marketing_Segmentation__c>();

		for(String emailKey: marketingSegMap.keySet()){
			//has existing marketing segmentations
			for(Marketing_Segmentation__c marSeg: marketingSegMap.get(emailKey)){
			if( emailToContactMap.get(emailKey).HasOptedOutOfEmail == false){
				//if opt in 
				marSeg.My_Profile_Persona__c = 'Open Professional Education';
				marSeg = processContactOptIn(marSeg);
			}else{
				//if opt out
				//nullify fields if equal to specified values
				marSeg = processContactOptOut(marSeg);
			}
			segmentationsToUpsert.add(marSeg);
			}

			//no existing marketing segmentation and contact is opt in
			if(marketingSegMap.get(emailKey).isEmpty() && emailToContactMap.get(emailKey).HasOptedOutOfEmail == false){
			//create new marketing segmentation
			newMarketingSeg = new Marketing_Segmentation__c(
				My_Profile_Persona__c = 'Open Professional Education',
				My_Primary_Study_Level__c = 'Short Courses and Professional Development',
				Contact__c = emailToContactMap.get(emailKey).Id
			);
			marketingSegMap.get(emailKey).add(newMarketingSeg);
			segmentationsToUpsert.addAll(marketingSegMap.get(emailKey));
			}
		}

		if(!segmentationsToUpsert.isEmpty()){
			MarketingSegmentationsDAO.newInstance().upsertRecords(segmentationsToUpsert, false, AccessLevel.SYSTEM_MODE);
		}
	}

	private static Marketing_Segmentation__c processContactOptIn(Marketing_Segmentation__c marSeg){
	
		if(   	marSeg.My_Primary_Study_Level__c != 'Short Courses and Professional Development' &&
				marSeg.My_Secondary_Study_Level__c != 'Short Courses and Professional Development' && 
				marSeg.My_Primary_Study_Level__c != null){
				//if both primary and study level is not short courses and professional development 
				//And primary study level is populated
				//update the secondary study level
				marSeg.My_Secondary_Study_Level__c = 'Short Courses and Professional Development';

		}else if(   marSeg.My_Primary_Study_Level__c != 'Short Courses and Professional Development' && 
					marSeg.My_Secondary_Study_Level__c != 'Short Courses and Professional Development' && 
					marSeg.My_Primary_Study_Level__c == null){
					//if both primary and study level is not short courses and professional development 
					//And primary study level is not populated
					//update the secondary study level
					marSeg.My_Primary_Study_Level__c = 'Short Courses and Professional Development';
		}

		return marSeg;
	}

	private static Marketing_Segmentation__c processContactOptOut(Marketing_Segmentation__c marSeg){
	
		marSeg.My_Profile_Persona__c = marSeg.My_Profile_Persona__c == 'Open Professional Education'?null:marSeg.My_Profile_Persona__c;
		marSeg.My_Primary_Study_Level__c = marSeg.My_Primary_Study_Level__c == 'Short Courses and Professional Development'?null:marSeg.My_Primary_Study_Level__c;
		marSeg.My_Secondary_Study_Level__c = marSeg.My_Secondary_Study_Level__c == 'Short Courses and Professional Development'?null:marSeg.My_Secondary_Study_Level__c;

		return marSeg;
	}
}