/**
 * @description Interface for Application DAO framework
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                            |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------|
      | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | Created IApplicationDAO cls         	 	|
 */
public interface IApplicationsDAO extends DmlInterface{
    List<hed__Application__c> getApplicationsBySetIds(Set<Id> applicationIds);
}