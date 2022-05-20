/**
 * @description Trigger for Rebuild Search Index for Product updates
 * @see B2BStoreSearchIndexHandler
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | November 22, 2021     | DEPP-131               | Created file                 |
      | john.bo.a.pineda               | May 13, 2022          | DEPP-2591              | Set Trigger to Inactive      |
      |                                |                       |                        |                              |
 */
trigger CallBuildSearchIndex on Product2(after update) {
  B2BStoreSearchIndexHandler handler = new B2BStoreSearchIndexHandler();

  if (Trigger.isUpdate && Trigger.isAfter) {
    handler.buildSearchIndex();
  }
}
