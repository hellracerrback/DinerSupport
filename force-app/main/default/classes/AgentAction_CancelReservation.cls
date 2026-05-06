/**
 * @description Two-step cancellation flow: move to pending, then cancel on confirmation.
 */
public with sharing class AgentAction_CancelReservation {

    /**
     * Invocable entry point to cancel reservations in bulk.
     *
     * @param requests List of CancelRequest inputs
     * @return List of CancelResult responses (one per input)
     */
    @InvocableMethod(label='Cancel Reservation'
                     description='Creates pending cancellation requests and finalizes cancellations after confirmation'
                     category='Agent Actions')
    public static List<CancelResult> cancelReservation(List<CancelRequest> requests) {
        List<CancelResult> results = new List<CancelResult>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        // Collect confirmation codes
        Set<String> confirmationCodes = new Set<String>();
        for (CancelRequest r : requests) {
            if (!String.isBlank(r.confirmationCode)) {
                confirmationCodes.add(r.confirmationCode.trim());
            }
        }

        Map<String, Reservation__c> reservationByName = new Map<String, Reservation__c>();
        if (!confirmationCodes.isEmpty()) {
            for (Reservation__c res : [
                SELECT Id, Name, Booking_DateTime__c, Party_Size__c, Status__c, Cancellation_Fee__c, Refund_Amount__c
                FROM Reservation__c
                WHERE Name IN :confirmationCodes
                LIMIT 200
            ]) {
                reservationByName.put(res.Name, res);
            }
        }

        List<Reservation__c> toUpdate = new List<Reservation__c>();

        for (CancelRequest req : requests) {
            CancelResult result = new CancelResult();
            result.success = false;
            result.confirmationCode = req.confirmationCode;
            result.cancellationFee = '0';
            result.refundAmount = '0';
            result.message = '';

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

            if (reservation.Status__c == 'Cancelled') {
                result.success = true;
                result.message = 'Reservation is already cancelled.';
                results.add(result);
                continue;
            }

            if (req.confirmCancellation == true && reservation.Status__c != 'Pending Cancellation') {
                result.message = 'Please submit a cancellation reason first. I will place this in Pending Cancellation before final confirmation.';
                results.add(result);
                continue;
            }

            if (req.confirmCancellation != true) {
                if (String.isBlank(req.cancellationReason)) {
                    result.message = 'Please provide a cancellation reason before proceeding.';
                    results.add(result);
                    continue;
                }

                reservation.Status__c = 'Pending Cancellation';
                toUpdate.add(reservation);
                result.success = true;
                result.message = 'Cancellation request recorded as Pending Cancellation for reason: ' +
                    req.cancellationReason + '. Please confirm to finalize.';
                results.add(result);
                continue;
            }

            // Calculate hours until booking
            Decimal hoursUntil = 0;
            try {
                hoursUntil = (reservation.Booking_DateTime__c.getTime() - System.now().getTime()) / (1000 * 60 * 60);
            } catch (Exception e) {
                // If booking date is null or invalid
                hoursUntil = -1;
            }

            Decimal cancellationFee = 0;
            Decimal refundAmount = 0;

            if (hoursUntil >= 0 && hoursUntil < 24 && hoursUntil >= 2) {
                cancellationFee = 25;
                refundAmount = 0;
            } else if (hoursUntil >= 0 && hoursUntil < 2) {
                cancellationFee = 50;
                refundAmount = 0;
            } else {
                cancellationFee = 0;
                refundAmount = 0;
            }

            reservation.Status__c = 'Cancelled';
            reservation.Cancellation_Fee__c = cancellationFee;
            reservation.Refund_Amount__c = refundAmount;
            toUpdate.add(reservation);

            result.success = true;
            result.cancellationFee = String.valueOf(cancellationFee);
            result.refundAmount = String.valueOf(refundAmount);
            result.message = 'Reservation cancelled. ';
            if (cancellationFee > 0) {
                result.message += 'Cancellation fee: $' + String.valueOf(cancellationFee) + '. ';
            } else {
                result.message += 'No cancellation fee. ';
            }
            if (refundAmount > 0) {
                result.message += 'Refund of $' + String.valueOf(refundAmount) + ' will be processed in 3-5 business days.';
            }

            results.add(result);
        }

        if (!toUpdate.isEmpty()) {
            try {
                Database.SaveResult[] sResults = Database.update(toUpdate, false);
                for (Integer i = 0; i < sResults.size(); i++) {
                    Database.SaveResult sr = sResults[i];
                    Reservation__c updatedRec = toUpdate[i];
                    for (CancelResult r : results) {
                        if (r.confirmationCode == updatedRec.Name) {
                            if (!sr.isSuccess()) {
                                r.success = false;
                                r.message = 'Failed to cancel: ' + (sr.getErrors().size() > 0 ? sr.getErrors()[0].getMessage() : 'Unknown error');
                            }
                            break;
                        }
                    }
                }
            } catch (Exception e) {
                for (Reservation__c rec : toUpdate) {
                    for (CancelResult r : results) {
                        if (r.confirmationCode == rec.Name) {
                            r.success = false;
                            r.message = 'Error cancelling reservation: ' + e.getMessage();
                        }
                    }
                }
            }
        }

        return results;
    }

    public class CancelRequest {
        @InvocableVariable(required=true label='Confirmation Code')
        public String confirmationCode;

        @InvocableVariable(label='Cancellation Reason')
        public String cancellationReason;

        @InvocableVariable(label='Confirm Cancellation')
        public Boolean confirmCancellation;
    }

    public class CancelResult {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Confirmation Code')
        public String confirmationCode;

        @InvocableVariable(label='Cancellation Fee')
        public String cancellationFee;

        @InvocableVariable(label='Refund Amount')
        public String refundAmount;
    }
}