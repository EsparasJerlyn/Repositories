/**
 * @description Helper class for Lead Score Calculation
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | October 10, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public inherited sharing class LeadScoreService {
    //arrange the range mappings from low to high 
    private static final Map<String, Map<String, Decimal>> STATUS_SCORE_CONFIG_MAP = new Map<String, Map<String, Decimal>>{
        LeadsDAO.NEW_STATUS => new Map<String, Decimal>{ 'min' => null, 'max' => 50 },
        LeadsDAO.ENGAGING_STATUS => new Map<String, Decimal>{ 'min' => 50, 'max' => 100 },
        LeadsDAO.NURTURING_STATUS => new Map<String, Decimal>{ 'min' => 100, 'max' => null }
    };

    public static String getLeadStatus(Decimal totalLeadScore) {
        String leadStatus = '';
        for (String status : STATUS_SCORE_CONFIG_MAP.keySet()) {
            Decimal min = STATUS_SCORE_CONFIG_MAP.get(status).get('min');
            Decimal max = STATUS_SCORE_CONFIG_MAP.get(status).get('max');

            if (isLeadScoreInRange(totalLeadScore, min, max)) {
                leadStatus = status;
                break;
            }
        }
        return leadStatus;
    }

    public static Boolean isLeadScoreInRange(
        Decimal leadScore,
        Decimal minScore,
        Decimal maxScore
    ) {
        if (minScore == null) {
            return leadScore < maxScore;
        } else if (maxScore == null) {
            return leadScore >= minScore;
        }
        return minScore <= leadScore && leadScore < maxScore;
    }
}
