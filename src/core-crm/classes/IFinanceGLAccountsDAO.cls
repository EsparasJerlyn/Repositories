/**
 * @description Interface for FinanceGLAccountsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | neil.s.h.lesidan               | April 12, 2024        | DEPP-8392              | Created file                                   |
*/
public interface IFinanceGLAccountsDAO extends DmlInterface {
    List<Finance_GL_Account__c> getFinanceGLAccountBySetNamesWithLimit(Set<String> financeGlAccountNames, Integer recordsCount);
}