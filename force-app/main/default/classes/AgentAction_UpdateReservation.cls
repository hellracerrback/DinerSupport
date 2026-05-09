/**
 * @description Modifies a reservation with new details (Invocable action)
 */
public with sharing class AgentAction_UpdateReservation {

    /**
     * Invocable entry point to update reservations in bulk.
     *
     * @param requests List of UpdateRequest inputs
     * @return List of UpdateResult responses (one per input)
     */
    @InvocableMethod(label='Update Reservation'
                     description='Modifies a reservation with new details'
                     category='Agent Actions')
    public static List<UpdateResult> updateReservation(List<UpdateRequest> requests) {
        List<UpdateResult> results = new List<UpdateResult>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        // Collect confirmation codes to query reservations in bulk
        Set<String> confirmationCodes = new Set<String>();
        for (UpdateRequest r : requests) {
            if (!String.isBlank(r.confirmationCode)) {
                confirmationCodes.add(r.confirmationCode.trim());
            }
        }

        Map<String, Reservation__c> reservationByName = new Map<String, Reservation__c>();
        if (!confirmationCodes.isEmpty()) {
            for (Reservation__c res : [
                SELECT Id, Name, Booking_DateTime__c, Party_Size__c, Status__c, Restaurant__c
                FROM Reservation__c
                WHERE Name IN :confirmationCodes
                LIMIT 200
            ]) {
                reservationByName.put(res.Name, res);
            }
        }

        List<Reservation__c> toUpdate = new List<Reservation__c>();

        for (UpdateRequest req : requests) {
            UpdateResult result = new UpdateResult();
            result.success = false;
            result.confirmationCode = req.confirmationCode;

            if (String.isBlank(req.confirmationCode)) {
                result.message = 'Missing confirmationCode.';
                results.add(result);
                continue;
            }

            if (!reservationByName.containsKey(req.confirmationCode)) {
                result.message = 'Reservation not found for confirmation code: ' + req.confirmationCode;
                results.add(result);
                continue;
            }

            Reservation__c reservation = reservationByName.get(req.confirmationCode);

            if (reservation.Status__c == 'Cancelled' || reservation.Status__c == 'No-Show') {
                result.message = 'This reservation cannot be modified because it is ' + reservation.Status__c + '.';
                results.add(result);
                continue;
            }
            if (reservation.Status__c == 'Pending Cancellation') {
                result.message = 'This reservation is currently pending cancellation. Please confirm cancellation or request a human agent.';
                results.add(result);
                continue;
            }

            // Save old values
            result.oldDateTime = reservation.Booking_DateTime__c;
            result.oldPartySize = reservation.Party_Size__c;

            Boolean changed = false;
            if (req.newDateTime != null && req.newDateTime != reservation.Booking_DateTime__c) {
                if (req.newDateTime <= System.now()) {
                    result.message = 'New reservation date/time must be in the future.';
                    results.add(result);
                    continue;
                }
                reservation.Booking_DateTime__c = req.newDateTime;
                changed = true;
                result.newDateTime = req.newDateTime;
            }
            if (req.newPartySize != null && req.newPartySize != reservation.Party_Size__c) {
                if (req.newPartySize <= 0) {
                    result.message = 'New party size must be greater than zero.';
                    results.add(result);
                    continue;
                }
                reservation.Party_Size__c = req.newPartySize;
                changed = true;
            }

            if (changed) {
                reservation.Status__c = 'Modified';
                toUpdate.add(reservation);
            } else {
                result.success = true;
                result.message = 'No changes required for reservation.';
            }

            results.add(result);
        }

        // Perform DML once for all changed reservations
        if (!toUpdate.isEmpty()) {
            try {
                Database.SaveResult[] sResults = Database.update(toUpdate, false);
                for (Integer i = 0; i < sResults.size(); i++) {
                    Database.SaveResult sr = sResults[i];
                    Reservation__c updatedRec = toUpdate[i];
                    // Find corresponding result by confirmationCode
                    for (UpdateResult r : results) {
                        if (r.confirmationCode == updatedRec.Name) {
                            if (sr.isSuccess()) {
                                r.success = true;
                                r.message = 'Reservation updated successfully!';
                                r.newDateTime = updatedRec.Booking_DateTime__c;
                            } else {
                                r.success = false;
                                r.message = 'Failed to update: ' + (sr.getErrors().size() > 0 ? sr.getErrors()[0].getMessage() : 'Unknown error');
                            }
                            break;
                        }
                    }
                }
            } catch (Exception e) {
                // If bulk DML failed entirely, mark all toUpdate entries as failed
                for (Reservation__c rec : toUpdate) {
                    for (UpdateResult r : results) {
                        if (r.confirmationCode == rec.Name) {
                            r.success = false;
                            r.message = 'Error updating reservation: ' + e.getMessage();
                        }
                    }
                }
            }
        }

        return results;
    }

    public class UpdateRequest {
        @InvocableVariable(required=true label='Confirmation Code')
        public String confirmationCode;

        @InvocableVariable(label='New Date Time')
        public DateTime newDateTime;

        @InvocableVariable(label='New Party Size')
        public Decimal newPartySize;
    }

    public class UpdateResult {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Confirmation Code')
        public String confirmationCode;

        @InvocableVariable(label='Old Date Time')
        public DateTime oldDateTime;

        @InvocableVariable(label='New Date Time')
        public DateTime newDateTime;

        @InvocableVariable(label='Old Party Size')
        public Decimal oldPartySize;
    }
}