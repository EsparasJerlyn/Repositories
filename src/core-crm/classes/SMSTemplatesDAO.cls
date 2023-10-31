/**
 * @description DAO class for SMS_Template__c
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | Oct 25, 2023          | DEPP-6985              | Created file                 |
 */
public with sharing class SMSTemplatesDAO extends DmlBase implements ISMSTemplatesDAO {
    
  public Schema.SObjectType getSObjectType(){
    return SMS_Template__c.SObjectType;
  }
    
  public static ISMSTemplatesDAO newInstance(){
    return (ISMSTemplatesDAO) ImplementationSelector.DAO.newInstance(SMS_Template__c.SObjectType);
  }
    
  public List<SMS_Template__c> getActiveSMSTemplates(AccessLevel accessLevel) {
      return Database.query(
          'SELECT Id, Cadence_Step_Name__c, Message_Content__c ' + 
          'FROM SMS_Template__c ' + 
          'WHERE IsActive__c = TRUE', accessLevel
      );        
  }   
}