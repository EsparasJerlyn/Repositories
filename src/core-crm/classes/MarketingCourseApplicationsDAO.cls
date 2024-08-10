/**
 * @description DAO Class for Marketing Course Application Object. 
 * Contains soql and constants related to the Marketing Course Application object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 02, 2024          | n/a                    | Created file
 */
public inherited sharing class MarketingCourseApplicationsDAO extends DmlBase implements IMarketingCourseApplicationsDAO{

    public Schema.SObjectType getSObjectType()
    {
        return Marketing_Course_Application__c.SObjectType;
    } 

    public static IMarketingCourseApplicationsDAO newInstance()
    {
        return (IMarketingCourseApplicationsDAO) ImplementationSelector.DAO.newInstance(Marketing_Course_Application__c.SObjectType);
    }

    public List<Marketing_Course_Application__c> getMrktngCourseAppsByLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    ) {
        if(!leadIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Lead__c, Contact__c FROM Marketing_Course_Application__c WHERE Lead__c IN :leadIds',
                accessLevel
            );
        } else { return new List<Marketing_Course_Application__c>(); }
    }
}