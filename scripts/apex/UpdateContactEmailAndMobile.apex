List<Contact> contactList = new List<Contact>([
    SELECT Id, Email, Personal_Email__c, MobilePhone, Personal_Mobile__c
    FROM Contact
    WHERE Personal_Email__c <> null
    OR Personal_Mobile__c <> null
]);

if(!contactList.isEmpty()){
    List<Task> contactTaskList = new List<Task>();
    Map<Id,Contact> contactToUpdate = new Map<Id,Contact>();
    for(Contact contactRecord : contactList){
        if(contactRecord.Personal_Email__c != null){
            //Task creation for Personal Email
            if(contactRecord.Email != null && contactRecord.Personal_Email__c != contactRecord.Email){
                Task newTask = new Task(
                    WhoId = contactRecord.Id,
                    Subject = 'Personal Email',
                    Description = 'Personal Email: ' + contactRecord.Personal_Email__c
                );
                contactTaskList.add(newTask);
            //Personal Email to Email Transfer
            }else if(contactRecord.Email == null){
                contactRecord.Email = contactRecord.Personal_Email__c;
            }
            contactRecord.Personal_Email__c = null;
            contactToUpdate.put(contactRecord.Id, contactRecord);
        }
        if(contactRecord.Personal_Mobile__c != null){
            //Task creation for Personal Mobile
            if(contactRecord.MobilePhone != null && contactRecord.Personal_Mobile__c != contactRecord.MobilePhone){
                Task newTask = new Task(
                    WhoId = contactRecord.Id,
                    Subject = 'Personal Mobile',
                    Description = 'Personal Mobile: ' + contactRecord.Personal_Mobile__c
                );
                contactTaskList.add(newTask);
            //Personal Mobile to Mobile Transfer
            }else if(contactRecord.MobilePhone == null){
                contactRecord.MobilePhone = contactRecord.Personal_Mobile__c;
            }
            contactRecord.Personal_Mobile__c = null;
            contactToUpdate.put(contactRecord.Id, contactRecord);
        }
    }
    if(!contactTaskList.isEmpty()){
        insert contactTaskList;
    }
    if(!contactToUpdate.values().isEmpty()){
        update contactToUpdate.values();
    }
}