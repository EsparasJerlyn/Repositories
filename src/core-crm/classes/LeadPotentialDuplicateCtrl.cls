/**
 * @description Controller Class for Lead Potential Duplicate
 * @see ../lwc/leadPotentialDuplicate
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary               |
      |--------------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.munoz                 | May 25, 2022          | DEPP-1902            | Created file                 | 
      |                                |                       |                      |                              |
	   
 */
public without sharing class LeadPotentialDuplicateCtrl {
    @AuraEnabled(cacheable=true)
    public static List<LeadContactWrapper> getSelectedLead(Id recordId){
        List<Lead> leadList = [SELECT Id, LastName, FirstName, Email, Work_Email__c FROM Lead WHERE Id = : recordId];
        List<LeadContactWrapper> responseList = new List<LeadContactWrapper>();
        for(Lead lead : leadList){
            LeadContactWrapper leadContactWrapper = new LeadContactWrapper();
            leadContactWrapper.id = lead.Id;
            leadContactWrapper.firstName = lead.FirstName;
            leadContactWrapper.lastName = lead.LastName;
            leadContactWrapper.email = lead.Email;
            leadContactWrapper.workEmail = lead.Work_Email__c ;  
            leadContactWrapper.type = 'Lead';          
            responseList.add(leadContactWrapper);
        }
        return responseList;
    }

    @AuraEnabled(cacheable=true)
    public static List<LeadContactWrapper> getLeadPotentialDuplicate(Id recordId){

        List<Potential_Duplicate__c> leadList = [SELECT Duplicate_Lead__r.Id, Duplicate_Lead__r.FirstName, Duplicate_Lead__r.LastName, 
                                        Duplicate_Lead__r.Email, Duplicate_Lead__r.Work_Email__c, Contact__r.Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.hed__WorkEmail__c 
                                                        FROM Potential_Duplicate__c WHERE (Lead__c =: recordId OR Duplicate_Lead__c =: recordId) ORDER BY Duplicate_Lead__r.FirstName ASC];

        List<LeadContactWrapper> responseList = new List<LeadContactWrapper>();
        for(Potential_Duplicate__c lead : leadList){
            LeadContactWrapper leadContactWrapper = new LeadContactWrapper();
            if(lead.Contact__c!=null){
                leadContactWrapper.id = lead.Contact__r.Id;
                leadContactWrapper.firstName = lead.Contact__r.FirstName;
                leadContactWrapper.lastName = lead.Contact__r.LastName;
                leadContactWrapper.email = lead.Contact__r.Email;
                leadContactWrapper.workEmail = lead.Contact__r.hed__WorkEmail__c ;  
                leadContactWrapper.type = 'Contact' ; 
            }else{
                leadContactWrapper.id = lead.Duplicate_Lead__r.Id;
                leadContactWrapper.firstName = lead.Duplicate_Lead__r.FirstName;
                leadContactWrapper.lastName = lead.Duplicate_Lead__r.LastName;
                leadContactWrapper.email = lead.Duplicate_Lead__r.Email;
                leadContactWrapper.workEmail = lead.Duplicate_Lead__r.Work_Email__c ;  
                leadContactWrapper.type = 'Lead' ;  
            }            
            responseList.add(leadContactWrapper);
        }
        return responseList;
    }  

    @AuraEnabled
    public static String mergeLeads(Object data){
        String response = '';
        try {
            List<LeadContactWrapper> records = (List<LeadContactWrapper>) JSON.deserialize(
                JSON.serialize(data),
                List<LeadContactWrapper>.class
            );   

            List<ID> recordIds = new List<ID>();
            for(LeadContactWrapper rec : records){
                recordIds.add(rec.id);
            }

            List<Potential_Duplicate__c> pList = [SELECT Id FROM Potential_Duplicate__c WHERE Duplicate_Lead__c IN : recordIds];
            List<Lead> leads = [SELECT Id FROM Lead WHERE Id IN : recordIds];

            delete leads;
            delete pList;
            response = 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
    
    public class LeadContactWrapper{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String workEmail;
        @AuraEnabled
        public String type;
    }
}
