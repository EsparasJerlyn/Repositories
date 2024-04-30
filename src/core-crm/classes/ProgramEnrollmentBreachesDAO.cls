/**
 * @description DAO Class for Program_Enrollment_Breach__c Object. Contains soql and constants related to the Program_Enrollment_Breach__c object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | julie.jane.alegre              | April 29, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */

public inherited sharing class ProgramEnrollmentBreachesDAO extends DmlBase implements IProgramEnrollmentBreachesDAO {
    
    public static final String ACTIVE_BREACH_STATUS = 'Active Breach';

    public static IProgramEnrollmentBreachesDAO newInstance() {
        return (IProgramEnrollmentBreachesDAO) ImplementationSelector.DAO.newInstance(
            Program_Enrollment_Breach__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return 	Program_Enrollment_Breach__c.SObjectType;
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for outreach Case.
     */
    public class Criteria {
        public String breachName;
        public String breachStatus;

        Boolean isEmpty() {
            return breachName == null && breachStatus == null;
        }
    }
}
