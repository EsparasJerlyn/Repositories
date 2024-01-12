/**
 * @description DAO Class for Program Offering Object. Contains soql and constants related to the Program Offering object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | julie.jane.alegre              | January 02,2024       | ApexCRUDViolationFix   | Created file                 |
 */
public inherited sharing class ProgramOfferingsDAO extends DmlBase implements IProgramOfferingsDAO{

    public Schema.SObjectType getSObjectType()
	{
		return Program_Offering__c.SObjectType;
	} 

    public static IProgramOfferingsDAO newInstance()
	{
		return (IProgramOfferingsDAO) ImplementationSelector.DAO.newInstance(Program_Offering__c.SObjectType);
	}
    

    public List<Program_Offering__c> getProgramOfferingByRecordIds(
        Set<Id> programOfferIdSet,
        AccessLevel accessLevel
    ) {
        if(programOfferIdSet.isEmpty()){
            return new List<Program_Offering__c>();
        }

        return Database.query(
            'SELECT Id, Checkout_Cart_Items_Count__c ' +
                'FROM Program_Offering__c ' +
                'WHERE Id IN :programOfferIdSet  ' ,
            accessLevel
        );
    }

}