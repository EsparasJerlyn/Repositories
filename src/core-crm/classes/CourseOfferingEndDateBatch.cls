/**
 * @description Batch class for Course Offering Object
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | sebastianne.k.trias       | January 25, 2024      | DEPP-7481    | Created file                                |
      | sebastianne.k.trias       | January 25, 2024      | DEPP-7481    | Set Course Offering status to false who     |
      |                           |                       |              | are end dates are today or in the past      |
*/
public class CourseOfferingEndDateBatch implements Database.Batchable<sObject> {
    

    private String originalTransactionId;

    /**
    * @description Method to query the Course Offering records
    * @param bc - BatchableContext
    * @return query - filtered query of course offering records
    */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        this.originalTransactionId = Logger.getTransactionId();
        Logger.info('Starting CourseOfferingEndBatch');
        Logger.saveLog();
        return CourseOfferingsDAO.newInstance().queryLocatorGetPastActiveRecords();
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param courseOfferingList - List of Course Offering
    * @return query - filtered query of course offering records
    */
    public void execute(Database.BatchableContext bc, List<hed__Course_Offering__c> courseOfferingList)
    {
        try{
            Logger.setParentLogTransactionId(this.originalTransactionId);

            for(hed__Course_Offering__c courseOffering: courseOfferingList){
                if(courseOffering.IsActive__c = true && courseOffering.hed__End_Date__c <= date.Today()){
                    courseOffering.IsActive__c = false;
                }
            }

            Database.SaveResult[] srList=  Database.update(courseOfferingList, false);
            logDatabaseResultToLogger(srList, 'execute()');
        }catch(Exception e){
            Logger.error('Executing execute() method of CourseOfferingEndDateBatch with Exception:').setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    public void finish(Database.BatchableContext bc) {} //NOPMD

    private void logDatabaseResultToLogger(Database.SaveResult[] srList, String methodName){
        for (Database.SaveResult sr : srList) {
            if(!sr.isSuccess()){
                Logger.error('[CourseOfferingEndDateBatch.'+ methodName + '] Database Result: ').setDatabaseResult(sr);
            }
        }
        if(Logger.getBufferSize() > 0){
            Logger.saveLog();
        }
    }
}