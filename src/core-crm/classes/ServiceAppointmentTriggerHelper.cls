/**
 * @description helper class for ServiceAppointmentTriggerHelper
 * @see ServiceAppointmentTriggerHelper
 *
 * @author Accenture-
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                   |
      |--------------------------------|-----------------------|------------------------|--------------------------------------------------|
      | arsenio.jr.dayrit              | November 21, 2023     | DEPP-7264              | Created file                                     |
 */
public with sharing class ServiceAppointmentTriggerHelper {
    /**
     * @description update the Contact or Lead and its related Marketing Segmentation record from Service Appointment
     *
     * @param newItems  List of new Service Appointment records
     */
     public static void updateContactLeadLinkedtoServiceAppointment(List<ServiceAppointment> newItems) {
        try{
            Map<Id,Contact> contactToUpdateMap = new Map<Id,Contact>();
            Map<Id,Lead> leadToUpdateMap = new Map<Id,Lead>();
            Map<Id,ServiceAppointment> serviceAppointmentMap = new Map<Id,ServiceAppointment>();
            for(ServiceAppointment serviceAppointment : newItems){
                Boolean isContactEmpty = (String.isEmpty(serviceAppointment.Contact__c));
                Boolean isLeadEmpty = (String.isEmpty(serviceAppointment.LeadId__c));
                if(!isContactEmpty){
                    mapServiceAppointmentToRelatedContact(contactToUpdateMap, serviceAppointmentMap, serviceAppointment);
                }
                else if(!isLeadEmpty){
                    mapServiceAppointmentToRelatedLead(leadToUpdateMap, serviceAppointmentMap, serviceAppointment);
                }
            }

            if(!contactToUpdateMap.values().isEmpty()){
                ContactsDAO.newInstance().updateRecords(contactToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
            }
            if(!leadToUpdateMap.values().isEmpty()){
                LeadsDAO.newInstance().updateRecords(leadToUpdateMap.values(), false, AccessLevel.SYSTEM_MODE);
            }
            
            updateMarketingSegLinkedToContactOrLead(contactToUpdateMap,leadToUpdateMap,serviceAppointmentMap);

        } catch (Exception e) {
            Logger.error('Exception caught in method updateContactLeadLinkedtoServiceAppointment in class ServiceAppointmentTriggerHelper.')
              .setExceptionDetails(e);
          } finally {
            if(Logger.getBufferSize() > 0) {
              Logger.saveLog();
            }
          }
     }

      /**
     * @description: get existing application preference Id from Package Component
     *
     * @param Set<Id>  Application Preference Id to evaluate
     */
    private static void updateMarketingSegLinkedToContactOrLead(Map<Id,Contact> contactMap, Map<Id,Lead> leadMap, Map<Id,ServiceAppointment> serviceAppointmentMap) {
        List<Marketing_Segmentation__c> marketingSegToUpdate = new List<Marketing_Segmentation__c>();
        List<Marketing_Segmentation__c> marketingSegList = MarketingSegmentationsDAO.newInstance().getMarketingSegmentationByContactOrLead(contactMap.keySet(),leadMap.keySet(), AccessLevel.SYSTEM_MODE);
        for(Marketing_Segmentation__c marketingSeg : marketingSegList){
            Boolean forContact = serviceAppointmentMap.containsKey(marketingSeg.Contact__c);
            Boolean forLead = serviceAppointmentMap.containsKey(marketingSeg.Lead__c);
            if(forContact){
                mapServiceAppointmentToContactMarketingSeg(marketingSeg, serviceAppointmentMap, marketingSegToUpdate);
            }
            else if(forLead){
                mapServiceAppointmentToLeadMarketingSeg(marketingSeg, serviceAppointmentMap, marketingSegToUpdate);
            }
        }

        if(!marketingSegToUpdate.isEmpty()){
            MarketingSegmentationsDAO.newInstance().updateRecords(marketingSegToUpdate,false, AccessLevel.SYSTEM_MODE);
        }
    }

    private static void mapServiceAppointmentToRelatedContact(Map<Id,Contact> contactToUpdateMap, Map<Id,ServiceAppointment> serviceAppointmentMap, ServiceAppointment serviceAppointment){
        Contact con = new Contact();
        con.id = serviceAppointment.Contact__c;
        if(serviceAppointment.Email != null){
            con.Email = serviceAppointment.Email;
        }
        if(serviceAppointment.Mobile_Locale__c != null){
            con.ContactMobile_Locale__c = serviceAppointment.Mobile_Locale__c;
        }
        if(serviceAppointment.Mobile_No_Locale__c != null){
            con.Mobile_No_Locale__c = serviceAppointment.Mobile_No_Locale__c;
        }
        if(serviceAppointment.Marketing_Consent__c){
            con.Email_Opt_In_DateTime__c = System.Now();
        }
        contactToUpdateMap.put(serviceAppointment.Contact__c,con);
        serviceAppointmentMap.put(serviceAppointment.Contact__c,serviceAppointment);
    }

    private static void mapServiceAppointmentToRelatedLead(Map<Id,Lead> leadToUpdateMap, Map<Id,ServiceAppointment> serviceAppointmentMap, ServiceAppointment serviceAppointment){
        Lead lead = new Lead();
        lead.id = serviceAppointment.LeadId__c;
        if(serviceAppointment.Email != null){
            lead.Email = serviceAppointment.Email;
        }
        if(serviceAppointment.Mobile_Locale__c != null){
            lead.LeadMobile_Locale__c = serviceAppointment.Mobile_Locale__c;
        }
        if(serviceAppointment.Mobile_No_Locale__c != null){
            lead.Mobile_No_Locale__c = serviceAppointment.Mobile_No_Locale__c;
        }
        if(serviceAppointment.Marketing_Consent__c){
            lead.Email_Opt_In_DateTime__c = System.Now();
        }
        leadToUpdateMap.put(serviceAppointment.LeadId__c,lead);
        serviceAppointmentMap.put(serviceAppointment.LeadId__c,serviceAppointment);
    }

    private static void mapServiceAppointmentToContactMarketingSeg(Marketing_Segmentation__c marketingSeg, Map<Id,ServiceAppointment> serviceAppointmentMap, List<Marketing_Segmentation__c> marketingSegToUpdate){
        boolean hasChanged = false;
        
        if(serviceAppointmentMap.get(marketingSeg.Contact__c).My_Citizenship_Status__c != null){
            marketingSeg.My_Citizenship_Status__c = serviceAppointmentMap.get(marketingSeg.Contact__c).My_Citizenship_Status__c;
            hasChanged = true;
        }
        if(serviceAppointmentMap.get(marketingSeg.Contact__c).My_Country_Of_Citizenship__c != null){
            marketingSeg.My_Country_Of_Citizenship__c = serviceAppointmentMap.get(marketingSeg.Contact__c).My_Country_Of_Citizenship__c;
            hasChanged = true;
        }
        if(serviceAppointmentMap.get(marketingSeg.Contact__c).My_Country_Of_Residency__c != null){
            marketingSeg.My_Country_Of_Residency__c = serviceAppointmentMap.get(marketingSeg.Contact__c).My_Country_Of_Residency__c;
            hasChanged = true;
        }
        if(hasChanged){
            marketingSegToUpdate.add(marketingSeg);
        }
        
    }

    private static void mapServiceAppointmentToLeadMarketingSeg(Marketing_Segmentation__c marketingSeg, Map<Id,ServiceAppointment> serviceAppointmentMap, List<Marketing_Segmentation__c> marketingSegToUpdate){
        boolean hasChanged = false;
        
        if(serviceAppointmentMap.get(marketingSeg.Lead__c).My_Citizenship_Status__c != null){
            marketingSeg.My_Citizenship_Status__c = serviceAppointmentMap.get(marketingSeg.Lead__c).My_Citizenship_Status__c;
            hasChanged = true;
        }
        if(serviceAppointmentMap.get(marketingSeg.Lead__c).My_Country_Of_Citizenship__c != null){
            marketingSeg.My_Country_Of_Citizenship__c = serviceAppointmentMap.get(marketingSeg.Lead__c).My_Country_Of_Citizenship__c;
            hasChanged = true;
        }
        if(serviceAppointmentMap.get(marketingSeg.Lead__c).My_Country_Of_Residency__c != null){
            marketingSeg.My_Country_Of_Residency__c = serviceAppointmentMap.get(marketingSeg.Lead__c).My_Country_Of_Residency__c;
            hasChanged = true;
        }
        if(hasChanged){
            marketingSegToUpdate.add(marketingSeg);
        }
    
    }

}