/**
 * @description DAO Class for Async Apex Job Object. Contains soql and constants related to the Async Apex Job object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 29, 2024        | DEPP-7984              | Created file
 */
public inherited sharing class AsyncApexJobsDAO extends DmlBase implements IAsyncApexJobsDAO{

	 public static final Set<String> JOB_FINISHED_STATUS = new Set<String>{
        'Completed',
        'Aborted',
        'Failed'
    };

    public Schema.SObjectType getSObjectType()
	{
		return AsyncApexJob.SObjectType;
	}

    public static IAsyncApexJobsDAO newInstance()
	{
		return (IAsyncApexJobsDAO) ImplementationSelector.DAO.newInstance(AsyncApexJob.SObjectType);
	}

	public List<AsyncApexJob> getRunningJobsByNameAndIdExemption(Set<String> jobNames, Set<Id> jobIds, AccessLevel accessLevel){

		if(jobNames.isEmpty() && jobIds.isEmpty()){
			return new List<AsyncApexJob>();
		}

		return Database.query(
			'SELECT Id, Status, ApexClass.Name, CreatedDate ' +
            'FROM AsyncApexJob ' +
            'WHERE Apexclass.Name IN: jobNames ' +
            'AND Status NOT IN: JOB_FINISHED_STATUS ' +
            'AND Id NOT IN: jobIds ' 
			,accessLevel);
	}
}