List<Lead> leadUpdate = [Select Id, Persona_Type__c From Lead];

for(Lead ld: leadUpdate){
    ld.Persona_Type__c = 'Personal';
}

Update leadUpdate;