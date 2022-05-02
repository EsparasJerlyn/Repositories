/**
 * @description batch job for sending certificate emails
 * @see 
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 02, 2022          | DEPP-1478              | Created file                 |
      |                                |                       |                        |                              |
 */
global class SendCertificateBatch implements Database.batchable<sObject>{
    global Set<Id> courseConnectionIds;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'Select Id, hed__Course_Offering__r.hed__Course__r.Name, ' +
        'hed__Course_Offering__r.hed__Course__r.Certificate_Type__c, hed__Contact__r.Email,hed__Contact__r.Name ' + 
        ' From hed__Course_Enrollment__c Where Id IN :courseConnectionIds' + (Test.isRunningTest()?' LIMIT 14':'');        
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<ManageCertificateDetails> certDetailsList = new List<ManageCertificateDetails>();
        for(hed__Course_Enrollment__c conEnroll : (List<hed__Course_Enrollment__c>)scope) {
            ManageCertificateDetails certDetail = new ManageCertificateDetails();
            certDetail.id = conEnroll.Id;
            if( conEnroll.hed__Course_Offering__c != null && 
                conEnroll.hed__Course_Offering__r.hed__Course__c != null &&
                conEnroll.hed__Course_Offering__r.hed__Course__r.Certificate_Type__c != null && 
                conEnroll.hed__Course_Offering__r.hed__Course__r.Name != null ){

                certDetail.courseName = conEnroll.hed__Course_Offering__r.hed__Course__r.Name;
                certDetail.certificateType = conEnroll.hed__Course_Offering__r.hed__Course__r.Certificate_Type__c;
            }

            if( conEnroll.hed__Contact__c != null &&
                conEnroll.hed__Contact__r.Email != null){
                    certDetail.contactEmail = conEnroll.hed__Contact__r.Email; 
            }

            if( conEnroll.hed__Contact__c != null &&
                conEnroll.hed__Contact__r.Name != null){
                    certDetail.contactFullName = conEnroll.hed__Contact__r.Name; 
            }
            certDetailsList.add(certDetail);
        }
        if(!certDetailsList.isEmpty()){
            ManageCertificateSectionCtrl.sendEmail(certDetailsList);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }

    /**
      * @description Wrapper class that holds data to be displayed
      */
      public class ManageCertificateDetails{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String certificateType;
        @AuraEnabled
        public String contactEmail;
        @AuraEnabled
        public String contactFullName;
        @AuraEnabled
        public String courseName;
        
   }   
 }