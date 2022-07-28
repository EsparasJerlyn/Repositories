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
 */

public with sharing class MarketingStagingTriggerHelper{




    private static final String CONTACT_API_NAME = Contact.SObjectType.getDescribe().getLocalName();
    private static final String LEAD_API_NAME = Lead.SObjectType.getDescribe().getLocalName();
    public static Map<Id,Contact> contactMatches = new Map<Id,Contact>();
    public static Map<Id,Lead> leadMatches = new Map<Id,Lead>();
    public static String currentProfileName;
    /**
     * @description create contact record from marketing staging fields
     * @param newItems - map of new marketing staging records
     */
    public static void marketingStagingMatching(Map<Id, SObject> newItems){

        Map<String,String> qtacMatchingMap = new Map<String,String>();
        Map<String,String> samsMatchingMap = new Map<String,String>();
        Map<String,String> studylinkMatchingMap = new Map<String,String>();
        Map<String,sObject> emailMap = new Map<String,sObject>();
        Map<String,sObject> mobileMap = new Map<String,sObject>();
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


        List<String> salutaionValues = new List<String>();
        salutaionValues.addAll(MarketingStagingMatchingHelper.getSalutations());

        Map<Id,Marketing_Staging__c> newMap = (Map<Id,Marketing_Staging__c>)newItems;

        Id currentUserProfileId = UserInfo.getProfileId();
        //Retrieve profile name of current user
        String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;
        currentProfileName = profileName;


        for(sObject mStaging: newItems.values()){
            //make sure last name amd email is populated
                if(mStaging.get('Email__c') != null){
                    //collect marketing staging emails
                    emailMap.put((String)mStaging.get('Email__c'),mStaging);
                }
                //collects student ids from inserted marketing stagings
                if(mStaging.get('QUT_Student_ID__c') != null){
                    studentIdMap.put((String)mStaging.get('QUT_Student_ID__c'),mStaging);
                }
                //collect marketing staging mobile
                if(mStaging.get('Mobile__c') !=null){
                    mobileMap.put((String)mStaging.get('Mobile__c'),mStaging);
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
        contactMatches = new Map<Id,Contact>([  SELECT Id, QUT_Student_ID__c, Email, Mobile_No_Locale__c, BirthDate
                            FROM Contact
                            WHERE (Email IN: emailMap.keySet()
                            OR Mobile_No_Locale__c IN: mobileMap.keySet()
                            OR QUT_Student_ID__c IN:studentIdMap.keySet())
                            ]);

        leadMatches = new Map<Id,Lead>([ SELECT Id, Email, Mobile_No_Locale__c, hed__Birth_Date__c
                        FROM Lead
                        WHERE (Email IN:emailMap.keySet()
                        OR Mobile_No_Locale__c IN: mobileMap.keySet())]);

        //get existing marketingrecords
        marketingClass = MarketingStagingMatchingHelper.getRelatedMarketingRecords(
            leadMatches.values(),
            contactMatches.values(),
            qtacMatchingMap.values(),
            samsMatchingMap.values(),
            studylinkMatchingMap.values()
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
                    
                    marStageToUpdateMap.put((Id)mStaging.get('Id'), new Marketing_Staging__c(
                        Id = (Id)mStaging.get('Id'),
                        Lead__c = matchingClass.leadEmailMap.get(key)[0].Id 
                        )
                    );
                    continue;
                }
            }
            if(mStaging.get('Mobile__c') != null){
                key = (String)mStaging.get('Mobile__c');
                if( matchingClass.contactMobileMap.containsKey(key)  && 
                    matchingClass.contactMobileMap.get(key).size() == 1
                ){
                    contactsToUpsertMap.put(
                        matchingClass.contactMobileMap.get(key)[0].Id,
                        (Contact)MarketingStagingMatchingHelper.createContactRecord(
                            mStaging,
                            matchingClass.contactMobileMap.get(key)[0].Id,
                            salutaionValues
                        )
                    );
    
                    recordsClass = MarketingStagingMatchingHelper.processMarketingMatching(
                        null,(String)matchingClass.contactMobileMap.get(key)[0].Id,(Marketing_Staging__c)mStaging, 
                        marketingClass.contactSegMap,marketingClass.contactAppMap,
                        qtacMatchingMap, samsMatchingMap, studylinkMatchingMap
                    );
    
                    if(!recordsClass.segmentationToUpsertMap.keySet().isEmpty()){
                        marSegmentationToUpsertMap.putAll(recordsClass.segmentationToUpsertMap);
                    }
                    if(!recordsClass.applicationToUpsertMap.keySet().isEmpty()){
                        marCourseAppToUpsertMap.putAll(recordsClass.applicationToUpsertMap);
                    }

                    marStageToUpdateMap.put((Id)mStaging.get('Id'), new Marketing_Staging__c(
                        Id = (Id)mStaging.get('Id'),
                        Contact__c = matchingClass.contactMobileMap.get(key)[0].Id 
                        )
                    );
                    continue;
                }
                if( matchingClass.leadMobileMap.containsKey(key) &&
                    matchingClass.leadMobileMap.get(key).size() == 1
                ){
                    leadsToUpsertMap.put(
                        matchingClass.leadMobileMap.get(key)[0].Id,
                        (Lead)MarketingStagingMatchingHelper.createLeadRecord(
                            mStaging,
                            matchingClass.leadMobileMap.get(key)[0].Id,
                            salutaionValues
                        )
                    );
    
                    recordsClass = MarketingStagingMatchingHelper.processMarketingMatching(
                        (String)matchingClass.leadMobileMap.get(key)[0].Id,null, (Marketing_Staging__c)mStaging, 
                        marketingClass.leadSegMap,marketingClass.leadAppMap,
                        qtacMatchingMap, samsMatchingMap, studylinkMatchingMap
                    );
    
                    if(!recordsClass.segmentationToUpsertMap.keySet().isEmpty()){
                        marSegmentationToUpsertMap.putAll(recordsClass.segmentationToUpsertMap);
                    }
                    if(!recordsClass.applicationToUpsertMap.keySet().isEmpty()){
                        marCourseAppToUpsertMap.putAll(recordsClass.applicationToUpsertMap);
                    }
                    
                    marStageToUpdateMap.put((Id)mStaging.get('Id'), new Marketing_Staging__c(
                        Id = (Id)mStaging.get('Id'),
                        Lead__c = matchingClass.leadMobileMap.get(key)[0].Id 
                        )
                    );
                    continue;
                }
            }

            if(mStaging.get('Last_Name__c') != null){
                leadsToUpsertMap.put(
                    (Id)mStaging.get('Id'),
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
        }

        if(!leadsToUpsertMap.keySet().isEmpty()){
            Database.upsert(leadsToUpsertMap.values(),false);

            for(String leadKey: leadsToUpsertMap.keySet()){
                //if linked to marketingstaging create new marketing records 
                //and link to the lead
                if(newMap.containsKey(leadKey)){
                    //create marketing segmentation records
                    marSegmentationToUpsertMap.put(
                        leadKey,
                        (Marketing_Segmentation__c) MarketingStagingMatchingHelper.createMarketingRecord(
                            newMap.get(leadKey),
                            null,
                            leadsToUpsertMap.get(leadKey).Id,
                            null,
                            'Marketing_Segmentation__c'
                        )
                    );

                    //check first if application data is populated 
                    if( qtacMatchingMap.containsKey(leadKey) || samsMatchingMap.containsKey(leadKey) || studylinkMatchingMap.containsKey(leadKey)){
                        marCourseAppToUpsertMap.put(
                            leadKey,
                            (Marketing_Course_Application__c)MarketingStagingMatchingHelper.createMarketingRecord(
                                newMap.get(leadKey),
                                null,
                                leadsToUpsertMap.get(leadKey).Id,
                                null,
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
            }
        }

        if(!marSegmentationToUpsertMap.keySet().isEmpty()){
            Database.upsert(marSegmentationToUpsertMap.values(),false);

            for(String segKey: marSegmentationToUpsertMap.keySet()){
                
                if(newMap.containsKey(segKey)){
                    //create marketing interaction records
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
                                marSegmentationToUpsertMap.get(segKey).Contact__c,
                                marSegmentationToUpsertMap.get(segKey).Lead__c,
                                marSegmentationToUpsertMap.get(segKey).Id,
                                'Marketing_Interaction__c'
                            )
                        );
                    }
                }
            }
        }

        if(!marInteractionToInsertMap.keySet().isEmpty()){
            Database.upsert(marInteractionToInsertMap.values(),false);
        }

        if(!marCourseAppToUpsertMap.keySet().isEmpty()){
            Database.upsert(marCourseAppToUpsertMap.values(),false);
        }

        if(!marStageToUpdateMap.keySet().isEmpty()){
            Database.update(marStageToUpdateMap.values(),false);
        }

    }
}