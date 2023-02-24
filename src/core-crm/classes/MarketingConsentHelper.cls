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

*/
public without sharing class MarketingConsentHelper {

	public static void setOptOutAndInDates(List<Contact> newItems, Map<Id,Contact> oldMap){
		for(Contact con: newItems){
			//add email opt out date when opt in -> opt out
			if(oldMap != null && con.HasOptedOutOfEmail != oldMap.get(con.Id).HasOptedOutOfEmail && con.HasOptedOutOfEmail == true){
				con.Email_Opt_Out_DateTime__c = System.now();
			//add email opt in date when opt in or opt out -> opt in
			}else if(con.HasOptedOutOfEmail == false && (oldMap == null || con.HasOptedOutOfEmail != oldMap.get(con.Id).HasOptedOutOfEmail)){
				con.Email_Opt_In_DateTime__c = System.now();
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

	private static Map<String, List<Marketing_Segmentation__c>> getExistingMarketingSegmentations(Map<String, List<Marketing_Segmentation__c>> marketingSegMap, Map<String, Contact> emailToContactMap ){

		if(!emailToContactMap.keySet().isEmpty()){
			for(Marketing_Segmentation__c marSeg: [ SELECT Id, My_Profile_Persona__c, 
			My_Primary_Study_Level__c, My_Secondary_Study_Level__c, 
			Contact__c, Contact__r.Email, Contact__r.Registered_Email__c,
			Contact__r.Work_Email__c, Contact__r.QUT_Staff_Email__c,
			Contact__r.QUT_Learner_Email__c
			FROM Marketing_Segmentation__c 
			WHERE Contact__r.Registered_Email__c IN: emailToContactMap.keySet()
			OR Contact__r.Email IN: emailToContactMap.keySet()
			OR Contact__r.Work_Email__c IN: emailToContactMap.keySet()
			OR Contact__r.QUT_Staff_Email__c IN: emailToContactMap.keySet()
			OR Contact__r.QUT_Learner_Email__c IN: emailToContactMap.keySet()]){

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
			upsert segmentationsToUpsert;
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
