@IsTest
private class AccountSummaryActionTest {

    @IsTest
    static void happyPath_resolvesByName_andIncludesExpectedFragments() {
        // Arrange: create related data.
        Account acct = new Account(
            Name = 'ACME Test Corp',
            Industry = 'Technology',
            Website = 'https://acme.example.com',
            Phone = '555-1234',
            BillingCity = 'San Francisco',
            BillingCountry = 'USA'
        );
        insert acct;

        Contact c = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Title = 'VP Engineering',
            Email = 'jane.doe@example.com',
            AccountId = acct.Id
        );
        insert c;

        Opportunity openOpp = new Opportunity(
            Name = 'Big Expansion Deal',
            StageName = 'Prospecting',
            Amount = 125000,
            CloseDate = Date.today().addDays(45),
            AccountId = acct.Id
        );
        Opportunity wonOpp = new Opportunity(
            Name = 'Prior Won Deal',
            StageName = 'Closed Won',
            Amount = 50000,
            CloseDate = Date.today().addDays(-30),
            AccountId = acct.Id
        );
        insert new List<Opportunity>{ openOpp, wonOpp };

        Case kase = new Case(
            Subject = 'Login issue',
            Status = 'New',
            AccountId = acct.Id
        );
        insert kase;

        // Act: call by name (fuzzy LIKE match).
        AccountSummaryAction.Input req = new AccountSummaryAction.Input();
        req.accountNameOrId = 'ACME';

        Test.startTest();
        List<AccountSummaryAction.Output> outs =
            AccountSummaryAction.execute(new List<AccountSummaryAction.Input>{ req });
        Test.stopTest();

        // Assert.
        System.assertEquals(1, outs.size(), 'Expected one output per input');
        String summary = outs[0].summary;
        System.assertNotEquals(null, summary, 'Summary must not be null');
        System.assert(summary.contains('ACME Test Corp'), 'Summary should include Account name');
        System.assert(summary.contains('Technology'), 'Summary should include industry');
        System.assert(summary.contains('San Francisco'), 'Summary should include billing city');
        System.assert(summary.contains('Big Expansion Deal'), 'Summary should include the open opportunity');
        System.assert(summary.contains('Jane Doe'), 'Summary should include the contact');
        System.assert(summary.contains('VP Engineering'), 'Summary should include the contact title');
        System.assert(summary.contains('jane.doe@example.com'), 'Summary should include the contact email');
        System.assert(summary.contains('New'), 'Summary should include the recent case status');
        System.assert(summary.contains('50000') || summary.contains('50,000.00') || summary.contains('50000.00'),
            'Summary should include the closed-won revenue total');
        System.assert(summary.contains('# Account Summary'), 'Summary should start with the markdown header');
    }

    @IsTest
    static void resolvesByAccountId() {
        Account acct = new Account(Name = 'Lookup By Id Co');
        insert acct;

        AccountSummaryAction.Input req = new AccountSummaryAction.Input();
        req.accountNameOrId = acct.Id;

        List<AccountSummaryAction.Output> outs =
            AccountSummaryAction.execute(new List<AccountSummaryAction.Input>{ req });

        System.assertEquals(1, outs.size());
        System.assert(outs[0].summary.contains('Lookup By Id Co'),
            'Should resolve Account by Id and include its name');
    }

    @IsTest
    static void notFound_returnsFriendlyMessage() {
        AccountSummaryAction.Input req = new AccountSummaryAction.Input();
        req.accountNameOrId = 'ZZZ_No_Such_Account_ZZZ';

        List<AccountSummaryAction.Output> outs =
            AccountSummaryAction.execute(new List<AccountSummaryAction.Input>{ req });

        System.assertEquals(1, outs.size());
        System.assert(outs[0].summary.contains('No Account found'),
            'Expected a not-found marker in the summary');
    }

    @IsTest
    static void blankInput_returnsNotFound() {
        AccountSummaryAction.Input req = new AccountSummaryAction.Input();
        req.accountNameOrId = '';

        List<AccountSummaryAction.Output> outs =
            AccountSummaryAction.execute(new List<AccountSummaryAction.Input>{ req });

        System.assertEquals(1, outs.size());
        System.assert(outs[0].summary.contains('No Account found'),
            'Blank input should surface a not-found message');
    }
}
