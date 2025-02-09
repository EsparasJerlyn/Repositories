/**
 * @description DAO Class for Opportunity Object. Contains soql and constants related to the Opportunity object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                         |
 *    |--------------------------------|-----------------------|------------------------|----------------------------------------|
 *    | roy.nino.s.regala              | May 04, 2023          | DEPP-5587              | Created file                           |
 *    | alexander.cadalin              | May 17, 2023          | DEPP-5594              | added methods                          |
 *    | carl.alvin.cabiles             | May 25, 2023          | DEPP-5410              | added getRecordsBySetName method       |
 *    | kenneth.f.alsay                | June 16, 2023         | DEPP-5434, 5399        | added getRecordsByStartingName method  |
 *    | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | added method getOpportunityByAccountIds|
 *    | marygrace.li@qut.edu.au        | August 7, 2023        | DEPP-6275              | Updated to Pure_Project_ID1__c before deleting the field  |
      | marygrace.li@qut.edu.au        | August 7, 2023        | DEPP-6275              | Updated to Pure_Project_ID__c field      |
 */
public inherited sharing class OpportunitiesDAO extends DmlBase implements IOpportunitiesDAO {
    public static final Id COMMERCIALIZATION_RECTYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get('Commercialisation') 
        .getRecordTypeId();
    public static final Id INTERNATIONALPROJECTSUNIT_RECTYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get('International_Projects_Unit')
        .getRecordTypeId();
    public static final Id RESEARCHPARTNERSHIP_RECTYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get('Research_Partnership')
        .getRecordTypeId();

    public static final String IDENTIFY_STAGE = 'Identify';
    public Schema.SObjectType getSObjectType() {
        return Opportunity.SObjectType;
    }

    public static IOpportunitiesDAO newInstance() {
        return (IOpportunitiesDAO) ImplementationSelector.DAO.newInstance(Opportunity.SObjectType);
    }

    public static List<Opportunity> getRecordsSortByOpportunityCodeAsc() {
        return [ //NOPMD
            SELECT Id, Opportunity_Code__c, Name
            FROM Opportunity
            WITH USER_MODE
            ORDER BY Opportunity_Code__c ASC
        ];
    }

    public static List<Opportunity> getRecordsWithLikeOpportunityCodeSortAsc(String codeIsLike) {
        return [ //NOPMD
            SELECT Id, Opportunity_Code__c
            FROM Opportunity
            WHERE Opportunity_Code__c LIKE :codeIsLike
            WITH USER_MODE
            ORDER BY Opportunity_Code__c ASC
        ];
    }

    public static List<Opportunity> getRecordsBySetName(Set<String> names) {
        return [ //NOPMD
            SELECT Id
            FROM Opportunity
            WHERE Name IN :names
            WITH USER_MODE
        ];
    }

    public List<Opportunity> getRecordsLikeName(
        String name,
        boolean wildCardBeforeName,
        String wildCard
    ) {
        name = wildCardBeforeName ? (wildCard + name) : (name + wildCard);
        return [ //NOPMD
            SELECT Id
            FROM Opportunity
            WHERE Name LIKE :name
            WITH USER_MODE
        ];
    }

    public static List<Opportunity> getRecordsByStageName(String stageName) {
        return [ //NOPMD
            SELECT Id
            FROM Opportunity
            WHERE StageName = :stageName
            WITH USER_MODE
        ];
    }

    public static List<Opportunity> getRecordsBySetIds(Set<Id> ids) {
        return [ //NOPMD
            SELECT Id, Memo_Status__c, Memo_PDF_URL__c, OwnerId, Description, Pure_Project_ID__c, CreatedDate
            FROM Opportunity
            WHERE ID IN :ids
            WITH USER_MODE
        ];
    }
    public static List<Opportunity> getOpportunityByAccountIds(
        Set<Id> accountIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id, AccountId ' +
            'FROM Opportunity ' +
            'WHERE AccountId IN :accountIds ' + 
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }
}