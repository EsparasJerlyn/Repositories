/**
 * @description helper Class for MarketingStagingTriggerHandler
 * @see ..MarketingStagingTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | roy.nino.s.regala              | May 23, 2022          | DEPP-2103              | Created file                                   |
      | cadalin@qut.edu.au             | June 15, 2022         | DEPP-3088              | Included new fields                            |
      | roy.nino.s.regala              | June 28, 2022         | DEPP-3070              | updated matching logic                         |
      | roy.nino.s.regala              | July 20, 2022         | DEPP-3535              | Updated logic to update mobile and birthdate   |
      | roy.nino.s.regala              | Oct 20, 2022          | DEPP-4672              | Removed mobile number criteria for matching    |
      | roy.nino.s.regala              | Mar 3, 2022           | DEPP-5327              | Update lead's last name if unknown             |
      | mark.j.mahilum                 | July 3, 2023          | DEPP-5961              | Remove reference to MarketingCourseApplication |
      | mark.j.mahilum                 | August 18, 2023       | DEPP-6391              | Marketing Application logic revert changes     |
      | kenneth.f.alsay                | January 3, 2024       |                        | Fixed excessive param list                     |
 */

public without sharing class MarketingStagingTriggerHelper{




    private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
    public static Map<Id,Contact> contactMatches = new Map<Id,Contact>();
    public static Map<Id,Lead> leadMatches = new Map<Id,Lead>();
    /**
     * @description create contact record from marketing staging fields
     * @param newItems - map of new marketing staging records
     */
    public static void marketingStagingMatching(Map<Id, SObject> newItems){
        Map<String,String> qtacMatchingMap = new Map<String,String>();
        Map<String,String> samsMatchingMap = new Map<String,String>();
        Map<String,String> studylinkMatchingMap = new Map<String,String>();
        Map<String,List<Marketing_Staging__c>> emailMap = new Map<String,List<Marketing_Staging__c>>();
        Map<String,sObject> studentIdMap = new Map<String, sObject>();
        MarketingStagingMatchingHelper.RelatedMarketingRecordsClass marketingClass = new MarketingStagingMatchingHelper.RelatedMarketingRecordsClass();
        MarketingStagingMatchingHelper.LeadContactMatchingClass matchingClass = new MarketingStagingMatchingHelper.LeadContactMatchingClass();
        MarketingStagingMatchingHelper.RecordsToUpsertClass recordsClass;
        Map<String,Lead> leadsToUpsertMap = new Map<String,Lead>();
        Map<String,Contact> contactsToUpsertMap = new Map<String,Contact>();
        Map<String,Marketing_Segmentation__c> marSegmentationToUpsertMap = new Map<String,Marketing_Segmentation__c>();
        Map<String,Marketing_Interaction__c> marInteractionToInsertMap = new Map<String,Marketing_Interaction__c>();
        Map<String,Marketing_Course_Application__c> marCourseAppToUpsertMap = new Map<String,Marketing_Course_Application__c>();
        Map<String,Marketing_Staging__c> marStageToUpdateMap = new Map<String, Marketing_Staging__c>();
        Map<String,Marketing_Staging__c> newMap = new Map<String,Marketing_Staging__c>();

        List<String> salutaionValues = new List<String>();
        salutaionValues.addAll(MarketingStagingMatchingHelper.getSalutations());

        for(sObject mStaging: newItems.values()){
            newMap.put((String)mStaging.get('Id'),(Marketing_Staging__c)mStaging);
            //make sure last name amd email is populated
                if(mStaging.get('Email__c') != null){
                    //collect marketing staging emails
                    if(!emailMap.containsKey((String)mStaging.get('Email__c'))){
                        emailMap.put((String)mStaging.get('Email__c'), new List<Marketing_Staging__c>());
                    }
                    emailMap.get((String)mStaging.get('Email__c')).add((Marketing_Staging__c)mStaging);
                }
                //collects student ids from inserted marketing stagings
                if(mStaging.get('QUT_Student_ID__c') != null){
                    studentIdMap.put((String)mStaging.get('QUT_Student_ID__c'),mStaging);
                }

                //create Application Source criteria map against the marketing staging records
                if( mStaging.get('Application_Source__c') == 'QTAC' &&
                    mStaging.get('Applicant_Id__c') != null &&
                    mStaging.get('Preference_Number__c') != null){

                        qtacMatchingMap.put((String)mStaging.get('Id'),(String)mStaging.get('QTAC_Matching_Criteria__c'));

                }else if(   mStaging.get('Application_Source__c') == 'SAMS' &&
                            mStaging.get('QUT_Student_ID__c') != null &&
                            mStaging.get('Admission_Period__c') != null &&
                            mStaging.get('Course_Code__c') != null &&
                            mStaging.get('Admission_Year__c') != null){

                                samsMatchingMap.put((String)mStaging.get('Id'),(String)mStaging.get('SAMS_Matching_Criteria__c'));

                }else if(   mStaging.get('Application_Source__c') == 'Studylink' &&
                            mStaging.get('Application_Id__c') != null &&
                            mStaging.get('Applicant_Id__c') != null ){

                                studylinkMatchingMap.put((String)mStaging.get('Id'),(String)mStaging.get('Studylink_Matching_Criteria__c'));
                }
        }


        //get all matching contacts and leads
        contactMatches = new Map<Id,Contact>([
                            SELECT Id, QUT_Student_ID__c, Email,LeadSource, Lead_Source_Category__c,
                            Mobile_No_Locale__c, BirthDate, ContactMobile_Locale__c, HasOptedOutOfEmail, Email_Opt_In_DateTime__c,
                            hed__SMS_Opt_Out__c, SMS_Opt_Out_DateTime__c, SMS_Opt_In_DateTime__c
                            FROM Contact
                            WHERE (Email IN: emailMap.keySet()
                            OR QUT_Student_ID__c IN:studentIdMap.keySet())]);

        leadMatches = new Map<Id,Lead>([
                        SELECT Id, Email, Mobile_No_Locale__c, LastName, LeadSource, Lead_Source_Category__c,
                        hed__Birth_Date__c, LeadMobile_Locale__c, HasOptedOutOfEmail, Email_Opt_In_DateTime__c,
                        hed__SMS_Opt_Out__c, SMS_Opt_Out_DateTime__c, SMS_Opt_In_DateTime__c
                        FROM Lead
                        WHERE (Email IN:emailMap.keySet())]);

        //get existing marketingrecords
        marketingClass = MarketingStagingMatchingHelper.getRelatedMarketingRecords(
            leadMatches.values(),
            contactMatches.values(),
            new Map<String, List<String>>{
                'qtacMatchingList' => qtacMatchingMap.values(),
                'samsMatchingList' => samsMatchingMap.values(),
                'studylinkMatchingList' => studylinkMatchingMap.values()
            }
        );

        //get matching map for lead and contact
        matchingClass = MarketingStagingMatchingHelper.getContactLeadMapping(
            contactMatches.values(),
            leadMatches.values()
        );
    
        for(sObject mStaging: newItems.values()){
            String key;
            recordsClass = new MarketingStagingMatchingHelper.RecordsToUpsertClass(); 
            if(mStaging.get('QUT_Student_Id__c') != null){
                key = (String)mStaging.get('QUT_Student_Id__c');
                if( matchingClass.contactIdMap.containsKey(key)  && 
                    matchingClass.contactIdMap.get(key).size() == 1
                ){
                    contactsToUpsertMap.put(
                        matchingClass.contactIdMap.get(key)[0].Id,
                        (Contact)MarketingStagingMatchingHelper.createContactRecord(
                            mStaging,
                            matchingClass.contactIdMap.get(key)[0].Id,
                            salutaionValues
                        )
                    );
    
                    recordsClass = MarketingStagingMatchingHelper.processMarketingMatching(
                        null,(String)matchingClass.contactIdMap.get(key)[0].Id,(Marketing_Staging__c)mStaging, 
                        marketingClass.contactSegMap,marketingClass.contactAppMap,
                        qtacMatchingMap, samsMatchingMap, studylinkMatchingMap
                    );
    
                    if(!recordsClass.segmentationToUpsertMap.keySet().isEmpty()){
                        marSegmentationToUpsertMap.putAll(recordsClass.segmentationToUpsertMap);
                    }
                    if(!recordsClass.applicationToUpsertMap.keySet().isEmpty()){
                        marCourseAppToUpsertMap.putAll(recordsClass.applicationToUpsertMap);
                    }
                    if(!recordsClass.interactionToUpsertMap.keySet().isEmpty()){
                        marInteractionToInsertMap.putAll(recordsClass.interactionToUpsertMap);
                    }

                    marStageToUpdateMap.put(mStaging.Id, new Marketing_Staging__c(
                        Id = (Id)mStaging.get('Id'),
                        Contact__c = matchingClass.contactIdMap.get(key)[0].Id 
                        )
                    );
                    continue;
                }
            }
            if(mStaging.get('Email__c') != null){
                key = (String)mStaging.get('Email__c');
                if( matchingClass.contactEmailMap.containsKey(key)  && 
                    matchingClass.contactEmailMap.get(key).size() == 1
                ){
                    contactsToUpsertMap.put(
                        matchingClass.contactEmailMap.get(key)[0].Id,
                        (Contact)MarketingStagingMatchingHelper.createContactRecord(
                            mStaging,
                            matchingClass.contactEmailMap.get(key)[0].Id,
                            salutaionValues
                        )
                    );
    
                    recordsClass = MarketingStagingMatchingHelper.processMarketingMatching(
                        null,(String)matchingClass.contactEmailMap.get(key)[0].Id,(Marketing_Staging__c)mStaging, 
                        marketingClass.contactSegMap,marketingClass.contactAppMap,
                        qtacMatchingMap, samsMatchingMap, studylinkMatchingMap
                    );
    
                    if(!recordsClass.segmentationToUpsertMap.keySet().isEmpty()){
                        marSegmentationToUpsertMap.putAll(recordsClass.segmentationToUpsertMap);
                    }
                    if(!recordsClass.applicationToUpsertMap.keySet().isEmpty()){
                        marCourseAppToUpsertMap.putAll(recordsClass.applicationToUpsertMap);
                    }
                    if(!recordsClass.interactionToUpsertMap.keySet().isEmpty()){
                        marInteractionToInsertMap.putAll(recordsClass.interactionToUpsertMap);
                    }

                    marStageToUpdateMap.put(mStaging.Id, new Marketing_Staging__c(
                        Id = (Id)mStaging.get('Id'),
                        Contact__c = matchingClass.contactEmailMap.get(key)[0].Id 
                        )
                    );
                    continue;
                }

                if( matchingClass.leadEmailMap.containsKey(key) &&
                    matchingClass.leadEmailMap.get(key).size() == 1
                ){
                    leadsToUpsertMap.put(
                        matchingClass.leadEmailMap.get(key)[0].Id,
                        (Lead)MarketingStagingMatchingHelper.createLeadRecord(
                            mStaging,
                            matchingClass.leadEmailMap.get(key)[0].Id,
                            salutaionValues
                        )
                    );
    
                    recordsClass = MarketingStagingMatchingHelper.processMarketingMatching(
                        (String)matchingClass.leadEmailMap.get(key)[0].Id,null,(Marketing_Staging__c)mStaging, 
                        marketingClass.leadSegMap,marketingClass.leadAppMap,
                        qtacMatchingMap, samsMatchingMap, studylinkMatchingMap
                    );
    
                    if(!recordsClass.segmentationToUpsertMap.keySet().isEmpty()){
                        marSegmentationToUpsertMap.putAll(recordsClass.segmentationToUpsertMap);
                    }
                    if(!recordsClass.applicationToUpsertMap.keySet().isEmpty()){
                        marCourseAppToUpsertMap.putAll(recordsClass.applicationToUpsertMap);
                    }
                    if(!recordsClass.interactionToUpsertMap.keySet().isEmpty()){
                        marInteractionToInsertMap.putAll(recordsClass.interactionToUpsertMap);
                    }
                    
                    marStageToUpdateMap.put((Id)mStaging.get('Id'), new Marketing_Staging__c(
                        Id = (Id)mStaging.get('Id'),
                        Lead__c = matchingClass.leadEmailMap.get(key)[0].Id 
                        )
                    );
                    continue;
                }
            }
            if(mStaging.get('Last_Name__c') != null){
                String newLeadKey = '';
                if(mStaging.get('Email__c') != null){
                    newLeadKey = (String)mStaging.get('Email__c');
                }else{
                    newLeadKey = (String)mStaging.get('Id');
                }
                leadsToUpsertMap.put(
                    newLeadKey,
                    (Lead) MarketingStagingMatchingHelper.createLeadRecord(
                        mStaging,
                        null,
                        salutaionValues
                    )
                );
            }
        }

        if(!contactsToUpsertMap.keySet().isEmpty()){
            Database.upsert(contactsToUpsertMap.values(),false);

            List<Database.UpsertResult> contactsToUpsertMapResult = Database.upsert(contactsToUpsertMap.values(),false);

            for (Database.UpsertResult result : contactsToUpsertMapResult){
                if (!result.isSuccess() && !result.isCreated()){
                    Logger.error('Error in upserting contacts').setDatabaseResult(result);
                }            
            }
            if(Logger.getBufferSize() > 0){
                Logger.saveLog();                
            }
            
        }

        if(!leadsToUpsertMap.keySet().isEmpty()){
            Database.upsert(leadsToUpsertMap.values(),false);

            List<Database.UpsertResult> leadsToUpsertMapResult = Database.upsert(leadsToUpsertMap.values(),false);

            for (Database.UpsertResult result : leadsToUpsertMapResult){
                if (!result.isSuccess() && !result.isCreated()){
                    Logger.error('Error in upserting leads').setDatabaseResult(result);
                }            
            }
            if(Logger.getBufferSize() > 0){
                Logger.saveLog();                
            }
            
            for(String leadKey: leadsToUpsertMap.keySet()){
                //if linked to marketingstaging create new marketing records 
                //and link to the lead
                if(newMap.containsKey(leadKey)){
                    //create marketing segmentation records
                    marSegmentationToUpsertMap.put(
                        leadKey,
                        (Marketing_Segmentation__c) MarketingStagingMatchingHelper.createMarketingRecord(
                            newMap.get(leadKey),
                            new Map<String, Id>{
                                'contactId' => null,
                                'leadId' => leadsToUpsertMap.get(leadKey).Id,
                                'oldId' => null
                            },
                            'Marketing_Segmentation__c'
                        )
                    );

                    //check first if application data is populated 
                    if( qtacMatchingMap.containsKey(leadKey) || samsMatchingMap.containsKey(leadKey) || studylinkMatchingMap.containsKey(leadKey)){
                        marCourseAppToUpsertMap.put(
                            leadKey,
                            (Marketing_Course_Application__c)MarketingStagingMatchingHelper.createMarketingRecord(
                                newMap.get(leadKey),
                                new Map<String, Id>{
                                    'contactId' => null,
                                    'leadId' => leadsToUpsertMap.get(leadKey).Id,
                                    'oldId' => null
                                },
                                'Marketing_Course_Application__c'
                            )
                        );
                    }

                    marStageToUpdateMap.put(leadKey, new Marketing_Staging__c(
                        Id = leadKey,
                        Lead__c = leadsToUpsertMap.get(leadKey).Id 
                        )
                    );
                }
                //if linked to marketingstaging email
                //create multiple marketing records based on number of staging with the same email
                if(emailMap.containsKey(leadKey)){
                    for(Marketing_Staging__c ms: emailMap.get(leadKey)){
                        //create marketing segmentation records
                        marSegmentationToUpsertMap.put(
                            leadKey,
                            (Marketing_Segmentation__c) MarketingStagingMatchingHelper.createMarketingRecord(
                                ms,
                                new Map<String, Id>{
                                    'contactId' => null,
                                    'leadId' => leadsToUpsertMap.get(leadKey).Id,
                                    'oldId' => null
                                },
                                'Marketing_Segmentation__c'
                            )
                        );

                        //check first if application data is populated
                        if( qtacMatchingMap.containsKey(ms.Id) || samsMatchingMap.containsKey(ms.Id) || studylinkMatchingMap.containsKey(ms.Id)){
                            marCourseAppToUpsertMap.put(
                                ms.Id,
                                (Marketing_Course_Application__c)MarketingStagingMatchingHelper.createMarketingRecord(
                                    ms,
                                    new Map<String, Id>{
                                        'contactId' => null,
                                        'leadId' => leadsToUpsertMap.get(leadKey).Id,
                                        'oldId' => null
                                    },
                                    'Marketing_Course_Application__c'
                                )
                            );
                        }

                            marStageToUpdateMap.put(ms.Id, new Marketing_Staging__c(
                                Id = ms.Id,
                                Lead__c = leadsToUpsertMap.get(leadKey).Id
                            )
                        );
                    }
                }
            }
        }

        if(!marSegmentationToUpsertMap.keySet().isEmpty()){
            Database.upsert(marSegmentationToUpsertMap.values(),false);

            List<Database.UpsertResult> marSegmentationToUpsertMapResult = Database.upsert(marSegmentationToUpsertMap.values(),false);

            for (Database.UpsertResult result : marSegmentationToUpsertMapResult){
                if (!result.isSuccess() && !result.isCreated()){
                    Logger.error('Error in upserting marketingsegmentation').setDatabaseResult(result);
                }            
            }
            if(Logger.getBufferSize() > 0){
                Logger.saveLog();                
            }

            for(String segKey: marSegmentationToUpsertMap.keySet()){
                if(newMap.containsKey(segKey)){
                    //create marketing new interaction records
                    if( newMap.get(segKey).Interaction_Type__c !=null ||
                        newMap.get(segKey).Interaction_DateTime__c !=null ||
                        newMap.get(segKey).Lead_Source_Category__c !=null ||
                        newMap.get(segKey).Lead_Source__c !=null ||
                        newMap.get(segKey).SPAD__c !=null ||
                        newMap.get(segKey).Event_Name__c !=null ){
                        marInteractionToInsertMap.put(
                            segKey,
                            (Marketing_Interaction__c) MarketingStagingMatchingHelper.createMarketingRecord(
                                    newMap.get(segKey),
                                    new Map<String, Id>{
                                        'contactId' => marSegmentationToUpsertMap.get(segKey).Contact__c,
                                        'leadId' => marSegmentationToUpsertMap.get(segKey).Lead__c,
                                        'oldId' => marSegmentationToUpsertMap.get(segKey).Id
                                    },
                                    'Marketing_Interaction__c'
                                )
                            );
                        }
                }else if(emailMap.containsKey(segKey)){
                    //create marketing interaction records
                    //against multple staging and 1 lead with the same email
                    for(Marketing_Staging__c ms: emailMap.get(segKey)){
                        if( ms.Interaction_Type__c !=null ||
                            ms.Interaction_DateTime__c !=null ||
                            ms.Lead_Source_Category__c !=null ||
                            ms.Lead_Source__c !=null ||
                            ms.SPAD__c !=null ||
                            ms.Event_Name__c !=null ){
                        marInteractionToInsertMap.put(
                            ms.Id,
                            (Marketing_Interaction__c) MarketingStagingMatchingHelper.createMarketingRecord(
                                    ms,
                                    new Map<String, Id>{
                                        'contactId' => marSegmentationToUpsertMap.get(segKey).Contact__c,
                                        'leadId' => marSegmentationToUpsertMap.get(segKey).Lead__c,
                                        'oldId' => marSegmentationToUpsertMap.get(segKey).Id
                                    },
                                    'Marketing_Interaction__c'
                                )
                            );
                        }
                    }
                }
            }
        }

        if(!marInteractionToInsertMap.keySet().isEmpty()){
            List<Database.UpsertResult> marInteractionToInsertMapResult = Database.upsert(marInteractionToInsertMap.values(),false);

            for (Database.UpsertResult result : marInteractionToInsertMapResult){
                if (!result.isSuccess() && !result.isCreated()){
                    Logger.error('Error in upserting marketingsegmentation').setDatabaseResult(result);
                }            
            }
            if(Logger.getBufferSize() > 0){
                Logger.saveLog();                
            }
        }

        if(!marCourseAppToUpsertMap.keySet().isEmpty()){
            List<Database.UpsertResult> marCourseAppToUpsertMapResult = Database.upsert(marCourseAppToUpsertMap.values(),false);
            for (Database.UpsertResult result : marCourseAppToUpsertMapResult){
                if (!result.isSuccess() && !result.isCreated()){
                    Logger.error('Error in upserting marketingcourseapplication').setDatabaseResult(result);
                }            
            }
            if(Logger.getBufferSize() > 0){
                Logger.saveLog();                
            }
        }
        
        if(!marStageToUpdateMap.keySet().isEmpty()){
            List<Database.SaveResult> marStageToUpdateMapResult = Database.update(marStageToUpdateMap.values(),false);

            for (Database.SaveResult result : marStageToUpdateMapResult){
                if (!result.isSuccess()){
                    Logger.error('Error in updating martketiingstaging').setDatabaseResult(result);
                }            
            }
            if(Logger.getBufferSize() > 0){
                Logger.saveLog();                
            }
        }

    }
}