/**
 * @description DAO Class for Account Object. Contains soql and constants related to the Account object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                   |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------------------------|
 *    | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created File                                                     |
 *    | mark.j.mahilum                 | June 1, 2023          | DEPP-5687              | Added getAccountBySetNamesWithLimit method                       |
 *    | ryan.j.a.dela.cruz             | June 5, 2023          | DEPP-5385              | Added getAccountIdByABN method                                   |
 *    | ryan.j.a.dela.cruz             | August 8, 2023        | DEPP-6521              | Updated getAccountIdByABN method, added space and length check   |
 */
public inherited sharing class AccountsDAO extends DmlBase implements IAccountsDAO {

    public static final String ACCOUNT_NAME_START_QUT = 'Start QUT';
    public static final String PROGRAM_CODE_QC19 = 'QC19';

    public static final String ACCT_ACADEMIC_PROGRAM = System.label.RT_Academic_Program;
    public static final Id ACCT_ACADEMIC_PROGRAM_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_ACADEMIC_PROGRAM)
        .getRecordTypeId();
    public static final String ACCT_BUSINESS_ORG = System.label.RT_Account_Business_Org;
    public static final Id ACCT_BUSINESS_ORG_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_BUSINESS_ORG)
        .getRecordTypeId();
    public static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    public static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(ACCT_UNIV_DEP)
        .getRecordTypeId();

    public static IAccountsDAO newInstance() {
        return (IAccountsDAO) ImplementationSelector.DAO.newInstance(Account.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public List<Account> getAccountsBySetIds(Set<Id> accountIds) {
        return [ //NOPMD
            SELECT Id, Name
            FROM Account
            WHERE Id IN :accountIds
            WITH USER_MODE
        ];
    }

    public List<Account> getPartnerAccountsByIds(Set<Id> recordIds, AccessLevel accessLevel) {
        if(!recordIds.isEmpty() && accessLevel != null) {
            return Database.query(
                'SELECT Id ' +
                'FROM Account ' +
                'WHERE IsPartner = true ' +
                'AND Id IN :recordIds',
                accessLevel
            );
        } else { return new List<Account>(); }
    }

    public List<Account> getAccountsBySetIds(Set<Id> accountIds, List<String> fields, AccessLevel accessLevel) {

        String fieldsToQuery = fields.size() > 0 ? 'Id, ' + String.join(fields, ',') : 'Id';

        return Database.query(
            'SELECT ' + String.escapeSingleQuotes(fieldsToQuery) + ' ' +
              'FROM Account ' +
             'WHERE Id IN: accountIds', accessLevel
        );

    }

    public List<Account> getAccountsBySetNames(Set<String> accountNames) {
        return [ //NOPMD
            SELECT Id, Name
            FROM Account
            WHERE Name IN :accountNames
            WITH USER_MODE
        ];
    }

    public List<Account> getAccountBySetNamesWithLimit(
        Set<String> accountNames,
        Integer recordsCount
    ) {
        return [ //NOPMD
            SELECT Id, Name
            FROM Account
            WHERE Name IN :accountNames
            WITH USER_MODE
            LIMIT :recordsCount
        ];
    }

    public Account getAccountIdByABN(String abn) {
        // Check if ABN is empty
        if (String.isBlank(abn)) {
            return null;
        }

        // Remove spaces and format the ABN value
        String formattedAbn = abn.replaceAll('\\s', '');
    
        // Construct the formatted ABN with '%' between each character
        String formattedAbnWithPercent = '%';
        // Construct the wildcard string for ABN length-based condition
        String abnLengthWildcard = '';
        for (Integer i = 0; i < formattedAbn.length(); i++) {
            formattedAbnWithPercent += formattedAbn.substring(i, i + 1) + '%';
            abnLengthWildcard += '_';
        }

        return [ //NOPMD
            SELECT Id
            FROM Account
            WHERE ABN__c LIKE :formattedAbnWithPercent AND ABN__c LIKE :abnLengthWildcard AND RecordTypeId = :ACCT_BUSINESS_ORG_ID
            WITH USER_MODE
            LIMIT 1
        ];
    }
}

