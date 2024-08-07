@IsTest
public with sharing class GenericBatchableTest {
    
    // It doesn't matter which user run this test
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    @IsTest
    public static void batchStartTest() {
        // Setup
        GenericBatchable batch = new GenericBatchable(new MockBatchableHandler());

        // Test
        Database.QueryLocator queryLocator = batch.start(null);
        
        // Verify
        Assert.areEqual('Select id from Account limit 1', queryLocator.getQuery(), 'Query Locator mismatch');
    }

    // It doesn't matter which user run this test
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    @IsTest
    public static void batchExecuteTest() {
        // Setup
        GenericBatchable batch = new GenericBatchable(new MockBatchableHandler());

        List<SObject> objects = new List<SObject>();
        objects.add(new Account());

        // Test
        batch.execute(null, objects);

        // Verify
        Assert.areEqual('Unit Test', objects.get(0).get('Name'), 'Failed to execute');
    }

    // It doesn't matter which user run this test
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    @IsTest
    public static void batchFinishTest() {
        // Setup
        GenericBatchable batch = new GenericBatchable(new MockBatchableHandler());

        String actualExceptionMessage; 

        // Test
        try {
            batch.finish(null);
        } catch (HandledException e) {
            actualExceptionMessage = e.getMessage();
        }

        // Verify
        Assert.areEqual('Expected Exception', actualExceptionMessage, 'Finish method was not executed');
    }

    private class MockBatchableHandler implements IGenericBatchableHandler {
        public Database.QueryLocator getQueryLocator() {
            return Database.getQueryLocator('Select id from Account limit 1');
        }

        public void execute(List<SObject> objects) {
            objects.get(0).put('Name', 'Unit Test');
        }
    
        public void finish() {
            throw new HandledException('Expected Exception');
        }
    }
}