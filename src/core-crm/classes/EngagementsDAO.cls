/**
 * @description DAO Class for Engagements Object. Contains soql and constants related to the Product object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              |  May 16, 2023         | DEPP-5594              | Created file
      | alexnder.cadalin               |  May 17, 2023         | DEPP-5594              | added methods
 */
public inherited sharing class EngagementsDAO extends DmlBase implements IEngagementsDAO {
    public static final Id RT_ENG_RCE_ID = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('Commercialisation').getRecordTypeId();
    public static final Id RT_ENG_RPE_ID = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('Research_Partnership').getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return Engagement__c.SObjectType;
    }

    public static IEngagementsDAO newInstance() {
        return (IEngagementsDAO) ImplementationSelector.DAO.newInstance(Engagement__c.SObjectType);
    }

    public static List<Engagement__c> getRecordsSortByEngagementCodeAsc() {
        return [
            SELECT Id, Engagement_Code__c 
            FROM Engagement__c 
            WITH SYSTEM_MODE 
            ORDER BY Engagement_Code__c ASC
            ];
    }

    public static List<Engagement__c> getRecordsWithLikeEngagementCodeSortAsc(String codeIsLike) {
        return [
            SELECT Id, Engagement_Code__c 
            FROM Engagement__c 
            WHERE Engagement_Code__c LIKE :codeIsLike 
            WITH SYSTEM_MODE 
            ORDER BY Engagement_Code__c ASC
            ];
    }
}