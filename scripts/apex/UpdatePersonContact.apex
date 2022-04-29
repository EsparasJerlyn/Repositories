Id personID = [Select Id from recordtype where sobjecttype='Contact' and name ='Person'].Id;
List<Contact> conUpdate = [Select Id, recordtypeId, Persona_Type__c From Contact Where RecordTypeId = null];

for(Contact con: conUpdate){
    con.recordtypeId = personID;
    con.Persona_Type__c = 'Personal';
}

Update conUpdate;