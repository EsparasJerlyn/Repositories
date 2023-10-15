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

    public static final String PRIMARY_STUDY_LEVEL_UNDERGRAD = 'Undergraduate';
    public static final String PRIMARY_STUDY_LEVEL_POSTGRAD = 'Postgraduate';
    public static final String PRIMARY_STUDY_LEVEL_UNDETERMINED = 'Undetermined';

    public static final String CITIZENSHIP_STATUS_DOMESTIC_AU = 'Australian Citizen or Permanent Resident';   
    public static final String CITIZENSHIP_STATUS_DOMESTIC_NZ = 'New Zealand Citizen';
    public static final String CITIZENSHIP_STATUS_INTERNATIONAL = 'International Student';

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
            ' Id, Contact__c, My_Primary_Study_Level__c, My_Expected_Admission_Year__c, My_Citizenship_Status__c ' +
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
            ' Id, Lead__c, My_Primary_Study_Level__c, My_Citizenship_Status__c ' +
            ' FROM' + 
            ' Marketing_Segmentation__c' +
            ' WHERE' +
            ' Lead__c IN:leadIds';
    
        return Database.query(marketingSegmentationQuery, accessLevel);
    }

    public static List<Marketing_Segmentation__c> getMarketingSegmentationByContactOrLead(
        Set<Id> contactIdSet, 
        Set<Id> leadIdSet,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Lead__c, Contact__c, My_Primary_Study_Level__c, My_Citizenship_Status__c, Contact__r.hed__Citizenship_Status__c ' +
            'FROM Marketing_Segmentation__c ' +
            'WHERE Contact__c IN : contactIdSet OR Lead__c IN : leadIdSet ',
            accessLevel
        );
    }

}