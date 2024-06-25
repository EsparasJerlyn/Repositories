/**
 * @description Mock DAO Class for Student_Sanction__c Object. 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2024        | DEPP-7984              | Created file
 */
@isTest
public inherited sharing class StudentSanctionsDAOMock extends DmlBaseMock implements IStudentSanctionsDAO {

	public Map<Id, Student_Sanction__c> studentSanctionsMap;

    public Schema.SObjectType getSObjectType()
	{
		return Student_Sanction__c.SObjectType;
	}

	public StudentSanctionsDAOMock() {
		super(new Map<Id, Student_Sanction__c>(), Schema.Student_Sanction__c.SObjectType);
		this.studentSanctionsMap = (Map<Id, Student_Sanction__c>) super.records;
	}

	public Database.QueryLocator queryLocatorGetStudentSanctionsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){
		return null;
    }

	public List<Student_Sanction__c> getStudentSanctionsByBatchProcess(Set<String> batchProcessSet, AccessLevel accessLevel){

		List<Student_Sanction__c> studentSanctionList = new List<Student_Sanction__c>();

		for(Student_Sanction__c studentSanction: studentSanctionsMap.values()){
			if(batchProcessSet.contains(studentSanction.Batch_Process__c)){
				studentSanctionList.add(studentSanction);
			}
		}

		return studentSanctionList;
    }

}