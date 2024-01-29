/**
* @description TriggerHandler Class for CourseConnectionTrigger
* @see ..CourseConnectionTriggerHandler
*
* @author Accenture
*
* @history
*
| Developer Email                | Date                  | JIRA                   | Change Summary                                                                |
|--------------------------------|-----------------------|------------------------|-------------------------------------------------------------------------------|
| johnbo.pineda@qut.edu.au       | December 03, 2021     | DEPP-789               | Created file                                                                  |
| johnbo.pineda@qut.edu.au       | January 03, 2022      | DEPP-1382              | Updated Class to include changes for DEPP-1382.                               |
| johnbo.pineda@qut.edu.au       | January 31, 2022      | DEPP-1519              | Updated Class to include changes for DEPP-1519.                               |
| roy.nino.s.regala@qut.edu.au   | March 04, 2022        | DEPP-1985              | External user is trying to update the field,removed with sharing restriction  |
| eugene.andrew.abuan            | March 22, 2022        | DEPP-1991              | Added Class for Before Insert                                                 |
| john.bo.a.pineda               | June 23, 2022         | DEPP-3222              | Added logic to Send Email on Registration for Student / Student - Program     |
| rhea.b.torres                  | July 22, 2022         | DEPP-3557              | Added logic to use email template setup in Communication Schedule             |
| rhea.b.torres                  | August 9, 2022        | DEPP-3723              | Added logic to send Welcome Email for learners with QUT Student Username      |
| rhea.b.torres                  | August 18, 2022       | DEPP-2002              | Added logic for creating Session records for Diagnostic Tool                  |
| rhea.b.torres                  | November 25, 2022     | DEPP-4628              | Welcome Email implementation                                                  |
| roy.nino.s.regala              | Sep 20, 2023          | DEPP-6417              | Added before update method, processEnrolmentPricingValidation                 |
| kenneth.f.alsay                | Sep 22, 2023          | DEPP-6299              | Added before update method, setLMSIntegrationStatusToNull                 	  |
| kenneth.f.alsay                | December 6, 2023      | DEPP-7339              | Updated query in sendWelcomeEmail method as per AC2                           |
| kenneth.f.alsay                | December 27, 2023     |                        | Removed unused variable                                                       |
*/
public without sharing class CourseConnectionTriggerHandler implements Disableable, BeforeInsert, BeforeUpdate, AfterInsert, AfterUpdate, AfterDelete {
  public static final Id STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student')
    .getRecordTypeId();
  public static final Id PROG_STUDENT_RECTYPEID = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName()
    .get('Student_Program')
    .getRecordTypeId();
  private static final String STR_QUTEX = 'QUTeX';

  /**
   * @description calls the ExternalIdHelper function to update the External Id
   * @param newItems - List of hed__Course_Enrollment__c.Trigger.new
   */
  public void beforeInsert(List<SObject> newItems) {
    SetExternalIdHelper.updateExternalId(newItems);
    CourseConPricingValidationHelper.processEnrolmentPricingValidation(newItems, null);
  }

  /**
   * @description update for Course Connections
   * @param newItems - List of hed__Course_Enrollment__c.Trigger.new
   * @param oldItems - Map of hed__Course_Enrollment__c.Trigger.old
   */
  public void beforeUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    CourseConPricingValidationHelper.processEnrolmentPricingValidation(
      (List<hed__Course_Enrollment__c>) newItems.values(),
      (Map<Id,hed__Course_Enrollment__c>) oldItems
    );
    CourseConnectionTriggerHelper.setLMSIntegrationStatusToNull(
      (List<hed__Course_Enrollment__c>) newItems.values(),
      (Map<Id,hed__Course_Enrollment__c>) oldItems
    );
  }

  /**
   * @description update counter for Course Connections
   * @param newItems - List of hed__Course_Enrollment__c.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {
    updateCourseConnectionCounter(
      (List<hed__Course_Enrollment__c>) newItems.values(),
      null
    );

    // Create Session records for Diagnostic Tool
    Map<Id,hed__Course_Enrollment__c> newMap = (Map<Id, hed__Course_Enrollment__c>) newItems;
    CorporateBundleAndSOAHelper.createAffiliationRecords(newMap.values());

    try{
      createSessionRecordsForDiagnosticTool(newItems.keySet());
      // Trigger Send Email on Registration Confirmation
      sendRegistrationConfirmEmail(newItems.keySet());
      sendWelcomeEmail(newItems.keySet());
    }catch(Exception e){
      Logger.error('Exception caught in method afterInsert in class CourseConnnectionTriggerHandler.').setExceptionDetails(e);
    } finally {
      if(Logger.getBufferSize() > 0) {
        Logger.saveLog();
      }
    }
    
      ESBIntegrateOnCourseConnectionUpsert.calloutToMDM((Map<Id, hed__Course_Enrollment__c>) newItems);
  }

  /**
   * @description update counter for Course Connections
   * @param newItems - List of hed__Course_Enrollment__c.Trigger.new
   * @param oldItems - Map of hed__Course_Enrollment__c.Trigger.old
   */
  public void afterUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    updateCourseConnectionCounter(
      (List<hed__Course_Enrollment__c>) newItems.values(),
      (List<hed__Course_Enrollment__c>) oldItems.values()
    );

    List<hed__Course_Enrollment__c> courseConNewStatusList = new List<hed__Course_Enrollment__c>();

    Map<Id,hed__Course_Enrollment__c> newMap = (Map<Id, hed__Course_Enrollment__c>) newItems;
    Map<Id,hed__Course_Enrollment__c> oldMap = (Map<Id, hed__Course_Enrollment__c>) oldItems;

    for(hed__Course_Enrollment__c courseCon: newMap.values()){
      if(courseCon.hed__Status__c != oldMap.get(courseCon.Id).hed__Status__c){
        courseConNewStatusList.add(courseCon);
      }
    }
    
    if(!courseConNewStatusList.isEmpty()){
      ProductLedgerTriggerHelper.productLedgerRollUpUpdate(courseConNewStatusList);
    }   

    ESBIntegrateOnCourseConnectionUpsert.calloutToMDM((Map<Id, hed__Course_Enrollment__c>) newItems);
  }
    
  /**
   * @description update counter for Course Connections
   * @param oldItems - Map of hed__Course_Enrollment__c.Trigger.old
   */
  public void afterDelete(Map<Id, SObject> oldItems) {
    updateCourseConnectionCounter(
      (List<hed__Course_Enrollment__c>) oldItems.values(),
      null
    );
  }

  /**
   * @description update counter for Course Connections
   * @param crseEnrollListNew - List of hed__Course_Enrollment__c.Trigger.new
   * @param crseEnrollListOld - Map of hed__Course_Enrollment__c.Trigger.old
   */
  public void updateCourseConnectionCounter(
    List<hed__Course_Enrollment__c> crseEnrollListNew,
    List<hed__Course_Enrollment__c> crseEnrollListOld
  ) {
    try {
      Map<Id, Integer> courseOfferMap = new Map<Id, Integer>();
      Map<Id, Integer> programOfferMap = new Map<Id, Integer>();
      Set<Id> courseOfferIdSet = new Set<Id>();
      Set<Id> programOfferIdSet = new Set<Id>();

      for (hed__Course_Enrollment__c crseEnroll : crseEnrollListNew) {
        if (String.isNotBlank(crseEnroll.hed__Course_Offering__c)) {
          courseOfferIdSet.add(crseEnroll.hed__Course_Offering__c);
        } else if (String.isNotBlank(crseEnroll.Program_Offering__c)) {
          programOfferIdSet.add(crseEnroll.Program_Offering__c);
        }
      }

      if (crseEnrollListOld != null) {
        for (hed__Course_Enrollment__c crseEnrollOld : crseEnrollListOld) {
          if (String.isNotBlank(crseEnrollOld.hed__Course_Offering__c)) {
            courseOfferIdSet.add(crseEnrollOld.hed__Course_Offering__c);
          } else if (String.isNotBlank(crseEnrollOld.Program_Offering__c)) {
            programOfferIdSet.add(crseEnrollOld.Program_Offering__c);
          }
        }
      }

      //count enrolments in course offering
      List<AggregateResult> aggrCourseOfferList = [
        SELECT hed__Course_Offering__c, COUNT(Id) counter
        FROM hed__Course_Enrollment__c
        WHERE
          RecordTypeId = :STUDENT_RECTYPEID
          AND hed__Course_Offering__c IN :courseOfferIdSet
          AND hed__Status__c != 'Cancelled'
        GROUP BY hed__Course_Offering__c
      ];

      for (AggregateResult aggrCourseOffer : aggrCourseOfferList) {
        if (
          String.isNotBlank((Id) aggrCourseOffer.get('hed__Course_Offering__c'))
        ) {
          courseOfferMap.put(
            (Id) aggrCourseOffer.get('hed__Course_Offering__c'),
            (Integer) aggrCourseOffer.get('counter')
          );
        }
      }

      List<hed__Course_Offering__c> courseOfferList = [
        SELECT Id, Total_Number_of_Registered_Learners__c
        FROM hed__Course_Offering__c
        WHERE Id IN :courseOfferIdSet
      ];

      for (hed__Course_Offering__c courseOffer : courseOfferList) {
        if (courseOfferMap.containsKey(courseOffer.Id)) {
          courseOffer.Total_Number_of_Registered_Learners__c = courseOfferMap.get(
            courseOffer.Id
          );
        } else {
          courseOffer.Total_Number_of_Registered_Learners__c = 0;
        }
      }

      update courseOfferList;

      //count enrolments in program offering
      List<AggregateResult> aggrProgramOfferList = [
        SELECT Program_Offering__c, COUNT(Id) counter
        FROM hed__Course_Enrollment__c
        WHERE
          RecordTypeId = :PROG_STUDENT_RECTYPEID
          AND Program_Offering__c IN :programOfferIdSet
          AND hed__Status__c != 'Cancelled'
        GROUP BY Program_Offering__c
      ];

      for (AggregateResult aggrProgramOffer : aggrProgramOfferList) {
        if (
          String.isNotBlank((Id) aggrProgramOffer.get('Program_Offering__c'))
        ) {
          programOfferMap.put(
            (Id) aggrProgramOffer.get('Program_Offering__c'),
            (Integer) aggrProgramOffer.get('counter')
          );
        }
      }

      List<Program_Offering__c> programOfferList = [
        SELECT Id, Total_Number_of_Registered_Learners__c
        FROM Program_Offering__c
        WHERE Id IN :programOfferIdSet
      ];

      for (Program_Offering__c programOffer : programOfferList) {
        if (programOfferMap.containsKey(programOffer.Id)) {
          programOffer.Total_Number_of_Registered_Learners__c = programOfferMap.get(
            programOffer.Id
          );
        } else {
          programOffer.Total_Number_of_Registered_Learners__c = 0;
        }
      }

      update programOfferList;
    } catch (Exception e) {
      Logger.error('Exception caught in method updateCourseConnectionCounter in class CourseConnnectionTriggerHandler.')
        .setExceptionDetails(e);
    } finally {
      if(Logger.getBufferSize() > 0) {
        Logger.saveLog();
      }
    }
  }

  /**
   * @description Sends Welcome Email on New Course Connections with QUT Student Username
   * @param courseConnectionIdSet - List of hed__Course_Enrollment__c.Trigger.new
   */
  private void sendWelcomeEmail(Set<Id> courseConnectionIdSet){
    Set<Id> contactsToSendWelcomeEmailSet = new Set<Id>();
    for(hed__Course_Enrollment__c courseConnection : [
                                                      SELECT Id, hed__Contact__c,hed__Course_Offering__r.hed__Start_Date__c
                                                      FROM hed__Course_Enrollment__c
                                                      WHERE Id IN: courseConnectionIdSet
                                                        AND hed__Course_Offering__r.Primary_Delivery_Platform__c = 'QUT Canvas'
                                                        AND hed__Contact__r.QUT_Student_Username__c != null
                                                        AND hed__Contact__r.Registered_Email__c != null
                                                        AND hed__Status__c = 'Active'
                                                        AND RecordTypeId =:STUDENT_RECTYPEID WITH SECURITY_ENFORCED]){
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
      Logger.error('Exception caught in method sendWelcomeEmail in class CourseConnectionTriggerHandler.')
        .setExceptionDetails(e);
    } finally {
      if(Logger.getBufferSize() > 0) {
        Logger.saveLog();
      }
    }
  }

  /**
   * @description send Registration Confirmation Email on New Course Connections
   * @param crseEnrollListNew - List of hed__Course_Enrollment__c.Trigger.new
   */
  public void sendRegistrationConfirmEmail(Set<Id> crseEnrollIdSet) {
    // Init
    Set<Id> ccCourseSet = new Set<Id>();
    Set<Id> ccProgPlanSet = new Set<Id>();
    Map<Id,String> productEmailTemplateMap = new Map<Id,String>();
    Set<String> emailTemplateIdSet = new Set<String>();
    // Set Map for Course Send Registration Email
    Map<Id, Boolean> courseSendRegEmailMap = new Map<Id, Boolean>();
    // Set Map for Program Send Registration Email
    Map<Id, Boolean> progPlanSendRegEmailMap = new Map<Id, Boolean>();

    Map<Id,EmailTemplate> emailTemplateMap = new Map<Id,EmailTemplate>();

    // Get Org Wide Email Address
    List<OrgWideEmailAddress> owea = [
      SELECT Id, Address, DisplayName
      FROM OrgWideEmailAddress
      WHERE DisplayName = 'QUTeX'
      LIMIT 1
    ];

    // Query Course Connection Details
    List<hed__Course_Enrollment__c> crseEnrollListNew = [
      SELECT
        Id,
        RecordTypeId,
        hed__Course_Offering__r.hed__Course__c,
        Program_Offering__r.hed_Program_Plan__c,
        hed__Course_Offering__r.hed__Course__r.Name,
        Program_Offering__r.hed_Program_Plan__r.Name,
        hed__Contact__r.FirstName,
        hed__Contact__r.LastName,
        Paid_in_Full__c,
        Amount__c,
        hed__Contact__r.Registered_Email__c,
        Course_Offering_Start_Date__c,
        Offering_End_Date__c,
        hed__Contact__r.QUT_Student_Username__c,
        hed__Contact__c
      FROM hed__Course_Enrollment__c
      WHERE Id IN :crseEnrollIdSet
      AND hed__Contact__r.Registered_Email__c != null
    ];

    // Get Course Connection Course / Program Plan
    for (hed__Course_Enrollment__c crsEnroll : crseEnrollListNew) {
        // Add Course Id to Course Set
        if (String.isNotBlank(crsEnroll.hed__Course_Offering__r.hed__Course__c)) {
          ccCourseSet.add(crsEnroll.hed__Course_Offering__r.hed__Course__c);
        }

        // Add Program Plan Id to Program Plan Set
        if (
          String.isNotBlank(crsEnroll.Program_Offering__r.hed_Program_Plan__c)
        ) {
          ccProgPlanSet.add(crsEnroll.Program_Offering__r.hed_Program_Plan__c);
        }
    }

  

    if(!ccCourseSet.isEmpty() || !ccProgPlanSet.isEmpty()){
        for (Communication_Schedule__c courseCommSched : [
          SELECT Id, Course__c, Email_on_Registration__c,On_Registration_Template__c, Program_Plan__c
          FROM Communication_Schedule__c
          WHERE ( Course__c IN :ccCourseSet 
          OR Program_Plan__c IN :ccProgPlanSet)
        ]) {
          Boolean isEmailOnRegistrationAndCourseNotNull = courseCommSched.Email_on_Registration__c == true && courseCommSched.Course__c != null;
          Boolean isCourseOnRegistrationTemplateNotNull = courseCommSched.Email_on_Registration__c == true && courseCommSched.Course__c != null && String.isNotBlank(courseCommSched.On_Registration_Template__c);
          Boolean isProgramPlanNotNull = courseCommSched.Email_on_Registration__c == true && courseCommSched.Program_Plan__c != null && courseCommSched.Course__c == null;
          Boolean isProgramPlanOnRegistrationTemplateNotNull = courseCommSched.Email_on_Registration__c == true && courseCommSched.Program_Plan__c != null && String.isNotBlank(courseCommSched.On_Registration_Template__c) && courseCommSched.Course__c == null;
          if (isEmailOnRegistrationAndCourseNotNull) {
              courseSendRegEmailMap.put(
              courseCommSched.Course__c,
              courseCommSched.Email_on_Registration__c
            );
           
          }
          if (isCourseOnRegistrationTemplateNotNull) {
            emailTemplateIdSet.add(String.valueOf(courseCommSched.On_Registration_Template__c));
            productEmailTemplateMap.put(courseCommSched.Course__c, String.valueOf(courseCommSched.On_Registration_Template__c));
          }
        
          if(isProgramPlanNotNull){
            progPlanSendRegEmailMap.put(
              courseCommSched.Program_Plan__c,
              courseCommSched.Email_on_Registration__c
            );
          }
          if(isProgramPlanOnRegistrationTemplateNotNull){
            // use custom email template
             emailTemplateIdSet.add(String.valueOf(courseCommSched.On_Registration_Template__c));
             productEmailTemplateMap.put(courseCommSched.Program_Plan__c, courseCommSched.On_Registration_Template__c);
          }
        }
    }

    // Get all email templates for new learners
    if(!emailTemplateIdSet.isEmpty()){
        emailTemplateMap = new Map<Id,EmailTemplate>([
          SELECT Id,
          Name,
          Subject,
          HtmlValue,
          Body
          FROM EmailTemplate
          WHERE Id IN :emailTemplateIdSet
      ]);
    }
    // Get Study Store URL Custom Setting
    Study_Store_URL_Settings__c storeLinkSettings = Study_Store_URL_Settings__c.getOrgDefaults();

    // Process
    List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
    for (hed__Course_Enrollment__c procCrsEnroll : crseEnrollListNew) {
      // Check if Student / Student Program
      if (
        procCrsEnroll.RecordTypeId == STUDENT_RECTYPEID ||
        procCrsEnroll.RecordTypeId == PROG_STUDENT_RECTYPEID
      ) {
        String productName;
        Boolean sendEmail = false;
        Id emailTemplateIdStr;
        Boolean isCourse = String.isNotBlank(procCrsEnroll.hed__Course_Offering__r.hed__Course__c);
        Boolean isCourseAndEmailMapContainsCourse = isCourse && courseSendRegEmailMap.containsKey(procCrsEnroll.hed__Course_Offering__r.hed__Course__c);
        Boolean isCourseAndProductEmailTemplateContainsCourse = isCourse && productEmailTemplateMap.containsKey(procCrsEnroll.hed__Course_Offering__r.hed__Course__c);
        /**Check Course */
        if (isCourse){
            // Set Product Name
            productName = procCrsEnroll.hed__Course_Offering__r.hed__Course__r.Name;
        }
        /**Check Course  &&  Check if Send Registration Email is True for Course */
        if (isCourseAndEmailMapContainsCourse) {
              sendEmail = (Boolean) courseSendRegEmailMap.get(
              procCrsEnroll.hed__Course_Offering__r.hed__Course__c
            );
          } 
        /**Check Course && Resolve email template to use for this course */
        if (isCourseAndProductEmailTemplateContainsCourse){
            emailTemplateIdStr = productEmailTemplateMap.get(procCrsEnroll.hed__Course_Offering__r.hed__Course__c);
        } 
        
        Boolean isProgram = String.isNotBlank(procCrsEnroll.Program_Offering__r.hed_Program_Plan__c);
        Boolean isProgramAndSendRegistrationEmail = isProgram && progPlanSendRegEmailMap.containsKey(procCrsEnroll.Program_Offering__r.hed_Program_Plan__c);
        Boolean isProgramAndProductEmailTemplateContainsProgram = isProgram && productEmailTemplateMap.containsKey(procCrsEnroll.Program_Offering__r.hed_Program_Plan__c);
        /** Check Program */
        if (isProgram){
          // Set Product Name
          productName = procCrsEnroll.Program_Offering__r.hed_Program_Plan__r.Name;
        }
        // Check if Send Registration Email is True for Program Plan
        if (isProgramAndSendRegistrationEmail){
          sendEmail = (Boolean) progPlanSendRegEmailMap.get(
              procCrsEnroll.Program_Offering__r.hed_Program_Plan__c
            );
        }
        if(isProgramAndProductEmailTemplateContainsProgram ){
          emailTemplateIdStr = productEmailTemplateMap.get(procCrsEnroll.Program_Offering__r.hed_Program_Plan__c);
        }
        

        // If Send Email True, Process Single Email
        if (sendEmail == true && String.isNotBlank(emailTemplateIdStr)) {
          EmailTemplate emailTemplate = emailTemplateMap.get(Id.valueOf(emailTemplateIdStr));
          // Set Email values
          String subject = STR_QUTEX + ' ' + productName;
          String fullname =
            procCrsEnroll.hed__Contact__r.FirstName +
            ' ' +
            procCrsEnroll.hed__Contact__r.LastName;

          String paidInFull = String.isNotBlank(procCrsEnroll.Paid_in_Full__c) ? 
            procCrsEnroll.Paid_in_Full__c:'No';

          String amount = String.isNotBlank(String.valueof(procCrsEnroll.Amount__c))?
            String.valueof(procCrsEnroll.Amount__c) : '0.00';

          String startDate = procCrsEnroll.Course_Offering_Start_Date__c != null? 
            procCrsEnroll.Course_Offering_Start_Date__c.format():'';

          String endDate = procCrsEnroll.Offering_End_Date__c != null? 
            procCrsEnroll.Offering_End_Date__c.format() : '';

          // Set Email Params
          Map<String, String> emailParams = new Map<String, String>{
            '{fullname}' => fullname,
            '{name}' => productName,
            '{paid}' => paidInFull,
            '{amount}' => amount,
            '{storeLink}' => storeLinkSettings.Study_Store_Link__c != null
              ? String.valueOf(storeLinkSettings.Study_Store_Link__c)
              : '',
            '{contactFirstName}' => procCrsEnroll.hed__Contact__r.FirstName,
            '{firstName}' => procCrsEnroll.hed__Contact__r.FirstName,
            '{firstname}' => procCrsEnroll.hed__Contact__r.FirstName,
            '{contactLastName}' => procCrsEnroll.hed__Contact__r.LastName,
            '{courseName}' => productName,
            '{courseOfferingName}' => productName,
            '{productName}' => productName,
            '{fullName}' => fullname,
            '{startDate}' => startDate,
            '{startdate}' => startDate,
            '{endDate}' => endDate,
            '{username}' => procCrsEnroll.hed__Contact__r.QUT_Student_Username__c!=null
              ? procCrsEnroll.hed__Contact__r.QUT_Student_Username__c
              : ''
          };

          // Build the Email
          Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
          msg.setToAddresses(new String[]{procCrsEnroll.hed__Contact__r.Registered_Email__c});
          msg.setSubject(subject);
          msg.setHtmlBody(EmailHelper.setBodyValues(emailTemplate.HtmlValue, emailParams, true));
          msg.setOrgWideEmailAddressId(owea[0]?.Id);
          msg.setWhatId(procCrsEnroll.Id);
          msg.setTargetObjectId(procCrsEnroll.hed__Contact__c);
          msg.setSaveAsActivity(true);
          msg.setTreatTargetObjectAsRecipient(false);
          msg.setUseSignature(false);
          
          // Add Email to List
          sendEmailList.add(msg);
        }
      }
    }

    // Send Email only when list it's not empty
    if(!sendEmailList.isEmpty()){
      Messaging.sendEmail(sendEmailList);
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
   * @description Create Session__c records for Diagnostic Tool
   * @param crseEnrollIdSet - set of hed__Course_Enrollment__c record Ids
   */
  private static void createSessionRecordsForDiagnosticTool(Set<Id> crseEnrollIdSet){
    hed__Course_Enrollment__c courseConnection = new hed__Course_Enrollment__c();
    Id diagnosticToolRecTypeId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName()
                                            .get(Label.RT_ProductRequest_Diagnostic_Tool)
                                            .getRecordTypeId();
    Id specialisedSessionRecTypeId = Schema.SObjectType.Session__c.getRecordTypeInfosByDeveloperName()
                                            .get(Label.RT_Session_Specialised_Session)
                                            .getRecordTypeId();
    List<Session__c> sessionList = new List<Session__c>();
    Map<Id, hed__Course_Offering__c> courseOfferingRecTypeMap = new Map<Id, hed__Course_Offering__c>();
    Map<Id, Program_Offering__c> programOfferingRecTypeMap = new Map<Id, Program_Offering__c>();

    // query course connection records
    Map<Id, hed__Course_Enrollment__c> courseConnectionMap 
              = new Map<Id, hed__Course_Enrollment__c>([SELECT Id,
                                                              hed__Contact__r.Name,
                                                              hed__Course_Offering__c,
                                                              Program_Offering__c
                                                        FROM hed__Course_Enrollment__c
                                                        WHERE Id IN :crseEnrollIdSet]);

    // get course offering and program offering Ids from course connection records
    Set<Id> courseOfferingIdSet = new Set<Id>();
    Set<Id> programOfferingIdSet = new Set<Id>();
    for(Id key : courseConnectionMap.keySet()){
      courseConnection = courseConnectionMap.get(key);

      //course offering id
      if(!String.isBlank(courseConnection.hed__Course_Offering__c)){
        courseOfferingIdSet.add(courseConnection.hed__Course_Offering__c);
      }

      //program offering id
      if(!String.isBlank(courseConnection.Program_Offering__c)){
        programOfferingIdSet.add(courseConnection.Program_Offering__c);
      }
    }

    //course offering records map
    if(!courseOfferingIdSet.isEmpty()){
      courseOfferingRecTypeMap = new Map<Id, hed__Course_Offering__c>([
        SELECT Id, hed__Course__r.ProductRequestID__r.RecordTypeId 
        FROM hed__Course_Offering__c 
        WHERE Id IN :courseOfferingIdSet]);
    }
    
                                         
    //program offering records map
    if(!programOfferingIdSet.isEmpty()){
      programOfferingRecTypeMap = new Map<Id, Program_Offering__c>([
        SELECT Id, hed_Program_Plan__r.Product_Request__r.RecordTypeId 
        FROM Program_Offering__c 
        WHERE Id IN :programOfferingIdSet]);
    }
    
    // Loop through each course connection record and check those registered to a Diagnostic Tool product request
    for(Id learnerId : courseConnectionMap.keySet()){
      courseConnection = courseConnectionMap.get(learnerId);
      Id recordTypeId;

      if(!String.isBlank(courseConnection.hed__Course_Offering__c)){
        if(courseOfferingRecTypeMap.containsKey(courseConnection.hed__Course_Offering__c)){
          recordTypeId = courseOfferingRecTypeMap.get(courseConnection.hed__Course_Offering__c)
                                                .hed__Course__r.ProductRequestID__r.RecordTypeId;
        }
      }

      if(!String.isBlank(courseConnection.Program_Offering__c)){
        if(programOfferingRecTypeMap.containsKey(courseConnection.Program_Offering__c)){
          recordTypeId = programOfferingRecTypeMap.get(courseConnection.Program_Offering__c)
                                                  .hed_Program_Plan__r.Product_Request__r.RecordTypeId;
        }
      }

      if(recordTypeId == diagnosticToolRecTypeId){
        Session__c session = new Session__c();
        session.Course_Connection__c = learnerId;
        session.Name = courseConnectionMap.get(learnerId).hed__Contact__r.Name;
        session.Session_Status__c = null;
        session.Completion_Date__c = null;
        session.Course_Offering__c = courseConnectionMap.get(learnerId).hed__Course_Offering__c;
        session.RecordTypeId = specialisedSessionRecTypeId;
        sessionList.add(session);
      }
    }//end of for loop

    if(!sessionList.isEmpty()){
      insert sessionList;
    }
  }
}