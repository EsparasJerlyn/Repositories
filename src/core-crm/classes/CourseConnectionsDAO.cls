/**
 * @description DAO Class for hed__Course_Enrollment__c Object. Contains soql and constants related to the Course Connection object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                             |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | created file                               |
 *    | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | added method named                         |
 *    |                                |                       |                        | getCourseConnectionByProgramEnrollmentIds  |
 *    | roy.nino.s.regala              | Sep 20, 2023          | DEPP-6714              | added method named                         |
 *    |                                |                       |                        | getActiveCourseConnectionsBySetContactIds  |
 */

public inherited sharing class CourseConnectionsDAO extends DmlBase implements ICourseConnectionsDAO {
    
    public static final Set<String> enrollmentStatus = new Set<String>{
       'Withdrawn'
    };

    public static final Set<String> programEnrollmentStatus = new Set<String>{
       'Admitted'
    };        
    
    public static ICourseConnectionsDAO newInstance() {
        return (ICourseConnectionsDAO) ImplementationSelector.DAO.newInstance(hed__Course_Enrollment__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return hed__Course_Enrollment__c.SObjectType;
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByPEContactIds(
        Set<Id> contactIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id,hed__Program_Enrollment__c,hed__Program_Enrollment__r.hed__Contact__c ' +
            'FROM hed__Course_Enrollment__c ' +
            'WHERE hed__Program_Enrollment__r.hed__Contact__c IN :contactIds ' + 
            'AND Enrollment_Status__c NOT IN :enrollmentStatus ' + 
            'AND hed__Program_Enrollment__r.Enrollment_Status__c IN :programEnrollmentStatus ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Course_Enrollment__c> getCourseConnectionByProgramEnrollmentIds(
        Set<Id> programEnrollmentIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT Id, hed__Program_Enrollment__c, hed__Program_Enrollment__r.hed__Contact__c, hed__Contact__c, Enrollment_Status__c ' +
            'FROM hed__Course_Enrollment__c ' +
            'WHERE hed__Program_Enrollment__c IN :programEnrollmentIds ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<hed__Course_Enrollment__c> getActiveCourseConnectionsBySetContactIds(
        Set<String> contactIds,
        AccessLevel accessLevel
    ) {
        return Database.query(
            'SELECT Id, Pricing_Validation__c,hed__Contact__c ' +
            'FROM hed__Course_Enrollment__c ' +
            'WHERE hed__Contact__c IN :contactIds ' + 
            'AND hed__Status__c = \'Active\' ',
            accessLevel
        );
    }

    public List<hed__Course_Enrollment__c> getRegisteredLearnersEmailByCourseOffering (
        Set<Id> courseOfferingIds, 
        Set<Id> programOfferingIds,
        AccessLevel accessLevel
    ){
        return Database.query(
            'SELECT Id, hed__Contact__r.Registered_Email__c, hed__Course_Offering__c, Program_Offering__c  ' +
            'FROM hed__Course_Enrollment__c '+
            'WHERE  hed__Status__c = \'Active\' ' +
            'AND (hed__Course_Offering__c IN :courseOfferingIds '+
            'OR Program_Offering__c IN: programOfferingIds ) ',
            accessLevel
        );
    }
    
}