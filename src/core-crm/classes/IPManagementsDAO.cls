/**
 * @description DAO Class for IP Managements Object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | eugene.andrew.abuan            | July 12, 2023         | DEPP-5483              | Created file                               |
 *    | kenneth.f.alsay                | July 13, 2023         | DEPP-5475              | Added all IPManagemet Record Types         |
 *    | kenneth.f.alsay                | August 28, 2023       | DEPP-6466              | Added getIPManagementRecordsBySetIds       |
 */
public inherited sharing class IPManagementsDAO extends DmlBase implements IIPManagementsDAO {
    public static final Id DESIGN_RIGHTS_RECTYPE_ID = Schema.SObjectType.IP_Management__c.getRecordTypeInfosByDeveloperName()
        .get('Design_Rights')
        .getRecordTypeId();
    public static final Id PATENT_RECTYPE_ID = Schema.SObjectType.IP_Management__c.getRecordTypeInfosByDeveloperName()
        .get('Patent')
        .getRecordTypeId();
    public static final Id PLANT_BREEDERS_RIGHTS_RECTYPE_ID = Schema.SObjectType.IP_Management__c.getRecordTypeInfosByDeveloperName()
        .get('Plant_Breeders_Rights')
        .getRecordTypeId();
    public static final Id TRADEMARK_RECTYPE_ID = Schema.SObjectType.IP_Management__c.getRecordTypeInfosByDeveloperName()
        .get('Trademark')
        .getRecordTypeId();

    public Schema.SObjectType getSObjectType() {
        return IP_Management__c.SObjectType;
    }

    public static IIPManagementsDAO newInstance() {
        return (IIPManagementsDAO) ImplementationSelector.DAO.newInstance(
            IP_Management__c.SObjectType
        );
    }

    public List<IP_Management__c> getIPManagementRecordsBySetIds(
        Set<Id> ipManagementIds
    ) {
        return [ //NOPMD
            SELECT Id, OwnerId
            FROM IP_Management__c
            WHERE Id IN: ipManagementIds
            WITH USER_MODE
        ];
    }
}
