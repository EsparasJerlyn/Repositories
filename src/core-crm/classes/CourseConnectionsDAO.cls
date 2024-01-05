/**
 * @description DAO Class for hed__Course_Enrollment__c Object. Contains soql and constants related to the Course Connection object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | mark.j.mahilum                 | June 19, 2023         | DEPP-5846              | created file                                   |
 *    | eccarius.munoz                 | August 08, 2023       | DEPP-5760              | added method named                             |
 *    |                                |                       |                        | getCourseConnectionByProgramEnrollmentIds      |
 *    | roy.nino.s.regala              | Sep 20, 2023          | DEPP-6714              | added method named                             |
 *    |                                |                       |                        | getActiveCourseConnectionsBySetContactIds      |
 *    | kenneth.f.alsay                | Sep 22, 2023          | DEPP-6299              | added method getCourseConnectionByStatus       |
 *    | arsenio.jr.dayrit              | January 03, 2023      | ApexCRUDViolationFix   | Added method for getCourseConnectionByCartItem |
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

    public List<hed__Course_Enrollment__c> getCourseConnectionByStatus(
        String status,
        String lmsIntegrationStatus
    ){
        return [ //NOPMD
            SELECT Id, hed__Status__c,LMS_Integration_Status__c
            FROM hed__Course_Enrollment__c
            WHERE hed__Status__c = :status AND LMS_Integration_Status__c = :lmsIntegrationStatus
            WITH USER_MODE
        ];
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

    public List<hed__Course_Enrollment__c> getCourseConnectionByCartItem (
        Set<Id> cartItemIdSet,
        AccessLevel accessLevel
    ){
        if(cartItemIdSet.isEmpty()){
            return new List<hed__Course_Enrollment__c>();
        }
        return Database.query(
            'SELECT Id, Cart_Item__c, Cart_ID__c, Cart_ID__r.TotalAmount, Cart_Id__r.Cart_Payment__c, hed__Status__c, ' +
            'Paid_in_Full__c, hed__Course_Offering__c, Program_Offering__c, Paid_Amount__c, Cart_Item__r.TotalPrice, Cart_Item__r.Promotion_Price__c  ' +
            'FROM hed__Course_Enrollment__c '+
            'WHERE Cart_Item__c IN: cartItemIdSet ',
            accessLevel
        );
    }

}