/**
 * @description Controller Class for Lead Scoring
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | w.li                           | June 05, 2022         | DEPP-1058              | Created file                 |
      |                                |                       |                        |                              |
 */
public without sharing class LeadScoringManager {
    
    public static void rollupScore(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){

        List<Marketing_Segmentation__c> newMarketingSegmentations = [SELECT Id, Score__c, Lead__c, Lead__r.Id, Lead__r.IsConverted, Contact__c, Contact__r.Id FROM Marketing_Segmentation__c WHERE Id IN :newItems.keySet()];
        List<Marketing_Course_Application__c> newMarketingCourseApplications =[SELECT Id, Score__c, Lead__c, Lead__r.Id, Lead__r.IsConverted, Contact__c, Contact__r.Id FROM Marketing_Course_Application__c WHERE Id IN :newItems.keySet()];
        List<Marketing_Interaction__c> newMarketingInteractions =[SELECT Id, Score__c, Lead__c, Lead__r.Id, Lead__r.IsConverted, Contact__c, Contact__r.Id FROM Marketing_Interaction__c WHERE Id IN :newItems.keySet()];
        List<et4ae5__IndividualEmailResult__c> newIndividualEmailResults =[SELECT Id, Score__c, Primary_Lead__c, Primary_Lead__r.Id, Primary_Lead__r.IsConverted, Primary_Contact__c, Primary_Contact__r.Id FROM et4ae5__IndividualEmailResult__c WHERE Id IN :newItems.keySet()];

        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for (Marketing_Segmentation__c marketingSegmentation : newMarketingSegmentations) {
            if (marketingSegmentation.Lead__c != null && marketingSegmentation.Lead__r.IsConverted != true) {
                leadIds.add(marketingSegmentation.Lead__r.Id);
            }
            if (marketingSegmentation.Contact__c != null) {
                contactIds.add(marketingSegmentation.Contact__r.Id);
            }
        }

        for (Marketing_Course_Application__c marketingCourseApplication : newMarketingCourseApplications) {
            if (marketingCourseApplication.Lead__c != null && marketingCourseApplication.Lead__r.IsConverted != true) {
                leadIds.add(marketingCourseApplication.Lead__r.Id);
            }
            if (marketingCourseApplication.Contact__c != null) {
                contactIds.add(marketingCourseApplication.Contact__r.Id);
            }
        }

        for (Marketing_Interaction__c marketingInteraction : newMarketingInteractions) {
            if (marketingInteraction.Lead__c != null && marketingInteraction.Lead__r.IsConverted != true) {
                leadIds.add(marketingInteraction.Lead__r.Id);
            }
            if (marketingInteraction.Contact__c != null) {
                contactIds.add(marketingInteraction.Contact__r.Id);
            }
        }

        for (et4ae5__IndividualEmailResult__c individualEmailResult : newIndividualEmailResults) {
            if (individualEmailResult.Primary_Lead__c != null && individualEmailResult.Primary_Lead__r.IsConverted != true) {
                leadIds.add(individualEmailResult.Primary_Lead__r.Id);
            }
            if (individualEmailResult.Primary_Contact__c != null) {
                contactIds.add(individualEmailResult.Primary_Contact__r.Id);
            }
        }

        calculateScore(leadIds, contactIds);
        
    }

    @future
    public static void calculateScore(Set<Id> leadIds, Set<Id> contactIds){
        
        Map<Id, Map<String, Decimal>> leadToScore = new Map<Id, Map<String, Decimal>>();
        Map<Id, Map<String, Decimal>> contactToScore = new Map<Id, Map<String, Decimal>>();
        
        List<Marketing_Segmentation__c> existingMarketingSegmentations =[SELECT Id, Score__c, Lead__c, Lead__r.Id, Lead__r.IsConverted, Contact__c, Contact__r.Id FROM Marketing_Segmentation__c WHERE Lead__r.Id IN :leadIds OR Contact__r.Id IN :contactIds];
        List<Marketing_Course_Application__c> existingMarketingCourseApplications =[SELECT Id, Score__c, Lead__c, Lead__r.Id, Lead__r.IsConverted, Contact__c, Contact__r.Id FROM Marketing_Course_Application__c WHERE Lead__r.Id IN :leadIds OR Contact__r.Id IN :contactIds];
        List<Marketing_Interaction__c> existingMarketingInteractions =[SELECT Id, Score__c, Lead__c, Lead__r.Id, Lead__r.IsConverted, Contact__c, Contact__r.Id FROM Marketing_Interaction__c WHERE Lead__r.Id IN :leadIds OR Contact__r.Id IN :contactIds];
        List<et4ae5__IndividualEmailResult__c> existinIndividualEmailResults =[SELECT Id, Score__c, Primary_Lead__c, Primary_Lead__r.Id, Primary_Lead__r.IsConverted, Primary_Contact__c, Primary_Contact__r.Id FROM et4ae5__IndividualEmailResult__c WHERE Primary_Lead__r.Id IN :leadIds OR Primary_Contact__r.Id IN :contactIds];


        for (Marketing_Segmentation__c marketingSegmentation : existingMarketingSegmentations) {
            if (marketingSegmentation.Lead__c != null && marketingSegmentation.Lead__r.IsConverted != true) {
                Map<String, Decimal> fieldToScore = new Map<String, Decimal>();
                fieldToScore.put('Marketing_Segmentation_Score__c', marketingSegmentation.Score__c);
                leadToScore.put(marketingSegmentation.Lead__r.Id, fieldToScore);
            }
            if (marketingSegmentation.Contact__c != null) {
                Map<String, Decimal> fieldToScore = new Map<String, Decimal>();
                fieldToScore.put('Marketing_Segmentation_Score__c', marketingSegmentation.Score__c);
                contactToScore.put(marketingSegmentation.Contact__r.Id, fieldToScore);
            }
        }

        Map<Id, Decimal> leadToMCAScore = new Map<Id, Decimal>();
        Map<Id, Decimal> contactToMCAScore = new Map<Id, Decimal>();

        for (Marketing_Course_Application__c marketingCourseApplication : existingMarketingCourseApplications) {
            if (marketingCourseApplication.Lead__c != null && marketingCourseApplication.Lead__r.IsConverted != true) {
                if (leadToMCAScore.get(marketingCourseApplication.Lead__r.Id) != null) {
                    if (marketingCourseApplication.Score__c > leadToMCAScore.get(marketingCourseApplication.Lead__r.Id)) {
                        leadToMCAScore.put(marketingCourseApplication.Lead__r.Id, marketingCourseApplication.Score__c);
                    }
                } else {
                    leadToMCAScore.put(marketingCourseApplication.Lead__r.Id, marketingCourseApplication.Score__c);
                }    
            }

            if (marketingCourseApplication.Contact__c != null) {
                if (contactToMCAScore.get(marketingCourseApplication.Contact__r.Id) != null) {
                    if (marketingCourseApplication.Score__c > contactToMCAScore.get(marketingCourseApplication.Contact__r.Id)) {
                        contactToMCAScore.put(marketingCourseApplication.Contact__r.Id, marketingCourseApplication.Score__c);
                    }
                } else {
                    contactToMCAScore.put(marketingCourseApplication.Contact__r.Id, marketingCourseApplication.Score__c);
                }
            }
        }

        for (Id id : leadToMCAScore.keySet()) {
            if (leadToScore.get(id) != null) {
                Map<String, Decimal> fieldToScore = leadToScore.get(id);
                fieldToScore.put('Marketing_Course_Application_Score__c', leadToMCAScore.get(id));
                leadToScore.put(id, fieldToScore);
            } else {
                Map<String, Decimal> fieldToScore = new  Map<String, Decimal>();
                fieldToScore.put('Marketing_Course_Application_Score__c', leadToMCAScore.get(id));
                leadToScore.put(id, fieldToScore);
            }
        }

        
        for (Id id : contactToMCAScore.keySet()) {
            if (contactToScore.get(id) != null) {
                Map<String, Decimal> fieldToScore = contactToScore.get(id);
                fieldToScore.put('Marketing_Course_Application_Score__c', contactToMCAScore.get(id));
                contactToScore.put(id, fieldToScore);
            } else {
                Map<String, Decimal> fieldToScore = new  Map<String, Decimal>();
                fieldToScore.put('Marketing_Course_Application_Score__c', contactToMCAScore.get(id));
                contactToScore.put(id, fieldToScore);
            }
        }

        Map<Id, Decimal> leadToMIScore = new Map<Id, Decimal>();
        Map<Id, Decimal> contactToMIScore = new Map<Id, Decimal>();

        for (Marketing_Interaction__c marketingInteraction : existingMarketingInteractions) {
            if (marketingInteraction.Lead__c != null && marketingInteraction.Lead__r.IsConverted != true) {
                if (leadToMIScore.get(marketingInteraction.Lead__r.Id) != null) {
                    leadToMIScore.put(marketingInteraction.Lead__r.Id, leadToMIScore.get(marketingInteraction.Lead__r.Id) + marketingInteraction.Score__c);
                } else {
                    leadToMIScore.put(marketingInteraction.Lead__r.Id, marketingInteraction.Score__c);
                }    
            }

            if (marketingInteraction.Contact__c != null) {
                if (contactToMIScore.get(marketingInteraction.Contact__r.Id) != null) {
                    contactToMIScore.put(marketingInteraction.Contact__r.Id, contactToMIScore.get(marketingInteraction.Contact__r.Id) + marketingInteraction.Score__c);
                } else {
                    contactToMIScore.put(marketingInteraction.Contact__r.Id, marketingInteraction.Score__c);
                }
            }
        }

        for (Id id : leadToMIScore.keySet()) {
            if (leadToScore.get(id) != null) {
                Map<String, Decimal> fieldToScore = leadToScore.get(id);
                fieldToScore.put('Marketing_Interaction_Score__c', leadToMIScore.get(id));
                leadToScore.put(id, fieldToScore);
            } else {
                Map<String, Decimal> fieldToScore = new  Map<String, Decimal>();
                fieldToScore.put('Marketing_Interaction_Score__c', leadToMIScore.get(id));
                leadToScore.put(id, fieldToScore);
            }
        }

        
        for (Id id : contactToMIScore.keySet()) {
            if (contactToScore.get(id) != null) {
                Map<String, Decimal> fieldToScore = contactToScore.get(id);
                fieldToScore.put('Marketing_Interaction_Score__c', contactToMIScore.get(id));
                contactToScore.put(id, fieldToScore);
            } else {
                Map<String, Decimal> fieldToScore = new  Map<String, Decimal>();
                fieldToScore.put('Marketing_Interaction_Score__c', contactToMIScore.get(id));
                contactToScore.put(id, fieldToScore);
            }
        }

        Map<Id, Decimal> leadToIERScore = new Map<Id, Decimal>();
        Map<Id, Decimal> contactToIERScore = new Map<Id, Decimal>();

        for (et4ae5__IndividualEmailResult__c individualEmailResult : existinIndividualEmailResults) {
            if (individualEmailResult.Primary_Lead__c != null && individualEmailResult.Primary_Lead__r.IsConverted != true) {
                if (leadToIERScore.get(individualEmailResult.Primary_Lead__r.Id) != null) {
                    leadToIERScore.put(individualEmailResult.Primary_Lead__r.Id, leadToIERScore.get(individualEmailResult.Primary_Lead__r.Id) + individualEmailResult.Score__c);
                } else {
                    leadToIERScore.put(individualEmailResult.Primary_Lead__r.Id, individualEmailResult.Score__c);
                }    
            }

            if (individualEmailResult.Primary_Contact__c != null) {
                if (contactToIERScore.get(individualEmailResult.Primary_Contact__r.Id) != null) {
                    contactToIERScore.put(individualEmailResult.Primary_Contact__r.Id, contactToIERScore.get(individualEmailResult.Primary_Contact__r.Id) + individualEmailResult.Score__c);
                } else {
                    contactToIERScore.put(individualEmailResult.Primary_Contact__r.Id, individualEmailResult.Score__c);
                }
            }
        }

        for (Id id : leadToIERScore.keySet()) {
            if (leadToScore.get(id) != null) {
                Map<String, Decimal> fieldToScore = leadToScore.get(id);
                fieldToScore.put('IER_Score__c', leadToIERScore.get(id));
                leadToScore.put(id, fieldToScore);
            } else {
                Map<String, Decimal> fieldToScore = new  Map<String, Decimal>();
                fieldToScore.put('IER_Score__c', leadToIERScore.get(id));
                leadToScore.put(id, fieldToScore);
            }
        }

        for (Id id : contactToIERScore.keySet()) {
            if (contactToScore.get(id) != null) {
                Map<String, Decimal> fieldToScore = contactToScore.get(id);
                fieldToScore.put('IER_Score__c', contactToIERScore.get(id));
                contactToScore.put(id, fieldToScore);
            } else {
                Map<String, Decimal> fieldToScore = new  Map<String, Decimal>();
                fieldToScore.put('IER_Score__c', contactToIERScore.get(id));
                contactToScore.put(id, fieldToScore);
            }
        }

        List<Lead> leadsToBeUpdated = new List<Lead>();
        List<Contact> contactsToBeUpdated = new List<Contact>();

        for (Id id : leadIds) {
            Lead lead = new Lead();
            lead.put('Id', id);
            if(leadToScore.containsKey(id)){
                Map<String,Decimal> leadScoreMap = new Map<String,Decimal>(leadToScore.get(id));
                if (leadScoreMap.containsKey('Marketing_Segmentation_Score__c') && leadScoreMap.get('Marketing_Segmentation_Score__c') != null) {
                    lead.put('Marketing_Segmentation_Score__c',  leadToScore.get(id).get('Marketing_Segmentation_Score__c'));
                }
                if (leadScoreMap.containsKey('Marketing_Course_Application_Score__c') && leadScoreMap.get('Marketing_Course_Application_Score__c') != null) {
                    lead.put('Marketing_Course_Application_Score__c',  leadToScore.get(id).get('Marketing_Course_Application_Score__c'));
                }
                if (leadScoreMap.containsKey('Marketing_Interaction_Score__c') && leadScoreMap.get('Marketing_Interaction_Score__c') != null) {
                    lead.put('Marketing_Interaction_Score__c',  leadToScore.get(id).get('Marketing_Interaction_Score__c'));
                }
                if (leadScoreMap.containsKey('IER_Score__c') && leadScoreMap.get('IER_Score__c') != null) {
                    lead.put('IER_Score__c',  leadToScore.get(id).get('IER_Score__c'));
                }
            }
            leadsToBeUpdated.add(lead);
        }

        for (Id id : contactIds) {
            Contact contact = new Contact();
            contact.put('Id', id);
            if (contactToScore.get(id).get('Marketing_Segmentation_Score__c') != null) {
                contact.put('Marketing_Segmentation_Score__c',  contactToScore.get(id).get('Marketing_Segmentation_Score__c'));
            }
            if (contactToScore.get(id).get('Marketing_Course_Application_Score__c') != null) {
                contact.put('Marketing_Course_Application_Score__c',  contactToScore.get(id).get('Marketing_Course_Application_Score__c'));
            }
            if (contactToScore.get(id).get('Marketing_Interaction_Score__c') != null) {
                contact.put('Marketing_Interaction_Score__c',  contactToScore.get(id).get('Marketing_Interaction_Score__c'));
            }
            if (contactToScore.get(id).get('IER_Score__c') != null) {
                contact.put('IER_Score__c',  contactToScore.get(id).get('IER_Score__c'));
            }
            contactsToBeUpdated.add(contact);
        }

        update leadsToBeUpdated;
        update contactsToBeUpdated;

    }
    
}