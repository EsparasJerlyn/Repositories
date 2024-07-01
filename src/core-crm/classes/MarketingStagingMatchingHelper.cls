/**
 * @description TriggerHandler Class for MarketingStagingMatchingHelper
 * @see ..MarketingStagingMatchingHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | June 28, 2022         | DEPP-3070              | Created file                                   |
      | roy.nino.s.regala              | July 20, 2022         | DEPP-3535              | Updated logic to update mobile and birthdate   |
      | kenneth.f.alsay                | January 3, 2024       |                        | Fixed excessive param list                     |
      | mark.j.mahilum                 | March 06, 2024        | DEPP-8008              | Added fieldmapping for lead source and category|
      | eccarius.munoz                 | March 26, 2024        | DEPP-8008              | Added fieldmapping for studylink app source    |
      | sebastianne.k.trias            | June 1, 2024          | DEPP-8474              | Add changes on opt in opt out fields           |
      
 */
public without sharing class MarketingStagingMatchingHelper{

    private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

    private static final List<String> MARKETING_SEGMENTATION_FIELDS = new List<String>{
        'Migration_Key__c','Prospects_Behaviour__c','Prospects_Rank__c',
        'Prospects_Score__c','Previous_Educational_Institution__c','Secondary_School_Name__c',
        'Alumnus_Educational_Institution__c','Course_Referrer__c','My_Profile_Persona__c','My_Citizenship_Status__c',
        'My_Indigenous_Status_ATSI__c','My_Country_Of_Citizenship__c','My_Country_Of_Residency__c','My_Expected_Admission_Year__c',
        'My_Year_12_Expected_Completion_Year__c','My_Studying_Australian_Curriculum__c','My_Funding_Source__c',
        'My_Moving_To_Brisbane__c','My_High_Achieving_Student__c','My_Elite_Athlete__c','My_Organisation__c',
        'My_Position__c','My_Industry__c','My_Primary_Study_Level__c','My_Primary_BSA__c','My_Primary_NSA__c',
        'My_Secondary_Study_Level__c','My_Secondary_BSA__c','My_Secondary_NSA__c','My_Double_Degree__c',
        'My_Interested_Pathway_Program_or_Diploma__c','My_Interested_English_Pathways__c','My_Interested_Financial_Assistance__c',
        'My_Interested_Entrepreneurship__c','My_Interested_Languages__c','My_Interested_ESport_Interest__c','My_Postcode__c',
        'My_State__c','My_Suburb__c','SE_Profile_Persona__c','SE_Citizenship_Status__c','SE_Indigenous_Status_ATSI__c',
        'SE_Country_Of_Citizenship__c','SE_Country_Of_Residency__c','SE_Expected_Admission_Year__c','SE_Education_Level__c', 'SE_Year_12_Expected_Completion_Year__c',
        'SE_Studying_Australian_Curriculum__c','SE_Funding_Source__c','SE_Moving_To_Brisbane__c','SE_High_Achieving_Student__c',
        'SE_Elite_Athlete__c','SE_Organisation__c','SE_Position__c','SE_Industry__c','SE_Primary_Study_Level__c','SE_Primary_BSA__c',
        'SE_Primary_NSA__c','SE_Secondary_Study_Level__c','SE_Secondary_BSA__c','SE_Secondary_NSA__c','SE_Double_Degree__c',
        'SE_Interested_Pathway_Program_or_Diploma__c','SE_Interested_English_Pathways__c','SE_Interested_Financial_Assistance__c',
        'SE_Interested_Entrepreneurship__c','SE_Interested_Languages__c','SE_Interested_ESport_Interest__c','SE_Interested_Course_Name__c',
        'SE_Postcode__c','SE_State__c','SE_Suburb__c','ORG_Profile_Persona__c','ORG_Indigenous_Status_ATSI__c','ORG_Country_Of_Residency__c',
        'ORG_Organisation__c','ORG_Position__c','ORG_Industry__c','ORG_Primary_Study_Level__c','ORG_Primary_BSA__c','ORG_Primary_NSA__c',
        'ORG_Secondary_Study_Level__c','ORG_Secondary_BSA__c','ORG_Secondary_NSA__c','ORG_Interested_Languages__c','ORG_Interested_Course_Name__c',
        'ORG_Postcode__c','ORG_State__c', 'ORG_Education_Level__c', 'ORG_Suburb__c', 'My_Education_Level__c','External_Key__c',
        'Mailing_Address_Country__c'
    };

    private static final List<String> MARKETING_INTERACTION_FIELDS = new List<String>{
        'External_Key__c','Migration_Key__c','Interaction_Type__c','Interaction_DateTime__c','Lead_Source_Category__c','Lead_Source__c',
        'SPAD__c','Page_Display_Name__c','Page_URL__c','UTM_Source__c','UTM_Campaign__c','UTM_Medium__c',
        'UTM_Term__c','UTM_Content__c','Enquiry_Type__c','Enquiry_Description__c','EDM_Last_Send_DateTime__c','Fee_Amount__c',
        'Discount_Amount__c','Country_Joining_From__c','QUT_Sloan_MIT_Affiliation__c','Has_Attended__c','Event_Agency_Host__c',
        'Event_City__c','Event_Date__c','Event_Name__c','QUT_Staff_Name__c','QUT_Staff_Email__c','Event_Type__c','Match_My_Skill_Completion__c',
        'MMS_Process_State__c', 'EDM_Last_Clicked_DateTime__c','EDM_Last_Opened_DateTime__c'
    };

    private static final List<String> MARKETING_APPLICATION_FIELDS = new List<String>{
        'Application_Source__c', 'Applicant_Id__c','Application_Id__c', 'QUT_Student_ID__c', 'Migration_Key__c',
        'Preference_Number__c', 'Course_Code__c','Course_Level__c','Course_Name__c','Course_Major__c','Course_Campus__c',
        'Course_URL__c','Pathway_Principal_Course_Code__c','Pathway_Principal_Course_Name__c','Pathway_Principal_Course_Owning_Faculty__c',
        'Faculty__c','Course_Description__c','Offer_Exists__c','Course_Start_Month__c','Admission_Year__c','Course_Start_Date__c',
        'Home_Environment_Responsibilities_Applic__c','Personal_Illness_Disability_Applicant__c','Educational_Disruption_Applicant__c',
        'English_Language_Difficulties_Applicant__c','EAS_Application__c','Financial_Hardship_Applicant__c','Course_Allocability_Status__c',
        'QTAC_Offer_Able__c','QTAC_Offer_Round__c','Intake_Year__c','isAgent_Assisted__c','Submission_Format__c','Application_Status__c',
        'Application_Status_Date__c','Submission_Date__c','Offer_Date__c','Intake_Period_Type__c','Offer_Expiry_Date__c','IsApplying_for_Visa_Onshore__c',
        'IsPackaged_Offer__c','Offer_Response_Date__c','Scholarship_Name__c','Scholarship_Status__c','Previous_Enrolled_Student__c','IsOffer_Made__c',
        'Admission_Category__c','Admission_Period__c','Admission_Status__c','Student_Study_Package_Status__c','Agency_Branch__c','Agency_Country__c',
        'Agency_Email__c','Agency_Name__c','Has_Offer_Condition__c','Offer_Status__c','Offer_Status_Date__c','Application_Number__c',
        'Is_International_Student_Application__c','Is_Research_Application__c','App_Condition_Verification_Status__c','Admission_Process__c','Agency_Code__c','QTAC_ID__c'
    };

    private static final Map<String,String> CONTACT_FIELDS = new Map<String,String>{
        'HasOptedOutOfEmail' => 'HasOptedOutOfEmail__c', 'Email_Opt_In_DateTime__c' => 'Email_OptIn_DateTime__c',
        'Email_Opt_Out_DateTime__c' => 'Email_OptOut_DateTime__c', 'hed__SMS_Opt_Out__c' => 'SMS_Opt_Out__c',
        'SMS_Opt_In_DateTime__c' => 'SMS_OptIn_DateTime__c', 'SMS_Opt_Out_DateTime__c' => 'SMS_OptOut_DateTime__c',
        'Dont_Market__c' => 'Dont_Market__c', 'Dont_Market_Reason__c' => 'Dont_Market_Reason__c',
        'Dont_Market_DateTime__c' => 'Dont_Market_DateTime__c', 'Dont_Market_DateTime__c' => 'Dont_Market_DateTime__c',
        'Consent_Source_Category__c' => 'Consent_Source_Category__c','Consent_Source__c' => 'Consent_Source__c',
        'Email_Unsub_JobID__c' => 'Email_Unsub_JobID__c', 'Email_Unsub_Reason__c' => 'Email_Unsub_Reason__c',
        'LeadSource' => 'Lead_Source__c','Lead_Source_Category__c' => 'Lead_Source_Category__c'
    };

    private static final Map<String,String> LEAD_FIELDS = new Map<String,String>{
        'Migration_key__c' => 'Migration_Key__c','FirstName' => 'First_Name__c' ,
        'LastName' => 'Last_Name__c', 'Email' => 'Email__c',
        'MiddleName' => 'Middle_Name__c','LeadMobile_Locale__c' => 'MarketingStaging_Mobile_Locale__c',
        'Preferred_Given_Name__c' => 'Preferred_Given_Name__c','Salutation' => 'Salutation__c',
        'hed__Birth_Date__c' => 'Birthdate__c', 'hed__Gender__c' => 'Gender__c',
        'Phone_No_Locale__c' => 'Phone__c', 'Mobile_No_Locale__c' => 'Mobile__c', 'Street' => 'Street__c',
        'City' => 'City__c', 'PostalCode' => 'PostalCode__c', 'State' => 'State__c',
        'Country' => 'Country__c', 'HasOptedOutOfEmail' => 'HasOptedOutOfEmail__c',
        'Email_Opt_In_DateTime__c' => 'Email_OptIn_DateTime__c','Email_Opt_Out_DateTime__c' => 'Email_OptOut_DateTime__c',
        'hed__SMS_Opt_Out__c' => 'SMS_Opt_Out__c', 'SMS_Opt_In_DateTime__c' => 'SMS_OptIn_DateTime__c',
        'SMS_Opt_Out_DateTime__c' => 'SMS_OptOut_DateTime__c','Dont_Market__c' => 'Dont_Market__c',
        'Dont_Market_Reason__c' => 'Dont_Market_Reason__c', 'Dont_Market_DateTime__c' => 'Dont_Market_DateTime__c',
        'Consent_Source_Category__c' => 'Consent_Source_Category__c',
        'Consent_Source__c' => 'Consent_Source__c', 'Email_Unsub_JobID__c' => 'Email_Unsub_JobID__c', 
        'Email_Unsub_Reason__c' => 'Email_Unsub_Reason__c',
        'LeadSource' => 'Lead_Source__c',
        'Lead_Source_Category__c' => 'Lead_Source_Category__c'
    };

    private static final Map<String,String> LEAD_FIELDS_UPDATE = new Map<String,String>{
        'HasOptedOutOfEmail' => 'HasOptedOutOfEmail__c','Email_Opt_In_DateTime__c' => 'Email_OptIn_DateTime__c',
        'Email_Opt_Out_DateTime__c' => 'Email_OptOut_DateTime__c', 'hed__SMS_Opt_Out__c' => 'SMS_Opt_Out__c',
        'SMS_Opt_In_DateTime__c' => 'SMS_OptIn_DateTime__c', 'SMS_Opt_Out_DateTime__c' => 'SMS_OptOut_DateTime__c',
        'Dont_Market__c' => 'Dont_Market__c','Dont_Market_Reason__c' => 'Dont_Market_Reason__c',
        'Dont_Market_DateTime__c' => 'Dont_Market_DateTime__c', 'Consent_Source_Category__c' => 'Consent_Source_Category__c',
        'Consent_Source__c' => 'Consent_Source__c','Email_Unsub_JobID__c' => 'Email_Unsub_JobID__c', 
        'Email_Unsub_Reason__c' => 'Email_Unsub_Reason__c'
    };

    private static final Map<String,List<String>> MARKETING_OBJECT_MAP = new Map<String,List<String>>{
        'Marketing_Segmentation__c' => MARKETING_SEGMENTATION_FIELDS,
        'Marketing_Interaction__c' => MARKETING_INTERACTION_FIELDS,
        'Marketing_Course_Application__c' => MARKETING_APPLICATION_FIELDS
    };

    private static final Set<String> MARKETING_STAGING_MARKETING_FIELDS = new Set<String>{
        'HasOptedOutOfEmail__c',
        'Email_OptIn_DateTime__c',
        'Email_OptOut_DateTime__c',
        'SMS_Opt_Out__c',
        'SMS_OptIn_DateTime__c',
        'SMS_OptOut_DateTime__c'
    };



    /**
     * @description create contact record from marketing staging fields
     * @param marketingStage - marketingstaging object
     * @param oldContactId - contactId
     * @param salutations - salutation picklist values
     */
    public static sObject createContactRecord(sObject marketingStage, Id oldContactId, List<String> salutations){
        sObject obj = Schema.getGlobalDescribe().get('Contact').newSObject();
        Map<String,String> finalMaping = new Map<String,String>();
        finalMaping = CONTACT_FIELDS;
        if(oldContactId != null){
            obj.put('Id',oldContactId);

            //check if current contact in loop has its birthdate populated
            if( MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) &&
                MarketingStagingTriggerHelper.contactMatches.get(oldContactId).BirthDate == null){
                finalMaping.put('BirthDate','Birthdate__c');
            }

                //check if current contact in loop has its mobile no locale populated
            if( MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) &&
                MarketingStagingTriggerHelper.contactMatches.get(oldContactId).Mobile_No_Locale__c == null){
                    finalMaping.put('Mobile_No_Locale__c','Mobile__c');
                finalMaping.put('ContactMobile_Locale__c','MarketingStaging_Mobile_Locale__c');
            }
            
            //check if current contact in loop has its Lead Source populated
            if( MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) &&
                MarketingStagingTriggerHelper.contactMatches.get(oldContactId).LeadSource == null){
                finalMaping.put('LeadSource','Lead_Source__c');
            }
            
            //check if current contact in loop has its Lead Source Category populated
            if( MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) &&
                MarketingStagingTriggerHelper.contactMatches.get(oldContactId).Lead_Source_Category__c == null){
                finalMaping.put('Lead_Source_Category__c','Lead_Source_Category__c');
            }

            if ( MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) && MarketingStagingTriggerHelper.contactMatches.get(oldContactId).LeadSource != null){
                finalMaping.remove('LeadSource');
            }
            
            if ( MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) && MarketingStagingTriggerHelper.contactMatches.get(oldContactId).Lead_Source_Category__c != null){
                finalMaping.remove('Lead_Source_Category__c');
            }

        }

        for(String fieldName: finalMaping.keySet()){
            if( marketingStage.get(finalMaping.get(fieldName)) != null &&
                !MARKETING_STAGING_MARKETING_FIELDS.contains(finalMaping.get(fieldName)) &&
                ( (  fieldName == 'Salutation' &&
                    salutations.contains((String)marketingStage.get(finalMaping.get(fieldName))) ) ||
                    fieldName != 'Salutation')){
                obj.put(fieldName,(marketingStage.get(finalMaping.get(fieldName))));
            }
        }

        Boolean checkMarketingStagingEmailOptOut = (Boolean) marketingStage.get(finalMaping.get('HasOptedOutOfEmail')) == true && 
                                              (Datetime) marketingStage.get(finalMaping.get('Email_Opt_Out_DateTime__c')) != null;

        Boolean checkMarketingStagingEmailOptIn =  (Boolean) marketingStage.get(finalMaping.get('HasOptedOutOfEmail')) == false &&
                                              (Datetime) marketingStage.get(finalMaping.get('Email_Opt_In_DateTime__c')) != null;

        Boolean conditionToContactEmailOptIn =  checkMarketingStagingEmailOptIn &&
                                      MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) &&
                                      ( MarketingStagingTriggerHelper.contactMatches.get(oldContactId).HasOptedOutOfEmail == true || 
                                       ( MarketingStagingTriggerHelper.contactMatches.get(oldContactId).HasOptedOutOfEmail == false &&
                                         MarketingStagingTriggerHelper.contactMatches.get(oldContactId).Email_Opt_In_DateTime__c == null
                                       ) 
                                      );

        Boolean conditionToContactEmailOptOut = checkMarketingStagingEmailOptOut &&
                                      MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) &&
                                      MarketingStagingTriggerHelper.contactMatches.get(oldContactId).HasOptedOutOfEmail == false;

        if( conditionToContactEmailOptIn ){
            obj.put('HasOptedOutOfEmail', false);
            obj.put('Email_Opt_In_DateTime__c', (Datetime) marketingStage.get(finalMaping.get('Email_Opt_In_DateTime__c')) );
        }

        else if( conditionToContactEmailOptOut ){
            obj.put('HasOptedOutOfEmail', true);
            obj.put('Email_Opt_Out_DateTime__c', (Datetime) marketingStage.get(finalMaping.get('Email_Opt_Out_DateTime__c')) );
        }

        // sms
        Boolean checkMarketingStagingSMSOptOut = (Boolean) marketingStage.get(finalMaping.get('hed__SMS_Opt_Out__c')) == true && 
                                              (Datetime) marketingStage.get(finalMaping.get('SMS_Opt_Out_DateTime__c')) != null;

        Boolean checkMarketingStagingSMSOptIn =  (Boolean) marketingStage.get(finalMaping.get('hed__SMS_Opt_Out__c')) == false &&
                                              (Datetime) marketingStage.get(finalMaping.get('SMS_Opt_In_DateTime__c')) != null;

        Boolean conditionToContactSMSOptIn =  checkMarketingStagingSMSOptIn &&
                                      MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) &&
                                      ( MarketingStagingTriggerHelper.contactMatches.get(oldContactId).hed__SMS_Opt_Out__c == true || 
                                       ( MarketingStagingTriggerHelper.contactMatches.get(oldContactId).hed__SMS_Opt_Out__c == false &&
                                         MarketingStagingTriggerHelper.contactMatches.get(oldContactId).SMS_Opt_In_DateTime__c == null
                                       ) 
                                      );

        Boolean conditionToContactSMSOptOut = checkMarketingStagingSMSOptOut &&
                                      MarketingStagingTriggerHelper.contactMatches.containsKey(oldContactId) &&
                                      MarketingStagingTriggerHelper.contactMatches.get(oldContactId).hed__SMS_Opt_Out__c == false;

        if( conditionToContactSMSOptIn ){
            obj.put('hed__SMS_Opt_Out__c', false);
            obj.put('SMS_Opt_In_DateTime__c', (Datetime) marketingStage.get(finalMaping.get('SMS_Opt_In_DateTime__c')) );
            // obj.put('SMS_Opt_Out_DateTime__c', (Datetime) MarketingStagingTriggerHelper.contactMatches.get(oldContactId).SMS_Opt_Out_DateTime__c );
        }

        else if( conditionToContactSMSOptOut ){
            obj.put('hed__SMS_Opt_Out__c', true);
            // obj.put('SMS_Opt_In_DateTime__c', (Datetime) MarketingStagingTriggerHelper.contactMatches.get(oldContactId).SMS_Opt_In_DateTime__c );
            obj.put('SMS_Opt_Out_DateTime__c', (Datetime) marketingStage.get(finalMaping.get('SMS_Opt_Out_DateTime__c')) );
        }
        
        return obj;
    }

    /**
     * @description create lead record from marketing staging fields
     * @param marketingStage - marketingstaging object
     * @param oldLeadId - leadId
     * @param salutations - salutation picklist values
     */
    public static sObject createLeadRecord(sObject marketingStage, Id oldLeadId, List<String> salutations){
        sObject obj = Schema.getGlobalDescribe().get('Lead').newSObject();

        Map<String,String> finalMaping = new Map<String,String>();
        if(oldLeadId != null){
            obj.put('Id',oldLeadId);
            finalMaping = LEAD_FIELDS_UPDATE;

                //check if current lead in loop has its birthdate populated
            if( MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).hed__Birth_Date__c == null){
                finalMaping.put('hed__Birth_Date__c','Birthdate__c');
            }

            //check if current lead in loop has its contact mobile locale populated
            if( MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).Mobile_No_Locale__c == null){
                finalMaping.put('LeadMobile_Locale__c','MarketingStaging_Mobile_Locale__c');
                finalMaping.put('Mobile_No_Locale__c','Mobile__c');
            }
            
            //check if current lead in loop has its lead source is not populated
            if( MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).LeadSource == null){
                finalMaping.put('LeadSource','Lead_Source__c');
            }
            //check if current lead in loop has its lead source category is not populated
            if( MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).Lead_Source_Category__c == null){
                finalMaping.put('Lead_Source_Category__c','Lead_Source_Category__c');
            }


            //check if current lead in loop has a LastName of Unkown
            if( MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).LastName.toLowercase() == 'unknown'){
                finalMaping.put('LastName','Last_Name__c');
            }
            
        }else{
            Marketing_Staging__c marketingStaging = (Marketing_Staging__c) marketingStage;
            if(marketingStaging.Application_Source__c == 'StudyLink'){
                obj.put('LeadSource', LeadsDAO.LEAD_SOURCE_STUDYLINK_STUDYLINK_UNSUBMITTED);
                obj.put('Lead_Source_Category__c', LeadsDAO.LEAD_SOURCE_CATEGORY_STUDY_APPLICATION);
            }
            obj.put('Company','Learner');
            obj.put('Lead_Type__c','Learner');
            finalMaping = LEAD_FIELDS;
        }

        for(String fieldName: finalMaping.keySet()){
            if(marketingStage.get(finalMaping.get(fieldName)) != null && 
                !MARKETING_STAGING_MARKETING_FIELDS.contains(finalMaping.get(fieldName)) &&
              (( fieldName == 'Salutation' &&  
                salutations.contains((String)marketingStage.get(finalMaping.get(fieldName)))) || 
                fieldName != 'Salutation')){
                obj.put(fieldName,(marketingStage.get(finalMaping.get(fieldName))));
            }
        }

        Boolean checkMarketingStagingEmailOptOut = (Boolean) marketingStage.get(finalMaping.get('HasOptedOutOfEmail')) == true && 
        (Datetime) marketingStage.get(finalMaping.get('Email_Opt_Out_DateTime__c')) != null;

        Boolean checkMarketingStagingEmailOptIn =  (Boolean) marketingStage.get(finalMaping.get('HasOptedOutOfEmail')) == false &&
        (Datetime) marketingStage.get(finalMaping.get('Email_Opt_In_DateTime__c')) != null;

        Boolean conditionToEmailOptIn =  checkMarketingStagingEmailOptIn &&
        ( (MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId) &&
          MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).HasOptedOutOfEmail == true || 
          ( MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId) && 
            MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).HasOptedOutOfEmail == false &&
            MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).Email_Opt_In_DateTime__c == null
          )  
        ) || !MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId)
        );

        Boolean conditionToEmailOptOut = checkMarketingStagingEmailOptOut &&
        ( (MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId) &&
           MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).HasOptedOutOfEmail == false) || 
           !MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId) );

        if( conditionToEmailOptIn ){
        obj.put('HasOptedOutOfEmail', false);
        obj.put('Email_Opt_In_DateTime__c', (Datetime) marketingStage.get(finalMaping.get('Email_Opt_In_DateTime__c')) );
        }

        else if( conditionToEmailOptOut ){
        obj.put('HasOptedOutOfEmail', true);
        obj.put('Email_Opt_Out_DateTime__c', (Datetime) marketingStage.get(finalMaping.get('Email_Opt_Out_DateTime__c')) );
        }

        // sms
        Boolean checkMarketingStagingSMSOptOut = (Boolean) marketingStage.get(finalMaping.get('hed__SMS_Opt_Out__c')) == true && 
                                              (Datetime) marketingStage.get(finalMaping.get('SMS_Opt_Out_DateTime__c')) != null;

        Boolean checkMarketingStagingSMSOptIn =  (Boolean) marketingStage.get(finalMaping.get('hed__SMS_Opt_Out__c')) == false &&
                                              (Datetime) marketingStage.get(finalMaping.get('SMS_Opt_In_DateTime__c')) != null;

        Boolean conditionToSMSOptIn =  checkMarketingStagingSMSOptIn &&
                                        ( (MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId) &&
                                        MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).hed__SMS_Opt_Out__c == true || 
                                        ( MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId) && 
                                            MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).hed__SMS_Opt_Out__c == false &&
                                            MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).SMS_Opt_In_DateTime__c == null
                                        )  
                                        ) || !MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId)
                                        );

        Boolean conditionToSMSOptOut = checkMarketingStagingSMSOptOut &&
                                        ( (MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId) &&
                                        MarketingStagingTriggerHelper.leadMatches.get(oldLeadId).hed__SMS_Opt_Out__c == false) || 
                                        !MarketingStagingTriggerHelper.leadMatches.containsKey(oldLeadId) );

        if( conditionToSMSOptIn ){
            obj.put('hed__SMS_Opt_Out__c', false);
            obj.put('SMS_Opt_In_DateTime__c', (Datetime) marketingStage.get(finalMaping.get('SMS_Opt_In_DateTime__c')) );
        }

        else if( conditionToSMSOptOut ){
            obj.put('hed__SMS_Opt_Out__c', true);
            obj.put('SMS_Opt_Out_DateTime__c', (Datetime) marketingStage.get(finalMaping.get('SMS_Opt_Out_DateTime__c')) );
        }

        return obj;
    }


    /**
     * @description create marketing records from marketing staging fields
     * @param marketingStage - marketing stage record
     * @param contactId - contact id
     * @param leadId - lead id
     * @param oldId - old segmentation id
     * @param marketingObj - object api name
     * @return sObject marketing record
     */
    public static sObject createMarketingRecord(sObject marketingStage, Map<String, Id> idMap, String marketingObj){

        sObject obj = Schema.getGlobalDescribe().get(marketingObj).newSObject();

        if(idMap.get('oldId') != null){
            if(marketingObj == 'Marketing_Interaction__c'){
                obj.put('Marketing_Segmentation__c',idMap.get('oldId'));
            }else{
                obj.put('Id',idMap.get('oldId'));
            }
           
        }

        if(idMap.get('leadId') != null){
            obj.put('Lead__c',idMap.get('leadId'));
        }

        if(idMap.get('contactId') != null){
            obj.put('Contact__c',idMap.get('contactId'));
        }

        for(String fieldName: MARKETING_OBJECT_MAP.get(marketingObj)){
            if(marketingStage.get(fieldName) != null){
                obj.put(fieldName,marketingStage.get(fieldName));
            }
        }

        return obj;
    }

    /**
     * @description get saluation picklist values
     * @return List<String> salutation picklist values
     */
    public static List<String> getSalutations(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }     
         return pickListValuesList;
     }


     /**
     * @description get marketing records
     * @param leadMatches - list of lead matches
     * @param contactMatches - list of contact matches
     * @param matchingList - map of list of qtac, sams and studyLink matching list
     * @return RelatedMarketingRecordsClass marketing record matching
     */
     public static RelatedMarketingRecordsClass getRelatedMarketingRecords( 
        List<Lead> leadMatches, 
        List<Contact> contactMatches,
        Map<String, List<String>> matchingList){

        RelatedMarketingRecordsClass marketingClass = new RelatedMarketingRecordsClass();
        marketingClass.contactSegMap = new Map<Id,List<Marketing_Segmentation__c>>();
        marketingClass.leadSegMap = new Map<Id,List<Marketing_Segmentation__c>>();
        marketingClass.contactAppMap = new Map<Id,List<Marketing_Course_Application__c>>();
        marketingClass.leadAppMap = new Map<Id,List<Marketing_Course_Application__c>>();

        //query for related marketing segmentation 
        for(Marketing_Segmentation__c marSeg: [ SELECT Id, Contact__c, Lead__c 
                                                FROM Marketing_Segmentation__c 
                                                WHERE Lead__c IN: leadMatches 
                                                OR Contact__c IN: contactMatches]){
         //create a contact map against the marketing segmentation records                                           
            if(marSeg.Contact__c != null){
                if(!marketingClass.contactSegMap.containsKey(marSeg.Contact__c)){
                    marketingClass.contactSegMap.put(marSeg.Contact__c, new List<Marketing_Segmentation__c>());
                }
                marketingClass.contactSegMap.get(marSeg.Contact__c).add(marSeg);
            }else if(marSeg.Lead__c != null){
                if(!marketingClass.leadSegMap.containsKey(marSeg.Lead__c)){
                    marketingClass.leadSegMap.put(marSeg.Lead__c, new List<Marketing_Segmentation__c>());
                }
                marketingClass.leadSegMap.get(marSeg.Lead__c).add(marSeg);
            }                                        
        }

        //created new query for related marketing application to reduce lead/lead query size
        for(Marketing_Course_Application__c marCourApp: [SELECT Id, QUT_Student_ID__c, Contact__c, Lead__c, Studylink_Matching_Criteria__c,
                                                QTAC_Matching_Criteria__c, SAMS_Matching_Criteria__c
                                                FROM Marketing_Course_Application__c 
                                                WHERE (Lead__c IN: leadMatches 
                                                OR Contact__c IN: contactMatches)
                                                AND ( QTAC_Matching_Criteria__c IN: matchingList.get('qtacMatchingList')
                                                OR SAMS_Matching_Criteria__c IN: matchingList.get('samsMatchingList')
                                                OR Studylink_Matching_Criteria__c IN: matchingList.get('studylinkMatchingList'))]){
        //create a contact map against the marketing segmentation records 
            if(marCourApp.Contact__c != null){
                if(!marketingClass.contactAppMap.containsKey(marCourApp.Contact__c)){
                    marketingClass.contactAppMap.put(marCourApp.Contact__c, new List<Marketing_Course_Application__c>());
                }
                marketingClass.contactAppMap.get(marCourApp.Contact__c).add(marCourApp);
            }
            if(marCourApp.Lead__c != null){
                if(!marketingClass.leadAppMap.containsKey(marCourApp.Lead__c)){
                    marketingClass.leadAppMap.put(marCourApp.Lead__c, new List<Marketing_Course_Application__c>());
                }
                marketingClass.leadAppMap.get(marCourApp.Lead__c).add(marCourApp);
            }                                        
        }  

        return marketingClass;
     }

     /**
     * @description get lead and contact matching classes
     * @param contactMatches - list of contact matches
     * @param leadMatches - list of lead matches
     * @return LeadContactMatchingClass 
     */
    public static LeadContactMatchingClass getContactLeadMapping(List<Contact> contactMatches, List<Lead> leadMatches){

        LeadContactMatchingClass matchingClass = new LeadContactMatchingClass();
        matchingClass.contactEmailMap = new Map<String,List<Contact>>();
        matchingClass.contactIdMap = new Map<String,List<Contact>>();
        matchingClass.leadEmailMap = new Map<String,List<Lead>>();

        for(Contact con: contactMatches){

            //create map that groups all contacts with similar studentId
            if(con.QUT_Student_ID__c !=null){
                if(!matchingClass.contactIdMap.containsKey(con.QUT_Student_ID__c)){
                    matchingClass.contactIdMap.put(
                        con.QUT_Student_ID__c,
                        new List<Contact>()
                    );
                }
                matchingClass.contactIdMap.get(con.QUT_Student_ID__c).add(con); 
            }
            
            if(con.Email != null){
                if(!matchingClass.contactEmailMap.containsKey(con.Email)){
                    matchingClass.contactEmailMap.put(
                        con.Email,
                        new List<Contact>()
                    );
                }
                matchingClass.contactEmailMap.get(con.Email).add(con);
            }
        }

        for(Lead lead: leadMatches){
            //create map that groups all nameemail and contacts
            if(lead.Email != null){
                if(!matchingClass.leadEmailMap.containsKey(lead.Email)){
                    matchingClass.leadEmailMap.put(
                        lead.Email,
                        new List<Lead>()
                    );
                }
                matchingClass.leadEmailMap.get(lead.Email).add(lead);
            }
        }

        return matchingClass;
    }

    /**
     * @description get lead and contact matching classes
     * @param contactMatches - list of contact matches
     * @param leadMatches - list of lead matches
     * @return LeadContactMatchingClass 
     */
    public static RecordsToUpsertClass processMarketingMatching(
        String leadId,
        String contactId,
        Marketing_Staging__c staging,
        Map<Id,List<Marketing_Segmentation__c>> segmenationMap,
        Map<Id,List<Marketing_Course_Application__c>> applicationMap,
        Map<String,String> qtacMatchingMap,
        Map<String,String> samsMatchingMap,
        Map<String,String> studylinkMatchingMap
    ){
        RecordsToUpsertClass recordsClass = new RecordsToUpsertClass();
        recordsClass.segmentationToUpsertMap = new Map<String,Marketing_Segmentation__c>();
        recordsClass.applicationToUpsertMap = new Map<String,Marketing_Course_Application__c>();
        recordsClass.interactionToUpsertMap = new Map<String,Marketing_Interaction__c>();
        String parentId = leadId !=null?leadId:contactId;

            if(segmenationMap.containsKey(parentId)){
                for(Marketing_Segmentation__c segmentation: segmenationMap.get(parentId)){
                    recordsClass.segmentationToUpsertMap.put(
                        segmentation.Id,
                        (Marketing_Segmentation__c)createMarketingRecord(
                            staging,
                            new Map<String, Id>{
                                'contactId' => segmentation.Contact__c,
                                'leadId' => segmentation.Lead__c,
                                'oldId' => segmentation.Id
                            },
                            'Marketing_Segmentation__c'
                        )
                    ); 
                    //create interaction for when segmentation is updated
                    if(
                        staging.Interaction_Type__c !=null ||
                        staging.Interaction_DateTime__c !=null ||
                        staging.Lead_Source_Category__c !=null ||
                        staging.Lead_Source__c !=null ||
                        staging.SPAD__c !=null ||
                        staging.Event_Name__c !=null
                    ){
                        recordsClass.interactionToUpsertMap.put(
                            staging.Id,
                            (Marketing_Interaction__c)createMarketingRecord(
                                staging,
                                new Map<String, Id>{
                                    'contactId' => segmentation.Contact__c,
                                    'leadId' => segmentation.Lead__c,
                                    'oldId' => segmentation.Id
                                },
                                'Marketing_Interaction__c'
                            )
                        );
                    }
                    
                }
            }else{
                //create new segmenation record
                recordsClass.segmentationToUpsertMap.put(
                    staging.Id,
                    (Marketing_Segmentation__c)createMarketingRecord(
                        staging,
                        new Map<String, Id>{
                            'contactId' => contactId,
                            'leadId' => leadId,
                            'oldId' => null
                        },                       
                        'Marketing_Segmentation__c'
                    )
                );
            }
            if( applicationMap.containsKey(parentId)){
                Boolean exactMatchFound = false;
                for(Marketing_Course_Application__c courseApp:applicationMap.get(parentId)){
                    if( ( qtacMatchingMap.containsKey(staging.Id) && courseApp.QTAC_Matching_Criteria__c == qtacMatchingMap.get(staging.Id)) ||
                        ( samsMatchingMap.containsKey(staging.Id) && courseApp.SAMS_Matching_Criteria__c == samsMatchingMap.get(staging.Id)) ||
                        ( studylinkMatchingMap.containsKey(staging.Id) && courseApp.Studylink_Matching_Criteria__c == studylinkMatchingMap.get(staging.Id)) 
                    ){
                        exactMatchFound = true;
                        recordsClass.applicationToUpsertMap.put(
                            courseApp.Id,
                        (Marketing_Course_Application__c)createMarketingRecord(
                            staging,
                            new Map<String, Id>{
                                'contactId' => courseApp.Contact__c,
                                'leadId' => courseApp.Lead__c,
                                'oldId' => courseApp.Id
                            },
                            'Marketing_Course_Application__c'
                            )
                        );
                    }
                }
                //if there is no match found
                //and required fields are populated on staging record
                //we need to create a new course application
                if( exactMatchFound == false &&
                    (qtacMatchingMap.containsKey(staging.Id) ||
                    samsMatchingMap.containsKey(staging.Id) ||
                    studylinkMatchingMap.containsKey(staging.Id)))
                    {
                        recordsClass.applicationToUpsertMap.put(
                            staging.Id,
                            (Marketing_Course_Application__c)createMarketingRecord(
                                staging,
                                new Map<String, Id>{
                                    'contactId' => contactId,
                                    'leadId' => leadId,
                                    'oldId' => null
                                },
                                'Marketing_Course_Application__c'
                            )
                        );
                }
            }else if(   qtacMatchingMap.containsKey(staging.Id) ||
                        samsMatchingMap.containsKey(staging.Id) || 
                        studylinkMatchingMap.containsKey(staging.Id)){
                        recordsClass.applicationToUpsertMap.put(
                            staging.Id,
                            (Marketing_Course_Application__c)createMarketingRecord(
                                staging,
                                new Map<String, Id>{
                                    'contactId' => contactId,
                                    'leadId' => leadId,
                                    'oldId' => null
                                },
                                'Marketing_Course_Application__c'
                            )
                        );
            }



        return recordsClass;
    }


    public class RelatedMarketingRecordsClass{
        public Map<Id,List<Marketing_Segmentation__c>> leadSegMap;
        public Map<Id,List<Marketing_Segmentation__c>> contactSegMap;
        public Map<Id,List<Marketing_Course_Application__c>> leadAppMap;
        public Map<Id,List<Marketing_Course_Application__c>> contactAppMap;
    }

    public class LeadContactMatchingClass{
        public Map<String,List<Contact>> contactEmailMap;
        public Map<String,List<Contact>> contactIdMap;
        public Map<String,List<Lead>> leadEmailMap;
    }

    public class RecordsToUpsertClass{
        public Map<String,Marketing_Segmentation__c> segmentationToUpsertMap;
        public Map<String,Marketing_Course_Application__c> applicationToUpsertMap;
        public Map<String,Marketing_Interaction__c> interactionToUpsertMap;
    }
    
}