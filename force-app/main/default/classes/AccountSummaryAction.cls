/**
 * Invocable action for the Account Summary Agentforce agent.
 *
 * Given either an Account Name (fuzzy match top result) or an Account Id,
 * returns a concise markdown summary containing company info, call notes,
 * top open opportunities, recent cases, key contacts, and total closed-won
 * revenue.
 *
 * NOTE on security mode:
 *   This enablement/demo org uses `WITH SYSTEM_MODE` to avoid the well-known
 *   silent-zero-rows pitfall where the Einstein Agent User lacks CRUD/FLS
 *   on queried objects when running under `WITH USER_MODE`. For a production
 *   org you should assign the Agent User appropriate permissions and prefer
 *   `WITH USER_MODE`. See references/agent-user-setup.md.
 */
global class AccountSummaryAction {

    private static final Integer OPP_LIMIT = 3;
    private static final Integer CONTACT_LIMIT = 5;
    private static final Integer CASE_LOOKBACK_DAYS = 90;
    private static final Integer CALL_NOTES_MAX_CHARS = 1000;

    @InvocableMethod(
        label='Get Account Summary'
        description='Returns a concise markdown summary for the Account identified by name or Id, including company info, top open opportunities, recent cases, key contacts, and closed-won revenue.'
    )
    public static List<Output> execute(List<Input> inputs) {
        List<Output> results = new List<Output>();
        for (Input req : inputs) {
            Output out = new Output();
            try {
                Account acct = resolveAccount(req.accountNameOrId);
                if (acct == null) {
                    out.summary = '**No Account found** for input: `' + String.valueOf(req.accountNameOrId) + '`.';
                } else {
                    out.summary = buildSummary(acct);
                }
            } catch (Exception e) {
                out.summary = '**Error building Account summary:** ' + e.getMessage();
            }
            results.add(out);
        }
        return results;
    }

    @TestVisible
    private static Account resolveAccount(String nameOrId) {
        if (String.isBlank(nameOrId)) {
            return null;
        }
        String trimmed = nameOrId.trim();

        // Account Id prefix is 001. Agents might also pass 15- or 18-char Ids.
        if ((trimmed.length() == 15 || trimmed.length() == 18) && trimmed.startsWith('001')) {
            List<Account> byId = [
                SELECT Id, Name, Industry, Website, Phone,
                       BillingCity, BillingCountry, Call_Notes__c
                FROM Account
                WHERE Id = :trimmed
                WITH SYSTEM_MODE
                LIMIT 1
            ];
            if (!byId.isEmpty()) {
                return byId[0];
            }
        }

        // Fuzzy name match (case-insensitive LIKE, Name ascending for stability).
        String likePattern = '%' + String.escapeSingleQuotes(trimmed) + '%';
        List<Account> byName = [
            SELECT Id, Name, Industry, Website, Phone,
                   BillingCity, BillingCountry, Call_Notes__c
            FROM Account
            WHERE Name LIKE :likePattern
            WITH SYSTEM_MODE
            ORDER BY Name ASC
            LIMIT 1
        ];
        return byName.isEmpty() ? null : byName[0];
    }

    @TestVisible
    private static String buildSummary(Account a) {
        List<Opportunity> openOpps = [
            SELECT Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE AccountId = :a.Id
              AND IsClosed = false
            WITH SYSTEM_MODE
            ORDER BY Amount DESC NULLS LAST, CloseDate ASC
            LIMIT :OPP_LIMIT
        ];

        Integer caseLookback = CASE_LOOKBACK_DAYS;
        List<Case> recentCases = [
            SELECT Status
            FROM Case
            WHERE AccountId = :a.Id
              AND CreatedDate = LAST_N_DAYS:90
            WITH SYSTEM_MODE
            LIMIT 500
        ];

        List<Contact> contacts = [
            SELECT Name, Title, Email
            FROM Contact
            WHERE AccountId = :a.Id
            WITH SYSTEM_MODE
            ORDER BY LastModifiedDate DESC
            LIMIT :CONTACT_LIMIT
        ];

        AggregateResult[] revenueAgg = [
            SELECT SUM(Amount) total
            FROM Opportunity
            WHERE AccountId = :a.Id
              AND IsWon = true
            WITH SYSTEM_MODE
        ];
        Decimal totalClosedWon = 0;
        if (revenueAgg != null && !revenueAgg.isEmpty() && revenueAgg[0].get('total') != null) {
            totalClosedWon = (Decimal) revenueAgg[0].get('total');
        }

        // Build markdown.
        String nl = '\n';
        String md = '';
        md += '# Account Summary: ' + nullSafe(a.Name) + nl + nl;

        md += '## Company Info' + nl;
        md += '- **Industry:** ' + nullSafe(a.Industry) + nl;
        md += '- **Website:** ' + nullSafe(a.Website) + nl;
        md += '- **Phone:** ' + nullSafe(a.Phone) + nl;
        String city = nullSafe(a.BillingCity);
        String country = nullSafe(a.BillingCountry);
        md += '- **Billing Location:** ' + city + (country == '-' ? '' : ', ' + country) + nl + nl;

        md += '## Call Notes' + nl;
        if (String.isBlank(a.Call_Notes__c)) {
            md += '_No call notes on file._' + nl;
        } else {
            String notes = a.Call_Notes__c.trim();
            Boolean truncated = notes.length() > CALL_NOTES_MAX_CHARS;
            if (truncated) {
                notes = notes.substring(0, CALL_NOTES_MAX_CHARS) + '…';
            }
            md += '> ' + notes.replace('\n', '\n> ') + nl;
            if (truncated) {
                md += nl + '_Notes truncated — full value is longer than ' + CALL_NOTES_MAX_CHARS + ' chars._' + nl;
            }
        }
        md += nl;

        md += '## Top ' + openOpps.size() + ' Open Opportunities' + nl;
        if (openOpps.isEmpty()) {
            md += '_No open opportunities._' + nl;
        } else {
            md += '| Name | Stage | Amount | Close Date |' + nl;
            md += '|---|---|---|---|' + nl;
            for (Opportunity o : openOpps) {
                md += '| ' + nullSafe(o.Name)
                    + ' | ' + nullSafe(o.StageName)
                    + ' | ' + (o.Amount == null ? '-' : '$' + formatCurrency(o.Amount))
                    + ' | ' + (o.CloseDate == null ? '-' : String.valueOf(o.CloseDate))
                    + ' |' + nl;
            }
        }
        md += nl;

        md += '## Recent Cases (last ' + caseLookback + ' days)' + nl;
        md += '- **Total:** ' + recentCases.size() + nl;
        Map<String, Integer> statusCounts = new Map<String, Integer>();
        for (Case c : recentCases) {
            String s = c.Status == null ? 'Unknown' : c.Status;
            statusCounts.put(s, (statusCounts.containsKey(s) ? statusCounts.get(s) : 0) + 1);
        }
        if (!statusCounts.isEmpty()) {
            for (String s : statusCounts.keySet()) {
                md += '  - ' + s + ': ' + statusCounts.get(s) + nl;
            }
        }
        md += nl;

        md += '## Key Contacts (up to ' + CONTACT_LIMIT + ')' + nl;
        if (contacts.isEmpty()) {
            md += '_No contacts on file._' + nl;
        } else {
            for (Contact c : contacts) {
                md += '- **' + nullSafe(c.Name) + '**'
                    + (String.isBlank(c.Title) ? '' : ' — ' + c.Title)
                    + (String.isBlank(c.Email) ? '' : ' (' + c.Email + ')')
                    + nl;
            }
        }
        md += nl;

        md += '## Total Closed-Won Revenue' + nl;
        md += '**$' + formatCurrency(totalClosedWon) + '**' + nl;

        return md;
    }

    private static String nullSafe(String v) {
        return String.isBlank(v) ? '-' : v;
    }

    private static String formatCurrency(Decimal d) {
        if (d == null) {
            return '0.00';
        }
        return d.setScale(2).toPlainString();
    }

    public class Input {
        @InvocableVariable(
            label='Account Name or Id'
            description='Account Name (fuzzy match, top result wins) or Account Id (15 or 18 char, 001-prefixed).'
            required=true
        )
        public String accountNameOrId;
    }

    public class Output {
        @InvocableVariable(
            label='Summary'
            description='Markdown-formatted summary of the Account.'
        )
        public String summary;
    }
}