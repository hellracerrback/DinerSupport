/**
 * @description Retrieves reservations for a diner (Invocable action for Flows/Agents)
 *
 * Diner__c fields: Contact__c (lookup to Contact), Average_Party_Size__c,
 *                  Dietary_Preferences__c, Favorite_Cuisines__c, Loyalty_Tier__c,
 *                  Preferred_Communication_Channel__c, Preferred_Dining_Time__c,
 *                  Total_Lifetime_Bookings__c
 * Email is resolved via Contact__r.Email on the Diner__c record.
 */
public with sharing class AgentAction_GetReservations {

    /**
     * Invocable entry point for Flow / Agent Builder
     *
     * @param requests List of ReservationRequest inputs (bulkified)
     * @return List of ReservationResult responses (one per input)
     */
    @InvocableMethod(label='Get User Reservations'
                     description='Retrieves active and upcoming reservations for a diner'
                     category='Agent Actions')
    public static List<ReservationResult> getReservations(List<ReservationRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return new List<ReservationResult>();
        }

        // Collect emails and diner Ids for lookup
        Set<String> emails = new Set<String>();
        Set<Id> dinerIdsFromInput = new Set<Id>();
        for (ReservationRequest req : requests) {
            if (!String.isBlank(req.userEmail)) {
                emails.add(req.userEmail.trim().toLowerCase());
            }
            if (req.dinerId != null) {
                dinerIdsFromInput.add(req.dinerId);
            }
        }

        // Resolve email -> Diner Id via Contact relationship
        Map<String, Id> dinerIdByEmail = new Map<String, Id>();
        if (!emails.isEmpty()) {
            for (Diner__c d : [
                SELECT Id, Contact__r.Email
                FROM Diner__c
                WHERE Contact__r.Email IN :emails
                LIMIT 500
            ]) {
                if (d.Contact__r != null && !String.isBlank(d.Contact__r.Email)) {
                    dinerIdByEmail.put(d.Contact__r.Email.trim().toLowerCase(), d.Id);
                }
            }
        }

        // Build the set of Diner Ids to query reservations for
        Set<Id> dinerIdsToQuery = new Set<Id>(dinerIdsFromInput);
        for (String em : emails) {
            if (dinerIdByEmail.containsKey(em)) {
                dinerIdsToQuery.add(dinerIdByEmail.get(em));
            }
        }

        // Query reservations
        Map<Id, List<Reservation__c>> reservationsByDinerId = new Map<Id, List<Reservation__c>>();
        if (!dinerIdsToQuery.isEmpty()) {
            for (Reservation__c r : [
                SELECT Id, Name, Confirmation_Code__c,
                       Restaurant__c, Restaurant__r.Name,
                       Booking_DateTime__c, Party_Size__c,
                       Status__c, Special_Requests__c,
                       Table_Assignment__c, Diner__c
                FROM Reservation__c
                WHERE Diner__c IN :dinerIdsToQuery
                  AND Status__c IN ('Confirmed', 'Modified')
                  AND Booking_DateTime__c >= :System.now()
                ORDER BY Booking_DateTime__c ASC
                LIMIT 200
            ]) {
                if (!reservationsByDinerId.containsKey(r.Diner__c)) {
                    reservationsByDinerId.put(r.Diner__c, new List<Reservation__c>());
                }
                reservationsByDinerId.get(r.Diner__c).add(r);
            }
        }

        // Build results
        List<ReservationResult> results = new List<ReservationResult>();
        for (ReservationRequest req : requests) {
            ReservationResult res = new ReservationResult();
            res.success = true;
            res.count = '0';
            res.reservations = new List<Reservation__c>();
            res.message = 'No upcoming reservations found.';

            Id dinerId = null;
            if (req.dinerId != null) {
                dinerId = req.dinerId;
            } else if (!String.isBlank(req.userEmail)) {
                String key = req.userEmail.trim().toLowerCase();
                if (dinerIdByEmail.containsKey(key)) {
                    dinerId = dinerIdByEmail.get(key);
                }
            }

            if (String.isBlank(req.userEmail) && req.dinerId == null) {
                res.success = false;
                res.message = 'Missing userEmail or dinerId input.';
            } else if (dinerId != null && reservationsByDinerId.containsKey(dinerId)) {
                List<Reservation__c> resList = reservationsByDinerId.get(dinerId);
                res.reservations = resList;
                res.count = String.valueOf(resList.size());
                res.message = 'Found ' + res.count + ' upcoming reservation(s).';
            }

            results.add(res);
        }

        return results;
    }

    // Input wrapper class
    public class ReservationRequest {
        @InvocableVariable(required=true label='User Email')
        public String userEmail;

        @InvocableVariable(label='Diner Id (fallback)')
        public Id dinerId;
    }

    // Output wrapper class
    public class ReservationResult {
        @InvocableVariable(label='Reservations')
        public List<Reservation__c> reservations;

        @InvocableVariable(label='Count')
        public String count;

        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;
    }
}