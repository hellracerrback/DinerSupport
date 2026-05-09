global without sharing class AgentAction_CreateReservation {

    global class CreateRequest {
        @InvocableVariable(label='User Email')
        global String userEmail;
        @InvocableVariable(label='Requested Date Time')
        global String requestedDateTime;
        @InvocableVariable(label='Party Size')
        global String partySize;
        @InvocableVariable(label='Restaurant Name')
        global String restaurantName;
    }

    global class CreateResult {
        @InvocableVariable(label='Success')
        global Boolean success;
        @InvocableVariable(label='Message')
        global String message;
        @InvocableVariable(label='Confirmation Code')
        global String confirmationCode;
    }

    @InvocableMethod(label='Create Reservation' description='Creates a restaurant reservation.')
    global static List<CreateResult> createReservation(List<CreateRequest> requests) {
        List<CreateResult> results = new List<CreateResult>();
        
        try {
            // Lookups
            Set<String> emails = new Set<String>();
            Set<String> names = new Set<String>();
            for (CreateRequest req : requests) {
                if (req.userEmail != null) emails.add(req.userEmail.trim().toLowerCase());
                if (req.restaurantName != null) names.add(req.restaurantName.trim());
            }

            Map<String, Id> dinerMap = new Map<String, Id>();
            for (Diner__c d : [SELECT Id, Email__c FROM Diner__c WHERE Email__c IN :emails]) {
                dinerMap.put(d.Email__c.toLowerCase(), d.Id);
            }
            
            Map<String, Id> restMap = new Map<String, Id>();
            for (Restaurant__c r : [SELECT Id, Name FROM Restaurant__c WHERE Name IN :names]) {
                restMap.put(r.Name.toLowerCase(), r.Id);
            }

            List<Reservation__c> toInsert = new List<Reservation__c>();
            List<Integer> insertMap = new List<Integer>();

            for (Integer i = 0; i < requests.size(); i++) {
                CreateRequest req = requests[i];
                CreateResult res = new CreateResult();
                res.success = false;
                
                String email = (req.userEmail != null) ? req.userEmail.trim().toLowerCase() : '';
                String rName = (req.restaurantName != null) ? req.restaurantName.trim().toLowerCase() : '';
                
                if (!dinerMap.containsKey(email)) {
                    Diner__c newDiner = new Diner__c(Email__c = email);
                    insert newDiner;
                    dinerMap.put(email, newDiner.Id);
                }
                
                if (!restMap.containsKey(rName)) {
                    res.message = 'Error: Restaurant ' + req.restaurantName + ' not found.';
                    results.add(res);
                    continue;
                }

                DateTime dt = DateTime.now().addDays(7); // Default if parsing fails
                try {
                    String clean = req.requestedDateTime.replace('T', ' ').replace('Z', '');
                    dt = DateTime.valueOfGmt(clean);
                } catch (Exception e) {}

                Reservation__c reservation = new Reservation__c();
                reservation.Diner__c = dinerMap.get(email);
                reservation.Restaurant__c = restMap.get(rName);
                reservation.Booking_DateTime__c = dt;
                String sizeStr = (req.partySize != null) ? req.partySize.replaceAll('[^0-9]', '') : '';
                reservation.Party_Size__c = (sizeStr != '') ? Decimal.valueOf(sizeStr) : 2;
                reservation.Status__c = 'Confirmed';
                
                toInsert.add(reservation);
                insertMap.add(results.size());
                results.add(res);
            }

            if (!toInsert.isEmpty()) {
                insert toInsert;
                for (Integer j = 0; j < toInsert.size(); j++) {
                    CreateResult r = results[insertMap[j]];
                    r.success = true;
                    r.confirmationCode = 'GLOBAL-' + String.valueOf(toInsert[j].Id).right(6).toUpperCase();
                    r.message = 'Reservation confirmed successfully.';
                }
            }
        } catch (Exception e) {
            CreateResult err = new CreateResult();
            err.success = false;
            err.message = 'Global Error: ' + e.getMessage();
            if (results.isEmpty()) results.add(err);
            else results[0] = err;
        }

        return results;
    }
}
