@isTest
private class AgentAction_UpdateReservationTest {
    @testSetup
    static void setup() {
        Diner__c diner = new Diner__c(
            First_Name__c='Updater',
            Last_Name__c='Test',
            Email__c='updater@example.com'
        );
        insert diner;

        Reservation__c res = new Reservation__c(
            Diner__c = diner.Id,
            Restaurant_Name__c = 'Update Restaurant',
            Booking_DateTime__c = System.now().addDays(2),
            Party_Size__c = 2,
            Status__c = 'Confirmed'
        );
        insert res;
    }

    static testMethod void testUpdateReservationChange() {
        // Query reservation to get confirmation code (Name)
        Reservation__c r = [SELECT Id, Name, Booking_DateTime__c, Party_Size__c FROM Reservation__c LIMIT 1];

        AgentAction_UpdateReservation.UpdateRequest req = new AgentAction_UpdateReservation.UpdateRequest();
        req.confirmationCode = r.Name;
        req.newPartySize = 4;
        req.newDateTime = r.Booking_DateTime__c.addHours(1);

        Test.startTest();
        List<AgentAction_UpdateReservation.UpdateResult> results =
            AgentAction_UpdateReservation.updateReservation(new List<AgentAction_UpdateReservation.UpdateRequest>{req});
        Test.stopTest();

        System.assertEquals(1, results.size());
        AgentAction_UpdateReservation.UpdateResult res = results[0];
        System.assertEquals(true, res.success);
        System.assertEquals('Reservation updated successfully!', res.message);
    }

    static testMethod void testUpdateReservationNoChange() {
        Reservation__c r = [SELECT Id, Name, Booking_DateTime__c, Party_Size__c FROM Reservation__c LIMIT 1];

        AgentAction_UpdateReservation.UpdateRequest req = new AgentAction_UpdateReservation.UpdateRequest();
        req.confirmationCode = r.Name;
        // No changes provided

        Test.startTest();
        List<AgentAction_UpdateReservation.UpdateResult> results =
            AgentAction_UpdateReservation.updateReservation(new List<AgentAction_UpdateReservation.UpdateRequest>{req});
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals('No changes required for reservation.', results[0].message);
    }
}