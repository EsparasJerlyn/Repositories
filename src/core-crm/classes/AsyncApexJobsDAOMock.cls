/**
 * @description Mock DAO Class for AsyncApexJob Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2024        | DEPP-7984              | Created file
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

}