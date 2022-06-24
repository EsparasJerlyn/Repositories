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
    Map<String,sObject> studentIdMarStagingMap = new Map<String, sObject>();
    Map<String,String> actionMap =  new Map<String,String>();
    List<Contact> contactMatches = new List<Contact>();
    List<Contact> contactMatchesWithId = new List<Contact>();
    List<Lead> leadMatches = new List<Lead>();
    Map<String,List<Contact>> contactMatchMapping = new Map<String,List<Contact>>();
    Map<String,List<Contact>> contactMatchWithIdMapping = new Map<String,List<Contact>>();
    Map<String,List<Lead>> leadMatchMapping = new Map<String,List<Lead>>();
    Map<String,Lead> leadsToUpsertMap = new Map<String,Lead>(); 
    Map<String,Contact> contactsToUpsertMap = new Map<String,Contact>(); 
    Map<String,Marketing_Segmentation__c> marSegmentationToUpsertMap = new Map<String,Marketing_Segmentation__c>();
    Map<String,Marketing_Interaction__c> marInteractionToInsertMap = new Map<String,Marketing_Interaction__c>();
    Map<String,Marketing_Course_Application__c> marCourseAppToUpsertMap = new Map<String,Marketing_Course_Application__c>();
    Map<String,Marketing_Staging__c> marStageToUpdateMap = new Map<String, Marketing_Staging__c>();
    Map<Id,List<Marketing_Segmentation__c>> contactToSegmentationsMap = new Map<Id,List<Marketing_Segmentation__c>>();
    Map<Id,List<Marketing_Course_Application__c>> contactToAppMap = new Map<Id,List<Marketing_Course_Application__c>>();
    Map<Id,List<Marketing_Segmentation__c>> leadToSegmentationsMap = new Map<Id,List<Marketing_Segmentation__c>>();
    Map<Id,List<Marketing_Course_Application__c>> leadToAppMap = new Map<Id,List<Marketing_Course_Application__c>>();
    Map<String,String> studentIdToNameEmailMap = new Map<String,String>();

    Set<String> lastNameList = new Set<String>();
    Set<String> emailList = new Set<String>();
    Set<String> qutStudentIdList = new Set<String>();
    Map<String,String> qtacMatchingMap = new Map<String,String>();
    Map<String,String> samsMatchingMap = new Map<String,String>();
    Map<String,String> studylinkMatchingMap = new Map<String,String>();
    Map<String,String> qtacMatchingConMap = new Map<String,String>();
    Map<String,String> samsMatchingConMap = new Map<String,String>();
    Map<String,String> studylinkMatchingConMap = new Map<String,String>();
    List<Contact> currentContacts;

    List<Potential_Duplicate__c> potentialDupToInsertList = new List<Potential_Duplicate__c>();
    List<String> salutaionValues = new List<String>();
    salutaionValues.addAll(MarketingStagingTriggerHelper.getSalutations());
    system.debug(salutaionValues);

    for(sObject mStaging: newItems.values()){


        //make sure last name amd email is populated
        if(mStaging.get('Last_Name__c') !=null && mStaging.get('Email__c') != null && mStaging.get('Name_and_Email__c') != null){

            //collects student ids from inserted marketing stagings
            //create a map of student ids and marketing staging
            if(mStaging.get('QUT_Student_ID__c') != null){
                qutStudentIdList.add((String)mStaging.get('QUT_Student_ID__c'));
                studentIdMarStagingMap.put((String)mStaging.get('QUT_Student_ID__c'),mStaging);
                studentIdToNameEmailMap.put((String)mStaging.get('QUT_Student_ID__c'),(String)mStaging.get('Name_and_Email__c'));
            }

            //create marketing staging map where key is the firstname lastname and email
            marStagingMap.put((String)mStaging.get('Name_and_Email__c'),mStaging);

            lastNameList.add((String)mStaging.get('Last_Name__c'));
            emailList.add((String)mStaging.get('Email__c'));

            //create Application Source criteria map against the marketing staging records

            if( mStaging.get('Application_Source__c') == 'QTAC' && 
                mStaging.get('Applicant_Id__c') != null &&
                mStaging.get('Preference_Number__c') != null){

                    qtacMatchingMap.put((String)mStaging.get('Name_and_Email__c'),(String)mStaging.get('QTAC_Matching_Criteria__c'));
                if(mStaging.get('QUT_Student_ID__c') != null){
                    qtacMatchingConMap.put((String)mStaging.get('QUT_Student_ID__c'),(String)mStaging.get('QTAC_Matching_Criteria__c'));
                }
                

            }else if(   mStaging.get('Application_Source__c') == 'SAMS' && 
                        mStaging.get('QUT_Student_ID__c') != null &&
                        mStaging.get('Admission_Period__c') != null &&
                        mStaging.get('Course_Code__c') != null &&
                        mStaging.get('Admission_Year__c') != null){

                            samsMatchingMap.put((String)mStaging.get('Name_and_Email__c'),(String)mStaging.get('SAMS_Matching_Criteria__c')); 
                            samsMatchingConMap.put((String)mStaging.get('QUT_Student_ID__c'),(String)mStaging.get('SAMS_Matching_Criteria__c'));

            }else if(   mStaging.get('Application_Source__c') == 'Studylink' && 
                        mStaging.get('Application_Id__c') != null &&
                        mStaging.get('Applicant_Id__c') != null ){

                            studylinkMatchingMap.put((String)mStaging.get('Name_and_Email__c'),(String)mStaging.get('Studylink_Matching_Criteria__c')); 
                            studylinkMatchingConMap.put((String)mStaging.get('QUT_Student_ID__c'),(String)mStaging.get('Studylink_Matching_Criteria__c'));

            }
        }          
    }

    //get all matching contacts with the same student ids of inserted marketing staging records
    if(!qutStudentIdList.isEmpty() && !studentIdMarStagingMap.keySet().isEmpty()){ 
        contactMatchesWithId = [  SELECT Id, QUT_Student_ID__c
                            FROM Contact 
                            WHERE QUT_Student_ID__c IN:qutStudentIdList];
                            
    }

    //make sure email and lastname is populated 
    if(!emailList.isEmpty() && !lastNameList.isEmpty()){
        
        //get all matching contacts and leads
        if(!marStagingMap.keySet().isEmpty()){

            contactMatches = [  SELECT Id, Name_and_Email__c, QUT_Student_ID__c
                                FROM Contact 
                                WHERE Id NOT IN: contactMatchesWithId
                                AND Name_and_Email__c IN: marStagingMap.keySet()
                                AND LastName IN:lastNameList
                                AND Email IN:emailList];

            leadMatches = [  SELECT Id, Name_and_Email__c
                            FROM Lead 
                            WHERE Name_and_Email__c IN: marStagingMap.keySet() 
                            AND LastName IN:lastNameList
                            AND Email IN:emailList];    
        }
        //created new query for related marketing segmentation to reduce contact/lead query size
        for(Marketing_Segmentation__c marSeg: [ SELECT Id, Contact__c, Lead__c 
                                                FROM Marketing_Segmentation__c 
                                                WHERE Lead__c IN: leadMatches 
                                                OR Contact__c IN: contactMatches
                                                OR Contact__c IN : contactMatchesWithId]){
         //create a contact map against the marketing segmentation records                                           
            if(marSeg.Contact__c != null){
                if(!contactToSegmentationsMap.containsKey(marSeg.Contact__c)){
                    contactToSegmentationsMap.put(marSeg.Contact__c, new List<Marketing_Segmentation__c>());
                }
                contactToSegmentationsMap.get(marSeg.Contact__c).add(marSeg);
            }else if(marSeg.Lead__c != null){
                if(!leadToSegmentationsMap.containsKey(marSeg.Lead__c)){
                    leadToSegmentationsMap.put(marSeg.Lead__c, new List<Marketing_Segmentation__c>());
                }
                leadToSegmentationsMap.get(marSeg.Lead__c).add(marSeg);
            }                                        
        }

        //created new query for related marketing application to reduce lead/lead query size
        for(Marketing_Course_Application__c marCourApp: [SELECT Id, QUT_Student_ID__c, Contact__c, Lead__c, Studylink_Matching_Criteria__c,
                                                QTAC_Matching_Criteria__c, SAMS_Matching_Criteria__c
                                                FROM Marketing_Course_Application__c 
                                                WHERE (Lead__c IN: leadMatches 
                                                OR Contact__c IN: contactMatches
                                                OR Contact__c IN : contactMatchesWithId)
                                                AND ( QTAC_Matching_Criteria__c IN: qtacMatchingMap.values() 
                                                OR QTAC_Matching_Criteria__c IN: qtacMatchingConMap.values()
                                                OR SAMS_Matching_Criteria__c IN: samsMatchingConMap.values()
                                                OR Studylink_Matching_Criteria__c IN: studylinkMatchingConMap.values()   
                                                )]){
        //create a contact map against the marketing segmentation records 
            if(marCourApp.Contact__c != null){
                if(!contactToAppMap.containsKey(marCourApp.Contact__c)){
                    contactToAppMap.put(marCourApp.Contact__c, new List<Marketing_Course_Application__c>());
                }
                contactToAppMap.get(marCourApp.Contact__c).add(marCourApp);
            }else if(marCourApp.Lead__c != null){
                if(!leadToAppMap.containsKey(marCourApp.Lead__c)){
                    leadToAppMap.put(marCourApp.Lead__c, new List<Marketing_Course_Application__c>());
                }
                leadToAppMap.get(marCourApp.Lead__c).add(marCourApp);
            }                                        
        }
                       
        for(Contact conWithId : contactMatchesWithId){
            
            //create map that groups all contacts with similar studentId
            if(!contactMatchWithIdMapping.containsKey(conWithId.QUT_Student_ID__c)){
                contactMatchWithIdMapping.put(
                    conWithId.QUT_Student_ID__c,
                    new List<Contact>()
                );
            }
            contactMatchWithIdMapping.get(conWithId.QUT_Student_ID__c).add(conWithId);
            
        }

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
/*******START CHECK MARKETING STAGING WITH STUDENT ID AGAINST EXISTING CONTACTS START*******/

        for(String studentIdKey : studentIdMarStagingMap.keySet()){
            if(//1 matching contact
                contactMatchWithIdMapping.containsKey(studentIdKey)  && 
                contactMatchWithIdMapping.get(studentIdKey).size() == 1
            ){ 
                actionMap.put(studentIdKey,'ONE_CONTACT_MATCH');
                //update contact matchingrecorcds
                contactsToUpsertMap.put(
                    studentIdKey,
                    (Contact)MarketingStagingTriggerHelper.createContactRecord(
                        studentIdMarStagingMap.get(studentIdKey),
                        contactMatchWithIdMapping.get(studentIdKey)[0].Id,
                        salutaionValues
                    )
                );

                marStagingMap.remove(studentIdToNameEmailMap.get(studentIdKey));

                if(contactMatchWithIdMapping.containsKey(studentIdKey) && contactToSegmentationsMap.containsKey(contactMatchWithIdMapping.get(studentIdKey)[0].Id)){
                    for(Marketing_Segmentation__c segmenation: contactToSegmentationsMap.get(contactMatchWithIdMapping.get(studentIdKey)[0].Id)){
                        marSegmentationToUpsertMap.put(
                            studentIdKey,
                            (Marketing_Segmentation__c)MarketingStagingTriggerHelper.createMarketingSegmentationRecord(
                                studentIdMarStagingMap.get(studentIdKey),
                                segmenation.Contact__c,
                                segmenation.Lead__c,
                                segmenation.Id
                            )
                        ); 
                    }
                }else{
                    //create new segmenation record
                    marSegmentationToUpsertMap.put(
                        studentIdKey,
                        (Marketing_Segmentation__c)MarketingStagingTriggerHelper.createMarketingSegmentationRecord(
                            studentIdMarStagingMap.get(studentIdKey),
                            contactMatchWithIdMapping.get(studentIdKey)[0].Id,
                            null,
                            null
                        )
                    );
                }
                
                if(contactMatchWithIdMapping.containsKey(studentIdKey) && contactToAppMap.containsKey(contactMatchWithIdMapping.get(studentIdKey)[0].Id)){
                    for(Marketing_Course_Application__c courseApp: contactToAppMap.get(contactMatchWithIdMapping.get(studentIdKey)[0].Id)){
                        marCourseAppToUpsertMap.put(
                            studentIdKey,
                        (Marketing_Course_Application__c) MarketingStagingTriggerHelper.createMarketingCourseAppRecord(
                            studentIdMarStagingMap.get(studentIdKey),
                            courseApp.Contact__c,
                            courseApp.Lead__c,
                            courseApp.Id
                            )
                        );
                    }
                }else if(   qtacMatchingConMap.containsKey(studentIdKey) || 
                            samsMatchingConMap.containsKey(studentIdKey) || 
                            studylinkMatchingConMap.containsKey(studentIdKey)){
                            marCourseAppToUpsertMap.put(
                                studentIdKey,
                                (Marketing_Course_Application__c) MarketingStagingTriggerHelper.createMarketingCourseAppRecord(
                                    studentIdMarStagingMap.get(studentIdKey),
                                    contactMatchWithIdMapping.get(studentIdKey)[0].Id,
                                    null,
                                    null
                                )
                            );
                }

            }
            // else if(// more than 1 matching contacts
            // contactMatchWithIdMapping.containsKey(studentIdKey) && 
            // contactMatchWithIdMapping.get(studentIdKey).size() > 1
            // ){ 
            //     actionMap.put(studentIdKey,'MULTI_CONTACT_MATCH');
            //     //create lead records
            //     leadsToUpsertMap.put(
            //         studentIdKey,
            //         (Lead) MarketingStagingTriggerHelper.createLeadRecord(
            //             studentIdMarStagingMap.get(studentIdKey),
            //             null,
            //             salutaionValues
            //         )
            //     );

            // }
        }

/*******END CHECK MARKETING STAGING WITH STUDENT ID AGAINST EXISTING CONTACTS  END*******/

/******* START CHECK MARKETING STAGING FIRST LAST NAME AND EMAIL AGAINST EXISTING LEADS AND CONTACTS START *******/

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
                        contactMatchMapping.get(nameEmailItem)[0].Id,
                        salutaionValues
                    )
                );

                if(contactMatchMapping.containsKey(nameEmailItem) && contactToSegmentationsMap.containsKey(contactMatchMapping.get(nameEmailItem)[0].Id)){
                    for(Marketing_Segmentation__c segmenation: contactToSegmentationsMap.get(contactMatchMapping.get(nameEmailItem)[0].Id)){
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
                
                if(contactMatchMapping.containsKey(nameEmailItem) && contactToAppMap.containsKey(contactMatchMapping.get(nameEmailItem)[0].Id)){
                    for(Marketing_Course_Application__c courseApp: contactToAppMap.get(contactMatchMapping.get(nameEmailItem)[0].Id)){
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
                }else if(   qtacMatchingMap.containsKey(nameEmailItem) || 
                            samsMatchingMap.containsKey(nameEmailItem) || 
                            studylinkMatchingMap.containsKey(nameEmailItem)){
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

            // }else if(// more than 1 matching contacts
            //     contactMatchMapping.containsKey(nameEmailItem) && 
            //     contactMatchMapping.get(nameEmailItem).size() > 1
            // ){ 
            //     actionMap.put(nameEmailItem,'MULTI_CONTACT_MATCH');

            //     //create lead records
            //     leadsToUpsertMap.put(
            //         nameEmailItem,
            //         (Lead) MarketingStagingTriggerHelper.createLeadRecord(
            //             marStagingMap.get(nameEmailItem),
            //             null,
            //             salutaionValues
            //         )
            //     );

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
                        leadMatchMapping.get(nameEmailItem)[0].Id,
                        salutaionValues
                    )
                );

                
                if(leadMatchMapping.containsKey(nameEmailItem) && leadToSegmentationsMap.containsKey(leadMatchMapping.get(nameEmailItem)[0].Id)){
                    for(Marketing_Segmentation__c segmentation: leadToSegmentationsMap.get(leadMatchMapping.get(nameEmailItem)[0].Id)){
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

                if(leadMatchMapping.containsKey(nameEmailItem) && leadToAppMap.containsKey(leadMatchMapping.get(nameEmailItem)[0].Id)){
                    for(Marketing_Course_Application__c courseApp: leadToAppMap.get(leadMatchMapping.get(nameEmailItem)[0].Id)){
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
                }else if(   qtacMatchingMap.containsKey(nameEmailItem) || 
                            samsMatchingMap.containsKey(nameEmailItem) || 
                            studylinkMatchingMap.containsKey(nameEmailItem)){
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

            // }else if(// more than 1 matching leads
            //     !contactMatchMapping.containsKey(nameEmailItem) &&
            //     leadMatchMapping.containsKey(nameEmailItem) && 
            //     leadMatchMapping.get(nameEmailItem).size() > 1
            // ){ 
            //     actionMap.put(nameEmailItem,'MULTI_LEAD_MATCH');
            //     //create lead records
            //     leadsToUpsertMap.put(
            //         nameEmailItem,
            //         (Lead) MarketingStagingTriggerHelper.createLeadRecord(
            //             marStagingMap.get(nameEmailItem),
            //             null,
            //             salutaionValues
            //         )
            //     );
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
                        null,
                        salutaionValues
                    )
                );
            }
        }
    }
/******* END CHECK MARKETING STAGING FIRST LAST NAME AND EMAIL AGAINST EXISTING LEADS AND CONTACTS END *******/

/******* START UPSERT CONTACTS START *******/

    if(!contactsToUpsertMap.isEmpty()){
        upsert contactsToUpsertMap.values();
        for(String conKey : contactsToUpsertMap.keySet()){
            sObject conStaging;
            if(marStagingMap.containsKey(conKey)){
                conStaging = marStagingMap.get(conKey);
            }else{
                conStaging = studentIdMarStagingMap.get(conKey);
            }
    
            marStageToUpdateMap.put((Id)conStaging.get('Id'), new Marketing_Staging__c(
                Id = (Id)conStaging.get('Id'),
                Contact__c = contactsToUpsertMap.get(conKey).Id 
                )
            );
        }
    }
/******* END UPSERT CONTACTS END *******/


/******* START UPSERT LEADS START *******/
    if(!leadsToUpsertMap.isEmpty()){
        upsert leadsToUpsertMap.values();
    }
/******* END UPSERT CONTACTS END *******/

    //after lead insertion
    //create marketing records

/******* START PROCESS MARKETING RECORDS AGAINS THE LEAD START *******/
    for(String leadKey : leadsToUpsertMap.keySet()){
        sObject currentStaging;
        currentContacts = new List<Contact>();

        if(marStagingMap.containsKey(leadKey)){
            currentStaging = marStagingMap.get(leadKey);
        }else{
            currentStaging = studentIdMarStagingMap.get(leadKey);
        }

        if(contactMatchMapping.containsKey(leadKey)){
            currentContacts = contactMatchMapping.get(leadKey);
        }else{
            currentContacts = contactMatchWithIdMapping.get(leadKey);
        }

        if( 
            actionMap.get(leadKey) == 'ZERO_MATCH' // || 
            // actionMap.get(leadKey) == 'MULTI_LEAD_MATCH' || 
            // actionMap.get(leadKey) == 'MULTI_CONTACT_MATCH'
        ){
            //create markeeting segmentation records
            marSegmentationToUpsertMap.put(
                leadKey,
                (Marketing_Segmentation__c) MarketingStagingTriggerHelper.createMarketingSegmentationRecord(
                    currentStaging,
                    null,
                    leadsToUpsertMap.get(leadKey).Id,
                    null
                )
            );

            //check first if application data is populated 
            if( qtacMatchingMap.containsKey(leadKey) || samsMatchingMap.containsKey(leadKey) || studylinkMatchingMap.containsKey(leadKey) ||
                qtacMatchingConMap.containsKey(leadKey) || samsMatchingConMap.containsKey(leadKey) || studylinkMatchingConMap.containsKey(leadKey)){
                marCourseAppToUpsertMap.put(
                    leadKey,
                    (Marketing_Course_Application__c) MarketingStagingTriggerHelper.createMarketingCourseAppRecord(
                        currentStaging,
                        null,
                        leadsToUpsertMap.get(leadKey).Id,
                        null
                    )
                );
            }
        }

        // if(actionMap.get(leadKey) == 'MULTI_CONTACT_MATCH'){
        //     //link new lead to contacts
        //     potentialDupToInsertList.addAll(
        //         MarketingStagingTriggerHelper.createPotentialDupRecords(
        //             leadsToUpsertMap.get(leadKey).Id,
        //             currentContacts,
        //             CONTACT_API_NAME
        //         )
        //     );
        // }

        // if(actionMap.get(leadKey) == 'MULTI_LEAD_MATCH'){
        //     //link new lead to leads
        //     potentialDupToInsertList.addAll(
        //         MarketingStagingTriggerHelper.createPotentialDupRecords(
        //             leadsToUpsertMap.get(leadKey).Id,
        //             leadMatchMapping.get(leadKey),
        //             LEAD_API_NAME
        //         )
        //     );
        // }

        marStageToUpdateMap.put((Id)currentStaging.get('Id'), new Marketing_Staging__c(
            Id = (Id)currentStaging.get('Id'),
            Lead__c = leadsToUpsertMap.get(leadKey).Id 
            )
        );
    }
    //upsert marketing segmentation records
    if(!marSegmentationToUpsertMap.isEmpty()){
        upsert marSegmentationToUpsertMap.values();
        for(String segKey: marSegmentationToUpsertMap.keySet()){
            sObject staging;
            if(marStagingMap.containsKey(segKey)){
                staging = marStagingMap.get(segKey);
            }else{
                staging = studentIdMarStagingMap.get(segKey);
            }
            //create marketing interaction records
            if( staging.get('Interaction_Type__c')!=null ||
                staging.get('Interaction_DateTime__c')!=null ||
                staging.get('Lead_Source_Category__c')!=null ||
                staging.get('Lead_Source__c')!=null ||
                staging.get('SPAD__c')!=null ||
                staging.get('Event_Name__c')!=null ){
                marInteractionToInsertMap.put(
                    segKey,
                    (Marketing_Interaction__c) MarketingStagingTriggerHelper.createMarketingInteractionRecord(
                            staging,
                            marSegmentationToUpsertMap.get(segKey).Contact__c,
                            marSegmentationToUpsertMap.get(segKey).Lead__c,
                            marSegmentationToUpsertMap.get(segKey).Id
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

    /******* END PROCESS MARKETING RECORDS AGAINST THE LEAD END *******/
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