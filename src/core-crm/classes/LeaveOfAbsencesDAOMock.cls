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
public inherited sharing class LeaveOfAbsencesDAOMock extends DmlBaseMock implements ILeaveOfAbsencesDAO {
    public Map<Id, Leave_of_Absence__c> leaveOfAbsenceMap;
    public Schema.SObjectType getSObjectType() {
        return Leave_of_Absence__c.SObjectType;
    }
    public LeaveOfAbsencesDAOMock() {
        super(new Map<Id, Leave_of_Absence__c>(), Schema.Leave_of_Absence__c.SObjectType);
        this.leaveOfAbsenceMap = (Map<Id, Leave_of_Absence__c>) super.records;
    }
}