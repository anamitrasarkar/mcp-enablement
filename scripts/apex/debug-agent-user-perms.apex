// Who is actually running the agent? What can they see?
// Run this as the Einstein Agent User (NOT as your admin user).
// To check, go to Setup → Agents → open AccountSummaryAgent → Settings tab,
// find the "Running User" / "Agent User" and either:
//   (a) temporarily login-as that user and run from Developer Console, OR
//   (b) run via: sf apex run --file ... --target-org <alias-authed-as-agent-user>

System.debug('Running user: ' + UserInfo.getUserName() + ' (' + UserInfo.getUserId() + ')');
System.debug('Profile: ' + UserInfo.getProfileId());

// FLS/CRUD checks
System.debug('Account isAccessible: ' + Schema.sObjectType.Account.isAccessible());
System.debug('Opportunity isAccessible: ' + Schema.sObjectType.Opportunity.isAccessible());
System.debug('Case isAccessible: ' + Schema.sObjectType.Case.isAccessible());
System.debug('Contact isAccessible: ' + Schema.sObjectType.Contact.isAccessible());

// Row-level visibility — what this user actually sees
System.debug('Accounts visible to this user: ' + [SELECT COUNT() FROM Account]);
System.debug('Opportunities visible to this user: ' + [SELECT COUNT() FROM Opportunity]);

// Permission sets assigned
List<PermissionSetAssignment> psas = [
    SELECT PermissionSet.Name
    FROM PermissionSetAssignment
    WHERE AssigneeId = :UserInfo.getUserId()
];
System.debug('Permission sets assigned to this user:');
for (PermissionSetAssignment p : psas) {
    System.debug('  - ' + p.PermissionSet.Name);
}
