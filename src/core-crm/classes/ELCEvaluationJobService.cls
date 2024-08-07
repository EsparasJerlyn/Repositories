/**
 * @description Service for ELCEvaluationJob
 *
 * @author Accenture
 * 
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | gabriel.p.ventayen             | May 13, 2024          | DEPP-8490              | Created file                 |
      |                                |                       |                        |                              |
 */

 public inherited sharing class ELCEvaluationJobService {
    public static List<ELCEvaluationJob> prepareELCEvaluationJobs(Date executionDate) {
        List<ELCEvaluationJob> eLCEvaluationJobs = new List<ELCEvaluationJob>();
        List<Engagement_List_Criteria__c> criteriaList = EngagementListCriteriasDAO.newInstance().findActiveEngagementListCriteriasByRecordtype(EngagementListCriteriasDAO.RECORD_TYPE_ID_ENTRY_CRITERIA, executionDate, AccessLevel.USER_MODE);
        
        for (Engagement_List_Criteria__c criteria : criteriaList) {
            eLCEvaluationJobs.add(new ELCEvaluationJob(criteria, executionDate));
        }
        return eLCEvaluationJobs;
    }
  }