List<Contact> contactList = [
    SELECT Id, Work_Email__c, hed__WorkEmail__c
    FROM Contact
    WHERE Work_Email__c = null AND hed__WorkEmail__c != null
    LIMIT 1000
];

system.debug('Size: '+contactList.size());

if(!contactList.isEmpty()){
    
    for(Contact record : contactList){
        record.Work_Email__c = record.hed__WorkEmail__c;
        system.debug('record.Work_Email__c: '+record.Work_Email__c);
    }
    update contactList;
}