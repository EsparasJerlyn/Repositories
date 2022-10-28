final Id ID_CURRENTUSER = UserInfo.getUserId();
List<User> sysadminUsers = 
    [SELECT Id, ProfileId FROM User 
    WHERE Profile.Name='System Administrator'
    AND IsActive=true
    AND Id!=:ID_CURRENTUSER];
final Id ID_PROFILE_QUTSYSADMIN = 
    [SELECT Id FROM Profile WHERE Name='QUT System Administrator' LIMIT 1].Id;
final Id ID_PERMSET_SYSADMIN = 
    [SELECT Id FROM PermissionSet WHERE Name='System_Administrator' LIMIT 1].Id;
List<PermissionSetAssignment> permsetAsgns = new List<PermissionSetAssignment>();
for(User sysadminUser : sysadminUsers) {
    permsetAsgns.add(
        new PermissionSetAssignment(
            AssigneeId = sysadminUser.Id, 
            PermissionSetId = ID_PERMSET_SYSADMIN
        )
    );
    sysadminUser.ProfileId = ID_PROFILE_QUTSYSADMIN;
}
upsert permsetAsgns;
update sysadminUsers;