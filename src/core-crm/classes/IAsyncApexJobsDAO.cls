/**
 * @description Interface for ApexAsyncJobs DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 29, 2024        | DEPP-7984              | Created file                 |
      | arsenio.jr.dayrit              | May 13, 2024          | DEPP-8743              | Created file                 |
 */
public interface IAsyncApexJobsDAO extends DmlInterface {
     List<AsyncApexJob> getRunningJobsByNameAndIdExemption(Set<String> jobNames, Set<Id> jobIds, AccessLevel accessLevel);
     AsyncApexJob findAsyncApexJobById(Id previewJobId, AccessLevel accessLevel); 
}
