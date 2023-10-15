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
        String category = 'Program Engagement';
        Boolean isForProgEng = validateCategory(leadScoreConfig, category);
        if(isForProgEng){ 
            leadScoreConfigProgEngagment.setTimeLimit(Integer.valueOf(leadScoreConfig.Time_Limit_Months__c));
            leadScoreConfigProgEngagment.setMaxScore(Integer.valueOf(leadScoreConfig.Max_Score__c));
        }

        Boolean isSubCategory = validateSubCategory(leadScoreConfig, category);
        if(isSubCategory && leadScoreConfig.Name == 'Program Engagement attendance'){
            leadScoreConfigProgEngagment.setProgramEngAttendance(Integer.valueOf(leadScoreConfig.Score_Allocation__c));
        }
    } 

    public static Map<Id, Integer> calculateLeadScore(Map<Id,hed__Program_Enrollment__c> programEnrollmentMap, LeadScoreConfigProgEngagment leadScoreConfigProgEngagment){
        
        Map<Id, Integer> progEngMap = new Map<Id, Integer>();
        
        Integer progEngScore = 0;
        Map<Id, hed__Program_Enrollment__c> accountProgramMap = new Map<Id, hed__Program_Enrollment__c>();
        for(hed__Program_Enrollment__c progEng : programEnrollmentMap.values()){
            accountProgramMap.put(progEng.hed__Account__c, progEng);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<String> fields = new List<String>{'Name', 'RecordTypeId', 'Program_Code__c'};
        List<Account> accountList = AccountsDAO.newInstance().getAccountsBySetIds(accountProgramMap.keySet(), fields, AccessLevel.SYSTEM_MODE);
        for(Account account : accountList){
            accountMap.put(accountProgramMap.get(account.Id).Id, account);
        }

        for(hed__Program_Enrollment__c progEng : programEnrollmentMap.values()){
            if(
                accountMap.containsKey(progEng.Id) && 
                accountMap.get(progEng.Id).RecordTypeId == AccountsDAO.ACCT_ACADEMIC_PROGRAM_ID &&
                ((accountMap.get(progEng.Id).Name.contains('Start QUT')) ||
                (accountMap.get(progEng.Id).Program_Code__c == 'QC19'))
            ){
                progEngScore = progEngScore + leadScoreConfigProgEngagment.getProgramEngAttendance();
            }
            Integer score = LeadScoreCalculatorService.validateScore(progEngScore, leadScoreConfigProgEngagment.getMaxScore());

            if(progEng.hed__Contact__c != null){
                progEngMap.put(progEng.hed__Contact__c, score);
            }
        }

        return progEngMap;
    }

    private static Boolean validateCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.Name == category && leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_CATEGORY;
    }

    private static Boolean validateSubCategory(Lead_Score_Configuration__c leadScoreConfig, String category){
        return leadScoreConfig.RecordTypeId == LeadScoreConfigurationDAO.RECTYPE_ID_SUB_CATEGORY && leadScoreConfig.Parent_Category__r.Name == category;
    }
}