List<Lead> leadList = new List<Lead>([
    SELECT Id, Email, Personal_Email__c, MobilePhone, Personal_Mobile__c
    FROM Lead
    WHERE Personal_Email__c <> null 
    OR Personal_Mobile__c <> null
]);

if(!leadList.isEmpty()){
    List<Task> leadTaskList = new List<Task>();
    Map<Id,Lead> leadToUpdate = new Map<Id,Lead>();
    for(Lead leadRecord : leadList){
        if(leadRecord.Personal_Email__c != null){
            //Task creation for Personal Email
            if(leadRecord.Email != null && leadRecord.Personal_Email__c != leadRecord.Email){
                Task newTask = new Task(
                    WhoId = leadRecord.Id,
                    Subject = 'Personal Email',
                    Description = 'Personal Email: ' + leadRecord.Personal_Email__c
                );
                leadTaskList.add(newTask);
            //Personal Email to Email Transfer
            }else if(leadRecord.Email == null){
                leadRecord.Email = leadRecord.Personal_Email__c;
            }
            leadRecord.Personal_Email__c = null;
            leadToUpdate.put(leadRecord.Id, leadRecord);
        }
        if(leadRecord.Personal_Mobile__c != null){
            //Task creation for Personal Mobile
            if(leadRecord.MobilePhone != null && leadRecord.Personal_Mobile__c != leadRecord.MobilePhone){
                Task newTask = new Task(
                    WhoId = leadRecord.Id,
                    Subject = 'Personal Mobile',
                    Description = 'Personal Mobile: ' + leadRecord.Personal_Mobile__c
                );
                leadTaskList.add(newTask);
            //Personal Mobile to Mobile Transfer
            }else if(leadRecord.MobilePhone == null){
                leadRecord.MobilePhone = leadRecord.Personal_Mobile__c;
            }
            leadRecord.Personal_Mobile__c = null;
            leadToUpdate.put(leadRecord.Id, leadRecord);
        }
    }
    if(!leadTaskList.isEmpty()){
        insert leadTaskList;
    }
    if(!leadToUpdate.values().isEmpty()){
        update leadToUpdate.values();
    }
}