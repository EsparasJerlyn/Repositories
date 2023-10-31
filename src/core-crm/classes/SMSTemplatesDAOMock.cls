/**
 * @description Mock DAO Class for SMS_Template__c Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | Oct 25, 2023          | DEPP-6985              | Created file                 |
 */
@isTest
public inherited sharing class SMSTemplatesDAOMock extends DmlBaseMock implements ISMSTemplatesDAO {

    public Map<Id, SMS_Template__c> smsTemplateMap;

    public SMSTemplatesDAOMock() {
        super(new Map<Id, SMS_Template__c>(), Schema.SMS_Template__c.SObjectType);
        this.smsTemplateMap = (Map<Id, SMS_Template__c>) super.records;
    }

    public Schema.SObjectType getSObjectType() {
        return SMS_Template__c.SObjectType;
    }

    public Database.QueryLocator queryLocatorScheduledCommunicationQueue() {
        return null;
    }

    public Database.QueryLocator queryLocatorSentCommunicationQueue() {
        return null;
    }

    public List<SMS_Template__c> getActiveSMSTemplates(
        AccessLevel accessLevel){
            
        List<SMS_Template__c> smsList = new List<SMS_Template__c>();
        for (SMS_Template__c record : smsTemplateMap.values()) {
            if (record.IsActive__c) {
                smsList.add(record);
            }
        }
        return smsList;
    }
    
}