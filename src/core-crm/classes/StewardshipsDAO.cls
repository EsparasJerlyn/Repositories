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
    public static final Id INDIVIDUAL_STEWARDSHIP_RECTYPE_ID = Schema.SObjectType.Stewardship__c.getRecordTypeInfosByDeveloperName().get('Individual_Stewardship').getRecordTypeId();
    public static final Id ORGANISATION_STEWARDSHIP_RECTYPE_ID = Schema.SObjectType.Stewardship__c.getRecordTypeInfosByDeveloperName().get('Organisation_Stewardship').getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return Stewardship__c.SObjectType;
    }

    public static IStewardshipsDAO newInstance() {
        return (IStewardshipsDAO) ImplementationSelector.DAO.newInstance(Stewardship__c.SObjectType);
    }

    public static List<Stewardship__c> getStewardshipBySetIds(
        Set<Id> stewardshipIds,
        AccessLevel accessLevel
    ) {
        if(!stewardshipIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Name, Stage__c ' +
                'FROM Stewardship__c ' +
                'WHERE Id IN :stewardshipIds',
                accessLevel
            );
        }  else { return new List<Stewardship__c>(); }
    }

    public static List<Stewardship__c> getStewardshipByRecordTypeIds(
        Set<Id> recordTypeIds,
        AccessLevel accessLevel
    ) {
        if(!recordTypeIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id, Stage__c ' +
                'FROM Stewardship__c ' +
                'WHERE RecordTypeId IN :recordTypeIds',
                accessLevel
            );
        }  else { return new List<Stewardship__c>(); }
    }
}