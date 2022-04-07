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
      |                           |                       |                      |                              | 
 */
public with sharing class ManageCertificateSectionCtrl {
     
     private static string studentRT = System.Label.RT_CourseConnection_Student;
     private static Id studentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByDeveloperName().get(studentRT).getRecordTypeId();
     /**
      * @description Retrieves list of certificate details of students
      * @param prodReqId - Record ID from record page
      * @param offeringId - offering id of the product
      * @return List of ManageCertificateDetails
      */
     @AuraEnabled(cacheable=true)
     public static List<ManageCertificateDetails> getCertificateDetails(String prodReqId, String offeringId){  
          return getNonProgPlanCerts(prodReqId, offeringId); 
     }

     /**
      * @description Retrieves list of certificate details of students for Non Program Plan
      * @param prodReqId - Record ID from record page
      * @param offeringId - offering id of the product
      * @return List of ManageCertificateDetails
      */
     private static List<ManageCertificateDetails> getNonProgPlanCerts(String prodReqId, String offeringIdd){
          List<ManageCertificateDetails> response = new List<ManageCertificateDetails>();          

          List<hed__Course_Offering__c> offerings = [
               SELECT Id, hed__Course__r.Certificate_Type__c, hed__Start_Date__c, hed__End_Date__c 
                 FROM hed__Course_Offering__c 
                WHERE Id = : offeringIdd ];                

          Id offeringId = offerings[0].Id;
          String certificateType = offerings[0].hed__Course__r.Certificate_Type__c;
          Date offeringStartDate = offerings[0].hed__Start_Date__c;
          Date offeringEndDate = offerings[0].hed__End_Date__c;

          if(offeringId == null){
               return new List<ManageCertificateDetails>();
          }
                    
          List<Questionnaire_Response_Summary__c> questionnaireResponseList = [
               SELECT Id, Name, Contact__c, Course_Offering__c, Questionnaire__c, Questionnaire__r.Questionnaire_Type__c, Registration_Status__c 
                 FROM Questionnaire_Response_Summary__c 
                WHERE Course_Offering__c =: offeringId AND Registration_Status__c = 'Confirmed'
          ];
          Map<Id, Questionnaire_Response_Summary__c> qrsMap = new Map<Id, Questionnaire_Response_Summary__c>();
          for(Questionnaire_Response_Summary__c qrs : questionnaireResponseList){
               qrsMap.put(qrs.Contact__c, qrs);
          }

          List<hed__Course_Enrollment__c > courseConnections = [
               SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Contact__r.Email, hed__Course_Offering__c, Paid_in_Full__c, 
                    hed__Status__c, Marks__c, Marks_Description__c, hed__Course_Offering__r.hed__Course__r.Name
                 FROM hed__Course_Enrollment__c 
                WHERE hed__Course_Offering__c =: offeringId AND RecordTypeId =: studentRecTypeId
          ];
          Map<Id, hed__Course_Enrollment__c> crsconnMap = new Map<Id, hed__Course_Enrollment__c>();
          for(hed__Course_Enrollment__c cc : courseConnections){
               crsconnMap.put(cc.hed__Contact__c, cc);
          }

          for(Id learnerId : crsconnMap.keySet()){
               if(qrsMap.containsKey(learnerId)){
                    ManageCertificateDetails certDetails = new ManageCertificateDetails();
                    certDetails.id = crsconnMap.get(learnerId).Id;
                    certDetails.contactFullName = crsconnMap.get(learnerId).hed__Contact__r.Name;
                    certDetails.contactEmail = crsconnMap.get(learnerId).hed__Contact__r.Email;
                    certDetails.registrationStatus = qrsMap.get(learnerId).Registration_Status__c;    
                    certDetails.marks = crsconnMap.get(learnerId).Marks__c;
                    certDetails.marksDesc = crsconnMap.get(learnerId).Marks_Description__c;
                    certDetails.courseName = crsconnMap.get(learnerId).hed__Course_Offering__r.hed__Course__r.Name;
                    certDetails.certificateType = certificateType;
                    String stDateString = offeringStartDate.format();
                    certDetails.startDate = stDateString;
                    String enDateString = offeringEndDate.format();
                    certDetails.endDate = enDateString;   
                    response.add(certDetails);
               }
          }
          
          return response;
     }

     /**
      * @description Updates the students' Marks record
      * @param data - List of ManageCertificateDetails
      * @return String
      */
     @AuraEnabled
     public static String updateCourseConnDetails(Object data){ 
          List<hed__Course_Enrollment__c> dataToUpdate = new List<hed__Course_Enrollment__c>();          
          List<ManageCertificateDetails> wrapperList = (List<ManageCertificateDetails>) JSON.deserialize(
               JSON.serialize(data),
               List<ManageCertificateDetails>.class
          );

          for(ManageCertificateDetails recordFromList : wrapperList){
               hed__Course_Enrollment__c student = new hed__Course_Enrollment__c();               
               if(recordFromList.marks != null){
                    student.Id = recordFromList.id;
                    student.Marks__c = recordFromList.marks;
                    dataToUpdate.add(student);
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

               if(type == null){ return 'No Certificate Type'; }

               List<Id> contentDocumentIdList = new List<Id>();
               Map<Id, ContentDocumentLink> contentDocumentMap = new Map <Id, ContentDocumentLink>();
               List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : dataMap.keySet()];
               for(ContentDocumentLink contentDocument : contentDocumentList){
                    contentDocumentMap.put(contentDocument.ContentDocumentId, contentDocument);
                    contentDocumentIdList.add(contentDocument.ContentDocumentId);
               }
               removePDF(contentDocumentIdList);

               EmailTemplate coverTemplate = getEmailTemplate('Send Certificate');   
               EmailTemplate attachTemplate = getEmailTemplate(type);

               if(coverTemplate != null){                    
                    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                    Map <Id, ContentVersion> pdfContentMap = new Map <Id, ContentVersion>();
                    for(ID id : dataMap.keySet()){
                         ManageCertificateDetails certDetails = dataMap.get(id);
                         String mailSubject = 'QUTeX - ' + certDetails.courseName;
                         Map<String, String> coverEmailParams = new Map<String, String> {
                              '{coursename}' => certDetails.courseName,  
                              '{name}' => certDetails.contactFullName
                         };
                         pdfContentMap.putAll(createPDF(id, certDetails, attachTemplate));
                         Blob pdfContent = pdfContentMap.get(id).VersionData;
                         Messaging.SingleEmailMessage mail = emailBuilder(certDetails.contactEmail, mailSubject, coverTemplate.HtmlValue, coverEmailParams);
                         Messaging.EmailFileAttachment attachment = attachmentBuilder(type + '.pdf', pdfContent);  
                         mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });                         
                         emailList.add(mail);  
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
                         contentDocuLink.shareType = 'V';
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

          }catch(Exception e){
               response = 'Response: ' +  response + 'Error: ' + e.getMessage();
          }          
          return response;
     }

     private static void removePDF(List<Id> contentDocumentIdList){
          List<ContentDocument> contentDocument = [SELECT Id FROM ContentDocument Where Id IN : contentDocumentIdList];
          try{
               delete contentDocument;
          }catch(Exception e){
               throw new AuraHandledException(e.getMessage());
          }          
     }

     private static Map<Id, ContentVersion> createPDF(Id id, ManageCertificateDetails certDetails, EmailTemplate attachTemplate){
          Map<Id, ContentVersion> responseMap = new Map<Id, ContentVersion>();
          String type = certDetails.certificateType;  
          String certOfParticipation = 'Certificate of Participation';
          String certOfAchievement = 'Certificate of Achievement';
          Date dt = date.today();
          String dateTodayString = dt.format();
          
          Blob strPdfBody = null;
          if (type == certOfParticipation){               
               Map<String, String> attachmentParams = new Map<String, String> {
                    '{courseName}' => certDetails.courseName, 
                    '{fullName}' => certDetails.contactFullName,
                    '{facilitator}' => certDetails.contactFullName,
                    '{dateToday}' => dateTodayString
               };
               String body = attachTemplate.HtmlValue;
               body = setBodyValues(body, attachmentParams);
               Blob strPdf = Blob.toPDF(body);
               strPdfBody = strPdf;
          }else if(type == certOfAchievement){
               Map<String, String> attachmentParams = new Map<String, String> {
                    '{courseName}' => certDetails.courseName, 
                    '{fullName}' => certDetails.contactFullName,
                    '{startDate}' => certDetails.startDate,
                    '{endDate}' => certDetails.endDate,
                    '{mark}' => String.valueOf(certDetails.marks),
                    '{markDesc}' => certDetails.marksDesc,                    
                    '{facilitator}' => certDetails.contactFullName,
                    '{dateToday}' => dateTodayString
               };
               String body = attachTemplate.HtmlValue;
               body = setBodyValues(body, attachmentParams);
               Blob strPdf = Blob.toPDF(body);
               strPdfBody = strPdf;
          }

          ContentVersion contentVersion = new ContentVersion();
          contentVersion.ContentLocation = 'S';
          contentVersion.PathOnClient = id + '-' + type + '.pdf';
          contentVersion.Title = type;
          contentVersion.VersionData = strPdfBody;
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

          List<Id> contentDocumentIdList = new List<Id>();
          Id contentDocumentId = null;
          List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recId LIMIT 1];
          for(ContentDocumentLink contentDoc : contentDocList){
               contentDocumentId = contentDoc.ContentDocumentId;
               contentDocumentIdList.add(contentDocumentId);
          }
          
          removePDF(contentDocumentIdList);

          Map<Id, ContentVersion> contentMap = createPDF(recId, certDetails, attachTemplate);
          insert contentMap.values();

          List<ContentVersion> contentVersionList = [SELECT PathOnClient, ContentDocumentId, VersionData FROM ContentVersion WHERE Id IN : contentMap.values()];
          List<ContentDocumentLink> contentDocuLinkList = new List<ContentDocumentLink>();
          for(ContentVersion contentVersion : contentVersionList){
               ContentDocumentLink contentDocuLink = new ContentDocumentLink();
               contentDocuLink.LinkedEntityId = recId;
               contentDocuLink.ContentDocumentId = contentVersion.ContentDocumentId;
               contentDocuLink.shareType = 'V';
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
                    system.debug('body:' + body);
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
               System.debug('Error: ' + e.getMessage());
               attach = new Messaging.EmailFileAttachment();
          }
          
          return attach;
     }
    
     private static Messaging.SingleEmailMessage emailBuilder(String email, String subject, String emailHtml, Map<String,String> emailContent){
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setUseSignature(false);
          mail.setToAddresses(new String[]{email});
          mail.setSubject(subject);
          String body = emailHtml;
          body = setBodyValues(body, emailContent);
          mail.setHtmlBody(body);
          return mail;
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