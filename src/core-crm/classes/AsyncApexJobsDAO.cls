/**
 * @description DAO Class for Async Apex Job Object. Contains soql and constants related to the Async Apex Job object.
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
public inherited sharing class AsyncApexJobsDAO extends DmlBase implements IAsyncApexJobsDAO{

    public static final String EMAIL_TRIGGER_SALES_CADENCE_BATCH = 'EmailTriggerSalesCadenceBatch';
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

    public AsyncApexJob findAsyncApexJobById(Id previewJobId, AccessLevel accessLevel){
        if(String.isBlank(previewJobId)){
            return null;
        }

        List<AsyncApexJob> asyncApexJob = Database.query(
            'SELECT Id, Status, ' +
            'ApexClass.Name, ' +
            'NumberOfErrors, ' +
            'ExtendedStatus ' +
            'FROM AsyncApexJob ' +
            'WHERE Id =: previewJobId ' +
            'LIMIT 1 ',
            accessLevel
        ); 
        return asyncApexJob.isEmpty()?null:asyncApexJob[0];    
    }

    public AsyncApexJob findAsyncApexJobByApexName(String apexName, AccessLevel accessLevel){
        if(String.isBlank(apexName)){
            return new AsyncApexJob();
        }
        List<AsyncApexJob> asyncApexJob = Database.query(
            'SELECT Id, ApexClass.Name ' +
            'FROM AsyncApexJob ' +
            'WHERE Apexclass.Name =: apexName '+
            'LIMIT 1 ',
            accessLevel
        );

        return asyncApexJob.isEmpty()?null:asyncApexJob[0];
    }
    
}