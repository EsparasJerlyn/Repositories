/**
    DEPP-5810 Add permission set group to IT3 Personas
    Persona	                            Perm Set Grp            Role
    Partnership Manager	                Partnership Manager     Partnership Manager
    Operations Manager	                Operations Manager      Operations Manager
    VP Business Development	            VPBD/Director           VP Business Development
    Director Business Development	    VPBD/Director           VP Business Development
 */

PermissionSetGroup partnershipMngrPermSetGrp = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName = 'Partnership_Manager' LIMIT 1];
PermissionSetGroup operationMngrPermSetGrp = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName = 'Operations_Manager' LIMIT 1];
PermissionSetGroup vpbdPermSetGrp = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName = 'VPBD_Director' LIMIT 1];

List<PermissionSetAssignment> newAssignmentList = new List<PermissionSetAssignment>();

List<User> users = [SELECT Id, Name, UserRole.DeveloperName FROM User WHERE Profile.Name = 'Industry Engagement'];

for(User user : users){
    if(user.UserRole.DeveloperName == 'Partnership_Manager'){
        newAssignmentList.add(new PermissionSetAssignment(
            PermissionSetGroupId = partnershipMngrPermSetGrp.Id,
            AssigneeId = user.Id)
        );
        System.debug('Adding ' + partnershipMngrPermSetGrp.DeveloperName + ' to ' + user.Name);
    }

    if(user.UserRole.DeveloperName == 'Operations_Manager'){
        newAssignmentList.add(new PermissionSetAssignment(
            PermissionSetGroupId = operationMngrPermSetGrp.Id,
            AssigneeId = user.Id)
        );
        System.debug('Adding ' + operationMngrPermSetGrp.DeveloperName + ' to ' + user.Name);
    }

    if(user.UserRole.DeveloperName == 'VP_Business_Development'){
        newAssignmentList.add(new PermissionSetAssignment(
            PermissionSetGroupId = vpbdPermSetGrp.Id,
            AssigneeId = user.Id)
        );
        System.debug('Adding ' + vpbdPermSetGrp.DeveloperName + ' to ' + user.Name);
    }
}

if(!newAssignmentList.isEmpty()){
    Database.SaveResult[] srList = Database.insert(newAssignmentList, false);
    for (Database.SaveResult result : srList){
        if(result.isSuccess()){
            System.debug('Successfully added permission set group to IT3 persona.');
        }else{
            System.debug('Database error in adding permission set group to IT3 persona: ' + result.getErrors());
        }            
    }
}
