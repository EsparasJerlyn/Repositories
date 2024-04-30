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

 public inherited sharing class ProgramEnrollmentBreachesDAOMock extends DmlBaseMock implements IProgramEnrollmentBreachesDAO {
    public Map<Id, Program_Enrollment_Breach__c> programEnrollmentBreachMap;

    public Schema.SObjectType getSObjectType() {
        return Program_Enrollment_Breach__c.SObjectType;
    }

    public ProgramEnrollmentBreachesDAOMock() {
        super(new Map<Id, Program_Enrollment_Breach__c>(), Schema.Program_Enrollment_Breach__c.SObjectType);
        this.programEnrollmentBreachMap = (Map<Id, Program_Enrollment_Breach__c>) super.records;
    }
}
