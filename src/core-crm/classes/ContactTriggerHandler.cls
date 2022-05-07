/**
 * @description TriggerHandler Class for ContactTrigger
 * @see ..ContactTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | April 21, 2022        | DEPP-1211              | Created file                 |
      | Ana                            | 29/4/22               | DEPP-1418              | Create child MC persona      |                                                 |
 */
public without sharing class ContactTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate, AfterInsert, AfterUpdate {
    public static final Id PERSON = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Person')
        .getRecordTypeId();
    public static final Id MC_PERSONA = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('MC_Persona')
        .getRecordTypeId();
    
  /**
   * @description call method to display error when Image count on Contact.Contact_Image__c is > 1
   * @param newItems - List of Contact.Trigger.new
   */
  public void beforeInsert(List<SObject> newItems) { 
    ContactImageHelper.validateContactImageFile((List<Contact>) newItems);
  }

  /**
   * @description call method to display error when Image count on Contact.Contact_Image__c is > 1
   * @param newItems - List of Contact.Trigger.new
   * @param oldItems - List of Contact.Trigger.old
   */
  public void beforeUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    ContactImageHelper.validateContactImageFile(
      (List<Contact>) newItems.values()
    );
  }

  /**
   * @description call method to create related ContactImage
   * @param newItems - List of Contact.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {
    ContactImageHelper.generateContactImageFile(
      (List<Contact>) newItems.values(),
      null
    );
    createChildMCPersona((List<Contact>) newItems.values());
  }

  /**
   * @description update counter for Course Connections
   * @param newItems - List of Contact.Trigger.new
   * @param oldItems - List of Contact.Trigger.old
   */
  public void afterUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    ContactImageHelper.generateContactImageFile(
      (List<Contact>) newItems.values(),
      (Map<Id, Contact>) oldItems
    );
  }
  
  public void createChildMCPersona(List<Contact> newContacts){
        List<Contact> childContacts = new List<Contact>();
        Id sysAdUserId = [Select Id from User Where Name = 'Sys Admin Integration User' limit 1].Id;
      
        for(Contact con: newContacts){
            system.debug(con.RecordTypeId);
            system.debug(PERSON);
            if(con.RecordTypeId == PERSON){
                if(!String.isBlank(con.hed__WorkEmail__c)){
                    Contact conWork = new Contact(FirstName = con.FirstName,
                                                 LastName = con.LastName,
                                                 RecordtypeId = MC_PERSONA,
                                                 Email = con.hed__WorkEmail__c,
                                                 Parent_Person_Contact__c = con.Id,
                                                 Persona_Type__c = 'Work',
                                                 OwnerId=sysAdUserId);   
                    childContacts.add(conWork);
                }
                system.debug(childContacts);
                if(!String.isBlank(con.QUT_Learner_Email__c)){
                    Contact conLearner = new Contact(FirstName = con.FirstName,
                                                 LastName = con.LastName,
                                                 RecordtypeId = MC_PERSONA,
                                                 Email = con.QUT_Learner_Email__c,
                                                 Parent_Person_Contact__c = con.Id,
                                                 Persona_Type__c = 'QUT Learner',
                                                 OwnerId=sysAdUserId);    
                    childContacts.add(conLearner);
                }
                
                if(!String.isBlank(con.QUT_Staff_Email__c)){
                    Contact conStaff = new Contact(FirstName = con.FirstName,
                                                 LastName = con.LastName,
                                                 RecordtypeId = MC_PERSONA,
                                                 Email = con.QUT_Staff_Email__c,
                                                 Parent_Person_Contact__c = con.Id,
                                                 Persona_Type__c = 'QUT Staff',
                                                 OwnerId=sysAdUserId);    
                    childContacts.add(conStaff);
                }
            }
        }
        
        insert childContacts;
    }

  /**
   * @description indicates it the trigger is disabled
   * @return disabled bypass
   */
  public Boolean isDisabled() {
    final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
    return bypass.isDisabled();
  }
}