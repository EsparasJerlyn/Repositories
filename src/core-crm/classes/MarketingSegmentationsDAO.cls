/**
 * @description Interface for Marketing Segmentation DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | julie.jane.alegre              | Sept 14, 2023         | DEPP-6679              | Created file                 |
 */
public inherited sharing class MarketingSegmentationsDAO extends DmlBase implements IMarketingSegmentationsDAO{

    public Schema.SObjectType getSObjectType(){
        return Marketing_Segmentation__c.SObjectType;
	  }

    public static IMarketingSegmentationsDAO newInstance(){
		    return (IMarketingSegmentationsDAO) ImplementationSelector.DAO.newInstance(Marketing_Segmentation__c.SObjectType);
	  }

    public List<Marketing_Segmentation__c> getMarketingSegmentationByContactIds(
        Set<Id> contactIds,
        AccessLevel accessLevel
    ) {
        String marketingSegmentationQuery = 
            'SELECT' +
            ' Id, Contact__c' +
            ' FROM' + 
            ' Marketing_Segmentation__c' +
            ' WHERE' +
            ' Contact__c IN:contactIds';
        
        return Database.query(marketingSegmentationQuery, accessLevel);
    }

    public List<Marketing_Segmentation__c> getMarketingSegmentationByLeadIds(
      Set<Id> leadIds,
      AccessLevel accessLevel
    ) {
        String marketingSegmentationQuery = 
            'SELECT' +
            ' Id, Lead__c' +
            ' FROM' + 
            ' Marketing_Segmentation__c' +
            ' WHERE' +
            ' Lead__c IN:leadIds';
    
        return Database.query(marketingSegmentationQuery, accessLevel);
    }

}