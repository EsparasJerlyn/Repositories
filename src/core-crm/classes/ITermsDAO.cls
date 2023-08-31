/**
 * @description Interface for TermsDAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                      |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------------|
 *    | eccarius.munoz                 | August 10, 2023       |DEPP-5760               | Created File                        |
 */
public interface ITermsDAO extends DmlInterface{
    List<hed__Term__c> getTermRecordByApplication(
        Set<Id> termIds,
        String accessLevel
    );
}