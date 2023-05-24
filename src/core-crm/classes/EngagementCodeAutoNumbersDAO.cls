/**
 * @description DAO Class for Engagement Auto Number custom setting
 * Contains soql and constants related to the Engagement Auto Number custom setting
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 18, 2023          | DEPP-5594              | Created file
 */
public inherited sharing class EngagementCodeAutoNumbersDAO extends DmlBase implements IEngagementCodeAutoNumbersDAO {
    public Schema.SObjectType getSObjectType() {
        return Engagement_Code_Auto_Number__c.SObjectType;
    }

    public static IEngagementCodeAutoNumbersDAO newInstance() {
        return (IEngagementCodeAutoNumbersDAO) ImplementationSelector.DAO.newInstance(Engagement_Code_Auto_Number__c.SObjectType);
    }
}
