/**
 * @description DAO Mock Class for Async Apex Job Object. 
 *
 * @author Accenture
 *
  * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | arsenio.jr.dayrit              | May 13, 2024          | DEPP-8743              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
@isTest
public inherited sharing class AsyncApexJobsDAOMock extends DmlBaseMock implements IAsyncApexJobsDAO {
    public Map<Id, AsyncApexJob> asyncApexJobsMap;
    public AsyncApexJobsDAOMock() {
        super(new Map<Id, AsyncApexJob>(), Schema.AsyncApexJob.SObjectType);
        this.asyncApexJobsMap = (Map<Id, AsyncApexJob>) super.records;
    }
    public Schema.SObjectType getSObjectType() {
        return AsyncApexJob.SObjectType;
    }
    public AsyncApexJob findAsyncApexJobById(Id previewJobId, AccessLevel accessLevel){
        AsyncApexJob asyncApexJob = new AsyncApexJob();
        for(AsyncApexJob record : asyncApexJobsMap.values()){
            if(record.Id == previewJobId){
                asyncApexJob = record;
            }
        }
        return asyncApexJob;
    }
}