public with sharing class GenericBatchable implements Database.Batchable<sObject> {
    IGenericBatchableHandler batchHandler;

    public GenericBatchable(IGenericBatchableHandler batchHandler) {
        this.batchHandler = batchHandler;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return batchHandler.getQueryLocator();
    }

    public void execute(Database.BatchableContext bc, List<SObject> objects) {
        batchHandler.execute(objects);
    }

    
    public void finish(Database.BatchableContext bc) {
        batchHandler.finish();
    }
}