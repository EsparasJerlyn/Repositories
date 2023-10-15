/**
  * @description Batch class to compute Lead Score for contact/lead
  * @see ..
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer                      | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | eccarius.munoz                 | October 07, 2023      | DEPP-5866              | Created file to handle lead score calculation  |
  *    |                                |                       |                        | for Lead and Contact                           |
  */
public with sharing class LeadScoreCalculationBatch implements Database.Batchable<sObject>{

    private static Map<Id,Marketing_Interaction__c> domesticUnderGradMapMktInt = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> domesticPostGradMapMktInt = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> domesticUndeterminedMapMktInt = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> internationalUnderGradMapMktInt = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> internationalPostGradMapMktInt = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> internationalUndeterminedMapMktInt = new Map<Id,Marketing_Interaction__c>();
    private static Map<Id,Marketing_Interaction__c> undeterminedUndeterminedMapMktInt = new Map<Id,Marketing_Interaction__c>();
    
    private static Map<Id,Case> domesticUnderGradMapCase = new Map<Id,Case>();
    private static Map<Id,Case> domesticPostGradMapCase = new Map<Id,Case>();
    private static Map<Id,Case> domesticUndeterminedMapCase = new Map<Id,Case>();
    private static Map<Id,Case> internationalUnderGradMapCase = new Map<Id,Case>();
    private static Map<Id,Case> internationalPostGradMapCase = new Map<Id,Case>();
    private static Map<Id,Case> internationalUndeterminedMapCase = new Map<Id,Case>();
    private static Map<Id,Case> undeterminedUndeterminedMapCase = new Map<Id,Case>();
    
    /**
    * @description Retrieves lead score detail with contact or lead
    * @param bc - BatchableContext
    * @return query - filtered query of lead score details
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        return LeadScoreDetailsDAO.newInstance().getLeadScoreDetailsWithContactOrLead();
    }
    
    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param leadScoreDetails - List of Lead_Score_Detail__c
    */
    public void execute(Database.BatchableContext bc, List<Lead_Score_Detail__c> leadScoreDetails){
        try{ 
            Set<Id> contactLeadIds = new Set<Id>();
            for(Lead_Score_Detail__c leadScoreDtl : leadScoreDetails){
                if(leadScoreDtl.Contact__c != null){
                    contactLeadIds.add(leadScoreDtl.Contact__c);
                }
                else{
                    contactLeadIds.add(leadScoreDtl.Lead__c);
                }
            }            

            Map<Id,Marketing_Segmentation__c> marketingSegMap = LeadScoreCalculatorService.getMarketingSegmentation(contactLeadIds, contactLeadIds);

            /**
             * Recalculate for Event Registration and Attendance and Downloaded PDF Categories
             */
            processMarketingInterActions(contactLeadIds, marketingSegMap);

            /**
             * Recalculate for Enquiries Category
             */
            processCase(contactLeadIds, marketingSegMap);
            
           /**
            * Email Interaction
            */
            //processEmailInteractions(contactLeadIds);

        }catch(Exception e){
            Logger.error('Exception caught in method execute in Apex class LeadScoreCalculationBatch.').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    } 

    private static void processCase(Set<Id> contactLeadIds, Map<Id,Marketing_Segmentation__c> marketingSegMap){    

        List<Case> cases = CasesDAO.newInstance().getCasesByContactOrLeadIds(contactLeadIds, AccessLevel.SYSTEM_MODE);
        for(Case caseRec : cases){
            mapUnderGradStudyLevelCase(caseRec, marketingSegMap);
            mapPostGradStudyLevelCase(caseRec, marketingSegMap);
            mapUndeterminedStudyLevelCase(caseRec, marketingSegMap);
        }

        LeadScoreCalculatorService.ObjectMap objectMap = new LeadScoreCalculatorService.ObjectMap();
        objectMap.domesticUnderGradMap = domesticUnderGradMapCase;
        objectMap.domesticPostGradMap = domesticPostGradMapCase;
        objectMap.domesticUndeterminedMap = domesticUndeterminedMapCase;
        objectMap.internationalUnderGradMap = internationalUnderGradMapCase;
        objectMap.internationalPostGradMap = internationalPostGradMapCase;
        objectMap.internationalUndeterminedMap = internationalUndeterminedMapCase;
        objectMap.undeterminedUndeterminedMap = undeterminedUndeterminedMapCase;

        LeadScoreCalculatorService.calculateLeadScore(objectMap, contactLeadIds, Case.getSObjectType());

    }

    private static void processMarketingInterActions(Set<Id> contactLeadIds, Map<Id,Marketing_Segmentation__c> marketingSegMap){        

        List<Marketing_Interaction__c> mktgInteractions = MarketingInteractionsDAO.newInstance().getMarketingInteractionsByContactOrLeadIds(contactLeadIds, AccessLevel.SYSTEM_MODE);
        for(Marketing_Interaction__c mktgInt : mktgInteractions){
            mapUnderGradStudyLevelForMktgInt(mktgInt, marketingSegMap);
            mapPostGradStudyLevelForMktgInt(mktgInt, marketingSegMap);
            mapUndeterminedStudyLevelForMktgInt(mktgInt, marketingSegMap);
        }

        LeadScoreCalculatorService.ObjectMap objectMap = new LeadScoreCalculatorService.ObjectMap();
        objectMap.domesticUnderGradMap = domesticUnderGradMapMktInt;
        objectMap.domesticPostGradMap = domesticPostGradMapMktInt;
        objectMap.domesticUndeterminedMap = domesticUndeterminedMapMktInt;
        objectMap.internationalUnderGradMap = internationalUnderGradMapMktInt;
        objectMap.internationalPostGradMap = internationalPostGradMapMktInt;
        objectMap.internationalUndeterminedMap = internationalUndeterminedMapMktInt;
        objectMap.undeterminedUndeterminedMap = undeterminedUndeterminedMapMktInt;
        
        LeadScoreCalculatorService.calculateLeadScore(objectMap, contactLeadIds, Marketing_Interaction__c.getSObjectType());
    }

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevelForMktgInt(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUnderGrad = marketingSegMap.containsKey(mktgInt.Contact__c) && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isContactDomestic = isContactUnderGrad && MarketingInteractionLeadScoreHelper.validateDomesticContact(mktgInt, marketingSegMap);
        Boolean isContactInternational = isContactUnderGrad && MarketingInteractionLeadScoreHelper.validateInternationalContact(mktgInt, marketingSegMap);
        Boolean isLeadUnderGrad = marketingSegMap.containsKey(mktgInt.Lead__c) && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isLeadDomestic = isLeadUnderGrad && MarketingInteractionLeadScoreHelper.validateDomesticLead(mktgInt, marketingSegMap);
        Boolean isLeadInternational = isLeadUnderGrad && MarketingInteractionLeadScoreHelper.validateInternationalLead(mktgInt, marketingSegMap);

        if(isContactDomestic){
            domesticUnderGradMapMktInt.put(mktgInt.Id, mktgInt);                
        }
        else if(isContactInternational){
            internationalUnderGradMapMktInt.put(mktgInt.Id, mktgInt);
        }
        else if(isLeadDomestic){
            domesticUnderGradMapMktInt.put(mktgInt.Id, mktgInt);                
        }
        else if(isLeadInternational){
            internationalUnderGradMapMktInt.put(mktgInt.Id, mktgInt);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticPostGradMap and internationalPostGradMap
     */
    private static void mapPostGradStudyLevelForMktgInt(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactPostGrad = marketingSegMap.containsKey(mktgInt.Contact__c) && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isContactDomestic = isContactPostGrad && MarketingInteractionLeadScoreHelper.validateDomesticContact(mktgInt, marketingSegMap);
        Boolean isContactInternational = isContactPostGrad && MarketingInteractionLeadScoreHelper.validateInternationalContact(mktgInt, marketingSegMap);
        Boolean isLeadPostGrad = marketingSegMap.containsKey(mktgInt.Lead__c) && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isLeadDomestic = isLeadPostGrad && MarketingInteractionLeadScoreHelper.validateDomesticLead(mktgInt, marketingSegMap);
        Boolean isLeadInternational = isLeadPostGrad && MarketingInteractionLeadScoreHelper.validateInternationalLead(mktgInt, marketingSegMap);

        if(isContactDomestic){
            domesticPostGradMapMktInt.put(mktgInt.Id, mktgInt);                
        }
        else if(isContactInternational){
            internationalPostGradMapMktInt.put(mktgInt.Id, mktgInt);
        }

        else if(isLeadDomestic){
            domesticPostGradMapMktInt.put(mktgInt.Id, mktgInt);                
        }
        else if(isLeadInternational){
            internationalPostGradMapMktInt.put(mktgInt.Id, mktgInt);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUndeterminedMap and internationalUndeterminedMap
     */
    private static void mapUndeterminedStudyLevelForMktgInt(Marketing_Interaction__c mktgInt, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUndetermined = marketingSegMap.containsKey(mktgInt.Contact__c) && marketingSegMap.get(mktgInt.Contact__c).My_Primary_Study_Level__c == null;
        Boolean isContactDomestic = isContactUndetermined && MarketingInteractionLeadScoreHelper.validateDomesticContact(mktgInt, marketingSegMap);
        Boolean isContactInternational = isContactUndetermined && MarketingInteractionLeadScoreHelper.validateInternationalContact(mktgInt, marketingSegMap);
        Boolean isLeadUndetermined = marketingSegMap.containsKey(mktgInt.Lead__c) && marketingSegMap.get(mktgInt.Lead__c).My_Primary_Study_Level__c == null;
        Boolean isLeadDomestic = isLeadUndetermined && MarketingInteractionLeadScoreHelper.validateDomesticLead(mktgInt, marketingSegMap);
        Boolean isLeadInternational = isLeadUndetermined && MarketingInteractionLeadScoreHelper.validateInternationalLead(mktgInt, marketingSegMap);
        Boolean isConCitizenshipUD = isContactUndetermined && MarketingInteractionLeadScoreHelper.validateUndeterminedContact(mktgInt, marketingSegMap);
        Boolean isLeadCitizenshipUD = isLeadUndetermined && MarketingInteractionLeadScoreHelper.validateUndeterminedLead(mktgInt, marketingSegMap);

        if(isContactDomestic){
            domesticUndeterminedMapMktInt.put(mktgInt.Id, mktgInt);                
        }
        else if(isContactInternational){
            internationalUndeterminedMapMktInt.put(mktgInt.Id, mktgInt);
        }
        else if(isLeadDomestic){
            domesticUndeterminedMapMktInt.put(mktgInt.Id, mktgInt);                
        }
        else if(isLeadInternational){
            internationalUndeterminedMapMktInt.put(mktgInt.Id, mktgInt);
        }
        else if(isConCitizenshipUD){
            undeterminedUndeterminedMapMktInt.put(mktgInt.Id, mktgInt);                
        }
        else if(isLeadCitizenshipUD){
            undeterminedUndeterminedMapMktInt.put(mktgInt.Id, mktgInt);                
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUnderGradMap and internationalUnderGradMap
     */
    private static void mapUnderGradStudyLevelCase(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUnderGrad = marketingSegMap.containsKey(caseRec.ContactId) && marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c!=null && marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isContactDomestic = isContactUnderGrad && CaseLeadScoreHelper.validateDomesticContact(caseRec, marketingSegMap);
        Boolean isContactInternational = isContactUnderGrad && CaseLeadScoreHelper.validateInternationalContact(caseRec, marketingSegMap);
        Boolean isLeadUnderGrad = marketingSegMap.containsKey(caseRec.Lead__c) && marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_UNDERGRAD;
        Boolean isLeadDomestic = isLeadUnderGrad && CaseLeadScoreHelper.validateDomesticLead(caseRec, marketingSegMap);
        Boolean isLeadInternational = isLeadUnderGrad && CaseLeadScoreHelper.validateInternationalLead(caseRec, marketingSegMap);

        if(isContactDomestic){
            domesticUnderGradMapCase.put(caseRec.Id, caseRec);                
        }
        else if(isContactInternational){
            internationalUnderGradMapCase.put(caseRec.Id, caseRec);
        }

        else if(isLeadDomestic){
            domesticUnderGradMapCase.put(caseRec.Id, caseRec);                
        }
        else if(isLeadInternational){
            internationalUnderGradMapCase.put(caseRec.Id, caseRec);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticPostGradMap and internationalPostGradMap
     */
    private static void mapPostGradStudyLevelCase(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactPostGrad = marketingSegMap.containsKey(caseRec.ContactId) && marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c!=null && marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isContactDomestic = isContactPostGrad && CaseLeadScoreHelper.validateDomesticContact(caseRec, marketingSegMap);
        Boolean isContactInternational = isContactPostGrad && CaseLeadScoreHelper.validateInternationalContact(caseRec, marketingSegMap);
        Boolean isLeadPostGrad = marketingSegMap.containsKey(caseRec.Lead__c) && marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c!=null && marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c == MarketingSegmentationsDAO.PRIMARY_STUDY_LEVEL_POSTGRAD;
        Boolean isLeadDomestic = isLeadPostGrad && CaseLeadScoreHelper.validateDomesticLead(caseRec, marketingSegMap);
        Boolean isLeadInternational = isLeadPostGrad && CaseLeadScoreHelper.validateInternationalLead(caseRec, marketingSegMap);

        if(isContactDomestic){
            domesticPostGradMapCase.put(caseRec.Id, caseRec);                
        }
        else if(isContactInternational){
            internationalPostGradMapCase.put(caseRec.Id, caseRec);
        }

        else if(isLeadDomestic){
            domesticPostGradMapCase.put(caseRec.Id, caseRec);                
        }
        else if(isLeadInternational){
            internationalPostGradMapCase.put(caseRec.Id, caseRec);
        }
    }

    /**
     * Maps Undergrad studylevel records to domesticUndeterminedMap and internationalUndeterminedMap
     */
    private static void mapUndeterminedStudyLevelCase(Case caseRec, Map<Id,Marketing_Segmentation__c> marketingSegMap) {
        
        Boolean isContactUndetermined = marketingSegMap.containsKey(caseRec.ContactId) && marketingSegMap.get(caseRec.ContactId).My_Primary_Study_Level__c == null;
        Boolean isContactDomestic = isContactUndetermined && CaseLeadScoreHelper.validateDomesticContact(caseRec, marketingSegMap);
        Boolean isContactInternational = isContactUndetermined && CaseLeadScoreHelper.validateInternationalContact(caseRec, marketingSegMap);
        Boolean isLeadUndetermined = marketingSegMap.containsKey(caseRec.Lead__c) && marketingSegMap.get(caseRec.Lead__c).My_Primary_Study_Level__c == null;
        Boolean isLeadDomestic = isLeadUndetermined && CaseLeadScoreHelper.validateDomesticLead(caseRec, marketingSegMap);
        Boolean isLeadInternational = isLeadUndetermined && CaseLeadScoreHelper.validateInternationalLead(caseRec, marketingSegMap);
        Boolean isConCitizenshipUD = isContactUndetermined && CaseLeadScoreHelper.validateUndeterminedContact(caseRec, marketingSegMap);
        Boolean isLeadCitizenshipUD = isLeadUndetermined && CaseLeadScoreHelper.validateUndeterminedLead(caseRec, marketingSegMap);

        if(isContactDomestic){
            domesticUndeterminedMapCase.put(caseRec.Id, caseRec);                
        }
        else if(isContactInternational){
            internationalUndeterminedMapCase.put(caseRec.Id, caseRec);
        }

        else if(isLeadDomestic){
            domesticUndeterminedMapCase.put(caseRec.Id, caseRec);                
        }
        else if(isLeadInternational){
            internationalUndeterminedMapCase.put(caseRec.Id, caseRec);
        }
        else if(isConCitizenshipUD){
            undeterminedUndeterminedMapCase.put(caseRec.Id, caseRec);               
        }
        else if(isLeadCitizenshipUD){
            undeterminedUndeterminedMapCase.put(caseRec.Id, caseRec);                
        }
    }

    public void finish(Database.BatchableContext bc) {} //NOPMD
}


