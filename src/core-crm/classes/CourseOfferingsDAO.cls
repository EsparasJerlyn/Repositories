/**
 * @description DAO Class for Course Offering Object. Contains soql and constants related to the Course Offering object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                        |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------------------------|
 *    | eugene.andrew.abuan            | September 18, 2023    | DEPP-6592              | Created file                                          |
 *    | kenneth.f.alsay                | September 25, 2023    | DEPP-6629              | added getRecordsLikeName                              |
 *    | julie.jane.alegre              | January 02, 2024      | ApexCRUDViolationFix   | added getCourseOfferingByRecordIds                    |
 *    | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseOfferingByProgramOfferingId |
 *    | sebastianne.k.trias            | January 25, 2024      | DEPP-7481              | added queryLocatorGetPastActiveRecords |
 */
public inherited sharing class CourseOfferingsDAO extends DmlBase implements ICourseOfferingsDAO{

    public Schema.SObjectType getSObjectType()
	{
		return hed__Course_Offering__c.SObjectType;
	}

    public static ICourseOfferingsDAO newInstance()
	{
		return (ICourseOfferingsDAO) ImplementationSelector.DAO.newInstance(hed__Course_Offering__c.SObjectType);
	}
    
    public static List<hed__Course_Offering__c> getRecordsLikeName(
    	String name
    ) {
		name = '%' + name + '%';
        return [ //NOPMD
            SELECT Id, hed__End_Date__c, Name, hed__Start_Date__c, LMS_Integration_Status__c, IsActive__c
            FROM hed__Course_Offering__c
			WHERE Name LIKE :name
            WITH USER_MODE
        ];
    }

    public List<hed__Course_Offering__c> getCourseOfferingByProgramOfferingId (
        Set<Id> programOfferingIds,
        AccessLevel accessLevel
    ){
        if(programOfferingIds.isEmpty()){
            return new List<hed__Course_Offering__c>();
        }
        return Database.query(
            'SELECT Id, Program_Offering__c  ' +
            'FROM hed__Course_Offering__c '+
            'WHERE Program_Offering__c IN: programOfferingIds ',
            accessLevel
        );
    }

    public List<hed__Course_Offering__c> getCourseOfferingByRecordIds(
        Set<Id> courseOfferIdSet,
        AccessLevel accessLevel
    ) {
        if(courseOfferIdSet.isEmpty()){
            return new List<hed__Course_Offering__c>();
        }

        return Database.query(
            'SELECT Id, Checkout_Cart_Items_Count__c ' +
                'FROM hed__Course_Offering__c ' +
                'WHERE Id IN :courseOfferIdSet  ' ,
            accessLevel
        );
    }

    public Database.QueryLocator queryLocatorGetPastActiveRecords() 
    {
        String query = 
        ' SELECT Id, hed__Start_Date__c, hed__End_Date__c, IsActive__c' +
        ' FROM hed__Course_Offering__c' + 
        ' WHERE IsActive__c = true AND hed__End_Date__c <= TODAY';

        return Database.getQueryLocator(query);
    }
}