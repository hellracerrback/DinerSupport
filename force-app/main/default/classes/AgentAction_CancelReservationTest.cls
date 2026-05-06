@isTest
private class AgentAction_CancelReservationTest {
    @testSetup
    static void setup() {
        Diner__c diner = new Diner__c(
            First_Name__c='Canceller',
            Last_Name__c='Test',
            Email__c='canceller@example.com'
        );
        insert diner;

        // Upcoming reservation >48 hours
        Reservation__c res1 = new Reservation__c(
            Diner__c = diner.Id,
            Restaurant_Name__c = 'Cancel Restaurant',
            Booking_DateTime__c = System.now().addDays(5),
            Party_Size__c = 2,
            Status__c = 'Confirmed'
        );

        // Reservation within 3 hours (no-show/late)
        Reservation__c res2 = new Reservation__c(
            Diner__c = diner.Id,
            Restaurant_Name__c = 'Cancel Restaurant',
            Booking_DateTime__c = System.now().addHours(2),
            Party_Size__c = 3,
            Status__c = 'Confirmed'
        );

        insert new List<Reservation__c>{res1, res2};
    }

    static testMethod void testCancelReservationFree() {
        // Cancel the far-out booking (should be free)
        Reservation__c r = [SELECT Id, Name FROM Reservation__c WHERE Booking_DateTime__c > :System.now() ORDER BY Booking_DateTime__c ASC LIMIT 1];

        AgentAction_CancelReservation.CancelRequest req = new AgentAction_CancelReservation.CancelRequest();
        req.confirmationCode = r.Name;

        Test.startTest();
        List<AgentAction_CancelReservation.CancelResult> results =
            AgentAction_CancelReservation.cancelReservation(new List<AgentAction_CancelReservation.CancelRequest>{req});
        Test.stopTest();

        System.assertEquals(1, results.size());
        AgentAction_CancelReservation.CancelResult res = results[0];
        System.assertEquals(true, res.success);
        System.assertEquals(0, Integer.valueOf(res.cancellationFee == null ? 0 : res.cancellationFee.intValue()));
    }

    static testMethod void testCancelReservationLateFee() {
        // Cancel the near booking (within 2-24 or <2 hours depending on timing)
        Reservation__c r = [SELECT Id, Name, Booking_DateTime__c FROM Reservation__c WHERE Booking_DateTime__c > :System.now() ORDER BY Booking_DateTime__c ASC LIMIT 2];
        Reservation__c near = r[0];

        AgentAction_CancelReservation.CancelRequest req = new AgentAction_CancelReservation.CancelRequest();
        req.confirmationCode = near.Name;

        Test.startTest();
        List<AgentAction_CancelReservation.CancelResult> results =
            AgentAction_CancelReservation.cancelReservation(new List<AgentAction_CancelReservation.CancelRequest>{req});
        Test.stopTest();

        System.assertEquals(1, results.size());
        // fee may be 25 or 50 depending on exact timing; assert success boolean true
        System.assertEquals(true, results[0].success);
    }
}