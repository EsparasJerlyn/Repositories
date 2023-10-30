/**
 * @description Interface class for SMSTemplatesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | Oct 25, 2023          | DEPP-6985              | Created file                 |
 */
public interface ISMSTemplatesDAO extends DmlInterface {
    List<SMS_Template__c> getActiveSMSTemplates(
        AccessLevel accessLevel
    );
}