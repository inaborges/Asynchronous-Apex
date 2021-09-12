public without sharing class AddPrimaryContact implements Queueable{

    private Contact contact;
    private String state;
    
    public AddPrimaryContact(Contact inputContact, String inputState) {
        this.contact = inputContact;
        this.state = inputState;

    }

    public void execute (QueueableContext context){
        //Retrieve 200 Account records
        List<Account> lstAcc = [SELECT Id FROM Account WHERE BillingState = :state LIMIT 200];
        
        //Create empty list of contacts 
        List<Contact> lstCon = new List<Contact>();

        //Iterate through the Account records
        for (Account acc : lstAcc){
            //Clone the contact record, make the clone a child of this specific Account record
            //and add to the list of Contacts
            Contact contactClone = contact.clone();
            contactClone.AccountId = acc.Id;
            lstCon.add(contactClone); 
        }
        insert lstCon;
    }
}
    
//Test Method    
@isTest
public with sharing class AddPrimaryContactTest {

    @isTest
    public static void testQueueableClass() {

        //Load test data
        List<Account> lstAcc = new List<Account>();
        for(Integer i=0; i<500; i++){
            Account acc = new Account(Name='Test Account');
            if(i<250){
                acc.BillingState = 'NY';
            } else{
                acc.BillingState = 'CA';
            }
            lstAcc.add(acc);

        }
        insert lstAcc;

        Contact contact = new Contact(FirstName='Marina', LastName='Borges');
        insert contact;

        //Perform the test
        Test.startTest();
        Id jobId = System.enqueueJob(new AddPrimaryContact(contact, 'CA'));
        Test.stopTest();

        //Check the result
        List<Contact> lstCon = [SELECT Id FROM Contact WHERE Contact.Account.BillingState = 'CA'];
        system.assertEquals(200, lstCon.size(), 'ERROR: Incorrect number of Contact records found');


    }
}    
