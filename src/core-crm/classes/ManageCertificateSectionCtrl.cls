/**
 * @description Controller Class for manageCertificateSection LWC
 * @see ../lwc/manageCertificateSection
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | February 14, 2022     | DEPP-1560            | Created file                 | 
      | eccarius.karl.munoz       | March 31, 2022        | DEPP-1560            | Added method for PDF         | 
      |                           |                       |                      | Generation                   | 
      | roy.nino.s.regala         | May 02, 2022          | DEPP-1478            |                              | 
      | eccarius.karl.munoz       | May 03, 2022          | DEPP-2314            | Handling for Program Presc.  |
 */
public with sharing class ManageCertificateSectionCtrl {
     
     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
     private static Id studentProgramRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentProgramRT).getRecordTypeId();
     
     /**
      * @description Retrieves list of certificate details of students for Non Program Plan
      * @param offeringId - offering id of the product
      * @return List of ManageCertificateDetails
      */
      @AuraEnabled(cacheable=true)
      public static List<ManageCertificateDetails> getCertificateDetails(String offeringId, Boolean prescribedProgram){
          List<ManageCertificateDetails> response = new List<ManageCertificateDetails>();          

          String certificateType = '';
          Date offeringStartDate = null;
          Date offeringEndDate = null;

          if(!prescribedProgram){
               List<hed__Course_Offering__c> offerings = [
                    SELECT Id, hed__Course__r.Certificate_Type__c, hed__Start_Date__c, hed__End_Date__c 
                      FROM hed__Course_Offering__c 
                     WHERE Id = : offeringId 
               ];    
               for(hed__Course_Offering__c offering : offerings){
                    certificateType = offering.hed__Course__r.Certificate_Type__c;
                    offeringStartDate = offering.hed__Start_Date__c;
                    offeringEndDate = offering.hed__End_Date__c;
               }               
          }else{
               List<Program_Offering__c> offerings = [
                    SELECT Id, hed_Program_Plan__r.Certificate_Type__c, Start_Date__c, End_Date__c 
                      FROM Program_Offering__c 
                     WHERE Id = : offeringId 
               ]; 
               for(Program_Offering__c offering : offerings){
                    certificateType = offering.hed_Program_Plan__r.Certificate_Type__c;
                    offeringStartDate = offering.Start_Date__c;
                    offeringEndDate = offering.End_Date__c;  
               }               
          }    

          if(offeringId == null){
               return new List<ManageCertificateDetails>();
          }
                    
          List<Questionnaire_Response_Summary__c> questionnaireResponseList = [
               SELECT Id, Name, Contact__c, Course_Offering__c, Questionnaire__c, Questionnaire__r.Questionnaire_Type__c, Registration_Status__c 
                 FROM Questionnaire_Response_Summary__c 
                WHERE (Course_Offering__c =: offeringId OR Program_Offering__c  =: offeringId)
          ];

          Map<Id, Questionnaire_Response_Summary__c> qrsMap = new Map<Id, Questionnaire_Response_Summary__c>();
          for(Questionnaire_Response_Summary__c qrs : questionnaireResponseList){
               qrsMap.put(qrs.Contact__c, qrs);
          }

          List<hed__Course_Enrollment__c > courseConnections = [
               SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Contact__r.Registered_Email__c, hed__Course_Offering__c, Paid_in_Full__c, 
                    hed__Status__c, Marks__c, Marks_Description__c, hed__Course_Offering__r.hed__Course__r.Name, Program_Offering__r.hed_Program_Plan__r.Name
                 FROM hed__Course_Enrollment__c 
                WHERE RecordTypeId IN (:studentRecTypeId, :studentProgramRecTypeId) 
                AND (hed__Course_Offering__c =: offeringId OR (Program_Offering__c  =: offeringId AND hed__Course_Offering__c = null )) 
                AND (hed__Status__c = 'Active' OR (hed__Status__c = 'Completed'))
          ];

          Map<Id, hed__Course_Enrollment__c> crsconnMap = new Map<Id, hed__Course_Enrollment__c>();
          for(hed__Course_Enrollment__c cc : courseConnections){
               crsconnMap.put(cc.hed__Contact__c, cc);
          }

          for(Id learnerId : crsconnMap.keySet()){
               ManageCertificateDetails certDetails = new ManageCertificateDetails();
               certDetails.id = crsconnMap.get(learnerId).Id;
               certDetails.contactFullName = crsconnMap.get(learnerId).hed__Contact__r.Name;
               certDetails.contactEmail = crsconnMap.get(learnerId).hed__Contact__r.Registered_Email__c;
               certDetails.registrationStatus = crsconnMap.get(learnerId).hed__Status__c; 
               certDetails.marks = crsconnMap.get(learnerId).Marks__c;
               certDetails.marksDesc = crsconnMap.get(learnerId).Marks_Description__c;
               if(prescribedProgram){
                    certDetails.courseName = crsconnMap.get(learnerId).Program_Offering__r.hed_Program_Plan__r.Name;
               }else{
                    certDetails.courseName = crsconnMap.get(learnerId).hed__Course_Offering__r.hed__Course__r.Name;
               }
               
               certDetails.certificateType = certificateType;
               String stDateString = offeringStartDate.format();
               certDetails.startDate = stDateString;
               String enDateString = offeringEndDate.format();
               certDetails.endDate = enDateString;   
               response.add(certDetails);
          }
          return response;
     }

     /**
      * @description Updates the students' Marks record
      * @param data - List of ManageCertificateDetails
      * @return String
      */
     @AuraEnabled
     public static String updateCourseConnDetails(Object data, String programOfferingId){ 
          List<hed__Course_Enrollment__c> dataToUpdate = new List<hed__Course_Enrollment__c>();          

          Set<Id> enrolmentIds = new Set<Id>();
          
          List<ManageCertificateDetails> wrapperList = (List<ManageCertificateDetails>) JSON.deserialize(
               JSON.serialize(data),
               List<ManageCertificateDetails>.class
          );

          for(ManageCertificateDetails recordFromList : wrapperList){
               enrolmentIds.add(recordFromList.id);
          }

          Map<Id, Id> studentMap = new Map<Id, Id>();
          List<hed__Course_Enrollment__c> studentList = [SELECT Id, hed__Contact__c, Marks__c FROM hed__Course_Enrollment__c WHERE Program_Offering__c =: programOfferingId AND Id IN:enrolmentIds];
          for(hed__Course_Enrollment__c student : studentList){
               studentMap.put(student.Id, student.hed__Contact__c);
          }

          Map<Id, Decimal> recordMap = new Map<Id, Decimal>();
          for(ManageCertificateDetails recordFromList : wrapperList){
               hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();               
               if(recordFromList.marks != null){
                    student.Id = recordFromList.id;
                    student.Marks__c = recordFromList.marks;
                    dataToUpdate.add(student);
                    recordMap.put(studentMap.get(recordFromList.id), recordFromList.marks);
               }  
          }

          if(programOfferingId != ''){
               List<hed__Course_Enrollment__c> students = [SELECT Id, hed__Contact__c, Marks__c FROM hed__Course_Enrollment__c WHERE hed__Course_Offering__c != NULL AND Program_Offering__c =: programOfferingId];
               for(hed__Course_Enrollment__c student : students){
                    if(recordMap.containsKey(student.hed__Contact__c)){
                         hed__Course_Enrollment__c learner = new hed__Course_Enrollment__c();
                         learner.Id = student.id;
                         learner.Marks__c = recordMap.get(student.hed__Contact__c);
                         dataToUpdate.add(learner);
                    }                               
               }
          }   

          try {
               update dataToUpdate;
               return 'Success';
          }
          catch (Exception e) {
               return 'The following exception has occurred: ' + e.getMessage();
          }
     } 

     /**
      * @description Sends the certificate to the students email
      * @param data - List of ManageCertificateDetails
      * @return String
      */
     @AuraEnabled
     public static String sendEmail(Object data){
          String response = '';
          try{                            
               List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='QUTeX' LIMIT 1];
               List<ManageCertificateDetails> wrapperList = (List<ManageCertificateDetails>) JSON.deserialize(
                    JSON.serialize(data),
                    List<ManageCertificateDetails>.class
               );   
               String type = '';  
               Map<Id, ManageCertificateDetails> dataMap = new Map<Id, ManageCertificateDetails>();
               for(ManageCertificateDetails certDetails : wrapperList){
                    dataMap.put(certDetails.id, certDetails);
                    type = certDetails.certificateType;
               }    
               //check if data is more than 14
               if(dataMap.keySet().size() > 14){
                    SendCertificateBatch objbatch = new SendCertificateBatch();
                    objbatch.courseConnectionIds = dataMap.keySet();   
                    Database.executeBatch(objbatch, 14);
                    response = 'Success';
               }else{
                    if(type == null){ return 'No Certificate Type'; }
     
                    EmailTemplate coverTemplate = getEmailTemplate('Send Certificate');   
                    EmailTemplate attachTemplate = getEmailTemplate(type);
                    Study_Store_URL_Settings__c storeLinkSettings = Study_Store_URL_Settings__c.getOrgDefaults();
                    if(coverTemplate != null){                    
                         List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                         Map <Id, ContentVersion> pdfContentMap = new Map <Id, ContentVersion>();
                         for(ID id : dataMap.keySet()){
                              ManageCertificateDetails certDetails = dataMap.get(id);
                              String mailSubject = 'QUTeX - ' + certDetails.courseName;
                              Map<String, String> coverEmailParams = new Map<String, String> {
                                   '{name}' => certDetails.contactFullName,
                                   '{storeLink}' => storeLinkSettings.Study_Store_Link__c != null? String.valueOf(storeLinkSettings.Study_Store_Link__c) : ''
                              };
                              pdfContentMap.putAll(createPDF(id, certDetails, attachTemplate));
                              Blob pdfContent = pdfContentMap.get(id).VersionData;
                              Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                              msg.setToAddresses(new String[]{certDetails.contactEmail});
                              msg.setSubject(mailSubject);
                              msg.setHtmlBody(EmailHelper.setBodyValues(coverTemplate.HtmlValue, coverEmailParams, true));
                              msg.setOrgWideEmailAddressId(owea[0].Id);
                              msg.setTreatTargetObjectAsRecipient(false);
                              msg.setUseSignature(false);
                              Messaging.EmailFileAttachment attachment = attachmentBuilder(type + '.pdf', pdfContent);  
                              msg.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });          
                              emailList.add(msg);  
                         }
     
                         insert pdfContentMap.values();
     
                         List<ContentVersion> contentVersionList = [SELECT PathOnClient, ContentDocumentId, VersionData FROM ContentVersion WHERE Id IN : pdfContentMap.values()];
     
                         Map <String,ContentVersion> content2 = new Map <String,ContentVersion>();
                         for(ContentVersion contentVersion : contentVersionList){
                              content2.put(contentVersion.PathOnClient, contentVersion);
                         }
     
                         List<ContentDocumentLink> contentDocuLinkList = new List<ContentDocumentLink>();
                         for(ID id : pdfContentMap.keySet()){
                              ContentDocumentLink contentDocuLink = new ContentDocumentLink();
                              contentDocuLink.LinkedEntityId = id;
                              contentDocuLink.ContentDocumentId = content2.get(pdfContentMap.get(id).PathOnClient).ContentDocumentId;
                              contentDocuLink.ShareType = 'I';
                              contentDocuLink.Visibility = 'AllUsers';
                              contentDocuLinkList.add(contentDocuLink);
                         }
     
                         insert contentDocuLinkList;
     
                         if(!emailList.isEmpty()){
                              Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                              if (results[0].success) {
                                   response = 'Success';
                              } else {
                                   response = 'Failed';
                              }
                          }else{
                              response = 'No emails to be sent';
                          }      
                    }
               }
               

          }catch(Exception e){
               response = 'Response: ' +  response + 'Error: ' + e.getMessage();
          }
          return response;
     }

     private static Map<Id, ContentVersion> createPDF(Id id, ManageCertificateDetails certDetails, EmailTemplate attachTemplate){
          Map<Id, ContentVersion> responseMap = new Map<Id, ContentVersion>();
          String type = certDetails.certificateType;  
          String certOfParticipation = 'Certificate of Participation';
          PageReference pdf;
          if(type == certOfParticipation){
               pdf = new PageReference(
                    '/apex/CertificateOfParticipationPDFView?courseConnectionId=' +
                    id
               );
          }else{
               pdf = new PageReference(
                    '/apex/CertificateOfAchievementPDFView?courseConnectionId=' +
                    id
               );
          }

          ContentVersion contentVersion = new ContentVersion();
          contentVersion.ContentLocation = 'S';
          contentVersion.PathOnClient = id + '-' + type + '.pdf';
          contentVersion.Title = type;
          if(Test.isRunningTest()) { 
               contentVersion.VersionData = blob.valueOf('Unit.Test');
          } else {
               contentVersion.VersionData = pdf.getContent();
          }
          responseMap.put(id, contentVersion);
          return responseMap;
     }

     /**
      * @description Returns content document id to preview the certificate of the student
      * @param data - List of ManageCertificateDetails
      * @return Id
      */
     @AuraEnabled
     public static Id previewPdf(Object data){
          Id response = null;

          List<ManageCertificateDetails> wrapperList = (List<ManageCertificateDetails>) JSON.deserialize(
               JSON.serialize(data),
               List<ManageCertificateDetails>.class
          );   

          ManageCertificateDetails certDetails = null; 
          Id recId = null;
          String type= '';
          for(ManageCertificateDetails manageCertDetails : wrapperList){
               certDetails = manageCertDetails;
               recId = manageCertDetails.id;
               type = manageCertDetails.certificateType;
          }

          EmailTemplate attachTemplate = getEmailTemplate(type);

          Map<Id, ContentVersion> contentMap = createPDF(recId, certDetails, attachTemplate);
          insert contentMap.values();

          List<ContentVersion> contentVersionList = [SELECT PathOnClient, ContentDocumentId, VersionData FROM ContentVersion WHERE Id IN : contentMap.values()];
          List<ContentDocumentLink> contentDocuLinkList = new List<ContentDocumentLink>();
          for(ContentVersion contentVersion : contentVersionList){
               ContentDocumentLink contentDocuLink = new ContentDocumentLink();
               contentDocuLink.LinkedEntityId = recId;
               contentDocuLink.ContentDocumentId = contentVersion.ContentDocumentId;
               contentDocuLink.ShareType = 'I';
               contentDocuLink.Visibility = 'AllUsers';
               contentDocuLinkList.add(contentDocuLink);

               response = contentVersion.ContentDocumentId;
          }
          insert contentDocuLinkList;

          return response;
     }

     private static String setBodyValues(String body, Map<String,String> params){
          if(params!=null && params.size()>0){
               for(String key : params.keySet()){
                    string val = params.get(key);
                    body = body.replace(key,val);
               }
          }
          return body;
     } 

     private static Messaging.EmailFileAttachment attachmentBuilder(String fileName, Blob emailContent){
          Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
          try{
               attach.setContentType('application/pdf');
               attach.setFileName(fileName);
               attach.setInline(true);
               attach.Body = emailContent;
          }catch(Exception e){
               Logger.error('Exception caught in method attachmentBuilder in class ManageCertificatSectionCtrl.')
                    .setExceptionDetails(e);
               attach = new Messaging.EmailFileAttachment();
          } finally {
               if(Logger.getBufferSize() > 0) {
                    Logger.saveLog();
               }
          }
          
          return attach;
     }

     private static EmailTemplate getEmailTemplate(String name){  
          return [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name =: name LIMIT 1];
     }

     /**
      * @description Wrapper class that holds data to be displayed
      */
     public class ManageCertificateDetails{
          @AuraEnabled
          public String id;
          @AuraEnabled
          public String contactFullName;
          @AuraEnabled
          public String contactEmail;
          @AuraEnabled
          public String registrationStatus;
          @AuraEnabled
          public Decimal marks;
          @AuraEnabled
          public String marksDesc;
          @AuraEnabled
          public String courseName;
          @AuraEnabled
          public String certificateType;
          @AuraEnabled
          public String endDate;
          @AuraEnabled
          public String startDate;
     }   
}