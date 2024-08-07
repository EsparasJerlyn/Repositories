public interface IGenericBatchableHandler {
    Database.QueryLocator getQueryLocator();

    void execute(List<SObject> objects);

    void finish();
}