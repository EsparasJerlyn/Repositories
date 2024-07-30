/**
 * @description Service Class for Enquiries Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 02, 2023      | DEPP-5866              | Created file                 |
      | eccarius.munoz                 | October 22, 2023      | DEPP-5866 update       | Used constants               |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigEnquiriesService {
    
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigEnquiries leadScoreConfigEnquiries){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_ENQUIRIES;
        Boolean isForEnquiries = validateCategory(leadScoreConfig, category);
        if(isForEnquiries){ 
            leadScoreConfigEnquiries.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigEnquiries.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = validateSubCategory(leadScoreConfig, category);
        if(isSubCategory){
            setLeadScore(leadScoreConfig, leadScoreConfigEnquiries);
        }
        
    }   

    public static Map<Id, Integer> calculateLeadScore(Map<Id,Case> caseMap, LeadScoreConfigEnquiries leadScoreConfigEnquiries){
        Map<Id, Integer> enquiryMap = new Map<Id, Integer>();
        Integer enquiryScore = 0;
        Date today = Date.today();
        for(Case caseRec : caseMap.values()){

            if(enquiryMap.containsKey(caseRec.ContactId)){
                enquiryScore = enquiryMap.get(caseRec.ContactId);
            }else if(enquiryMap.containsKey(caseRec.Lead__c)){
                enquiryScore = enquiryMap.get(caseRec.Lead__c);
            }else{
                enquiryScore = 0;
            }

            Boolean isDateValid = DateService.isDateWithinRangeDefaultFalse(
                today, 
                caseRec.CreatedDate.date(), 
                caseRec.CreatedDate.date().addMonths(leadScoreConfigEnquiries.getTimeLimit())
            );
            if(String.isNotBlank(caseRec.Category__c) && isDateValid && !caseRec.Lead_Score_Reset__c){
                enquiryScore = enquiryScore + getEnquiryScore(caseRec.Category__c, leadScoreConfigEnquiries);
            }            
            
            Integer score = LeadScoreCalculatorService.validateScore(enquiryScore, leadScoreConfigEnquiries.getMaxScore());
            if(caseRec.ContactId != null){
                enquiryMap.put(caseRec.ContactId, score);
            }
            else if(caseRec.Lead__c != null){
                enquiryMap.put(caseRec.Lead__c, score);
            }
        }
        return enquiryMap;
    }

    private static Integer getEnquiryScore(String caseCategory, LeadScoreConfigEnquiries leadScoreConfigEnquiries){
        Integer enquiryScore = 0;

        if(caseCategory == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_APPLYING_FOR_COURSE){ 
            enquiryScore = enquiryScore + leadScoreConfigEnquiries.getApplyingForCourse();
        }
        else if(caseCategory == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_ENTRY_REQ_STUDY_PATH){ 
            enquiryScore = enquiryScore + leadScoreConfigEnquiries.getEntryReqAndUnivStudy();
        }
        else if(caseCategory == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_FEES_COST_SCHOLARSHIP){ 
            enquiryScore = enquiryScore + leadScoreConfigEnquiries.getFeesCostScholarship();
        }
        else if(caseCategory == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COURSE_INFO){ 
            enquiryScore = enquiryScore + leadScoreConfigEnquiries.getCourseInformation();
        }
        else if(caseCategory == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COURSE_APPLICATION_AND_OFFERS){ 
            enquiryScore = enquiryScore + leadScoreConfigEnquiries.getMyApplicationAndOffer();
        }
        else if(caseCategory == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_PREPARING_TO_STUDY){ 
            enquiryScore = enquiryScore + leadScoreConfigEnquiries.getMyEnrollment();
        }
        else if(caseCategory == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_STUDY_LIFE){ 
            enquiryScore = enquiryScore + leadScoreConfigEnquiries.getStudentLife();
        }

        return enquiryScore;
    }

    private static Boolean validateCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
    }

    private static Boolean validateSubCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
    }

    private static void setLeadScore(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigEnquiries leadScoreConfigEnquiries){
        if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_APPLYING_FOR_COURSE){
            leadScoreConfigEnquiries.setApplyingForCourse(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_ENTRY_REQ_STUDY_PATH){
            leadScoreConfigEnquiries.setEntryReqAndUnivStudy(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_FEES_COST_SCHOLARSHIP){
            leadScoreConfigEnquiries.setFeesCostScholarship(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COURSE_INFO){
            leadScoreConfigEnquiries.setCourseInformation(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_COURSE_APPLICATION_AND_OFFERS){
            leadScoreConfigEnquiries.setMyApplicationAndOffer(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_PREPARING_TO_STUDY){
            leadScoreConfigEnquiries.setMyEnrollment(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_STUDY_LIFE){
            leadScoreConfigEnquiries.setStudentLife(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    }
    
}