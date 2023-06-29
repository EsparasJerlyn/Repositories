/**
 * @description Interface for Opportunity Outcome Code Auto Number DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | May 18, 2023          | DEPP-5594              | created file
 */
public interface IOpportunityOutcomeCodeAutoNumbersDAO extends DmlInterface {
     Opportunity_Outcome_Code_Auto_Number__c getOrganizationalDefaults();
}