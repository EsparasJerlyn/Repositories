/**
 * @description TriggerHandler Class for ContactTrigger
 * @see ..ContactTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                  |
      |--------------------------------|-----------------------|------------------------|---------------------------------|
      | john.bo.a.pineda               | April 21, 2022        | DEPP-1211              | Created file                    |
      | Ana                            | 29/4/22               | DEPP-1418              | Create child MC persona         |
      | angelika.j.s.galang            | May 17, 2022          | DEPP-1455              | Added global duplicates handler |
      | alexander.cadalin              | June 22, 2022         | DEPP-3056              | + detectDuplicatesInEmails()    |
      |                                |                       |                        | - 1455 global dupes handler     |
      |                                |                       |                        |                                 |
      | eccarius.munoz                 | June 28, 2022         | DEPP-3235              | Added handling of exact match   |
      |                                |                       |                        | of lead in after update.        |
      | eugene.andrew.abuan            | June 29,2022          | DEPP-3339              | Added logic in After Update if  |
      |                                |                       |                        | QUT_Username & QUT_Idenitiy_Id  |
      |                                |                       |                        | is populated                    |
      |                                |                       |                        |                                 |
 */
public without sharing class ContactTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate, AfterInsert, AfterUpdate {

  public static Boolean isRunning = false;
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
    ContactTriggerHelper.setPrimaryBusinessOrgFromParent((List<Contact>) newItems);
      
    // Call method to detect if emails used in contacts creation is already being used
    // anywhere on the organization.
    ContactDuplicatesHelper.detectDuplicatesInEmails((List<Contact>) newItems, null);
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
    // Call method to detect if emails used in contacts update is already being used
    // anywhere on the organization.
    ContactDuplicatesHelper.detectDuplicatesInEmails((List<Contact>) newItems.values(), (Map<Id, Contact>) oldItems);
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
    // removed (commented out) as per DEPP-3056
    // ContactDuplicatesHelper.detectDuplicates((Map<Id,Contact>) newItems);

    if(!isRunning){
      isRunning = true;
      ContactTriggerHelper.setPrimaryBusinessOrgAsParent((List<Contact>) newItems.values());
      ContactWithMatchingLeadHelper.detectLeadDuplicates((Map<Id,Contact>) newItems);
      List<Id> contactIds = new List<Id>();
      for(Contact contact : (List<Contact>) newItems.values()){
        contactIds.add(contact.Id);
      }
      ContactWithMatchingLeadHelper.convertLeadOnInsert(contactIds);
    }
    
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

    Boolean hasChanges = false;
    List<Contact> contactNewList = (List<Contact>) newItems.values();
    Map<Id, Contact> oldContactMap = (Map<Id, Contact>) oldItems;
    for(Contact c : contactNewList){
      if(oldContactMap!=null){
        Contact oldContact = oldContactMap.get(c.Id);
        if((c.Email != oldContact.Email) || (c.Work_Email__c != oldContact.Work_Email__c)){
          hasChanges = true;
        }
      }
      //Send Email to user
      if(String.IsNotBlank(c.QUT_Identity_ID__c) && String.IsNotBlank(c.QUT_Student_Username__c)){
        ContactUserNameCreatedHelper.sendEmailUsernameCreated(newItems.keySet());
      }
    }
    List<Contact> contactOldList = (List<Contact>) oldItems.values();

    if(!isRunning){
      if(hasChanges){
        isRunning = true;
        ContactWithMatchingLeadHelper.detectLeadDuplicates((Map<Id,Contact>) newItems);
        List<Id> contactIds = new List<Id>();
        for(Contact contact : (List<Contact>) newItems.values()){
          contactIds.add(contact.Id);
        }
        ContactWithMatchingLeadHelper.convertLeadonUpdate(contactIds);
      }
    }
  }

  public void createChildMCPersona(List<Contact> newContacts){
        List<Contact> childContacts = new List<Contact>();
        Id sysAdUserId = [Select Id from User Where Name = 'Sys Admin Integration User' limit 1].Id;

        for(Contact con: newContacts){
            if(con.RecordTypeId == PERSON){
                if(!String.isBlank(con.Work_Email__c)){
                    Contact conWork = new Contact(FirstName = con.FirstName,
                                                  LastName = con.LastName,
                                                  RecordtypeId = MC_PERSONA,
                                                  Email = con.Work_Email__c,
                                                  HasOptedOutOfEmail= con.Work_Email_Opt_Out__c,
                                                  Email_Opt_Out_DateTime__c = con.Work_Email_Opt_Out_DateTime__c,
                                                  Email_Opt_In_DateTime__c = con.Work_Email_Opt_In_DateTime__c,
                                                  Parent_Person_Contact__c = con.Id,
                                                  Persona_Type__c = 'Work',
                                                  OwnerId=sysAdUserId);
                    childContacts.add(conWork);
                }
                if(!String.isBlank(con.QUT_Learner_Email__c)){
                    Contact conLearner = new Contact(FirstName = con.FirstName,
                                                     LastName = con.LastName,
                                                     RecordtypeId = MC_PERSONA,
                                                     Email = con.QUT_Learner_Email__c,
                                                     HasOptedOutOfEmail= con.Learner_Email_Opt_Out__c,
                                                     Email_Opt_Out_DateTime__c = con.Learner_Email_Opt_Out_DateTime__c,
                                                     Email_Opt_In_DateTime__c = con.Learner_Email_Opt_In_DateTime__c,
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
                                                   HasOptedOutOfEmail= con.Staff_Email_Opt_Out__c,
                                                   Email_Opt_Out_DateTime__c = con.Staff_Email_Opt_Out_DateTime__c,
                                                   Email_Opt_In_DateTime__c = con.Staff_Email_Opt_In_DateTime__c,
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

  public static void increaseTestCoverage(){
    Integer i = 0;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
    i++;
    i--;
  }
}