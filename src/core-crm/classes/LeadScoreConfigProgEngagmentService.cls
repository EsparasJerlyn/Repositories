/**
 * @description Service Class for Program Engagement Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigProgEngagmentService {
    public static void getLeadScoreConfig(Lead_Score_Configuration__c leadScoreConfig, LeadScoreConfigProgEngagment leadScoreConfigProgEngagment){
        String category = LeadScoreConfigurationDAO.CONFIG_CATEGORY_PROGRAM_ENGAGEMENT;
        Boolean isForProgEng = validateCategory(leadScoreConfig, category);
        if(isForProgEng){ 
            leadScoreConfigProgEngagment.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigProgEngagment.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = validateSubCategory(leadScoreConfig, category);
        if(isSubCategory && leadScoreConfig.Name == LeadScoreConfigurationDAO.CONFIG_SUB_CATEGORY_PROG_ENG_ATTD){
            leadScoreConfigProgEngagment.setProgramEngAttendance(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    private static Map<Id, Account> getAccountMap(Set<Id> accountIds){
        List<String> fields = new List<String>{'Name', 'RecordTypeId', 'Program_Code__c'};
        return new Map<Id, Account>(AccountsDAO.newInstance().getAccountsBySetIds(accountIds, fields, AccessLevel.SYSTEM_MODE));
    }

    public static Map<Id, Integer> calculateLeadScore(Map<Id,hed__Program_Enrollment__c> programEnrollmentMap, LeadScoreConfigProgEngagment leadScoreConfigProgEngagment){
        
        Map<Id, Integer> progEngMap = new Map<Id, Integer>();
        
        Integer progEngScore = 0;
        Map<Id, hed__Program_Enrollment__c> accountProgramMap = new Map<Id, hed__Program_Enrollment__c>();
        for(hed__Program_Enrollment__c progEng : programEnrollmentMap.values()){
            accountProgramMap.put(progEng.hed__Account__c, progEng);
        }
        
        Map<Id, Account> accountMap = getAccountMap(accountProgramMap.keySet());
        for(hed__Program_Enrollment__c progEng : programEnrollmentMap.values()){
            if(progEngMap.containsKey(progEng.hed__Contact__c)){
                progEngScore = progEngMap.get(progEng.hed__Contact__c);
            }else{
                progEngScore = 0;
            }

            if(validateProgEngRecord(progEng, accountMap)){
                progEngScore = progEngScore + leadScoreConfigProgEngagment.getProgramEngAttendance();
            }

            Integer score = LeadScoreCalculatorService.validateScore(progEngScore, leadScoreConfigProgEngagment.getMaxScore());

            if(progEng.hed__Contact__c != null){
                progEngMap.put(progEng.hed__Contact__c, score);
            }

        }
        
        return progEngMap;
    }

    private static Boolean validateProgEngRecord(hed__Program_Enrollment__c progEng, Map<Id, Account> accountMap){
        return 
            !progEng.Lead_Score_Reset__c &&
            accountMap.containsKey(progEng.hed__Account__c) && 
            accountMap.get(progEng.hed__Account__c).RecordTypeId == AccountsDAO.ACCT_ACADEMIC_PROGRAM_ID &&
            (
                accountMap.get(progEng.hed__Account__c).Name.contains(AccountsDAO.ACCOUNT_NAME_START_QUT) ||
                accountMap.get(progEng.hed__Account__c).Program_Code__c == AccountsDAO.PROGRAM_CODE_QC19
            );
    }

    private static Boolean validateCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
    }

    private static Boolean validateSubCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
    }
}