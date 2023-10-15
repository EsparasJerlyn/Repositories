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
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigEnquiriesService {
    
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigEnquiries leadScoreConfigEnquiries){
        String category = 'Enquiries';
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
        for(Case caseRec : caseMap.values()){
            if(String.isNotBlank(caseRec.Category__c)){
                if(caseRec.Category__c == 'Applying for a course'){ 
                    enquiryScore = enquiryScore + leadScoreConfigEnquiries.getApplyingForCourse();
                }
                else if(caseRec.Category__c == 'Entry requirements & study pathways'){ 
                    enquiryScore = enquiryScore + leadScoreConfigEnquiries.getEntryReqAndUnivStudy();
                }
                else if(caseRec.Category__c == 'Fees, costs and scholarships'){ 
                    enquiryScore = enquiryScore + leadScoreConfigEnquiries.getFeesCostScholarship();
                }
                else if(caseRec.Category__c == 'Course information'){ 
                    enquiryScore = enquiryScore + leadScoreConfigEnquiries.getCourseInformation();
                }
                else if(caseRec.Category__c == 'My application and offer'){ 
                    enquiryScore = enquiryScore + leadScoreConfigEnquiries.getMyApplicationAndOffer();
                }
                else if(caseRec.Category__c == 'My enrolment'){ 
                    enquiryScore = enquiryScore + leadScoreConfigEnquiries.getMyEnrollment();
                }
                else if(caseRec.Category__c == 'Student life'){ 
                    enquiryScore = enquiryScore + leadScoreConfigEnquiries.getStudentLife();
                }
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

    private static Boolean validateCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
    }

    private static Boolean validateSubCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
    }

    private static void setLeadScore(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigEnquiries leadScoreConfigEnquiries){
        if(leadScoreConfig.Name == 'Applying for a course'){
            leadScoreConfigEnquiries.setApplyingForCourse(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == 'Entry requirements & study pathways'){
            leadScoreConfigEnquiries.setEntryReqAndUnivStudy(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == 'Fees, costs and scholarships'){
            leadScoreConfigEnquiries.setFeesCostScholarship(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == 'Course information'){
            leadScoreConfigEnquiries.setCourseInformation(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == 'My application and offer'){
            leadScoreConfigEnquiries.setMyApplicationAndOffer(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == 'My enrolment'){
            leadScoreConfigEnquiries.setMyEnrollment(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
        else if(leadScoreConfig.Name == 'Student Life'){
            leadScoreConfigEnquiries.setStudentLife(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    }
    
}