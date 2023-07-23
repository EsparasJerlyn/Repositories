/**
 * @description DAO Class for hed__Affiliation__c Object. Contains soql and constants related to the Affiliation object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | mark.j.mahilum                 | July 21, 2023         | DEPP-5799              | created file                               |
 */
public inherited sharing class AffiliationsDAO extends DmlBase implements IAffiliationsDAO {

    public static IAffiliationsDAO newInstance() {
        return (IAffiliationsDAO) ImplementationSelector.DAO.newInstance(hed__Affiliation__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Affiliation__c.SObjectType;
    }

    public static List<hed__Affiliation__c> getAffiliationByContactIds(
        Set<Id> contactIds,
        String affilationStatus,
        String accessLevel
    ) {
        Id recordTypeId = AccountsDAO.ACCT_BUSINESS_ORG_ID; //Added NOPMD as the variable is getting treated as unused in below query
        return Database.query(//NOPMD
            'SELECT Id,hed__Account__c,hed__Account__r.RecordTypeId,hed__Contact__c ' +
            'FROM hed__Affiliation__c ' +
            'WHERE hed__Contact__c IN :contactIds ' +
            'AND hed__Account__r.RecordTypeId =:recordTypeId ' +
            'AND hed__Status__c =:affilationStatus ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }
}