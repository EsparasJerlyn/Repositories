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
   
    private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe().getLocalName();
    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe().getLocalName();


    public static Contact createContactRecord(Marketing_Staging__c marketingStage, Id oldContactId){
        Contact obj = new Contact();

        if(oldContactId != null){
            obj.Id = oldContactId;
        }
        obj.Marketing_Mobile_Locale__c = marketingStage.Mobile_Locale__c;
        obj.FirstName = marketingStage.First_Name__c;
        obj.LastName = marketingStage.Last_Name__c;
        obj.Email = marketingStage.Email__c;
        obj.Preferred_Given_Name__c = marketingStage.Preferred_Given_Name__c;
        obj.Salutation = marketingStage.Salutation__c;
        obj.BirthDate = marketingStage.Birthdate__c;
        obj.hed__Gender__c = marketingStage.Gender__c;
        obj.Phone = marketingStage.Phone__c;
        obj.MobilePhone = marketingStage.Mobile__c;
        obj.MailingStreet = marketingStage.Street__c;
        obj.MailingCity = marketingStage.City__c;
        obj.MailingPostalCode = marketingStage.PostalCode__c;
        obj.MailingState = marketingStage.State__c;
        obj.MailingCountry = marketingStage.Country__c;
        obj.HasOptedOutOfEmail = marketingStage.HasOptedOutOfEmail__c;
        obj.Email_Opt_In_DateTime__c = marketingStage.Email_OptIn_DateTime__c;
        obj.Email_Opt_Out_DateTime__c = marketingStage.Email_OptOut_DateTime__c;
        obj.hed__SMS_Opt_Out__c = marketingStage.SMS_Opt_Out__c;
        obj.SMS_Opt_In_DateTime__c = marketingStage.SMS_OptIn_DateTime__c;
        obj.SMS_Opt_Out_DateTime__c = marketingStage.SMS_OptOut_DateTime__c;
        obj.Dont_Market__c = marketingStage.Dont_Market__c;
        obj.Dont_Market_Reason__c = marketingStage.Dont_Market_Reason__c;
        obj.Dont_Market_DateTime__c = marketingStage.Dont_Market_DateTime__c;
        obj.Consent_Source_Category__c = marketingStage.Consent_Source_Category__c;
        obj.Consent_Source__c = marketingStage.Consent_Source__c;
        return obj;
    }  

    public static Lead createLeadRecord(Marketing_Staging__c marketingStage, Id oldLeadId){
        Lead obj = new Lead();

        if(oldLeadId != null){
            obj.Id = oldLeadId;
        }
        obj.Marketing_Mobile_Locale__c = marketingStage.Mobile_Locale__c;
        obj.Lead_Type__c = 'Learner';
        obj.Company = 'Learner';
        obj.FirstName = marketingStage.First_Name__c;
        obj.LastName = marketingStage.Last_Name__c;
        obj.Email = marketingStage.Email__c;
        obj.Preferred_Given_Name__c = marketingStage.Preferred_Given_Name__c;
        obj.Salutation = marketingStage.Salutation__c;
        obj.hed__Birth_Date__c = marketingStage.Birthdate__c;
        obj.hed__Gender__c = marketingStage.Gender__c;
        obj.Phone = marketingStage.Phone__c;
        obj.MobilePhone = marketingStage.Mobile__c;
        obj.Street = marketingStage.Street__c;
        obj.City = marketingStage.City__c;
        obj.PostalCode = marketingStage.PostalCode__c;
        obj.State = marketingStage.State__c;
        obj.Country = marketingStage.Country__c;
        obj.HasOptedOutOfEmail = marketingStage.HasOptedOutOfEmail__c;
        obj.Email_Opt_In_DateTime__c = marketingStage.Email_OptIn_DateTime__c;
        obj.Email_Opt_Out_DateTime__c = marketingStage.Email_OptOut_DateTime__c;
        obj.hed__SMS_Opt_Out__c = marketingStage.SMS_Opt_Out__c;
        obj.SMS_Opt_In_DateTime__c = marketingStage.SMS_OptIn_DateTime__c;
        obj.SMS_Opt_Out_DateTime__c = marketingStage.SMS_OptOut_DateTime__c;
        obj.Dont_Market__c = marketingStage.Dont_Market__c;
        obj.Dont_Market_Reason__c = marketingStage.Dont_Market_Reason__c;
        obj.Dont_Market_DateTime__c = marketingStage.Dont_Market_DateTime__c;
        obj.Consent_Source_Category__c = marketingStage.Consent_Source_Category__c;
        obj.Consent_Source__c = marketingStage.Consent_Source__c;
        return obj;
    }


    public static List<Potential_Duplicate__c> createPotentialDupRecords(Id newLeadId , List<sObject> matchingObjects, String matchingObject){
        List<Potential_Duplicate__c> potentialDuplToInsertList = new List<Potential_Duplicate__c>();
        Potential_Duplicate__c dupItem;

        for(sObject obj: matchingObjects){
            dupItem = new Potential_Duplicate__c();
            dupItem.Lead__c = newLeadId;
            if(matchingObject == CONTACT_API_NAME){
                dupItem.Duplicate_Contact__c = (Id)obj.get('Id');
            }else if(matchingObject == LEAD_API_NAME){
                dupItem.Duplicate_Lead__c = (Id)obj.get('Id');
            }
            potentialDuplToInsertList.add(dupItem);
        }
        
        return potentialDuplToInsertList;
    } 


    public static Marketing_Segmentation__c createMarketingSegmentationRecord(Marketing_Staging__c marketingStage, Id contactId, Id leadId, Id oldSegId){
        Marketing_Segmentation__c obj = new Marketing_Segmentation__c();

        if(oldSegId != null){
            obj.Id = oldSegId;
        }

        if(leadId != null){
            obj.Lead__c = leadId;
        }

        if(contactId != null){
            obj.Contact__c = contactId;
        }

        obj.Migration_Key__c = marketingStage.Migration_Key__c;
        //obj.External_Key__c = marketingStage.External_Key__c;
        obj.Prospects_Behaviour__c = marketingStage.Prospects_Behaviour__c;
        obj.Prospects_Rank__c = marketingStage.Prospects_Rank__c;
        obj.Prospects_Score__c = marketingStage.Prospects_Score__c;
        obj.Previous_Educational_Institution__c = marketingStage.Previous_Educational_Institution__c;
        obj.Secondary_School_Name__c = marketingStage.Secondary_School_Name__c;
        obj.Alumnus_Educational_Institution__c = marketingStage.Alumnus_Educational_Institution__c;
        obj.Course_Referrer__c = marketingStage.Course_Referrer__c;
        obj.My_Profile_Persona__c = marketingStage.My_Profile_Persona__c;
        obj.My_Citizenship_Status__c = marketingStage.My_Citizenship_Status__c;
        obj.My_Indigenous_Status_ATSI__c = marketingStage.My_Indigenous_Status_ATSI__c;
        //obj.My_Current_Education_Level__c = marketingStage.My_Current_Education_Level__c;
        //obj.My_Completed_Education_Level__c = marketingStage.My_Completed_Education_Level__c;
        obj.My_Country_Of_Citizenship__c = marketingStage.My_Country_Of_Citizenship__c;
        obj.My_Country_Of_Residency__c = marketingStage.My_Country_Of_Residency__c;
        obj.My_Expected_Admission_Year__c = marketingStage.My_Expected_Admission_Year__c;
        obj.My_Year_12_Expected_Completion_Year__c = marketingStage.My_Year_12_Expected_Completion_Year__c;
        obj.My_Studying_Australian_Curriculum__c = marketingStage.My_Studying_Australian_Curriculum__c;
        obj.My_Funding_Source__c = marketingStage.My_Funding_Source__c;
        obj.My_Moving_To_Brisbane__c = marketingStage.My_Moving_To_Brisbane__c;
        obj.My_High_Achieving_Student__c = marketingStage.My_High_Achieving_Student__c;
        obj.My_Elite_Athlete__c = marketingStage.My_Elite_Athlete__c;
        obj.My_Organisation__c = marketingStage.My_Organisation__c;
        obj.My_Position__c = marketingStage.My_Position__c;
        obj.My_Industry__c = marketingStage.My_Industry__c;
        obj.My_Primary_Study_Level__c = marketingStage.My_Primary_Study_Level__c;
        obj.My_Primary_BSA__c = marketingStage.My_Primary_BSA__c;
        obj.My_Primary_NSA__c = marketingStage.My_Primary_NSA__c;
        obj.My_Secondary_Study_Level__c = marketingStage.My_Secondary_Study_Level__c;
        obj.My_Secondary_BSA__c = marketingStage.My_Secondary_BSA__c;
        obj.My_Secondary_NSA__c = marketingStage.My_Secondary_NSA__c;
        obj.My_Double_Degree__c = marketingStage.My_Double_Degree__c;
        obj.My_Interested_Pathway_Program_or_Diploma__c = marketingStage.My_Interested_Pathway_Program_or_Diploma__c;
        obj.My_Interested_English_Pathways__c = marketingStage.My_Interested_English_Pathways__c;
        obj.My_Interested_Financial_Assistance__c = marketingStage.My_Interested_Financial_Assistance__c;
        obj.My_Interested_Entrepreneurship__c = marketingStage.My_Interested_Entrepreneurship__c;
        obj.My_Interested_Languages__c = marketingStage.My_Interested_Languages__c;
        obj.My_Interested_ESport_Interest__c = marketingStage.My_Interested_ESport_Interest__c;
        obj.My_Postcode__c = marketingStage.My_Postcode__c;
        obj.My_State__c = marketingStage.My_State__c;
        obj.My_Suburb__c = marketingStage.My_Suburb__c;
        obj.SE_Profile_Persona__c = marketingStage.SE_Profile_Persona__c;
        obj.SE_Citizenship_Status__c = marketingStage.SE_Citizenship_Status__c;
        obj.SE_Indigenous_Status_ATSI__c = marketingStage.SE_Indigenous_Status_ATSI__c;
        //obj.SE_Current_Education_Level__c = marketingStage.SE_Current_Education_Level__c;
        //obj.SE_Completed_Education_Level__c = marketingStage.SE_Completed_Education_Level__c;
        obj.SE_Country_Of_Citizenship__c = marketingStage.SE_Country_Of_Citizenship__c;
        obj.SE_Country_Of_Residency__c = marketingStage.SE_Country_Of_Residency__c;
        obj.SE_Expected_Admission_Year__c = marketingStage.SE_Expected_Admission_Year__c;
        obj.SE_Year_12_Expected_Completion_Year__c = marketingStage.SE_Year_12_Expected_Completion_Year__c;
        obj.SE_Studying_Australian_Curriculum__c = marketingStage.SE_Studying_Australian_Curriculum__c;
        obj.SE_Funding_Source__c = marketingStage.SE_Funding_Source__c;
        obj.SE_Moving_To_Brisbane__c = marketingStage.SE_Moving_To_Brisbane__c;
        obj.SE_High_Achieving_Student__c = marketingStage.SE_High_Achieving_Student__c;
        obj.SE_Elite_Athlete__c = marketingStage.SE_Elite_Athlete__c;
        obj.SE_Organisation__c = marketingStage.SE_Organisation__c;
        obj.SE_Position__c = marketingStage.SE_Position__c;
        obj.SE_Industry__c = marketingStage.SE_Industry__c;
        obj.SE_Primary_Study_Level__c = marketingStage.SE_Primary_Study_Level__c;
        obj.SE_Primary_BSA__c = marketingStage.SE_Primary_BSA__c;
        obj.SE_Primary_NSA__c = marketingStage.SE_Primary_NSA__c;
        obj.SE_Secondary_Study_Level__c = marketingStage.SE_Secondary_Study_Level__c;
        obj.SE_Secondary_BSA__c = marketingStage.SE_Secondary_BSA__c;
        obj.SE_Secondary_NSA__c = marketingStage.SE_Secondary_NSA__c;
        obj.SE_Double_Degree__c = marketingStage.SE_Double_Degree__c;
        obj.SE_Interested_Pathway_Program_or_Diploma__c = marketingStage.SE_Interested_Pathway_Program_or_Diploma__c;
        obj.SE_Interested_English_Pathways__c = marketingStage.SE_Interested_English_Pathways__c;
        obj.SE_Interested_Financial_Assistance__c = marketingStage.SE_Interested_Financial_Assistance__c;
        obj.SE_Interested_Entrepreneurship__c = marketingStage.SE_Interested_Entrepreneurship__c;
        obj.SE_Interested_Languages__c = marketingStage.SE_Interested_Languages__c;
        obj.SE_Interested_ESport_Interest__c = marketingStage.SE_Interested_ESport_Interest__c;
        obj.SE_Interested_Course_Name__c = marketingStage.SE_Interested_Course_Name__c;
        obj.SE_Postcode__c = marketingStage.SE_Postcode__c;
        obj.SE_State__c = marketingStage.SE_State__c;
        obj.SE_Suburb__c = marketingStage.SE_Suburb__c;
        obj.ORG_Profile_Persona__c = marketingStage.ORG_Profile_Persona__c;
        obj.ORG_Indigenous_Status_ATSI__c = marketingStage.ORG_Indigenous_Status_ATSI__c;
        //obj.ORG_Current_Education_Level__c = marketingStage.ORG_Current_Education_Level__c;
        //obj.ORG_Completed_Education_Level__c = marketingStage.ORG_Completed_Education_Level__c;
        obj.ORG_Country_Of_Residency__c = marketingStage.ORG_Country_Of_Residency__c;
        obj.ORG_Organisation__c = marketingStage.ORG_Organisation__c;
        obj.ORG_Position__c = marketingStage.ORG_Position__c;
        obj.ORG_Industry__c = marketingStage.ORG_Industry__c;
        obj.ORG_Primary_Study_Level__c = marketingStage.ORG_Primary_Study_Level__c;
        obj.ORG_Primary_BSA__c = marketingStage.ORG_Primary_BSA__c;
        obj.ORG_Primary_NSA__c = marketingStage.ORG_Primary_NSA__c;
        obj.ORG_Secondary_Study_Level__c = marketingStage.ORG_Secondary_Study_Level__c;
        obj.ORG_Secondary_BSA__c = marketingStage.ORG_Secondary_BSA__c;
        obj.ORG_Secondary_NSA__c = marketingStage.ORG_Secondary_NSA__c;
        obj.ORG_Interested_Languages__c = marketingStage.ORG_Interested_Languages__c;
        obj.ORG_Interested_Course_Name__c = marketingStage.ORG_Interested_Course_Name__c;
        obj.ORG_Postcode__c = marketingStage.ORG_Postcode__c;
        obj.ORG_State__c = marketingStage.ORG_Suburb__c;
        return obj;
    }

    public static Marketing_Interaction__c createMarketingInteractionRecord(Marketing_Staging__c marketingStage, Id contactId, Id leadId, Id marketingSegId){
        Marketing_Interaction__c obj = new Marketing_Interaction__c();
        if(leadId != null){
            obj.Lead__c = leadId;
        }

        if(contactId != null){
            obj.Contact__c = contactId;
        }
        
        obj.Marketing_Segmentation__c = marketingSegId;
        obj.Migration_Key__c = marketingStage.Migration_Key__c;
        obj.Interaction_Type__c = marketingStage.Interaction_Type__c;
        obj.Interaction_DateTime__c = marketingStage.Interaction_DateTime__c;
        obj.Lead_Source_Category__c = marketingStage.Lead_Source_Category__c;
        obj.Lead_Source__c = marketingStage.Lead_Source__c;
        obj.SPAD__c = marketingStage.SPAD__c;
        obj.Page_Display_Name__c = marketingStage.Page_Display_Name__c;
        obj.Page_URL__c = marketingStage.Page_URL__c;
        obj.UTM_Source__c = marketingStage.UTM_Source__c;
        obj.UTM_Campaign__c = marketingStage.UTM_Campaign__c;
        obj.UTM_Medium__c = marketingStage.UTM_Medium__c;
        obj.UTM_Term__c = marketingStage.UTM_Term__c;
        obj.UTM_Content__c = marketingStage.UTM_Content__c;
        obj.Enquiry_Type__c = marketingStage.Enquiry_Type__c;
        obj.Enquiry_Description__c = marketingStage.Enquiry_Description__c;
        obj.EDM_Last_Send_DateTime__c = marketingStage.EDM_Last_Send_DateTime__c;
        //obj.EDM_Last_Open_DateTime__c = marketingStage.EDM_Last_Open_DateTime__c;
        //obj.EDM_Last_Click_DateTime__c = marketingStage.EDM_Last_Click_DateTime__c;
        obj.Fee_Amount__c = marketingStage.Fee_Amount__c;
        obj.Discount_Amount__c = marketingStage.Discount_Amount__c;
        obj.Country_Joining_From__c = marketingStage.Country_Joining_From__c;
        obj.QUT_Sloan_MIT_Affiliation__c = marketingStage.QUT_Sloan_MIT_Affiliation__c;
        obj.Has_Attended__c = marketingStage.Has_Attended__c;
        obj.Event_Agency_Host__c = marketingStage.Event_Agency_Host__c;
        obj.Event_City__c = marketingStage.Event_City__c;
        obj.Event_Date__c = marketingStage.Event_Date__c;
        obj.Event_Name__c = marketingStage.Event_Name__c;
        obj.QUT_Staff_Name__c = marketingStage.QUT_Staff_Name__c;
        obj.QUT_Staff_Email__c = marketingStage.QUT_Staff_Email__c;
        obj.Event_Type__c = marketingStage.Event_Type__c;

        return obj;
    }


    public static Marketing_Course_Application__c createMarketingCourseAppRecord(Marketing_Staging__c marketingStage, Id contactId, Id leadId, Id oldCourseAppId){
        Marketing_Course_Application__c obj = new Marketing_Course_Application__c();

        if(leadId != null){
            obj.Lead__c = leadId;
        }

        if(contactId != null){
            obj.Contact__c = contactId;
        }

        if(oldCourseAppId != null){
            obj.Id = oldCourseAppId;
        }
        obj.Application_Source__c = marketingStage.Application_Source__c;
        obj.Applicant_Id__c = marketingStage.Applicant_Id__c;
        obj.Application_Id__c = marketingStage.Application_Id__c;
        obj.QUT_Student_ID__c = marketingStage.QUT_Student_ID__c;
        obj.Migration_Key__c = marketingStage.Migration_Key__c;
        obj.Preference_Number__c = marketingStage.Preference_Number__c;
        obj.Course_Code__c = marketingStage.Course_Code__c;
        obj.Course_Level__c = marketingStage.Course_Level__c;
        obj.Course_Name__c = marketingStage.Course_Name__c;
        obj.Course_Major__c = marketingStage.Course_Major__c;
        obj.Course_Campus__c = marketingStage.Course_Campus__c;
        obj.Course_URL__c = marketingStage.Course_URL__c;
        obj.Pathway_Principal_Course_Code__c = marketingStage.Pathway_Principal_Course_Code__c;
        obj.Pathway_Principal_Course_Name__c = marketingStage.Pathway_Principal_Course_Name__c;
        obj.Pathway_Principal_Course_Owning_Faculty__c = marketingStage.Pathway_Principal_Course_Owning_Faculty__c;
        obj.Faculty__c = marketingStage.Faculty__c;
        obj.Course_Description__c = marketingStage.Course_Description__c;
        obj.Offer_Exists__c = marketingStage.Offer_Exists__c;
        obj.Course_Start_Month__c = marketingStage.Course_Start_Month__c;
        obj.Admission_Year__c = marketingStage.Admission_Year__c;
        obj.Course_Start_Date__c = marketingStage.Course_Start_Date__c;
        obj.Environment_Responsibilities_Applicant__c = marketingStage.Environment_Responsibilities_Applicant__c;
        obj.Personal_Illness_Disability_Applicant__c = marketingStage.Personal_Illness_Disability_Applicant__c;
        obj.Educational_Disruption_Applicant__c = marketingStage.Educational_Disruption_Applicant__c;
        obj.English_Language_Difficulties_Applicant__c = marketingStage.English_Language_Difficulties_Applicant__c;
        obj.EAS_Application__c = marketingStage.EAS_Application__c;
        obj.Financial_Hardship_Applicant__c = marketingStage.Financial_Hardship_Applicant__c;
        obj.Course_Allocability_Status__c = marketingStage.Course_Allocability_Status__c;
        obj.QTAC_Offer_Able__c = marketingStage.QTAC_Offer_Able__c;
        obj.QTAC_Offer_Round__c = marketingStage.QTAC_Offer_Round__c;
        obj.Intake_Year__c = marketingStage.Intake_Year__c;
        obj.isAgent_Assisted__c = marketingStage.isAgent_Assisted__c;
        obj.Submission_Format__c = marketingStage.Submission_Format__c;
        obj.Application_Status__c = marketingStage.Application_Status__c;
        obj.Application_Status_Date__c = marketingStage.Application_Status_Date__c;
        obj.Submission_Date__c = marketingStage.Submission_Date__c;
        obj.Offer_Date__c = marketingStage.Offer_Date__c;
        obj.Intake_Period_Type__c = marketingStage.Intake_Period_Type__c;
        obj.Offer_Expiry_Date__c = marketingStage.Offer_Expiry_Date__c;
        obj.IsApplying_for_Visa_Onshore__c = marketingStage.IsApplying_for_Visa_Onshore__c;
        obj.IsPackaged_Offer__c = marketingStage.IsPackaged_Offer__c;
        obj.Offer_Response_Date__c = marketingStage.Offer_Response_Date__c;
        obj.Scholarship_Name__c = marketingStage.Scholarship_Name__c;
        obj.Scholarship_Status__c = marketingStage.Scholarship_Status__c;
        obj.Previous_Enrolled_Student__c = marketingStage.Previous_Enrolled_Student__c;
        obj.IsOffer_Made__c = marketingStage.IsOffer_Made__c;
        obj.Admission_Category__c = marketingStage.Admission_Category__c;
        obj.Admission_Period__c = marketingStage.Admission_Period__c;
        obj.Admission_Status__c = marketingStage.Admission_Status__c;
        obj.Student_Study_Package_Status__c = marketingStage.Student_Study_Package_Status__c;
        obj.Agency_Branch__c = marketingStage.Agency_Branch__c;
        obj.Agency_Code__c = marketingStage.Agency_Code__c;
        obj.Agency_Country__c = marketingStage.Agency_Country__c;
        obj.Agency_Email__c = marketingStage.Agency_Email__c;
        obj.Agency_Name__c = marketingStage.Agency_Name__c;
        return obj;
    }

}