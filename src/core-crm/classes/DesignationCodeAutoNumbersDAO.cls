/**
 * @description DAO Class for Designation Code Auto Number custom setting
 * Contains soql and constants related to the Designation Code Auto Number custom setting
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer                 | March  18, 2024       | DEPP-8200              | Created file                 |
 */
public inherited sharing class DesignationCodeAutoNumbersDAO extends DmlBase implements IDesignationCodeAutoNumbersDAO {
    public Schema.SObjectType getSObjectType() {
        return Designation_Code_Auto_Number__c.SObjectType;
    }

    public static IDesignationCodeAutoNumbersDAO newInstance() {
        return (IDesignationCodeAutoNumbersDAO) ImplementationSelector.DAO.newInstance(Designation_Code_Auto_Number__c.SObjectType);
    }

    public static Designation_Code_Auto_Number__c getOrganizationalDefaults() {
        return Designation_Code_Auto_Number__c.getOrgDefaults();
    }
}