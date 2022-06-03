/**
 * @description TriggerHandler Class for MarketingStagingTrigger
 * @see ..MarketingStagingTrigger
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | May 23, 2022          | DEPP-2103              | Created file                 |
 */

public with sharing class MarketingStagingTriggerHandler implements Disableable, AfterInsert {
   
    private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe().getLocalName();
    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe().getLocalName();

  /**
   * @description 
   * @param newItems - List of MarketingStaging.Trigger.new
   */
  public void afterInsert(Map<Id, SObject> newItems) {

    Map<String,sObject> marStagingMap = new Map<String,sObject>();
    Map<String,String> actionMap =  new Map<String,String>();
    List<Contact> contactMatches = new List<Contact>();
    List<Lead> leadMatches = new List<Lead>();
    Map<String,List<Contact>> contactMatchMapping = new Map<String,List<Contact>>();
    Map<String,List<Lead>> leadMatchMapping = new Map<String,List<Lead>>();
    Map<String,Lead> leadsToUpsertMap = new Map<String,Lead>(); 
    Map<String,Contact> contactsToUpsertMap = new Map<String,Contact>(); 
    Map<String,Marketing_Segmentation__c> marSegmentationToUpsertMap = new Map<String,Marketing_Segmentation__c>();
    Map<String,Marketing_Interaction__c> marInteractionToInsertMap = new Map<String,Marketing_Interaction__c>();
    Map<String,Marketing_Course_Application__c> marCourseAppToUpsertMap = new Map<String,Marketing_Course_Application__c>();
    Map<String,Marketing_Staging__c> marStageToUpdateMap = new Map<String, Marketing_Staging__c>();
    Set<String> appIdPrefNumset = new Set<String>();
    Set<String> lastNameList = new Set<String>();
    Set<String> emailList = new Set<String>();

    List<Potential_Duplicate__c> potentialDupToInsertList = new List<Potential_Duplicate__c>();
    
    for(sObject mStaging: newItems.values()){
        if(mStaging.get('Name_and_Email__c') != null){
            marStagingMap.put((String)mStaging.get('Name_and_Email__c'),mStaging);
        }
        if(mStaging.get('Applicant_Id_and_Preference_Num__c') != null){
            appIdPrefNumset.add((String)mStaging.get('Applicant_Id_and_Preference_Num__c'));
        }
        if(mStaging.get('Last_Name__c') != null){
            lastNameList.add((String)mStaging.get('Last_Name__c'));
        }
        if(mStaging.get('Email__c') != null){
            emailList.add((String)mStaging.get('Email__c'));
        }
    }

    if(!marStagingMap.keySet().isEmpty() && !emailList.isEmpty() && !lastNameList.isEmpty()){
        //get all matching contacts
        contactMatches = [  SELECT Id, Name_and_Email__c,
                            (SELECT Id, Lead__c, Contact__c FROM Marketing_Segmentations__r),
                            (SELECT Id, Lead__c, Contact__c, Applicant_Id_and_Preference_Num__c
                             FROM Marketing_Course_Applications__r
                             WHERE Applicant_Id_and_Preference_Num__c IN:appIdPrefNumset)
                            FROM Contact 
                            WHERE Name_and_Email__c IN: marStagingMap.keySet()
                            AND LastName IN:lastNameList
                            AND Email IN:emailList];
        //get all matching leads
        leadMatches = [  SELECT Id, Name_and_Email__c, 
                         (SELECT Id, Lead__c, Contact__c FROM Marketing_Segmentations__r),
                         (SELECT Id, Lead__c, Contact__c, Applicant_Id_and_Preference_Num__c 
                         FROM Marketing_Course_Applications__r  
                         WHERE Applicant_Id_and_Preference_Num__c IN:appIdPrefNumset)
                            FROM Lead 
                            WHERE Name_and_Email__c IN: marStagingMap.keySet() 
                            AND LastName IN:lastNameList
                            AND Email IN:emailList];                    

        for(Contact con: contactMatches){
            //create map that groups all nameemail and contacts
            if(!contactMatchMapping.containsKey(con.Name_and_Email__c)){
                contactMatchMapping.put(
                    con.Name_and_Email__c,
                    new List<Contact>()
                );
            }
            contactMatchMapping.get(con.Name_and_Email__c).add(con);
        }

        for(Lead lead: leadMatches){
            //create map that groups all nameemail and leads
            if(!leadMatchMapping.containsKey(lead.Name_and_Email__c)){

                leadMatchMapping.put(
                    lead.Name_and_Email__c,
                    new List<Lead>()
                );
            }
            leadMatchMapping.get(lead.Name_and_Email__c).add(lead);
        }

        for(String nameEmailItem: marStagingMap.keySet()){

            if(//1 matching contact
                contactMatchMapping.containsKey(nameEmailItem)  && 
                contactMatchMapping.get(nameEmailItem).size() == 1
            ){ 
                actionMap.put(nameEmailItem,'ONE_CONTACT_MATCH');
                //update contact matchingrecorcds
                contactsToUpsertMap.put(
                    nameEmailItem,
                    (Contact)MarketingStagingTriggerHelper.createContactRecord(
                        marStagingMap.get(nameEmailItem),
                        contactMatchMapping.get(nameEmailItem)[0].Id
                    )
                );

                if(!contactMatchMapping.get(nameEmailItem)[0].Marketing_Segmentations__r.isEmpty()){
                    for(Marketing_Segmentation__c segmenation: contactMatchMapping.get(nameEmailItem)[0].Marketing_Segmentations__r){
                        marSegmentationToUpsertMap.put(
                            nameEmailItem,
                            (Marketing_Segmentation__c)MarketingStagingTriggerHelper.createMarketingSegmentationRecord(
                                marStagingMap.get(nameEmailItem),
                                segmenation.Contact__c,
                                segmenation.Lead__c,
                                segmenation.Id
                            )
                        ); 
                    }
                }else{
                    //create new segmenation record
                    marSegmentationToUpsertMap.put(
                        nameEmailItem,
                        (Marketing_Segmentation__c)MarketingStagingTriggerHelper.createMarketingSegmentationRecord(
                            marStagingMap.get(nameEmailItem),
                            contactMatchMapping.get(nameEmailItem)[0].Id,
                            null,
                            null
                        )
                    );
                }
                
                if(!contactMatchMapping.get(nameEmailItem)[0].Marketing_Course_Applications__r.isEmpty()){
                    for(Marketing_Course_Application__c courseApp: contactMatchMapping.get(nameEmailItem)[0].Marketing_Course_Applications__r){
                        marCourseAppToUpsertMap.put(
                        nameEmailItem,
                        (Marketing_Course_Application__c) MarketingStagingTriggerHelper.createMarketingCourseAppRecord(
                            marStagingMap.get(nameEmailItem),
                            courseApp.Contact__c,
                            courseApp.Lead__c,
                            courseApp.Id
                            )
                        );
                    }
                }else if(marStagingMap.get(nameEmailItem).get('Applicant_Id_and_Preference_Num__c') != null){
                    marCourseAppToUpsertMap.put(
                        nameEmailItem,
                        (Marketing_Course_Application__c) MarketingStagingTriggerHelper.createMarketingCourseAppRecord(
                            marStagingMap.get(nameEmailItem),
                            contactMatchMapping.get(nameEmailItem)[0].Id,
                            null,
                            null
                        )
                    );
                }

            }else if(// more than 1 matching contacts
                contactMatchMapping.containsKey(nameEmailItem) && 
                contactMatchMapping.get(nameEmailItem).size() > 1
            ){ 
                actionMap.put(nameEmailItem,'MULTI_CONTACT_MATCH');

                //create lead records
                leadsToUpsertMap.put(
                    nameEmailItem,
                    (Lead) MarketingStagingTriggerHelper.createLeadRecord(
                        marStagingMap.get(nameEmailItem),
                        null
                    )
                );

            }else if(// 1 matching Lead
                !contactMatchMapping.containsKey(nameEmailItem) &&
                leadMatchMapping.containsKey(nameEmailItem) && 
                leadMatchMapping.get(nameEmailItem).size() == 1
            ){ 
                actionMap.put(nameEmailItem,'ONE_LEAD_MATCH');

                //update lead
                leadsToUpsertMap.put(
                    nameEmailItem,
                    (Lead) MarketingStagingTriggerHelper.createLeadRecord(
                        marStagingMap.get(nameEmailItem),
                        leadMatchMapping.get(nameEmailItem)[0].Id
                    )
                );

                
                if(!leadMatchMapping.get(nameEmailItem)[0].Marketing_Segmentations__r.isEmpty()){
                    for(Marketing_Segmentation__c segmentation: leadMatchMapping.get(nameEmailItem)[0].Marketing_Segmentations__r){
                        marSegmentationToUpsertMap.put(
                            nameEmailItem,
                            (Marketing_Segmentation__c) MarketingStagingTriggerHelper.createMarketingSegmentationRecord(
                                marStagingMap.get(nameEmailItem),
                                segmentation.Contact__c,
                                segmentation.Lead__c,
                                segmentation.Id
                            )
                        );
                    }
                //create new segmentation record
                }else{
                    marSegmentationToUpsertMap.put(
                        nameEmailItem,
                        (Marketing_Segmentation__c) MarketingStagingTriggerHelper.createMarketingSegmentationRecord(
                            marStagingMap.get(nameEmailItem),
                            null,
                            leadMatchMapping.get(nameEmailItem)[0].Id,
                            null
                        )
                    );
                }

                if(!leadMatchMapping.get(nameEmailItem)[0].Marketing_Course_Applications__r.isEmpty()){
                    for(Marketing_Course_Application__c courseApp: leadMatchMapping.get(nameEmailItem)[0].Marketing_Course_Applications__r){
                        marCourseAppToUpsertMap.put(
                        nameEmailItem,
                        (Marketing_Course_Application__c) MarketingStagingTriggerHelper.createMarketingCourseAppRecord(
                            marStagingMap.get(nameEmailItem),
                            courseApp.Contact__c,
                            courseApp.Lead__c,
                            courseApp.Id
                            )
                        );
                    }
                }else if(marStagingMap.get(nameEmailItem).get('Applicant_Id_and_Preference_Num__c') != null){
                    marCourseAppToUpsertMap.put(
                        nameEmailItem,
                        (Marketing_Course_Application__c) MarketingStagingTriggerHelper.createMarketingCourseAppRecord(
                            marStagingMap.get(nameEmailItem),
                            null,
                            leadsToUpsertMap.get(nameEmailItem).Id,
                            null
                        )
                    );
                } 

            }else if(// more than 1 matching leads
                !contactMatchMapping.containsKey(nameEmailItem) &&
                leadMatchMapping.containsKey(nameEmailItem) && 
                leadMatchMapping.get(nameEmailItem).size() > 1
            ){ 
                actionMap.put(nameEmailItem,'MULTI_LEAD_MATCH');
                //create lead records
                leadsToUpsertMap.put(
                    nameEmailItem,
                    (Lead) MarketingStagingTriggerHelper.createLeadRecord(
                        marStagingMap.get(nameEmailItem),
                        null
                    )
                );
            // no match for lead and contact
            }else if( 
                !contactMatchMapping.containsKey(nameEmailItem) &&
                !leadMatchMapping.containsKey(nameEmailItem)
            ){ 
                actionMap.put(nameEmailItem,'ZERO_MATCH');
                //create lead records
                leadsToUpsertMap.put(
                    nameEmailItem,
                    (Lead) MarketingStagingTriggerHelper.createLeadRecord(
                        marStagingMap.get(nameEmailItem),
                        null
                    )
                );
            }
        }
    }

    if(!contactsToUpsertMap.isEmpty()){
        upsert contactsToUpsertMap.values();
        for(String nameEmailItem : contactsToUpsertMap.keySet()){
            marStageToUpdateMap.put(nameEmailItem, new Marketing_Staging__c(
                Id = marStagingMap.get(nameEmailItem).Id,
                Contact__c = contactsToUpsertMap.get(nameEmailItem).Id 
                )
            );
        }
    }

    if(!leadsToUpsertMap.isEmpty()){
        upsert leadsToUpsertMap.values();
    }

    //after lead insertion
    //create marketing records
    for(String nameEmailItem : leadsToUpsertMap.keySet()){
        if( 
            actionMap.get(nameEmailItem) == 'ZERO_MATCH' || 
            actionMap.get(nameEmailItem) == 'MULTI_LEAD_MATCH' || 
            actionMap.get(nameEmailItem) == 'MULTI_CONTACT_MATCH'
        ){
            //create markeeting segmentation records
            marSegmentationToUpsertMap.put(
                nameEmailItem,
                (Marketing_Segmentation__c) MarketingStagingTriggerHelper.createMarketingSegmentationRecord(
                    marStagingMap.get(nameEmailItem),
                    null,
                    leadsToUpsertMap.get(nameEmailItem).Id,
                    null
                )
            );

            //check first if application data is populated
            if(marStagingMap.get(nameEmailItem).get('Applicant_Id_and_Preference_Num__c') != null){
                marCourseAppToUpsertMap.put(
                    nameEmailItem,
                    (Marketing_Course_Application__c) MarketingStagingTriggerHelper.createMarketingCourseAppRecord(
                        marStagingMap.get(nameEmailItem),
                        null,
                        leadsToUpsertMap.get(nameEmailItem).Id,
                        null
                    )
                );
            }
        }

        if(actionMap.get(nameEmailItem) == 'MULTI_CONTACT_MATCH'){
            //link new lead to contacts
            potentialDupToInsertList.addAll(
                MarketingStagingTriggerHelper.createPotentialDupRecords(
                    leadsToUpsertMap.get(nameEmailItem).Id,
                    contactMatchMapping.get(nameEmailItem),
                    CONTACT_API_NAME
                )
            );
        }

        if(actionMap.get(nameEmailItem) == 'MULTI_LEAD_MATCH'){
            //link new lead to leads
            potentialDupToInsertList.addAll(
                MarketingStagingTriggerHelper.createPotentialDupRecords(
                    leadsToUpsertMap.get(nameEmailItem).Id,
                    leadMatchMapping.get(nameEmailItem),
                    LEAD_API_NAME
                )
            );
        }

        marStageToUpdateMap.put(nameEmailItem, new Marketing_Staging__c(
            Id = marStagingMap.get(nameEmailItem).Id,
            Lead__c = leadsToUpsertMap.get(nameEmailItem).Id 
            )
        );
    }
    //upsert marketing segmentation records
    if(!marSegmentationToUpsertMap.isEmpty()){
        upsert marSegmentationToUpsertMap.values();
        for(String nameEmailItem: marSegmentationToUpsertMap.keySet()){
            //create marketing interaction records
            if( marStagingMap.get(nameEmailItem).get('Interaction_Type__c')!=null &&
                marStagingMap.get(nameEmailItem).get('Interaction_DateTime__c')!=null && 
                marStagingMap.get(nameEmailItem).get('Lead_Source_Category__c')!=null && 
                marStagingMap.get(nameEmailItem).get('Lead_Source__c')!=null && 
                marStagingMap.get(nameEmailItem).get('SPAD__c')!=null &&
                marStagingMap.get(nameEmailItem).get('Event_Name__c')!=null ){
                marInteractionToInsertMap.put(
                    nameEmailItem,
                    (Marketing_Interaction__c) MarketingStagingTriggerHelper.createMarketingInteractionRecord(
                            marStagingMap.get(nameEmailItem),
                            marSegmentationToUpsertMap.get(nameEmailItem).Contact__c,
                            marSegmentationToUpsertMap.get(nameEmailItem).Lead__c,
                            marSegmentationToUpsertMap.get(nameEmailItem).Id
                        )
                    );
            }
        }
    }

    //insert marketing interaction records
    if(!marInteractionToInsertMap.isEmpty()){
        insert marInteractionToInsertMap.values();
    }

    if(!marCourseAppToUpsertMap.isEmpty()){
        upsert marCourseAppToUpsertMap.values();
    }

    if(!potentialDupToInsertList.isEmpty()){
        insert potentialDupToInsertList;
    }

    if(!marStageToUpdateMap.isEmpty()){
        update marStageToUpdateMap.values();
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