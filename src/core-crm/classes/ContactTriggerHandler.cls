/**
 * @description TriggerHandler Class for ContactTrigger
 * @see ..ContactTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                  |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------|
      | john.bo.a.pineda               | April 21, 2022        | DEPP-1211              | Created file                                    |
      | Ana                            | 29/4/22               | DEPP-1418              | Create child MC persona                         |
      | angelika.j.s.galang            | May 17, 2022          | DEPP-1455              | Added global duplicates handler                 |
      | alexander.cadalin              | June 22, 2022         | DEPP-3056              | + detectDuplicatesInEmails()                    |
      |                                |                       |                        | - 1455 global dupes handler                     |
      |                                |                       |                        |                                                 |
      | eccarius.munoz                 | June 28, 2022         | DEPP-3235              | Added handling of exact match                   |
      |                                |                       |                        | of lead in after update.                        |
      | eugene.andrew.abuan            | June 29,2022          | DEPP-3339              | Added logic in After Update if                  |
      |                                |                       |                        | QUT_Username & QUT_Idenitiy_Id                  |
      |                                |                       |                        | is populated                                    |
      |                                |                       |                        |                                                 |
      | eugene.andrew.abuan            | July 01, 2022         | DEPP-3387              | Updated logic for QUT_Username                  |
      |                                |                       |                        | in AfterUpdate                                  |
      | roy.nino.s.regala              | July 30, 2022         | DEPP-3577              | removed send welcome email logic                |
      | eugene.andrew.abuan            | August 04, 2022       | DEPP-3677              | Added logic for send welcome                    |
      |                                |                       |                        | for Online Self-paced                           |
      | john.m.tambasen                | September 23, 2022    | DEPP-4367              | birthdate validation                            |
      | rhea.b.torres                  | November 24, 2022     | DEPP-4628              | Welcome Email implementation                    |
      | roy.nino.s.regala              | February 20, 2022     | DEPP-5221              | Added opt in and out dates logic                |
      | mark.j.mahilum                 | July 23, 2023         | DEPP-5799              | Added setQUTPersonaFlag method                  |
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Added updateCanNurtureFlag                      |
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Added createMarketingSegmentation               |
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Added lead score calculation                    |
      | roy.nino.s.regala              | November 01, 2023     | DEPP-7105              | updated creation of marketing                   |
      | roy.nino.s.regala              | November 01, 2023     | DEPP-7105              | segmentation to future                          |
      | kenneth.f.alsay                | December 06, 2023     | DEPP-7339              | updated query in sendWelcomeEmail               |
      | kenneth.f.alsay                | December 27, 2023     |                        | removed unused variable                         |
      | mark.j.mahilum                 | February 29, 2024     | DEPP-7739              | Move up the method fastFieldUpdateAndValidation |
      |                                |                       |                        | on beforeUpdate trigger event                   |
      | mark.j.mahilum                 | May 06, 2024          | DEPP-7987              | Updated convertLead method to check transaction |
      |                                |                       |                        | is running on async call                        |
      | sebastianne.k.trias            | June 06, 2024         | DEPP-8474              | modify setOptOutAndInDates                      |
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

    MarketingConsentHelper.setOptOutAndInDates(newItems, null, 'Contact');
    ContactTriggerHelper.reparentAccount((List<Contact>)newItems);
    ContactImageHelper.validateContactImageFile((List<Contact>) newItems);
    // Call method to detect if emails used in contacts creation is already being used
    // anywhere on the organization.
    ContactDuplicatesHelper.detectDuplicatesInEmails((List<Contact>) newItems, null);
    setContactOwner((List<Contact>)newItems);
    ContactTriggerHelper.fastFieldUpdateAndValidation((List<Contact>) newItems, null);
    FutureStudentJourneyStatusHelper.setFutureStudentJourneyStatus((List<Contact>) newItems, null);
    ContactTriggerHelper.updateMovingToBrisbane(newItems);
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
    ContactTriggerHelper.fastFieldUpdateAndValidation((List<Contact>) newItems.values(), (Map<Id, Contact>) oldItems);
    // Call method to detect if emails used in contacts update is already being used
    // anywhere on the organization.
    MarketingConsentHelper.setOptOutAndInDates(newItems.values(), oldItems, 'Contact');
    ContactDuplicatesHelper.detectDuplicatesInEmails((List<Contact>) newItems.values(), (Map<Id, Contact>) oldItems);
    ContactTriggerHelper.createAccountContactRelationRecords((List<Contact>) newItems.values(),(Map<Id, Contact>) oldItems);
    FutureStudentJourneyStatusHelper.setFutureStudentJourneyStatus((List<Contact>) newItems.values(), (Map<Id, Contact>) oldItems);
    ContactTriggerHelper.updateMovingToBrisbane(newItems, oldItems);
    ContactTriggerHelper.processContactMatchingOnContactTrigger((List<Contact>) newItems.values(),(Map<Id, Contact>) oldItems);
    ContactTriggerHelper.processSystemKeyChangeOnContactTrigger((List<Contact>) newItems.values(),(Map<Id, Contact>) oldItems);
  }

  /**
   * @description call method to create related ContactImage
   * @param newItems - List of Contact.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {
    Map<Id, Contact> newMap = (Map<Id,Contact>) newItems;
    ContactImageHelper.generateContactImageFile(newMap.values(),null);
    ContactTriggerHelper.createLeadScoreDetailRecord(newMap.values());
    ContactTriggerHelper.createAccountContactRelationRecords(newMap.values(), null);
  
    MarketingConsentHelper.processMarketingConsent((List<Contact>) newItems.values(), null);
    ContactTriggerMDMIntegration.logMDMStudents(newMap.values());
    setContactOwner((List<Contact>) newItems.values());
    ContactTriggerHelper.mapMarketingFields((List<Contact>)newMap.values(),null);
    ContactLeadScoreHelper.processLeadScoreCalculation((List<Contact>) newItems.values(), null);
    ContactTriggerHelper.createMarketingSegmentation(newMap.keySet());
    ContactTriggerHelper.processSystemKeyChangeOnContactTrigger((List<Contact>) newItems.values(), null);
    ContactWithMatchingLeadHelper.processLeadMatching((List<Contact>) newItems.values(), null);
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
    processWelcomeEmail(newMap, oldMap);
    MarketingConsentHelper.processMarketingConsent((List<Contact>) newItems.values(), (Map<Id, Contact>) oldItems);
    ContactTriggerMDMIntegration.logMDMStudents(newMap.values());
    ContactTriggerHelper.getContactCalculatedCadence((List<Contact>) newItems.values(),(Map<Id, Contact>) oldItems);
    ContactTriggerHelper.mapMarketingFields((List<Contact>)newItems.values(),(Map<Id, Contact>) oldItems);
    ContactLeadScoreHelper.processLeadScoreCalculation((List<Contact>) newItems.values(), (Map<Id, Contact>) oldItems);
    ContactWithMatchingLeadHelper.processLeadMatching((List<Contact>) newItems.values(), oldMap);
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

    if(!contactSet.isEmpty()){ //add
      sendWelcomeEmail(contactSet);
    }
    
  }

  /**
   * @description Sends Welcome email to the list of contacts which is enrolled to QUT Canvas
   * @param contactSet - List of Contact.Trigger.new
   */
  private void sendWelcomeEmail(Set<Id> contactSet){
    Set<Id> contactsToSendWelcomeEmailSet = new Set<Id>();
    List<hed__Course_Enrollment__c> courseConnections = new List<hed__Course_Enrollment__c>();

    if(Schema.sObjectType.hed__Course_Enrollment__c.isAccessible()){
      courseConnections = [
        SELECT Id, hed__Contact__c,hed__Course_Offering__r.hed__Start_Date__c
        FROM hed__Course_Enrollment__c
        WHERE hed__Contact__r.Id IN: contactSet
          AND hed__Course_Offering__r.Primary_Delivery_Platform__c = 'QUT Canvas'
          AND hed__Contact__r.Registered_Email__c != null
          AND hed__Status__c = 'Active'
          AND RecordType.DeveloperName =:STUDENT
      ];
    }

    for(hed__Course_Enrollment__c courseConnection : courseConnections){
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
      Logger.error('Exception caught in method sendWelcomeEmail in class ContactTriggerHandler.').setExceptionDetails(e);
    } finally {
      if(Logger.getBufferSize() > 0) {
        Logger.saveLog();
      }
    }
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
      List<Contact> contactsToUpdate = new List<Contact>();

      Id sysAdIntegUserId;
      User currentUser;
      Id currentUserId = UserInfo.getUserId();

      if(Schema.sObjectType.User.isAccessible()){
        //query once, get current user and syss admin integration user id
        for(User u: [ SELECT Id, Name, Contact.hed__Primary_Organization__r.OwnerId, Profile.Name
                      FROM User 
                      WHERE Id = :currentUserId 
                      OR Name = 'Sys Admin Integration User']){
          if(u.Id == currentUserId){
            currentUser = u;
          }else if(u.Name == 'Sys Admin Integration User'){
            sysAdIntegUserId = u.Id;
          }
        }
      }

      for (Contact c : contacts) {
        if(c.Id == null && c.RecordtypeId == MC_PERSONA){//before insert and is mc persona
            c.OwnerId = sysAdIntegUserId;
        }else if(c.Id != null && currentUser.Profile.Name == 'Corporate Partner'){ //after insert and current user is corporate partner
            contactsToUpdate.add(new Contact(Id = c.Id, OwnerId = currentUser.Contact.hed__Primary_Organization__r.OwnerId));
        }
      }

      List<Database.SaveResult> updateResults = new List<Database.SaveResult>();

      if(Schema.sObjectType.Contact.isUpdateable() && !contactsToUpdate.isEmpty()){
        updateResults = Database.update(contactsToUpdate, false);
      }
      
      for (Database.SaveResult result : updateResults){
        if (!result.isSuccess()){
          Logger.error('Error in Updating Contact').setDatabaseResult(result);
        }            
      }
      if(Logger.getBufferSize() > 0){
        Logger.saveLog();                
      }
  }
}