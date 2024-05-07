/**
 * @description DAO Completed Cadence Object. Contains soql and constants related to the custom object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                   |
      |--------------------------------|-----------------------|------------------------|------------------------------------------------------------------|
      | mark.j.mahilum                 | July 25, 2023         | DEPP-6106              | Created file                                                     |
      | roy.nino.s.regala              | Aug 9, 2023           | DEPP-5677              | added new query                                                  |
      | mark.j.mahilum                 | Aug 23, 2023          | DEPP-6215              | Added query filter condition and updated method                  |
      |                                |                       |                        | getCompletedCadenceByTargetIdsAndCadenceName                     |
      | arsenio.jr.dayrit              | September 08, 2023    | DEPP-5652              | Added fields in getCompletedCadenceByLeadIds                     |
      | arsenio.jr.dayrit              | September 11, 2023    | DEPP-5652              | Added method for getCompletedCadenceByTargetIds                  |
      | mark.j.mahilum                 | Sept 19, 2023         | DEPP-6524              | Added logic to include follow-up call in Completed               |
      |                                |                       |                        | Cadence statuses                                                 |
      | roy.nino.s.regala              | Sep 22, 2023          | DEPP-6365              | Added addition fields for soql                                   |
      | johanna.a.gibas                | Oct 16, 2023          | DEPP-6855              | Used string literals for Statuses                                |
      | neil.lesidan                   | Oct 23, 2023          | DEPP-6975              | Add additional return fields in SOQL                             |
      | johanna.a.gibas                | Oct 25, 2023          | DEPP-6889              | Added new fields in getCompletedCadenceByTargetIdsAndCadenceName |
      | roy.nino.s.regala              | Oct 30, 2023          | DEPP-7024              | Added new fields in getCompletedCadenceByTargetIdsAndCadenceName |
      | eccarius.munoz                 | April 30, 2024        | DEPP-8041              | Added methods for outreach case.                                 |
      | julie.jane.alegre              | May 06, 2024          | DEPP-8490              | Add access level on findByCriteria method                        |
 */
public inherited sharing class CompletedCadencesDAO extends DmlBase implements ICompletedCadencesDAO {

    public static final String NULL_STATUS = '';
    public static final String SUCCESSFUL_STATUS = 'Successful';
    public static final String CLOSED_FOLLOW_UP_STATUS = 'Closed - Follow Up';
    public static final String UNSUCCESSFUL_STATUS = 'Unsuccessful';

    public static final Set<String> completedCadenceStatuses = new Set<String>{
        UNSUCCESSFUL_STATUS,
        CLOSED_FOLLOW_UP_STATUS,
        NULL_STATUS
    };   

    public static ICompletedCadencesDAO newInstance() {
        return (ICompletedCadencesDAO) ImplementationSelector.DAO.newInstance(
            Completed_Cadence__c.SObjectType
        );
    }

    public Schema.SObjectType getSObjectType() {
        return Completed_Cadence__c.SObjectType;
    }

    public List<Completed_Cadence__c> getCompletedCadenceByContactIds(
        Set<Id> contactIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Application__c, Contact__c, Lead__c, Nurture_Track_Configuration__c, Nurture_Track_Configuration__r.Cadence_Name__c ' +
            'FROM Completed_Cadence__c ' +
            'WHERE Contact__c IN:contactIds '+
            'AND Completed_Cadence_Status__c NOT IN: completedCadenceStatuses ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<Completed_Cadence__c> getCompletedCadenceByLeadIds(
        Set<Id> leadIds,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Application__c, Contact__c, Lead__c, Nurture_Track_Configuration__c, Nurture_Track_Configuration__r.Cadence_Name__c, ' +
                'Lead__r.Lead_Source_Category__c, Lead__r.Calculated_Cadence__c, Lead__r.Can_Nurture__c, CreatedDate ' +
                'FROM Completed_Cadence__c ' +
                'WHERE Lead__c IN:leadIds ' +
                'AND Completed_Cadence_Status__c NOT IN: completedCadenceStatuses ' +
                'WITH ' +
                String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<Completed_Cadence__c> getCompletedCadenceByTargetIdsAndCadenceName(
        Set<String> targetIds,
        Set<String> cadenceNames,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Contact__c, Lead__c, Completed_Cadence_Status__c, CreatedDate, ' +
            'Application__r.Offered_Preference__r.Name, ' +
            'Application__r.Offered_Preference__r.Faculty__c, ' +
            'Application__r.Offered_Program_Plan__r.Name, ' +
            'Application__r.Offered_Program_Plan__r.Owning_Faculty__r.Name, ' +
            'Application__r.Related_QTAC_Application__r.QTAC_Offer_Round__c, ' +
            'Application__r.Current_Preference__r.Name, ' + 
            'Cadence_Name__c, Calculated_Cadence__c ' +
            'FROM Completed_Cadence__c ' +
            'WHERE Nurture_Track_Configuration__r.Cadence_Name__c IN :cadenceNames ' +
            'AND Completed_Cadence_Status__c IN: completedCadenceStatuses ' +
            'AND (Contact__c IN :targetIds OR Lead__c IN :targetIds) ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public List<Completed_Cadence__c> getCompletedCadenceByTargetIds(
        Set<Id> targetIds,
        Set<String> cadenceNames,
        String accessLevel
    ) {
        return Database.query(
            'SELECT  Id, Contact__c,Lead__c,Nurture_Track_Configuration__c,Nurture_Track_Configuration__r.Cadence_Name__c, Completed_Cadence_Status__c ' +
            'FROM Completed_Cadence__c ' +
            'WHERE Nurture_Track_Configuration__r.Cadence_Name__c IN :cadenceNames ' +
            'AND (Contact__c IN :targetIds OR Lead__c IN :targetIds) ' +
            'WITH ' +
            String.escapeSingleQuotes(accessLevel)
        );
    }

    public String getWhereClauseByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = '';
        //Collate all criteria checked in every Criteria fields
        soql = 
            whereClauseCheckerForCompletedCadenceCriteria(completedCadenceCriteria, contactCriteria) + 
            whereClauseCheckerForContactCriteria(completedCadenceCriteria, contactCriteria); 
        
        if(soql != '') {
            soql = 'WHERE ' + soql.trim().removeStart('AND').trim();
        }
    
        return soql;   
    }

    public String whereClauseCheckerForCompletedCadenceCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = '';
        if(completedCadenceCriteria.getCompletedCadence() != null){
            soql += 'AND Cadence_Name__c = \'' + completedCadenceCriteria.getCompletedCadence() + '\' ' ;
        }
        if(completedCadenceCriteria.getStatus() != null){
            soql += 'AND Completed_Cadence_Status__c = \'' + completedCadenceCriteria.getStatus() + '\' ' ;
        }
        if(
            completedCadenceCriteria.executionDate != null 
            && completedCadenceCriteria.completedCadanceDateFrom != null  
            && completedCadenceCriteria.completedCadanceDateTo != null
        ){
            soql = soql 
            + 'AND LastModifiedDate >= ' + completedCadenceCriteria.getCompletedCadanceDateFrom() + ' ' 
            + 'AND LastModifiedDate <= ' + completedCadenceCriteria.getCompletedCadanceDateTo() + ' ';
        }  
    
        return soql; 
    }

    public String whereClauseCheckerForContactCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = '';
        if(contactCriteria.getIsQUTStudent() != null){
            soql += 'AND Contact__r.QUT_Student__c = ' + contactCriteria.getIsQUTStudent() + ' ' ;
        }
        if(contactCriteria.getRecordType() != null){
            soql += 'AND Contact__r.RecordType.DeveloperName = \'' + contactCriteria.getRecordType() + '\' ' ;
        }     
    
        return soql; 
    }

    public String getContactQueryByCriteria(
         CompletedCadencesDAO.Criteria completedCadenceCriteria, 
         ContactsDAO.Criteria contactCriteria
    ){
        String soql = 'SELECT Contact__c FROM Completed_Cadence__c ' + getWhereClauseByCriteria(completedCadenceCriteria, contactCriteria);
        return soql.trim();
    }

    public List<Completed_Cadence__c> findByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria,
        AccessLevel accessLevel
    ){
        return Database.query(getQueryByCriteria(completedCadenceCriteria, contactCriteria) , accessLevel);
    }

    public String getQueryByCriteria(
        CompletedCadencesDAO.Criteria completedCadenceCriteria, 
        ContactsDAO.Criteria contactCriteria
    ){
        String soql = 'SELECT Id, Contact__c, Cadence_Name__c, LastModifiedDate FROM Completed_Cadence__c ' + getWhereClauseByCriteria(completedCadenceCriteria, contactCriteria);
        return soql.trim();
    }

    /**
     * @Description:Wrapper Class that represents the Criteria for Completed Cadence.
     */
    public class Criteria {
        private String status;
        private String completedCadence;   
        private Date executionDate;
        private Integer completedCadanceDateFrom;
        private Integer completedCadanceDateTo;

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getCompletedCadence() {
            return completedCadence;
        }

        public void setCompletedCadence(String completedCadence) {
            this.completedCadence = completedCadence;
        }

        public Date getExecutionDate() {
            return executionDate;
        }

        public void setExecutionDate(Date executionDate) {
            this.executionDate = executionDate;
        }

        public String getCompletedCadanceDateFrom(){
            if ( this.executionDate != null ) {
                Date returnDate = this.executionDate.addDays(this.completedCadanceDateFrom);
                String strReturnDate =  DateTime.newInstance(returnDate.year(), returnDate.month(), returnDate.day()).format('YYYY-MM-dd HH:mm:ss');
                strReturnDate = strReturnDate.replaceFirst(' ', 'T') + 'Z';
                return strReturnDate;
            } else {
                return null;
            }
        }
        public void setCompletedCadanceDateFrom(Integer completedCadanceDateFrom){
            this.completedCadanceDateFrom = completedCadanceDateFrom;
        }
        public String getCompletedCadanceDateTo(){
            if ( this.executionDate != null ) {
                Date returnDate = this.executionDate.addDays(this.completedCadanceDateTo);
                String strReturnDate =  DateTime.newInstance(returnDate.year(), returnDate.month(), returnDate.day()).format('YYYY-MM-dd HH:mm:ss');
                strReturnDate = strReturnDate.replaceFirst(' ', 'T') + 'Z';
                return strReturnDate;
            } else {
                return null;
            }
        }
        public void setCompletedCadanceDateTo(Integer completedCadanceDateTo){
            this.completedCadanceDateTo = completedCadanceDateTo;
        }
        
        public Boolean isEmpty() {
            return status == null && completedCadence == null && completedCadanceDateTo == null && completedCadanceDateFrom == null && executionDate == null;
        }
    }
   
}
