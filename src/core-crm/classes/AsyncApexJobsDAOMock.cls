/**
 * @description Mock DAO Class for AsyncApexJob Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                           |
      |--------------------------------|-----------------------|------------------------|------------------------------------------|
      | roy.nino.s.regala              | April 24, 2024        | DEPP-7984              | Created file                             |
      | arsenio.jr.dayrit              | May 13, 2024          | DEPP-8743              | Created findAsyncApexJobById             |
      | eugene.andrew.abuan            | May 29, 2024          | DEPP-8822              | Created findAsyncApexJobByApexName       |
 */
@isTest
public inherited sharing class AsyncApexJobsDAOMock extends DmlBaseMock implements IAsyncApexJobsDAO {

	public Map<Id, AsyncApexJob> asyncApexJobsMap;

    public Schema.SObjectType getSObjectType()
	{
		return AsyncApexJob.SObjectType;
	}

	public AsyncApexJobsDAOMock() {
		super(new Map<Id, AsyncApexJob>(), Schema.AsyncApexJob.SObjectType);
		this.asyncApexJobsMap = (Map<Id, AsyncApexJob>) super.records;
	}

	public List<AsyncApexJob> getRunningJobsByNameAndIdExemption(Set<String> jobNames, Set<Id> jobIds, AccessLevel accessLevel){

		List<AsyncApexJob> asyncApexJobList = new List<AsyncApexJob>();
 
		for(AsyncApexJob asyncApexJob: asyncApexJobsMap.values()){
			if(!AsyncApexJobsDAO.JOB_FINISHED_STATUS.contains(asyncApexJob.Status)){
				asyncApexJobList.add(asyncApexJob);
			}
		}

		return asyncApexJobList;
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

	public AsyncApexJob findAsyncApexJobByApexName(String apexName, AccessLevel accessLevel){
        AsyncApexJob asyncApexJob = new AsyncApexJob();
        for(AsyncApexJob record : asyncApexJobsMap.values()){
            if(record.ApexClass.Name == apexName){
                asyncApexJob = record;
            }
        }
        return asyncApexJob;
    }

}