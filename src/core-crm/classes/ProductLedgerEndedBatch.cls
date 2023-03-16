/**
 * @description Batch class to check product ledgers that offering has ended
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala   	       | Aug 23, 2022          | DEPP-3482              | Created file                 | 
 */
public class ProductLedgerEndedBatch implements Database.Batchable<sObject> {

    /**
    * @description to end product ledgers that offering has passed
    * @param bc - BatchableContext
    * @return query - filtered query of product ledger records
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryFilter = 
            'SELECT Id, Offering_Ended__c ' + 
            'FROM Product_Ledger__c ' + 
            'WHERE Offering_Ended__c = False ' + 
            'AND Offering_End_Date__c < TODAY';
        return Database.getQueryLocator(queryFilter);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param assetList - List of assets
    */
    public void execute(Database.BatchableContext bc, List<Product_Ledger__c> productLedgerList){
        try{ 

            for(Product_Ledger__c prodLedger : productLedgerList){
                prodLedger.Offering_Ended__c= true;
            }

           update productLedgerList;

        }catch(Exception e){
            Logger.error('Exception caught in method execute in class ProductLedgerEndedBatch.').setExceptionDetails(e);
            Logger.saveLog();
        }
       
    } 

    public void finish(Database.BatchableContext bc) {}//NOPMD
}