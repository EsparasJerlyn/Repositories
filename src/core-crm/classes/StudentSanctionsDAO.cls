/**
 * @description DAO Class for Student Sanction Object. Contains soql and constants related to the Student Sanction object.
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2024        | DEPP-7984              | Created file
 */
public inherited sharing class StudentSanctionsDAO extends DmlBase implements IStudentSanctionsDAO{

	public static final String INSERT_PROCESS = 'Insert';
	public static final String PROCESSED = 'Processed';

    public Schema.SObjectType getSObjectType()
	{
		return Student_Sanction__c.SObjectType;
	}

    public static IStudentSanctionsDAO newInstance()
	{
		return (IStudentSanctionsDAO) ImplementationSelector.DAO.newInstance(Student_Sanction__c.SObjectType);
	}
	
	public Database.QueryLocator queryLocatorGetStudentSanctionsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){
        String query =
		' SELECT Id, Sanction_Code__c, QUT_Student_ID__c ' +
		' FROM Student_Sanction__c ' +
		' WHERE Batch_Process__c IN: batchProcessSet ';
        return Database.getQueryLocator(query,accessLevel);
    }

	public List<Student_Sanction__c> getStudentSanctionsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){

		if(batchProcessSet.isEmpty()){
			return new List<Student_Sanction__c>();
		}
		
        String query =
		' SELECT Id, Sanction_Code__c, QUT_Student_ID__c ' +
		' FROM Student_Sanction__c ' +
		' WHERE Batch_Process__c IN: batchProcessSet ' +
		' LIMIT 1 ';
        return Database.query(query,accessLevel);
    }

}