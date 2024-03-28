/**
 * @description Interface for Designation Code Auto Number DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | vincent.ferrer              | March 18, 2024          | DEPP-8200              | created file
 */
public interface IDesignationCodeAutoNumbersDAO extends DmlInterface {
    Designation_Code_Auto_Number__c getOrganizationalDefaults();
}