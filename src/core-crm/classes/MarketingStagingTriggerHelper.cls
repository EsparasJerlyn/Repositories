/**
 * @description helper Class for MarketingStagingTriggerHandler
 * @see ..MarketingStagingTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 23, 2022          | DEPP-2103              | Created file                 |
 */

public with sharing class MarketingStagingTriggerHelper{
   
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
        'SE_Country_Of_Citizenship__c','SE_Country_Of_Residency__c','SE_Expected_Admission_Year__c','SE_Year_12_Expected_Completion_Year__c',
        'SE_Studying_Australian_Curriculum__c','SE_Funding_Source__c','SE_Moving_To_Brisbane__c','SE_High_Achieving_Student__c',
        'SE_Elite_Athlete__c','SE_Organisation__c','SE_Position__c','SE_Industry__c','SE_Primary_Study_Level__c','SE_Primary_BSA__c',
        'SE_Primary_NSA__c','SE_Secondary_Study_Level__c','SE_Secondary_BSA__c','SE_Secondary_NSA__c','SE_Double_Degree__c',
        'SE_Interested_Pathway_Program_or_Diploma__c','SE_Interested_English_Pathways__c','SE_Interested_Financial_Assistance__c',
        'SE_Interested_Entrepreneurship__c','SE_Interested_Languages__c','SE_Interested_ESport_Interest__c','SE_Interested_Course_Name__c',
        'SE_Postcode__c','SE_State__c','SE_Suburb__c','ORG_Profile_Persona__c','ORG_Indigenous_Status_ATSI__c','ORG_Country_Of_Residency__c',
        'ORG_Organisation__c','ORG_Position__c','ORG_Industry__c','ORG_Primary_Study_Level__c','ORG_Primary_BSA__c','ORG_Primary_NSA__c',
        'ORG_Secondary_Study_Level__c','ORG_Secondary_BSA__c','ORG_Secondary_NSA__c','ORG_Interested_Languages__c','ORG_Interested_Course_Name__c',
        'ORG_Postcode__c','ORG_State__c'
    };

    private static final List<String> MARKETING_INTERACTION_FIELDS = new List<String>{
        'Migration_Key__c','Interaction_Type__c','Interaction_DateTime__c','Lead_Source_Category__c','Lead_Source__c',
        'SPAD__c','Page_Display_Name__c','Page_URL__c','UTM_Source__c','UTM_Campaign__c','UTM_Medium__c',
        'UTM_Term__c','UTM_Content__c','Enquiry_Type__c','Enquiry_Description__c','EDM_Last_Send_DateTime__c','Fee_Amount__c',
        'Discount_Amount__c','Country_Joining_From__c','QUT_Sloan_MIT_Affiliation__c','Has_Attended__c','Event_Agency_Host__c',
        'Event_City__c','Event_Date__c','Event_Name__c','QUT_Staff_Name__c','QUT_Staff_Email__c','Event_Type__c','Match_My_Skill_Completion__c',
        'MMS_Process_State__c'
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
        'Is_International_Student_Application__c','Is_Research_Application__c','App_Condition_Verification_Status__c','Admission_Process__c'
    };

    private static final Map<String,String> CONTACT_FIELDS = new Map<String,String>{
        'FirstName' => 'First_Name__c' , 'LastName' => 'Last_Name__c', 'Email' => 'Email__c',
        'Marketing_Mobile_Locale__c' => 'Mobile_Locale__c', 'Preferred_Given_Name__c' => 'Preferred_Given_Name__c',
        'Salutation' => 'Salutation__c', 'BirthDate' => 'Birthdate__c', 'hed__Gender__c' => 'Gender__c',
        'Phone' => 'Phone__c', 'MobilePhone' => 'Mobile__c', 'MailingStreet' => 'Street__c',
        'MailingCity' => 'City__c', 'MailingPostalCode' => 'PostalCode__c', 'MailingState' => 'State__c',
        'MailingCountry' => 'Country__c', 'HasOptedOutOfEmail' => 'HasOptedOutOfEmail__c', 
        'Email_Opt_In_DateTime__c' => 'Email_OptIn_DateTime__c','Email_Opt_Out_DateTime__c' => 'Email_OptOut_DateTime__c', 
        'hed__SMS_Opt_Out__c' => 'SMS_Opt_Out__c', 'SMS_Opt_In_DateTime__c' => 'SMS_OptIn_DateTime__c', 
        'SMS_Opt_Out_DateTime__c' => 'SMS_OptOut_DateTime__c','Dont_Market__c' => 'Dont_Market__c',
        'Dont_Market_Reason__c' => 'Dont_Market_Reason__c', 'Dont_Market_DateTime__c' => 'Dont_Market_DateTime__c',
        'Dont_Market_DateTime__c' => 'Dont_Market_DateTime__c', 'Consent_Source_Category__c' => 'Consent_Source_Category__c'
    };

    private static final Map<String,String> LEAD_FIELDS = new Map<String,String>{
        'FirstName' => 'First_Name__c' , 'LastName' => 'Last_Name__c', 'Email' => 'Email__c',
        'Marketing_Mobile_Locale__c' => 'Mobile_Locale__c','Preferred_Given_Name__c' => 'Preferred_Given_Name__c',
        'Salutation' => 'Salutation__c', 'hed__Birth_Date__c' => 'Birthdate__c', 'hed__Gender__c' => 'Gender__c',
        'Phone' => 'Phone__c', 'MobilePhone' => 'Mobile__c', 'Street' => 'Street__c',
        'City' => 'City__c', 'PostalCode' => 'PostalCode__c', 'State' => 'State__c',
        'Country' => 'Country__c', 'HasOptedOutOfEmail' => 'HasOptedOutOfEmail__c',
        'Email_Opt_In_DateTime__c' => 'Email_OptIn_DateTime__c','Email_Opt_Out_DateTime__c' => 'Email_OptOut_DateTime__c', 
        'hed__SMS_Opt_Out__c' => 'SMS_Opt_Out__c', 'SMS_Opt_In_DateTime__c' => 'SMS_OptIn_DateTime__c', 
        'SMS_Opt_Out_DateTime__c' => 'SMS_OptOut_DateTime__c','Dont_Market__c' => 'Dont_Market__c',
        'Dont_Market_Reason__c' => 'Dont_Market_Reason__c', 'Dont_Market_DateTime__c' => 'Dont_Market_DateTime__c',
        'Dont_Market_DateTime__c' => 'Dont_Market_DateTime__c', 'Consent_Source_Category__c' => 'Consent_Source_Category__c'
    };


    private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe().getLocalName();
    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe().getLocalName();


    /**
     * @description create contact record from marketing staging fields
     * @param marketingStage - marketingstaging object
     * @param oldContactId - contactId
     */
    public static sObject createContactRecord(sObject marketingStage, Id oldContactId){
        sObject obj = Schema.getGlobalDescribe().get('Contact').newSObject();

        if(oldContactId != null){
            obj.put('Id',oldContactId);
        }

        for(String fieldName: CONTACT_FIELDS.keySet()){
            if(marketingStage.get(CONTACT_FIELDS.get(fieldName)) != null){
                obj.put(fieldName,(marketingStage.get(CONTACT_FIELDS.get(fieldName))));
            }
        }

        return obj;
    }  

    /**
     * @description create lead record from marketing staging fields
     * @param marketingStage - marketingstaging object
     * @param oldLeadId - leadId
     */
    public static sObject createLeadRecord(sObject marketingStage, Id oldLeadId){
        sObject obj = Schema.getGlobalDescribe().get('Lead').newSObject();

        obj.put('Company','Learner');
        obj.put('Lead_Type__c','Learner');
        if(oldLeadId != null){
            obj.put('Id',oldLeadId);
        }
        
        for(String fieldName: LEAD_FIELDS.keySet()){
            if(marketingStage.get(LEAD_FIELDS.get(fieldName)) != null){
                obj.put(fieldName,(marketingStage.get(LEAD_FIELDS.get(fieldName))));
            }
        }

        return obj;
    }


    /**
     * @description create potential duplicate record from marketing staging fields
     * @param newLeadId - lead id
     * @param matchingObjects - list matching object contact or lead
     * @param matchingObject - matchingObject name
     */
    public static List<Potential_Duplicate__c> createPotentialDupRecords(Id newLeadId , List<sObject> matchingObjects, String matchingObject){
        List<Potential_Duplicate__c> potentialDuplToInsertList = new List<Potential_Duplicate__c>();
        Potential_Duplicate__c dupItem;

        for(sObject obj: matchingObjects){
            dupItem = new Potential_Duplicate__c();
            
            if(matchingObject == CONTACT_API_NAME){
                dupItem.Contact__c = (Id)obj.get('Id');
                dupItem.Duplicate_Lead__c = newLeadId;
            }else if(matchingObject == LEAD_API_NAME){
                dupItem.Lead__c = newLeadId;
                dupItem.Duplicate_Lead__c = (Id)obj.get('Id');
            }
            potentialDuplToInsertList.add(dupItem);
        }
        
        return potentialDuplToInsertList;
    } 


    /**
     * @description create marketing segmentation record from marketing staging fields
     * @param marketingStage - marketing stage record
     * @param contactId - contact id
     * @param leadId - lead id
     * @param oldSegId - old segmentation id
     */
    public static sObject createMarketingSegmentationRecord(sObject marketingStage, Id contactId, Id leadId, Id oldSegId){

        sObject obj = Schema.getGlobalDescribe().get('Marketing_Segmentation__c').newSObject();

        if(oldSegId != null){
           obj.put('Id',oldSegId);
        }

        if(leadId != null){
            obj.put('Lead__c',leadId);
        }

        if(contactId != null){
            obj.put('Contact__c',contactId);
        }

        for(String fieldName: MARKETING_SEGMENTATION_FIELDS){
            if(marketingStage.get(fieldName) != null){
                obj.put(fieldName,marketingStage.get(fieldName));
            }
        }

        return obj;
    }

    /**
     * @description create marketing interactions record from marketing staging fields
     * @param marketingStage - marketing stage record
     * @param contactId - contact id
     * @param leadId - lead id
     * @param marketingSegId -  segmentation id
     */
    public static sOBject createMarketingInteractionRecord(sObject marketingStage, Id contactId, Id leadId, Id marketingSegId){
        sObject obj = Schema.getGlobalDescribe().get('Marketing_Interaction__c').newSObject();
        
        if(leadId != null){
             obj.put('Lead__c',leadId);
        }
 
        if(contactId != null){
             obj.put('Contact__c',contactId);
        }

        obj.put('Marketing_Segmentation__c',marketingSegId);

        for(String fieldName: MARKETING_INTERACTION_FIELDS){
            if(marketingStage.get(fieldName) != null){
                obj.put(fieldName,marketingStage.get(fieldName));
            }
        }

        return obj;
    }


    /**
     * @description create marketing course application record from marketing staging fields
     * @param marketingStage - marketing stage record
     * @param contactId - contact id
     * @param leadId - lead id
     * @param oldCourseAppId -  old course application id
     */
    public static sObject createMarketingCourseAppRecord(sObject marketingStage, Id contactId, Id leadId, Id oldCourseAppId){
        sObject obj = Schema.getGlobalDescribe().get('Marketing_Course_Application__c').newSObject();


        if(oldCourseAppId != null){
            obj.put('Id',oldCourseAppId);
        }

        if(leadId != null){
            obj.put('Lead__c',leadId);
        }

        if(contactId != null){
            obj.put('Contact__c',contactId);
        }

        for(String fieldName: MARKETING_APPLICATION_FIELDS){
            if(marketingStage.get(fieldName) != null){
                obj.put(fieldName,marketingStage.get(fieldName));
            }
        }
        return obj;
    }

}