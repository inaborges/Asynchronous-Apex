public with sharing class AccountProcessor {

    @future
    public static void countContacts(List<Id> accIds) {
        
        List<Account> lstAcc = [SELECT Id, Name, Number_Of_Contacts__c, (SELECT Id FROM Contacts) FROM Account WHERE Id in :accIds];
        
        for (Account a : lstAcc){
            List<Contact> lstCon = a.Contacts;
            a.Number_Of_Contacts__c = lstCon.size();

        }

        update lstAcc;
        system.debug('LstAccounts:::' + lstAcc);

    }
}

// Test Method
@isTest
public with sharing class AccountProcessorTest {
    public static testmethod void testAccountProcessor() {

        Account acc = new Account();
        acc.Name = 'Test';
        Contact con = new Contact();
        con.Id = acc.Id;
        con.LastName = 'Borges';

        insert acc;
        insert con;

        test.startTest();
        List<Id> lstIds = new List<Id>();
        lstIds.add(acc.Id);
              
        AccountProcessor.countContacts(lstIds);

        test.stopTest();

        system.debug(lstIds);
        system.assertEquals(1, lstIds.size(), 'List Ids size should be equals 1');

    }

    
}
