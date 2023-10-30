/**
 * @description DAO Class for Adhoc Communication Object. Contains soql and constants related to the Adhoc Communication object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan            | October 10, 2023      | DEPP-6612              | Created file                 |
 */
public inherited sharing class AdhocCommunicationsDAO extends DmlBase implements IAdhocCommunicationsDAO {
    public Schema.SObjectType getSObjectType() {
        return Adhoc_Communication__c.SObjectType;
    }

    public static IAdhocCommunicationsDAO newInstance() {
        return (IAdhocCommunicationsDAO) ImplementationSelector.DAO.newInstance(Adhoc_Communication__c.sObjectType);
    }

    public List<Adhoc_Communication__c> getAdhocCommunicationsByOfferingFieldAndProductOfferingId(
        String productOfferingId, 
        String offeringField,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id, Name, IsSent__c, Send_Date__c, Subject__c, CreatedDate, Email_Content__c,  Course_Offering__c , Program_Offering__c ' +
            'FROM Adhoc_Communication__c ' +
            'WHERE ' + String.escapeSingleQuotes(offeringField) + ' = \'' + String.escapeSingleQuotes(productOfferingId) +
            '\' ORDER BY CreatedDate DESC ',
            accessLevel
        );
    }

    public Database.QueryLocator getAdhocCommunicationsByDate(
        Date todayDate
    ){
        return Database.getQueryLocator(
            'SELECT Id, Subject__c, Email_Content__c, IsSent__c, Send_Date__c, Course_Offering__c , Program_Offering__c ' + 
            'FROM Adhoc_Communication__c ' + 
            'WHERE Send_Date__c =: todayDate ' +
            'AND IsSent__c = FALSE '
        );
    }
}
