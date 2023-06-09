/**
 * @description Controller Class for Account
 * @see ../lwc/opportunityCreation
 * @see ../lwc/flowABNField
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | September 27, 2021    | DEP1-158, DEP1-623     | Created file                 | 
      | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Applied dao frame work       | 
      | ryan.j.a.dela.cruz             | June 5, 2023          | DEPP-5385              | Added checkABNExists method  |
 */
public with sharing class AccountCtrl {
    /**
     * @description retrieve account name from Account
     * @param accountId - accountId
     * @return accountname
     */
    @AuraEnabled
    public static string getAccountName(String accountId) {
        try {
            return AccountsDAO.newInstance()
                .getAccountsBySetIds(new Set<Id>{ (Id) accountId })
                .iterator()
                .next()
                ?.Name;
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method getAccountName in class AccountCtrl.',
                e
            );
            throw (e);
        }
    }
    /**
     * @description Checks if an Account record with the given ABN already exists.
     * @param abn The ABN value to check.
     * @return Boolean value indicating if an Account with the ABN already exists (true) or not (false).
     */
    @AuraEnabled
    public static Boolean checkABNExists(String abn) {
        Boolean abnExists = false;

        try {
            Account matchingAccount = AccountsDAO.newInstance().getAccountIdByABN(abn);
            abnExists = matchingAccount != null;
        } catch (Exception e) {
            NebulaLoggerService.logExceptionDetails(
                'Exception caught in method checkABNExists in class AccountCtrl.',
                e
            );
        }

        return abnExists;
    }
}
