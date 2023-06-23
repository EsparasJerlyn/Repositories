/**
    DEPP-5922 Add permissionset groups to IT2 persona
    PERSONA	                            PERMISSIONSET GROUP                USER ROLE
    Future Student Config               Future Student Super User          Future Student Super User
 */
List<PermissionSetAssignment> newAssignmentList = new List<PermissionSetAssignment>();

PermissionSetGroup futureStudentSuperUserPermSetGrp = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName = 'Future_Student_Super_User' LIMIT 1];

List<User> users = [SELECT Id, Name, UserRole.DeveloperName FROM User WHERE UserRole.DeveloperName = 'Future_Student_Super_User' ];

for(User user : users){    
    newAssignmentList.add(new PermissionSetAssignment(
        PermissionSetGroupId = futureStudentSuperUserPermSetGrp.Id,
        AssigneeId = user.Id)
    );
}

if(!newAssignmentList.isEmpty()){
    Database.SaveResult[] srList = Database.insert(newAssignmentList, false);
    for (Database.SaveResult result : srList){
        if(result.isSuccess()){
            System.debug('Successfully added permission set group to Future Student Engagement Persona.');
        }else{
            System.debug('Database error in adding permission set group to Future Student Engagement Persona: ' + result.getErrors());
        }            
    }
}