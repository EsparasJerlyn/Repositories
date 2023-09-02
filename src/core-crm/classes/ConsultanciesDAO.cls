/**
 * @description DAO Class for Consultancy object. Contains soql and constants related to the Consultancy object.
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
public inherited sharing class ConsultanciesDAO extends DmlBase implements IConsultanciesDAO {
    public static IConsultanciesDAO newInstance() {
        return (IConsultanciesDAO) ImplementationSelector.DAO.newInstance(
            Consultancy__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return Consultancy__c.SObjectType;
    }

    public List<Consultancy__c> getConsultanciesWithActionsBySetProductRequestIds(
        Set<Id> productRequestIds
    ) {
        return [
            SELECT
                Id,
                Mark_Activity_as_Complete__c,
                (SELECT Id FROM Actions__r),
                Investigation_Summary__c,
                Mark_Investigation_as_Complete__c,
                Product_Request__r.Product_Request_Status__c
            FROM Consultancy__c
            WHERE Product_Request__c IN :productRequestIds
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Consultancy__c> getConsultanciesBySetNames(Set<String> consultancyNames) {
        return [
            SELECT Id
            FROM Consultancy__c
            WHERE Name IN :consultancyNames
            WITH SECURITY_ENFORCED
        ];
    }
}
