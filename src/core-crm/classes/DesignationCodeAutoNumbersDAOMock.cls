/**
 * @description Mock DAO Class for Designation Code Auto Number custom setting. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | March 20, 2023        | DEPP-8200              | Created file                 |
 */
@isTest
public inherited sharing class DesignationCodeAutoNumbersDAOMock extends DmlBaseMock implements IDesignationCodeAutoNumbersDAO {
    public Map<Id, Designation_Code_Auto_Number__c> designationAutoNumMap;

    public Schema.SObjectType getSObjectType() {
        return Designation_Code_Auto_Number__c.SObjectType;
    }

    public DesignationCodeAutoNumbersDAOMock() {
        super(new Map<Id, Designation_Code_Auto_Number__c>(), Schema.Designation_Code_Auto_Number__c.SObjectType);
        this.designationAutoNumMap = (Map<Id, Designation_Code_Auto_Number__c>) super.records;
    }

    public Designation_Code_Auto_Number__c getOrganizationalDefaults() {
        if(designationAutoNumMap.isEmpty()) {
            return new Designation_Code_Auto_Number__c();
        } else {
            return designationAutoNumMap.values()[0];
        }
    }
}