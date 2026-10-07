// Direct invocation of AccountSummaryAction — bypasses the agent runtime entirely.
// Change the test input below to any Account Name or Id in the org.

String testInput = 'Jennifer Blake';

AccountSummaryAction.Input in1 = new AccountSummaryAction.Input();
in1.accountNameOrId = testInput;

System.debug('=== INPUT ===');
System.debug('accountNameOrId: ' + in1.accountNameOrId);

List<AccountSummaryAction.Output> results =
    AccountSummaryAction.execute(new List<AccountSummaryAction.Input>{ in1 });

System.debug('=== OUTPUT ===');
System.debug('result count: ' + results.size());
for (AccountSummaryAction.Output o : results) {
    System.debug('--- summary begin ---');
    // Debug lines truncate at ~5000 chars; split for safety.
    String s = o.summary == null ? '[null]' : o.summary;
    Integer chunk = 3000;
    for (Integer i = 0; i < s.length(); i += chunk) {
        System.debug(s.substring(i, Math.min(i + chunk, s.length())));
    }
    System.debug('--- summary end ---');
}
