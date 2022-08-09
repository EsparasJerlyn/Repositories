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

*/
public without sharing class CourseConnectionTriggerHandler implements Disableable, BeforeInsert, AfterInsert, AfterUpdate, AfterDelete {
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

    try{
      // Trigger Send Email on Registration Confirmation
      sendRegistrationConfirmEmail(newItems.keySet());
      sendWelcomeEmail(newItems.keySet());
    } catch(Exception e){
      System.debug('Sending of Registration Email fail, see error: ' + e.getMessage());
    }
    
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
      System.debug(LoggingLevel.DEBUG, e); //NOPMD
    }
  }

  /**
   * @description Sends Welcome Email on New Course Connections with QUT Student Username
   * @param crseEnrollListNew - List of hed__Course_Enrollment__c.Trigger.new
   */
  public void sendWelcomeEmail(Set<Id> crseEnrollIdSet){

    Set<Id> programOfferingIdSet = new Set<Id>();
    Set<Id> courseOfferingIdSet = new Set<Id>();

    // Query Course Connection Details based on the Contact Id
    //Id: hed__Course_Offering__c or Program_Offering__c
    Map<Id, hed__Course_Enrollment__c> productCourseConnectionMap = new Map<Id, hed__Course_Enrollment__c>();
    for(hed__Course_Enrollment__c courseConnection : [ SELECT
                                                        Id,
                                                        hed__Course_Offering__c,
                                                        Program_Offering__c,
                                                        hed__Contact__c,
                                                        Program_Offering__r.hed_Program_Plan__r.Id,
                                                        Program_Offering__r.hed_Program_Plan__c,
                                                        hed__Course_Offering__r.hed__Course__r.Id,
                                                        hed__Course_Offering__r.hed__Course__c
                                                      FROM hed__Course_Enrollment__c
                                                      WHERE Id IN :crseEnrollIdSet
                                                      AND RecordTypeId = :STUDENT_RECTYPEID
                                                      AND hed__Contact__r.Registered_Email__c != null
                                                      AND hed__Contact__r.QUT_Student_Username__c != null]){

      if(String.isNotBlank(courseConnection.Program_Offering__r.hed_Program_Plan__c)){
        productCourseConnectionMap.put(courseConnection.Program_Offering__r.hed_Program_Plan__r.Id, courseConnection);
      }

      if(String.isNotBlank(courseConnection.hed__Course_Offering__r.hed__Course__c)){
        productCourseConnectionMap.put(courseConnection.hed__Course_Offering__r.hed__Course__r.Id, courseConnection);
      }

      //Populate the Offering Sets based on the course connection
      if(String.isNotBlank(courseConnection.Program_Offering__c)){
        programOfferingIdSet.add(courseConnection.Program_Offering__c);
      }else if(String.isNotBlank(courseConnection.hed__Course_Offering__c)){
        courseOfferingIdSet.add(courseConnection.hed__Course_Offering__c);
      }
    }

    Set<Id> programPlanIdSet = new Set<Id>();
    Set<Id> courseIdSet = new Set<Id>();

    //Query Program Offering to get valid Offerings based on status and Start Date
    List<Program_Offering__c> programOfferings = [
      SELECT 
        Id , 
        hed_Program_Plan__c
      FROM Program_Offering__c
      WHERE Id IN: programOfferingIdSet 
      AND Start_Date__c < TODAY
      AND IsActive__c = true
    ];

    //Query Course Offering
    List<hed__Course_Offering__c> courseOfferings = [
      SELECT Id,
      hed__Course__c 
      FROM hed__Course_Offering__c
      WHERE Id IN: courseOfferingIdSet
      AND hed__Start_Date__c < TODAY
      AND IsActive__c = true
    ];

    // Populate the Course/ProgramPlan Set based on the offering.
    for(Program_Offering__c programOffering : programOfferings){
      if(String.isNotBlank(programOffering.hed_Program_Plan__c )){
        programPlanIdSet.add(programOffering.hed_Program_Plan__c);
      }
    }

    for(hed__Course_Offering__c courseOffering : courseOfferings){
      if(String.isNotBlank(courseOffering.hed__Course__c)){
        courseIdSet.add(courseOffering.hed__Course__c);
      }
    }

    Set<Id> validContactForEmail = new Set<Id>();
    // Query Product based on the ProgramPlan/Course
    //PROGRAM PLAN
    for(Product2 product : [SELECT Id,
                                    Program_Plan__c
                              FROM Product2
                              WHERE Delivery__c INCLUDES ('Online Self-paced')
                                AND Program_Plan__c IN: programPlanIdSet]){
      if(productCourseConnectionMap.containsKey(product.Program_Plan__c)){
        validContactForEmail.add(productCourseConnectionMap.get(product.Program_Plan__c).hed__Contact__c);
      }                    
    }
    //COURSE
    for(Product2 product : [SELECT Id,
                                  Course__c
                            FROM Product2
                            WHERE Delivery__c INCLUDES ('Online Self-paced')
                            AND Course__c IN : courseIdSet]){
      if(productCourseConnectionMap.containsKey(product.Course__c)){
        validContactForEmail.add(productCourseConnectionMap.get(product.Course__c).hed__Contact__c);
      }                    
    }

    ContactUserNameCreatedHelper.sendEmailUsernameCreated(validContactForEmail);
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
        hed__Contact__r.QUT_Student_Username__c
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

    // Set Map for Course Send Registration Email
    Map<Id, Boolean> courseSendRegEmailMap = new Map<Id, Boolean>();
    for (Communication_Schedule__c courseCommSched : [
      SELECT Id, Course__c, Email_on_Registration__c,On_Registration_Template__c
      FROM Communication_Schedule__c
      WHERE Course__c IN :ccCourseSet
    ]) {
      if (courseCommSched.Email_on_Registration__c == true) {
        courseSendRegEmailMap.put(
          courseCommSched.Course__c,
          courseCommSched.Email_on_Registration__c
        );

        if(String.isNotBlank(courseCommSched.On_Registration_Template__c)){
          // use custom email template
          emailTemplateIdSet.add(String.valueOf(courseCommSched.On_Registration_Template__c));
          productEmailTemplateMap.put(courseCommSched.Course__c, String.valueOf(courseCommSched.On_Registration_Template__c));
        }
      }
    }

    // Get List of Communication Schedule for Program Plan
    Map<Id, Boolean> progPlanSendRegEmailMap = new Map<Id, Boolean>();
    for (Communication_Schedule__c courseCommSched : [
      SELECT Id, Program_Plan__c, Email_on_Registration__c,On_Registration_Template__c
      FROM Communication_Schedule__c
      WHERE Program_Plan__c IN :ccProgPlanSet
    ]) {
      if (courseCommSched.Email_on_Registration__c == true) {
        progPlanSendRegEmailMap.put(
          courseCommSched.Program_Plan__c,
          courseCommSched.Email_on_Registration__c
        );

        if(String.isNotBlank(courseCommSched.On_Registration_Template__c)){
          // use custom email template
          emailTemplateIdSet.add(String.valueOf(courseCommSched.On_Registration_Template__c));
          productEmailTemplateMap.put(courseCommSched.Program_Plan__c, courseCommSched.On_Registration_Template__c);
        }
      }
    }

    // Get all email templates for new learners
    Map<Id,EmailTemplate> emailTemplateMap = new Map<Id,EmailTemplate>([SELECT Id,
                                                                              Name,
                                                                              Subject,
                                                                              HtmlValue,
                                                                              Body
                                                                        FROM EmailTemplate
                                                                        WHERE Id IN :emailTemplateIdSet]);

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

        /**Check Course */
        if (
          String.isNotBlank(
            procCrsEnroll.hed__Course_Offering__r.hed__Course__c
          )
        ) {
          // Set Product Name
          productName = procCrsEnroll.hed__Course_Offering__r.hed__Course__r.Name;

          // Check if Send Registration Email is True for Course
          if (
            courseSendRegEmailMap.containsKey(
              procCrsEnroll.hed__Course_Offering__r.hed__Course__c
            )
          ) {
            sendEmail = (Boolean) courseSendRegEmailMap.get(
              procCrsEnroll.hed__Course_Offering__r.hed__Course__c
            );
          }

          // Resolve email template to use for this course
          if(productEmailTemplateMap.containsKey(procCrsEnroll.hed__Course_Offering__r.hed__Course__c)){
            emailTemplateIdStr = productEmailTemplateMap.get(procCrsEnroll.hed__Course_Offering__r.hed__Course__c);
          }
        }

        /** Check Program */
        if (
          String.isNotBlank(
            procCrsEnroll.Program_Offering__r.hed_Program_Plan__c
          )
        ) {
          // Set Product Name
          productName = procCrsEnroll.Program_Offering__r.hed_Program_Plan__r.Name;

          // Check if Send Registration Email is True for Program Plan
          if (
            progPlanSendRegEmailMap.containsKey(
              procCrsEnroll.Program_Offering__r.hed_Program_Plan__c
            )
          ) {
            sendEmail = (Boolean) progPlanSendRegEmailMap.get(
              procCrsEnroll.Program_Offering__r.hed_Program_Plan__c
            );
          }

          // Resolve email template to use for this program
          if(productEmailTemplateMap.containsKey(procCrsEnroll.Program_Offering__r.hed_Program_Plan__c)){
            emailTemplateIdStr = productEmailTemplateMap.get(procCrsEnroll.Program_Offering__r.hed_Program_Plan__c);
          }
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

          String paidInFull = 'No';
          if (String.isNotBlank(procCrsEnroll.Paid_in_Full__c)) {
            paidInFull = procCrsEnroll.Paid_in_Full__c;
          }

          String amount = '0.00';
          if (String.isNotBlank(String.valueof(procCrsEnroll.Amount__c))) {
            amount = String.valueof(procCrsEnroll.Amount__c);
          }

          String startDate = '';
          if(procCrsEnroll.Course_Offering_Start_Date__c != null){
              startDate = procCrsEnroll.Course_Offering_Start_Date__c.format();
          }

          String endDate = '';
          if(procCrsEnroll.Offering_End_Date__c != null){
              endDate = procCrsEnroll.Offering_End_Date__c.format();
          }

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
          Messaging.SingleEmailMessage mail = EmailHelper.emailBuilder(
            procCrsEnroll.hed__Contact__r.Registered_Email__c,
            subject,
            emailTemplate.HtmlValue,
            emailParams
          );

          // Set Org Wide Email Address
          if (!owea.isEmpty()) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
          }

          // Add Email to List
          sendEmailList.add(mail);
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
}