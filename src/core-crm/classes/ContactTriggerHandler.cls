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
      | eugene.andrew.abuan            | July 01, 2022         | DEPP-3387              | Updated logic for QUT_Username  |
      |                                |                       |                        | in AfterUpdate                  |
      | roy.nino.s.regala              | July 30, 2022         | DEPP-3577              | removed send welcome email logic|
      | eugene.andrew.abuan            | August 04, 2022       | DEPP-3677              | Added logic for send welcome    |
      |                                |                       |                        | for Online Self-paced           |
      | john.m.tambasen                | September 23, 2022    | DEPP-4367              | birthdate validation            |
      | rhea.b.torres                  | November 24, 2022     | DEPP-4628              | Welcome Email implementation    |


 */
public without sharing class ContactTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate, AfterInsert, AfterUpdate {

  public static Boolean isRunning = false;
  private static final String STUDENT = 'Student';
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

    setContactOwner((List<Contact>) newItems);
    ContactTriggerHelper.reparentAccount((List<Contact>)newItems);
    ContactImageHelper.validateContactImageFile((List<Contact>) newItems);
    // Call method to detect if emails used in contacts creation is already being used
    // anywhere on the organization.
    ContactDuplicatesHelper.detectDuplicatesInEmails((List<Contact>) newItems, null);
    ContactTriggerHelper.birthdateValidation((List<Contact>) newItems);
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
    ContactTriggerHelper.createAccountContactRelationRecords((List<Contact>) newItems.values(),(Map<Id, Contact>) oldItems);
    ContactTriggerHelper.birthdateValidation((List<Contact>) newItems.values());
  }

  /**
   * @description call method to create related ContactImage
   * @param newItems - List of Contact.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {
    Map<Id, Contact> newMap = (Map<Id,Contact>) newItems;
    ContactImageHelper.generateContactImageFile(newMap.values(),null);
    processLeadOnInsert(newMap);
    createChildMCPersona(newMap.values());
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
    Map<Id, Contact> newMap = (Map<Id,Contact>) newItems;
    Map<Id, Contact> oldMap = (Map<Id,Contact>) oldItems;
    ContactImageHelper.generateContactImageFile(newMap.values(), oldMap);
    processLeadOnUpdate(newMap, oldMap);
    processWelcomeEmail(newMap, oldMap);
  }

  /**
   * @description Process Lead on insert
   * @param newMap - List of Contact.Trigger.new
   */
  private void processLeadOnInsert(Map<Id, Contact> newMap){
    if(!isRunning){
      isRunning = true;
      ContactTriggerHelper.createAccountContactRelationRecords(newMap.values(), null);
      ContactWithMatchingLeadHelper.detectLeadDuplicates(newMap);

      List<Id> contactIdList = new List<Id>();
      contactIdList.addAll(newMap.keySet());
      ContactWithMatchingLeadHelper.convertLeadOnInsert(contactIdList);
    }
  }

  /**
   * @description Process Lead duplicates and convert lead
   * @param newMap - List of Contact.Trigger.new
   * @param oldMap - List of Contact.Trigger.old
   */
  private void processLeadOnUpdate(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
    Boolean hasChanges = false;
    for(Id key : newMap.keySet()){
      if(oldMap.get(key).Email != newMap.get(key).Email || oldMap.get(key).Work_Email__c != newMap.get(key).Work_Email__c){
        hasChanges = true;
        break;
      }
    }
    if(!isRunning && hasChanges){
      isRunning = true;
      ContactWithMatchingLeadHelper.detectLeadDuplicates(newMap);

      List<Id> contactIdList = new List<Id>();
      contactIdList.addAll(newMap.keySet());
      ContactWithMatchingLeadHelper.convertLeadonUpdate(contactIdList);
    }
  }

  /**
   * @description Processes welcome email sending when QUT Student Username is available for the Contact
   * @param newMap - List of Contact.Trigger.new
   * @param oldMap - List of Contact.Trigger.old
   */
  private void processWelcomeEmail(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
    Set<Id> contactSet = new Set<Id>();
    // process only contacts with QUT Student Username being updated from empty
    for(Id key : newMap.keySet()){
      String oldUsername = oldMap.get(key).QUT_Student_Username__c;
      String newUsername = newMap.get(key).QUT_Student_Username__c;
      if(String.isBlank(oldUsername) && String.isNotBlank(newUsername)){
        contactSet.add(newMap.get(key).Id);
      }
    } 
    sendWelcomeEmail(contactSet);
  }

  /**
   * @description Sends Welcome email to the list of contacts which is enrolled to a blackboard
   * @param contactSet - List of Contact.Trigger.new
   */
  private void sendWelcomeEmail(Set<Id> contactSet){
    Set<Id> contactsToSendWelcomeEmailSet = new Set<Id>();
    for(hed__Course_Enrollment__c courseConnection : [
                                                      SELECT Id, hed__Contact__c,hed__Course_Offering__r.hed__Start_Date__c
                                                      FROM hed__Course_Enrollment__c
                                                      WHERE hed__Contact__r.Id IN: contactSet
                                                        AND hed__Course_Offering__r.Primary_Delivery_Platform__c = 'Blackboard'
                                                        AND hed__Contact__r.Registered_Email__c != null
                                                        AND hed__Status__c = 'Active'
                                                        AND RecordType.DeveloperName =:STUDENT]){
      Integer dayBeforeStart = Date.today().daysBetween(courseConnection.hed__Course_Offering__r.hed__Start_Date__c);
      if(dayBeforeStart <= 7){
        contactsToSendWelcomeEmailSet.add(courseConnection.hed__Contact__c); //set of contacts who will receive welcome email
      }                                            
    }

    try{
      if(!contactsToSendWelcomeEmailSet.isEmpty()){
        ContactUserNameCreatedHelper.sendEmailUsernameCreated(contactsToSendWelcomeEmailSet);
      }
    }catch(Exception e){
      System.debug(LoggingLevel.WARN, 'ContactTriggerHandler Welcome email failed, Error: ' + e.getMessage());//NOPMD
    }

  }

  private void createChildMCPersona(List<Contact> newContacts){
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

  /**
   * @description set the contact owner to the owner of the account associated with the current login user's contact if the current user is having UserType of PowerPartner
   * @param contacts the list of contacts to set owner for
   */
  private void setContactOwner(List<Contact> contacts) {
    if (UserInfo.getUserType() == 'PowerPartner') {

      User u = [Select Id, Contact.hed__Primary_Organization__r.ownerId from User where id = :UserInfo.getUserId()];

      for (Contact c : contacts) {
        c.ownerId = u.Contact.hed__Primary_Organization__r.ownerId;
      }
    }
  }

}