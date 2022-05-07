Id sysAd = [Select Id from UserRole Where Name ='System Administrator' limit 1].Id;
List<User> usersNoRole = [Select Id, UserRoleId from User 
                          Where UserRoleId = null AND
                          (NOT (Name In ('Automated Process','System','CCE Site Guest User',
                                         'Study Site Guest User','Platform Integration User','Chatter Expert')))];

for(User usr: usersNoRole){
    usr.UserRoleId = sysAd;
}

update usersNoRole;