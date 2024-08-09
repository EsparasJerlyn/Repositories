/**
 * @description DAO Class for Operating Hours Object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------|
      | john.aldric.s.seril            | July 26, 2024         | DEPP-9834              | Created file                                   |
*/
public inherited sharing class OperatingHoursDAO extends DmlBase implements IOperatingHoursDAO{

    public static final String TYPE_VOICE = 'Voice';
    
    public Schema.SObjectType getSObjectType() {
        return OperatingHours.SObjectType;
    }
    
    public static IOperatingHoursDAO newInstance() {
        return (IOperatingHoursDAO) ImplementationSelector.DAO.newInstance(
            OperatingHours.SObjectType
        );
    }
    
    public Database.QueryLocator queryLocatorGetVoiceOperatingHours() {
        String query =
            'SELECT Name, Channel_Type__c, AWS_Business_Hour_External_ID__c, TimeZone, Description ' +
            'FROM OperatingHours ' +
            'WHERE Channel_Type__c =: TYPE_VOICE'; 
        return Database.getQueryLocator(query);
    }

    public List<OperatingHours> getOperatingHoursByIdAndChannel(
        Set<Id> operatingHrsIds,
        String channelType,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Name, Channel_Type__c, AWS_Business_Hour_External_ID__c, TimeZone, Description ' +
              'FROM OperatingHours ' +
             'WHERE Id =: operatingHrsIds ' +
               'AND Channel_Type__c =: channelType', 
            accessLevel
        );
    }
    
}