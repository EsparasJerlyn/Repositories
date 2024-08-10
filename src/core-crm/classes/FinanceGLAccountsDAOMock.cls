/**
 * @description Mock DAO Class for Finance GL Account Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | neil.s.h.lesidan               | April 11, 2024        | DEPP-8392              | Created file                                      |
 */
@isTest
public inherited sharing class FinanceGLAccountsDAOMock extends DmlBaseMock implements IFinanceGLAccountsDAO {

    public Map<Id, Finance_GL_Account__c> financeGLAccountMap;

    public Schema.SObjectType getSObjectType() {
        return Finance_GL_Account__c.SObjectType;
    }

    public FinanceGLAccountsDAOMock() {
        super(new Map<Id, Finance_GL_Account__c>(), Schema.Finance_GL_Account__c.SObjectType);
        this.financeGLAccountMap = (Map<Id, Finance_GL_Account__c>) super.records;
    }


    public List<Finance_GL_Account__c> getFinanceGLAccountBySetNamesWithLimit(
        Set<String> financeGlAccountNames,
        Integer recordsCount
    ) {
        List<Finance_GL_Account__c> financeGlAccountList = new List<Finance_GL_Account__c>();

        for (Finance_GL_Account__c record : financeGLAccountMap.values()) {
            if (financeGlAccountNames.contains(record.Name)) {
                financeGlAccountList.add(record);
            }
            if (financeGlAccountList.size() == recordsCount) {
                break;
            }
        }

        return financeGlAccountList;
    }

}