/**
 * @description Interface for Opportunity Outcome Code Auto Number DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer              | March 18, 2024          | DEPP-8200              | created file
 */
public interface IDonationCauseCodeAutoNumbersDAO extends DmlInterface {
    Donation_Cause_Code_Auto_Number__c getOrganizationalDefaults();
}