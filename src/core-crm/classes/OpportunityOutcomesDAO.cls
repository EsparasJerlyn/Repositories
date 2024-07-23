/**
 * @description DAO Class for Opportunity Outcome Object. Contains soql and constants related to the Opportunity Outcome object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | alexander.cadalin              | May 17, 2023          | DEPP-5594              | Created file
 *    | carl.alvin.cabiles             | May 25, 2023          | DEPP-5410              | added methods
 *    | carl.alvin.cabiles             | June 13, 2023         | DEPP-5409              | added methods
 *    | ryan.j.a.dela.cruz             | July 6, 2023          | DEPP-5995              | Added ACTIVE_STAGE
 *    | kenneth.f.alsay                | November 7, 2023      | DEPP-7000              | Added Corporate Partnership Record Type
 *    | kenneth.f.alsay                | February 1, 2024      | DEPP-6938              | Added getActiveCorporateOutcomes
 */
public inherited sharing class OpportunityOutcomesDAO extends DmlBase implements IOpportunityOutcomesDAO {

    public static final Id RESEARCHPARTNERSHIPPROJECT_RECTYPE_ID = Schema.SObjectType.Opportunity_Outcome__c.getRecordTypeInfosByDeveloperName()
        .get('Research_Partnership_Project')
        .getRecordTypeId();
    public static final Id IPUPROJECT_RECTYPE_ID = Schema.SObjectType.Opportunity_Outcome__c.getRecordTypeInfosByDeveloperName()
        .get('IPU_Project')
        .getRecordTypeId();
    public static final Id RESEARCHCOMMERCIALISATIONPROJECT_RECTYPE_ID = Schema.SObjectType.Opportunity_Outcome__c.getRecordTypeInfosByDeveloperName()
        .get('Research_Commercialisation_Project')
        .getRecordTypeId();
    public static final Id STARTUP_RECTYPE_ID = Schema.SObjectType.Opportunity_Outcome__c.getRecordTypeInfosByDeveloperName()
        .get('Startup')
        .getRecordTypeId();
    public static final Id CORPORATEPARTNERSHIP_RECTYPE_ID = Schema.SObjectType.Opportunity_Outcome__c.getRecordTypeInfosByDeveloperName()
        .get('Corporate_Partnership')
        .getRecordTypeId();

    public static final String COMPLETED_STAGE = 'Completed';
    public static final String NEW_STAGE = 'New';
    public static final String ACTIVE_STAGE = 'Active';
    public static final String DECOMMISSIONED_STAGE = 'Decommissioned';

    public Schema.SObjectType getSObjectType() {
        return Opportunity_Outcome__c.SObjectType;
    }

    public static IOpportunityOutcomesDAO newInstance() {
        return (IOpportunityOutcomesDAO) ImplementationSelector.DAO.newInstance(
            Opportunity_Outcome__c.SObjectType
        );
    }

    public static List<Opportunity_Outcome__c> getRecordsSortByCodeAsc() {
        return [ //NO PMD
            SELECT Id, Code__c
            FROM Opportunity_Outcome__c
            WITH USER_MODE
            ORDER BY Code__c ASC
        ];
    }

    public static List<Opportunity_Outcome__c> getRecordsWithLikeCodeSortAsc(String codeIsLike) {
        return [ //NO PMD
            SELECT Id, Code__c
            FROM Opportunity_Outcome__c
            WHERE Code__c LIKE :codeIsLike
            WITH USER_MODE
            ORDER BY Code__c ASC
        ];
    }

    public List<Opportunity_Outcome__c> getRecordsWithEqualEndDate(Date endDate) {
        return [ //NO PMD
            SELECT Id, Stage_Name__c
            FROM Opportunity_Outcome__c
            WHERE End_Date__c = :endDate
            WITH USER_MODE
        ];
    }

    public List<Opportunity_Outcome__c> getRecordsWithNotEqualEndDate(Date endDate) {
        return [ //NO PMD
            SELECT Id, Stage_Name__c
            FROM Opportunity_Outcome__c
            WHERE End_Date__c != :endDate
            WITH USER_MODE
        ];
    }

    public List<Opportunity_Outcome__c> getRecordsWithStartDate(Date startDate) {
        return [ //NO PMD
            SELECT Id, Stage_Name__c
            FROM Opportunity_Outcome__c
            WHERE Start_Date__c = :startDate
            WITH USER_MODE
        ];
    }

    public List<Opportunity_Outcome__c> getRecordsWithOpportunity(List<Id> opportunityList) {
        return [ //NO PMD
            SELECT Id, Opportunity__c
            FROM Opportunity_Outcome__c
            WHERE Opportunity__c IN :opportunityList
            WITH USER_MODE
        ];
    }

    public List<Opportunity_Outcome__c> getRecordsWithPastDateAsDecommissionedDate() {
        return [ //NO PMD
            SELECT Id, Stage_Name__c, End_Date__c, Decommissioned_Date__c, Decommissioned_Reason__c
            FROM Opportunity_Outcome__c
            WHERE Decommissioned_Date__c <= :System.today()
            WITH USER_MODE
        ];
    }

    public List<Opportunity_Outcome__c> getRecordsWithFutureDateAsDecommissionedDate() {
        return [ //NO PMD
            SELECT Id, Stage_Name__c, End_Date__c, Decommissioned_Date__c, Decommissioned_Reason__c
            FROM Opportunity_Outcome__c
            WHERE Decommissioned_Date__c > :System.today()
            WITH USER_MODE
        ];
    }

    public List<Opportunity_Outcome__c> getActiveCorporateOutcomes(AccessLevel accessLevel){
        if(accessLevel != null){       
            return Database.query(
                'SELECT Id, Opportunity__c ' +
                'FROM Opportunity_Outcome__c ' +
                'WHERE Outcome_Is_Active__c = true ',
                accessLevel
            );
        }else{
            return new List<Opportunity_Outcome__c>();
        }      
    }
}
