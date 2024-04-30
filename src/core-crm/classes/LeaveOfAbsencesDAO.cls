/**
 * @description DAO Class for Leave_of_Absence__c Object. Contains soql and constants related to the Leave_of_Absence__c object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | gabriel.p.ventayen             | April 30, 2024        | DEPP-8041              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
public inherited sharing class LeaveOfAbsencesDAO extends DmlBase implements ILeaveOfAbsencesDAO {
    
    public static ILeaveOfAbsencesDAO newInstance() {
        return (ILeaveOfAbsencesDAO) ImplementationSelector.DAO.newInstance(
            Leave_of_Absence__c.SObjectType
        );
    }
    public Schema.SObjectType getSObjectType() {
        return 	Leave_of_Absence__c.SObjectType;
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for outreach Case.
     */
    public class Criteria {
        public Boolean isOnLeave;
        public Date keyDate;
        Boolean isEmpty() {
            return isOnLeave == null && keyDate == null;
        }
    }

}