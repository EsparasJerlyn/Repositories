/**
 * @description DAO Class for Stewardship Object
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                           |
      |--------------------------------|-----------------------|------------------------|----------------------------------------------------------|
      | nicole.genon                   | March 6, 2024         | DEPP-7922              | Created file                                             |
 *
 */
public inherited sharing class StewardshipsDAO extends DmlBase implements IStewardshipsDAO{
    public Schema.SObjectType getSObjectType() {
        return Stewardship__c.SObjectType;
    }

    public static IStewardshipsDAO newInstance() {
        return (IStewardshipsDAO) ImplementationSelector.DAO.newInstance(Stewardship__c.SObjectType);
    }
}