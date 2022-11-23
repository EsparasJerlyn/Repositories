/**
 * @description Batch Job for invalidating values on Sandbox refresh or by pipelines.
 * to use it, instanciate the object, then call the invalidateFieldsForObject method passing as 1st argument the sObject API name
 * where the fields reside, and then, a set with the api name of all the fields.
 * it invalidates ONLY EMAIL AND PHONE fields.
 *
 *
 * @author Marcelo Marsson
 */
@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class RemoveMarketingCloudFlag implements Database.Batchable<sObject>, Database.Stateful{
  
    private String query;


    /**
     * @description invalidateFieldsForObject
     * @param anObject - sObject API Name
     * @param allFields - Set with api name of all the fields that will be invalidated.
     */
    public void invalidateFieldsForObject(String anObject){

        Schema.DescribeSObjectResult aObjectDescribe;
        try{
            aObjectDescribe = Schema.describeSObjects(new List<String>{ anObject }, SObjectDescribeOptions.DEFERRED)[0];
        } catch (Exception e){
            throw new InvalidateMCException('sObject requested does not exist or user has no access to it');
        }

        this.generateQuery( anObject);
        Database.executeBatch(this);
    }

    /**
     * @description generateQuery
     * private method thatgenerates the querylocator for the batch job
     */
    private void generateQuery( String anObject){
       this.query = String.format('SELECT Id, Sync_to_MC__c from {0} Where Sync_to_MC__c = true', new List<String>{anObject}); 
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> objList){
        for (SObject obj : objList){
            obj.put('Sync_to_MC__c',false);
        }
        Database.update (objList, false);
    }

    public void finish(Database.BatchableContext context){
    }

    class InvalidateMCException extends Exception {

    }

}