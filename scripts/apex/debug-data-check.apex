// Confirms the org has data for the Account you want to summarize.

String nameOrId = 'Edge Communications';

List<Account> accts = [
    SELECT Id, Name, Industry
    FROM Account
    WHERE Name LIKE :('%' + nameOrId + '%')
    ORDER BY Name
    LIMIT 5
];
System.debug('Account matches: ' + accts.size());
for (Account a : accts) {
    System.debug('  - ' + a.Name + ' (' + a.Id + ')');
}

if (accts.isEmpty()) {
    System.debug('No accounts found. Showing any 5 accounts in the org:');
    for (Account a : [SELECT Id, Name FROM Account LIMIT 5]) {
        System.debug('  - ' + a.Name + ' (' + a.Id + ')');
    }
    return;
}

Id acctId = accts[0].Id;
System.debug('Using Account Id: ' + acctId);

System.debug('Open Opportunities: ' +
    [SELECT COUNT() FROM Opportunity WHERE AccountId = :acctId AND IsClosed = false]);
System.debug('Closed-Won Opportunities: ' +
    [SELECT COUNT() FROM Opportunity WHERE AccountId = :acctId AND IsWon = true]);
System.debug('Cases (last 90d): ' +
    [SELECT COUNT() FROM Case WHERE AccountId = :acctId AND CreatedDate = LAST_N_DAYS:90]);
System.debug('Contacts: ' +
    [SELECT COUNT() FROM Contact WHERE AccountId = :acctId]);
