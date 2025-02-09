/**
 * @description Concrete command class for Lead Score by International Undetermined Study Level
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreUndeterminedIntCmd implements ILeadScoreStudyLevelCommand{

    /**
     * Process all related international records with study level = undergraduate
     */
    public static List<Lead_Score_Detail__c> processStudyLevel(LeadScoreCalculatorService.LeadScoreCalculatorParams leadScoreCalculatorParams){

        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();

        Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap = LeadScoreCalculatorService.getExistingLeadScoreDetails(leadScoreCalculatorParams.contactLeadIdSet);
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference = mapLeadScoreConfigForInternationalUD(leadScoreCalculatorParams.leadScoreConfigList);
        SObjectType sObjectType = leadScoreCalculatorParams.sObjectType;
        Map<Id,SObject> sObjectMap = leadScoreCalculatorParams.sObjectMap;

        //Handler for each triggering object
        if(sObjectType == Marketing_Segmentation__c.getSObjectType()){
            leadScoreDetailList.addAll(processMarketingSegmentation((Map<Id,Marketing_Segmentation__c>) sObjectMap, existingLeadScoreDetailMap, leadScoreConfigReference));
        }

        else if(sObjectType == Case.getSObjectType()){
            leadScoreDetailList.addAll(processCase((Map<Id,Case>) sObjectMap, existingLeadScoreDetailMap, leadScoreConfigReference));
        }

        else if(sObjectType == Marketing_Interaction__c.getSObjectType()){
            leadScoreDetailList.addAll(processMarketingInteraction((Map<Id,Marketing_Interaction__c>) sObjectMap, existingLeadScoreDetailMap, leadScoreConfigReference));
        }

        else if(sObjectType == Contact.getSObjectType()){
            leadScoreDetailList.addAll(processContact((Map<Id,Contact>) sObjectMap, existingLeadScoreDetailMap, leadScoreConfigReference));
        }

        else if(sObjectType == Lead.getSObjectType()){
            leadScoreDetailList.addAll(processLead((Map<Id,Lead>) sObjectMap, existingLeadScoreDetailMap, leadScoreConfigReference));
        }
        else if(sObjectType == hed__Program_Enrollment__c.getSObjectType()){
            leadScoreDetailList.addAll(processProgramEnrollment((Map<Id,hed__Program_Enrollment__c>) sObjectMap, existingLeadScoreDetailMap, leadScoreConfigReference));
        }

        else if(sObjectType == et4ae5__IndividualEmailResult__c.getSObjectType()){
            leadScoreDetailList.addAll(processIndividualEmail((Map<Id,et4ae5__IndividualEmailResult__c>) sObjectMap, existingLeadScoreDetailMap, leadScoreConfigReference));
        }
        
        LeadScoreCalculatorService.saveLogs();
        
        return leadScoreDetailList;
    }

    /**
     * Mapping of Lead Score Configuration to be used for International Undergrad
     */
    private static LeadScoreConfigService.LeadScoreConfigReference mapLeadScoreConfigForInternationalUD(List<Lead_Score_Configuration__c> leadScoreConfigList){
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfig = new LeadScoreConfigService.LeadScoreConfigReference();
        for(Lead_Score_Configuration__c config : leadScoreConfigList){
            LeadScoreConfigCountryTierService.getLeadScoreConfig(config, leadScoreConfig.leadScoreCountryTier, false);
            LeadScoreConfigResidenceService.getLeadScoreConfig(config, leadScoreConfig.leadScoreResidence, false);
            LeadScoreConfigFundingService.getLeadScoreConfig(config, leadScoreConfig.leadScoreFunding, false);
            LeadScoreConfigPrimaryBSAService.getLeadScoreConfig(config, leadScoreConfig.leadScorePrimaryBSA);
            LeadScoreConfigPrimaryNSAService.getLeadScoreConfig(config, leadScoreConfig.leadScorePrimaryNSA);
            LeadScoreConfigPrefIntakeService.getLeadScoreConfig(config, leadScoreConfig.leadScorePrefIntake);
            LeadScoreConfigCourseLevelService.getLeadScoreConfig(config, leadScoreConfig.leadScoreCourseLevel);
            LeadScoreConfigIntDoubleDegService.getLeadScoreConfig(config, leadScoreConfig.leadScoreIntDoubleDeg, false);
            LeadScoreConfigIntEngPathwayService.getLeadScoreConfig(config, leadScoreConfig.leadScoreIntEngPath, false);
            LeadScoreConfigEnquiriesService.getLeadScoreConfig(config, leadScoreConfig.leadScoreEnquiries);
            LeadScoreConfigEventRegService.getLeadScoreConfig(config, leadScoreConfig.leadScoreEventRegistration);
            LeadScoreConfigDownloadPDFService.getLeadScoreConfig(config, leadScoreConfig.leadScoreDownloadPDF, false);
            LeadScoreConfigMatchMySkillsService.getLeadScoreConfig(config, leadScoreConfig.leadScoreMatchMySkills);
            LeadScoreConfigMktgConsentService.getLeadScoreConfig(config, leadScoreConfig.leadScoreMktConsent);
            LeadScoreConfigProgEngagmentService.getLeadScoreConfig(config, leadScoreConfig.leadScoreProgEng);
            LeadScoreConfigEmailInteractService.getLeadScoreConfig(config, leadScoreConfig.leadScoreEmailInteraction);
        }
        return leadScoreConfig;
    }

    /**
     * Process lead score calculation for Marketing Segmentation Records
     * @param Map<Id,Marketing_Segmentation__c> marketingSegmentationMap    - Map of Triggering object
     * @param Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap      - Map of existing Lead Score Details to be updated
     * @param LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference  - Lead Score Configs
     * @return List<Lead_Score_Detail__c> - Lead Score Detail to be updated from the triggering object
     */
    private static List<Lead_Score_Detail__c> processMarketingSegmentation(
        Map<Id,Marketing_Segmentation__c> marketingSegmentationMap, 
        Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap, 
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference
    ){
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();         

        Map<Id, Integer> countryTierMap = LeadScoreConfigCountryTierService.calculateLeadScore(marketingSegmentationMap, leadScoreConfigReference.leadScoreCountryTier, false);
        Map<Id, Integer> residenceMap = LeadScoreConfigResidenceService.calculateLeadScore(marketingSegmentationMap, leadScoreConfigReference.leadScoreResidence, false);
        Map<Id, Integer> fundingMap = LeadScoreConfigFundingService.calculateLeadScore(marketingSegmentationMap, leadScoreConfigReference.leadScoreFunding, false);
        Map<Id, Integer> primaryBSAMap = LeadScoreConfigPrimaryBSAService.calculateLeadScore(marketingSegmentationMap, leadScoreConfigReference.leadScorePrimaryBSA);
        Map<Id, Integer> primaryNSAMap = LeadScoreConfigPrimaryNSAService.calculateLeadScore(marketingSegmentationMap, leadScoreConfigReference.leadScorePrimaryNSA);
        Map<Id, Integer> preferredIntakeMap = LeadScoreConfigPrefIntakeService.calculateLeadScore(marketingSegmentationMap, leadScoreConfigReference.leadScorePrefIntake);
        Map<Id, Integer> courseLevelMap = LeadScoreConfigCourseLevelService.calculateLeadScore(marketingSegmentationMap, leadScoreConfigReference.leadScoreCourseLevel);
        Map<Id, Integer> doubleDegMap = LeadScoreConfigIntDoubleDegService.calculateLeadScore(marketingSegmentationMap, leadScoreConfigReference.leadScoreIntDoubleDeg, false);
        Map<Id, Integer> engPathMap = LeadScoreConfigIntEngPathwayService.calculateLeadScore(marketingSegmentationMap, leadScoreConfigReference.leadScoreIntEngPath, false);

        for(Id contactLeadId : marketingSegmentationMap.keySet()){  
            if(!existingLeadScoreDetailMap.containsKey(contactLeadId)){
                LeadScoreCalculatorService.addErrorLogs(contactLeadId);
                continue;
            }
            Lead_Score_Detail__c leadScoreDetail = new Lead_Score_Detail__c();
            leadScoreDetail.Country_Tier__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, countryTierMap);
            leadScoreDetail.Residence__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, residenceMap);
            leadScoreDetail.Funding__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, fundingMap);
            leadScoreDetail.Primary_BSA__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, primaryBSAMap);
            leadScoreDetail.Primary_NSA__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, primaryNSAMap);
            leadScoreDetail.Preferred_Intake__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, preferredIntakeMap);
            leadScoreDetail.Course_Level__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, courseLevelMap);
            leadScoreDetail.Interested_In_Double_Degrees__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, doubleDegMap);
            leadScoreDetail.Interested_In_English_Pathway_Programs__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, engPathMap);
            
            leadScoreDetail.Contact__c = marketingSegmentationMap.get(contactLeadId).Contact__c != null ? marketingSegmentationMap.get(contactLeadId).Contact__c : null;
            leadScoreDetail.Lead__c = marketingSegmentationMap.get(contactLeadId).Lead__c != null ? marketingSegmentationMap.get(contactLeadId).Lead__c : null;
            leadScoreDetail.Study_Level__c = LeadScoreDetailsDAO.STUDY_LEVEL_UNDETERMINED;
            leadScoreDetail.Domestic_International__c = LeadScoreDetailsDAO.INTERNATIONAL;         
            leadScoreDetail.Id = existingLeadScoreDetailMap.get(contactLeadId).Id;
            leadScoreDetailList.add(leadScoreDetail);
        }

        return leadScoreDetailList; 
    }

    /**
     * Process lead score calculation for Case Records
     * @param Map<Id,Case> caseMap - Map of Triggering object
     * @param Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap - Map of existing Lead Score Details to be updated
     * @param LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference  - Lead Score Configs
     * @return List<Lead_Score_Detail__c> - Lead Score Detail to be updated from the triggering object
     */
    private static List<Lead_Score_Detail__c> processCase(
        Map<Id,Case> caseMap, 
        Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap, 
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference
    ){
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();     

        Map<Id, Integer> enquiriesMap = LeadScoreConfigEnquiriesService.calculateLeadScore(caseMap, leadScoreConfigReference.leadScoreEnquiries);
        for(Id contactLeadId : enquiriesMap.keySet()){    
            if(!existingLeadScoreDetailMap.containsKey(contactLeadId)){
                LeadScoreCalculatorService.addErrorLogs(contactLeadId);
                continue;
            }
            Lead_Score_Detail__c leadScoreDetail = new Lead_Score_Detail__c();
            leadScoreDetail.Enquiries__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, enquiriesMap);
            if(ContactService.isContact(contactLeadId)){    
                leadScoreDetail.Contact__c = contactLeadId;
            }else{
                leadScoreDetail.Lead__c = contactLeadId;
            }
            leadScoreDetail.Study_Level__c = LeadScoreDetailsDAO.STUDY_LEVEL_UNDETERMINED;
            leadScoreDetail.Domestic_International__c = LeadScoreDetailsDAO.INTERNATIONAL;         
            leadScoreDetail.Id = existingLeadScoreDetailMap.get(contactLeadId).Id;
            leadScoreDetailList.add(leadScoreDetail);
        }
        return leadScoreDetailList;
    }

    /**
     * Process lead score calculation for Marketing Interaction Records
     * @param Map<Id,Marketing_Interaction__c> marketingInteractionMap      - Map of Triggering object
     * @param Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap      - Map of existing Lead Score Details to be updated
     * @param LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference  - Lead Score Configs
     * @return List<Lead_Score_Detail__c> - Lead Score Detail to be updated from the triggering object
     */
    private static List<Lead_Score_Detail__c> processMarketingInteraction(
        Map<Id,Marketing_Interaction__c> marketingInteractionMap, 
        Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap, 
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference
    ){
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();

        Map<Id, Integer> eventRegMap = LeadScoreConfigEventRegService.calculateLeadScore(marketingInteractionMap, leadScoreConfigReference.leadScoreEventRegistration);
        Map<Id, Integer> downloadPDFMap = LeadScoreConfigDownloadPDFService.calculateLeadScore(marketingInteractionMap, leadScoreConfigReference.leadScoreDownloadPDF, false);
        Map<Id, Integer> matchMySkillsMap = LeadScoreConfigMatchMySkillsService.calculateLeadScore(marketingInteractionMap, leadScoreConfigReference.leadScoreMatchMySkills);

        Set<Id> contactLeadIds = new Set<Id>();
        contactLeadIds.addAll(eventRegMap.keySet());
        contactLeadIds.addAll(downloadPDFMap.keySet());
        contactLeadIds.addAll(matchMySkillsMap.keySet());

        for(Id contactLeadId : contactLeadIds){   
            if(!existingLeadScoreDetailMap.containsKey(contactLeadId)){
                LeadScoreCalculatorService.addErrorLogs(contactLeadId);
                continue;
            }     
            Lead_Score_Detail__c leadScoreDetail = new Lead_Score_Detail__c();
            leadScoreDetail.Event_Registration_Attendance__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, eventRegMap);
            leadScoreDetail.Download__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, downloadPDFMap);
            leadScoreDetail.Match_My_Skills__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, matchMySkillsMap);
            if(ContactService.isContact(contactLeadId)){    
                leadScoreDetail.Contact__c = contactLeadId;
            }else{
                leadScoreDetail.Lead__c = contactLeadId;
            }
            leadScoreDetail.Study_Level__c = LeadScoreDetailsDAO.STUDY_LEVEL_UNDETERMINED;
            leadScoreDetail.Domestic_International__c = LeadScoreDetailsDAO.INTERNATIONAL;        
            leadScoreDetail.Id = existingLeadScoreDetailMap.get(contactLeadId).Id;
            leadScoreDetailList.add(leadScoreDetail);
        }
        return leadScoreDetailList;
    }

    /**
     * Process lead score calculation for Contact Records
     * @param Map<Id,Contact> contactMap - Map of Triggering object
     * @param Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap - Map of existing Lead Score Details to be updated
     * @param LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference  - Lead Score Configs
     * @return List<Lead_Score_Detail__c> - Lead Score Detail to be updated from the triggering object
     */
    private static List<Lead_Score_Detail__c> processContact(
        Map<Id,Contact> contactMap, 
        Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap, 
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference
    ){
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();

        Map<Id, Integer> mktConsentMap = LeadScoreConfigMktgConsentService.calculateLeadScoreForContact(contactMap, leadScoreConfigReference.leadScoreMktConsent);
        
        for(Id contactId : contactMap.keySet()){    
            if(!existingLeadScoreDetailMap.containsKey(contactId)){
                LeadScoreCalculatorService.addErrorLogs(contactId);
                continue;
            }   
            Lead_Score_Detail__c leadScoreDetail = new Lead_Score_Detail__c();
            leadScoreDetail.Marketing_Consent__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactId, mktConsentMap);
            leadScoreDetail.Contact__c = contactId;
            leadScoreDetail.Study_Level__c = LeadScoreDetailsDAO.STUDY_LEVEL_UNDETERMINED;
            leadScoreDetail.Domestic_International__c = LeadScoreDetailsDAO.INTERNATIONAL;         
            leadScoreDetail.Id = existingLeadScoreDetailMap.get(contactId).Id;
            leadScoreDetailList.add(leadScoreDetail);
            
        }
        return leadScoreDetailList;
    }

    /**
     * Process lead score calculation for Lead Records
     * @param Map<Id,Lead> leadMap - Map of Triggering object
     * @param Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap - Map of existing Lead Score Details to be updated
     * @param LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference  - Lead Score Configs
     * @return List<Lead_Score_Detail__c> - Lead Score Detail to be updated from the triggering object
     */
    private static List<Lead_Score_Detail__c> processLead(
        Map<Id,Lead> leadMap, 
        Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap, 
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference
    ){
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();

        Map<Id, Integer> mktConsentMap = LeadScoreConfigMktgConsentService.calculateLeadScoreForLead(leadMap, leadScoreConfigReference.leadScoreMktConsent);
    
        for(Id leadId : leadMap.keySet()){   
            if(!existingLeadScoreDetailMap.containsKey(leadId)){
                LeadScoreCalculatorService.addErrorLogs(leadId);
                continue;
            }    
            Lead_Score_Detail__c leadScoreDetail = new Lead_Score_Detail__c();
            leadScoreDetail.Marketing_Consent__c = LeadScoreCalculatorService.getLeadScoreByCategory(leadId, mktConsentMap);
            leadScoreDetail.Lead__c = leadId;
            leadScoreDetail.Study_Level__c = LeadScoreDetailsDAO.STUDY_LEVEL_UNDETERMINED;
            leadScoreDetail.Domestic_International__c = LeadScoreDetailsDAO.INTERNATIONAL;         
            leadScoreDetail.Id = existingLeadScoreDetailMap.get(leadId).Id;
            leadScoreDetailList.add(leadScoreDetail);
            
        }
        return leadScoreDetailList;
    }

    /**
     * Process lead score calculation for hed__Program_Enrollment__c Records
     * @param Map<Id,hed__Program_Enrollment__c> leadMap - Map of Triggering object
     * @param Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap - Map of existing Lead Score Details to be updated
     * @param LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference  - Lead Score Configs
     * @return List<Lead_Score_Detail__c> - Lead Score Detail to be updated from the triggering object
     */
    private static List<Lead_Score_Detail__c> processProgramEnrollment(
        Map<Id,hed__Program_Enrollment__c> programEnrollmentMap, 
        Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap, 
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference
    ){
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();        

        Map<Id, Integer> programEngMap = LeadScoreConfigProgEngagmentService.calculateLeadScore(programEnrollmentMap, leadScoreConfigReference.leadScoreProgEng);
        for(Id contactId : programEngMap.keySet()){   
            if(!existingLeadScoreDetailMap.containsKey(contactId)){
                LeadScoreCalculatorService.addErrorLogs(contactId);
                continue;
            }
            Lead_Score_Detail__c leadScoreDetail = new Lead_Score_Detail__c();
            leadScoreDetail.Program_Engagement__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactId, programEngMap);
            leadScoreDetail.Contact__c = contactId;
            leadScoreDetail.Study_Level__c = LeadScoreDetailsDAO.STUDY_LEVEL_UNDETERMINED;
            leadScoreDetail.Domestic_International__c = LeadScoreDetailsDAO.INTERNATIONAL;   
            leadScoreDetail.Id = existingLeadScoreDetailMap.get(contactId).Id;
            leadScoreDetailList.add(leadScoreDetail);
        }
        return leadScoreDetailList;
    }

    /**
     * Process lead score calculation for Individual Email Records Records
     * @param Map<Id,et4ae5__IndividualEmailResult__c> indivEmailMap - Map of Triggering object
     * @param Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap - Map of existing Lead Score Details to be updated
     * @param LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference  - Lead Score Configs
     * @return List<Lead_Score_Detail__c> - Lead Score Detail to be updated from the triggering object
     */
    private static List<Lead_Score_Detail__c> processIndividualEmail(
        Map<Id,et4ae5__IndividualEmailResult__c> indivEmailMap, 
        Map<Id, Lead_Score_Detail__c> existingLeadScoreDetailMap, 
        LeadScoreConfigService.LeadScoreConfigReference leadScoreConfigReference
    ){
        List<Lead_Score_Detail__c> leadScoreDetailList = new List<Lead_Score_Detail__c>();
        
        Map<Id, Integer> emailInteractionMap = LeadScoreConfigEmailInteractService.calculateLeadScore(indivEmailMap, leadScoreConfigReference.leadScoreEmailInteraction);
        for(Id contactLeadId : emailInteractionMap.keySet()){   
            if(!existingLeadScoreDetailMap.containsKey(contactLeadId)){
                LeadScoreCalculatorService.addErrorLogs(contactLeadId);
                continue;
            }
            Lead_Score_Detail__c leadScoreDetail = new Lead_Score_Detail__c();
            leadScoreDetail.Email_Interaction__c = LeadScoreCalculatorService.getLeadScoreByCategory(contactLeadId, emailInteractionMap);
            if(ContactService.isContact(contactLeadId)){   
                leadScoreDetail.Contact__c = contactLeadId;
            }else{
                leadScoreDetail.Lead__c = contactLeadId;
            }
            leadScoreDetail.Study_Level__c = LeadScoreDetailsDAO.STUDY_LEVEL_UNDETERMINED;
            leadScoreDetail.Domestic_International__c = LeadScoreDetailsDAO.INTERNATIONAL;   
            leadScoreDetail.Id = existingLeadScoreDetailMap.get(contactLeadId).Id;
            leadScoreDetailList.add(leadScoreDetail);
        }
        return leadScoreDetailList;
    }
}
