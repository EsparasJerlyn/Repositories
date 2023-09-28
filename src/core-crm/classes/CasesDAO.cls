/**
 * @description DAO Class for Case Object. Contains soql and constants related to the Case object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------|
 *    | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | created file                                |
 *    | arsenio.jr.dayrit              | September 26, 2023    | DEPP-6720              | added new method getCasesBySuppliedPhone    |
 */
public inherited sharing class CasesDAO extends DmlBase implements ICasesDAO {

    public static final String ORIGIN_WHATSAPP = 'WhatsApp';

    public static ICasesDAO newInstance() {
        return (ICasesDAO) ImplementationSelector.DAO.newInstance(
            Case.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return Case.SObjectType;
    }

    public List<Case> getCasesByContactIds(
        Set<Id> contactIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Category__c, CreatedDate, ContactId ' +
            'FROM Case ' +
            'WHERE ContactId IN :contactIds ',
            accessLevel
        );
    }

    public List<Case> getCasesByLeadIds(
        Set<Id> leadIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Category__c, CreatedDate, Lead__c ' +
            'FROM Case ' +
            'WHERE Lead__c IN :leadIds ',
            accessLevel
        );
    }

    public List<Case> getCasesByContactOrLeadIds(
        Set<Id> contactOrLeadIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Category__c, CreatedDate, Lead__c, ContactId ' +
            'FROM Case ' +
            'WHERE Lead__c IN :contactOrLeadIds ' + 
            'OR ContactId IN :contactOrLeadIds ',
            accessLevel
        );
    }

    public List<Case> getCasesBySuppliedPhone(
        Set<String> suppliedPhone,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, SuppliedPhone, ContactId, Lead__c ' +
            'FROM Case ' +
            'WHERE SuppliedPhone != NULL ' +
            'AND suppliedPhone IN :SuppliedPhone ', 
            accessLevel
        );
    }

}