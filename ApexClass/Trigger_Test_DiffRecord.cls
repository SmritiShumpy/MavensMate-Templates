@isTest
private class Trigger_Test_DiffRecord
{ 
    @isTest
    static void testDiffRecords()
    {
        Set<String> allAccountFieldNames = Schema.SObjectType.Account.fields.getMap().keySet();
        List<Account> accounts = new List<Account>{
            new Account(Name='a', AccountNumber='100', AnnualRevenue=10000),
            new Account(Name='b', AccountNumber='200', AnnualRevenue=20000)
        };

        insert accounts;

        Map<Id, Account> mapIdToAccount = new Map<Id, Account>(accounts);
        List<Account> accountsToCompare = new List<Account>();
        for (Account testAccount: accounts){
            accountsToCompare.add(testAccount.clone(true,true,true,true));
        }
        accountsToCompare[0].AccountNumber='1000';
        Map<Id, Account> mapIdToAccountsToCompare = new Map<Id, Account>(accountsToCompare);

        List<Account> accountsWithDifference = 
            Trigger_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, 'Name');
        System.assert(accountsWithDifference.isEmpty(), 'Expected no differences, found ' + accountsWithDifference.size());

        accountsWithDifference = 
            Trigger_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, 'AccountNumber');
        System.assertEquals(1, accountsWithDifference.size());
        System.assertEquals('1000', accountsWithDifference[0].AccountNumber);

        accountsWithDifference = 
            Trigger_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, new Set<String>{'Name', 'AnnualRevenue'});
        System.assert(accountsWithDifference.isEmpty(), 'Expected no differences, found ' + accountsWithDifference.size());

        accountsWithDifference = 
            Trigger_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, new Set<String>{'Name', 'AccountNumber'});
        System.assertEquals(1, accountsWithDifference.size());
        System.assertEquals('1000', accountsWithDifference[0].AccountNumber);

        try {
            Trigger_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, 'Test');
            System.assert(false, 'Did not throw exception for invalid field name.');
        }
        catch(Exception e){}
        
        accounts.remove(0);
        try {
            Trigger_DiffRecord.getRecordsWithDiff(accounts, accountsToCompare, 'Name');
            System.assert(false, 'Did not throw exception for lists of different sizes.');
        }
        catch(Exception e){}
   
        // maps

        Map<Id, SObject> mapAccountsWithDifference = 
            Trigger_DiffRecord.getRecordsWithDiff(mapIdToAccount, mapIdToAccountsToCompare, 'Name');
        System.assert(mapAccountsWithDifference.isEmpty(),
                        'Expected no differences, found ' + mapAccountsWithDifference.size());

        mapAccountsWithDifference = 
            Trigger_DiffRecord.getRecordsWithDiff(mapIdToAccount, mapIdToAccountsToCompare, 'AccountNumber');
        System.assertEquals(1, mapAccountsWithDifference.size());
        System.assertEquals('1000', mapAccountsWithDifference.values()[0].get('AccountNumber'));

        mapAccountsWithDifference = 
            Trigger_DiffRecord.getRecordsWithDiff(mapIdToAccount, mapIdToAccountsToCompare, new Set<String>{'Name', 'AnnualRevenue'});
        System.assert(mapAccountsWithDifference.isEmpty(), 'Expected no differences, found ' + mapAccountsWithDifference.size());

        mapAccountsWithDifference = 
            Trigger_DiffRecord.getRecordsWithDiff(mapIdToAccount, mapIdToAccountsToCompare, new Set<String>{'Name', 'AccountNumber'});
        System.assertEquals(1, mapAccountsWithDifference.size());
        System.assertEquals('1000', mapAccountsWithDifference.values()[0].get('AccountNumber'));

        Trigger_DiffRecord.getRecordsWithDiff(new List<SObject>(), new List<SObject>(), new Set<String>{}, '', '');
        Trigger_DiffRecord.getRecordsWithDiff(mapIdToAccount.values(), mapIdToAccountsToCompare.values(), new Set<String>{}, '', '');

        Trigger_DiffRecord.recordDiff(mapIdToAccount.values()[0], new Set<String>{'Name'}, '');

    }
}