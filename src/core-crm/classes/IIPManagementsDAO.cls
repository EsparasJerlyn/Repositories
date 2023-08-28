/**
 * @description Interface for IP Managements DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                        |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------|
 *    | eugene.andrew.abuan            | July 10, 2023         | DEPP-5483              | Created file                          |
 *    | kenneth.f.alsay                | July 14, 2023         | DEPP-5475              | Minor description change              |
 *    | kenneth.f.alsay                | August 28, 2023       | DEPP-6466              | Added getIPManagementRecordsBySetIds  |
 */
public interface IIPManagementsDAO extends DmlInterface {
    List<IP_Management__c> getIPManagementRecordsBySetIds(
        Set<Id> ipManagementIds
    );
}
