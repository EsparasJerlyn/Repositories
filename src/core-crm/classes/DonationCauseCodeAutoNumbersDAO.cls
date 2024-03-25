/**
 * @description DAO Class for Engagement Auto Number custom setting
 * Contains soql and constants related to the Engagement Auto Number custom setting
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer                 | March  18, 2024       | DEPP-8200              | Created file                 |
 */
public inherited sharing class DonationCauseCodeAutoNumbersDAO extends DmlBase implements IDonationCauseCodeAutoNumbersDAO {
    public Schema.SObjectType getSObjectType() {
        return Donation_Cause_Code_Auto_Number__c.SObjectType;
    }

    public static IDonationCauseCodeAutoNumbersDAO newInstance() {
        return (IDonationCauseCodeAutoNumbersDAO) ImplementationSelector.DAO.newInstance(Donation_Cause_Code_Auto_Number__c.SObjectType);
    }

    public static Donation_Cause_Code_Auto_Number__c getOrganizationalDefaults() {
        return Donation_Cause_Code_Auto_Number__c.getOrgDefaults();
    }
}