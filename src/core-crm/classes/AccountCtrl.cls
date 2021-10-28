/**
 * @description Controller Class for Account
 * @see ../lwc/opportunityCreation
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | September 27, 2021    | DEP1-158, DEP1-623     | Created file                 | 
      |                                |                       |                        |                              | 
 */
public with sharing class AccountCtrl {

   /**
   * @description retrieve account name from Account
   * @param accountId - accountId
   * @return accountname 
   */
   @AuraEnabled
   public static string getAccountName(String accountId){
      Account acct = [Select Id, Name from Account WHERE Id =:accountId];
      return acct.Name;
   }

}