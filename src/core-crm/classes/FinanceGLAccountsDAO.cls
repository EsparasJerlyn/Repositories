/**
 * @description DAO Class for Finance GL Account Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                                           |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------------------------------------------|
      | neil.s.h.lesidan               | April 11, 2024        | DEPP-8392              | Created file                                                                             |
*/
public inherited sharing class FinanceGLAccountsDAO extends DmlBase implements IFinanceGLAccountsDAO {

    public static IFinanceGLAccountsDAO newInstance() {
        return (IFinanceGLAccountsDAO) ImplementationSelector.DAO.newInstance(Finance_GL_Account__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Finance_GL_Account__c.SObjectType;
    }

    public List<Finance_GL_Account__c> getFinanceGLAccountBySetNamesWithLimit(
        Set<String> financeGlAccountNames,
        Integer recordsCount
    ) {
        return [ //NOPMD
            SELECT Id, Name
            FROM Finance_GL_Account__c
            WHERE Name IN :financeGlAccountNames
            WITH USER_MODE
            LIMIT :recordsCount
        ];
    }
}