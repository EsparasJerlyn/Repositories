/**
 * @description Handler for ProductLedgerEndedBatchScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala		       | Aug  25, 2022	       | DEPP-3482              | Created file                 | 
      |                                |                       |                        |                              | 
 */
public with sharing class ProductLedgerEndedBatchScheduler implements Schedulable {
    
    /**
    * @description Method for calling Product Ledger Ended batch job
    */
    public void execute (SchedulableContext context){
        ProductLedgerEndedBatch batch = new ProductLedgerEndedBatch();
		Database.executeBatch(batch);
    }
}