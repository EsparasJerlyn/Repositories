/**
 * @description Handler for PublishingEndDateScheduler
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eugene.andrew.abuan		       | March  02, 2022	   | DEPP-1256              | Created file                 | 
      |                                |                       |                        |                              | 
 */
public class PublishingEndDateBatchScheduler implements Schedulable {
    
    /**
    * @description Method for calling Publishing End Date batch job
    */
    public void execute (SchedulableContext context){
        PublishingEndDateBatch batch = new PublishingEndDateBatch();
		Id batchId = Database.executeBatch(batch);
    }
}