 /**
    DEPP-6307: Role Raname from Executive Director Industry Engagement to Executive Director Business Development 
 */
// Query Users with the current User Role
List<User> usersToUpdate = [SELECT Id, UserRole.Id FROM User WHERE UserRole.Name = 'Executive Director Industry Engagement'];

// Query the Id of the Executive Director Business Development Role
Id newRoleId = [SELECT Id,Name FROM UserRole WHERE Name='Executive Director Business Development']?.Id;


// Update User Role for each User
for (User user : usersToUpdate) {
    user.UserRoleId = newRoleId;
}

// Perform DML to update User Roles
if (!usersToUpdate.isEmpty()) {
    update usersToUpdate;
}