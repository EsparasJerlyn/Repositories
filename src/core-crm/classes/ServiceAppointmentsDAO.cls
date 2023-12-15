/**
 * @description DAO Class for Service Appointment Object. Contains soql and constants related to the Service Appointment object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                       |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------|
      | arsenio.jr.dayrit              | November 22, 2023     | DEPP-7264              | created file                                         |
      | nicole.genon                   | November 24, 2023     | DEPP-7259              | added getServiceAppointmentsBySetIds                 |
      | neil.s.h.lesidan               | November 29, 2023     | DEPP-7280              | Added getServiceAppointmentByEmail                   |
      | arsenio.jr.dayrit              | December 14, 2023     |DEPP-7357               | Added Test  getServiceAppointmentByLeadId            |

 */
public inherited sharing class ServiceAppointmentsDAO extends DmlBase implements IServiceAppointmentsDAO{

    public Schema.SObjectType getSObjectType(){
		return ServiceAppointment.SObjectType;
	}

    public static IServiceAppointmentsDAO newInstance(){
		return (IServiceAppointmentsDAO) ImplementationSelector.DAO.newInstance(ServiceAppointment.SObjectType);
	}

    public List<ServiceAppointment> getServiceAppointmentsBySetIds(Set<Id> serviceAppointmentIds, List<String> fields, AccessLevel accessLevel) {

        String fieldsToQuery = fields.size() > 0 ? 'Id, ' + String.join(fields, ',') : 'Id';

        return Database.query(
            'SELECT ' + String.escapeSingleQuotes(fieldsToQuery) + ' ' +
              'FROM ServiceAppointment ' +
             'WHERE Id IN: serviceAppointmentIds', accessLevel
        );
    }

    public List<ServiceAppointment> getServiceAppointmentByEmail(
        String email,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Mobile_No_Locale__c, First_Name__c, Last_Name__c, Email, Contact__c, LeadId__c ' +
                'FROM ServiceAppointment ' +
                'WHERE Email =: email ',
                accessLevel
        );
    }

    public List<ServiceAppointment> getServiceAppointmentByAppointmentEmail(
        String email,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Appointment_Email__c ' +
                'FROM ServiceAppointment ' +
                'WHERE Appointment_Email__c =: email ',
                accessLevel
        );
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    public List<ServiceAppointment> getServiceAppointmentByLeadId(
        Set<Id> leadId
    ) {
        return [
            SELECT Id,LeadId__c,My_Country_Of_Citizenship__c,My_Citizenship_Status__c,My_Country_Of_Residency__c 
            FROM ServiceAppointment
            WHERE LeadId__c IN: leadId 
            WITH SYSTEM_MODE
            ORDER BY LastModifiedDate DESC
        ];
    }
}
