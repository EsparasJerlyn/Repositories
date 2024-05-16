/**
 * @description DAO Class for Async Apex Job object. Contains soql and constants related to the Async Apex Job object.
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
public inherited sharing class AsyncApexJobsDAO extends DmlBase implements IAsyncApexJobsDAO {
    
    public static IAsyncApexJobsDAO newInstance() {
        return (IAsyncApexJobsDAO) ImplementationSelector.DAO.newInstance(
            AsyncApexJob.SObjectType
        );
    }
    public Schema.SObjectType getSObjectType() {
        return 	AsyncApexJob.SObjectType;
    }
    public AsyncApexJob findAsyncApexJobById(Id previewJobId, AccessLevel accessLevel){
        if(String.isBlank(previewJobId)){
            return null;
        }

        List<AsyncApexJob> asyncApexJob = Database.query(
            'SELECT Id, ' +
            'ApexClass.Name, ' +
            'NumberOfErrors ' +
            'FROM AsyncApexJob ' +
            'WHERE Id =: previewJobId ' +
            'LIMIT 1 ',
            accessLevel
        ); 
        return asyncApexJob.isEmpty()?null:asyncApexJob[0];    
    }
}