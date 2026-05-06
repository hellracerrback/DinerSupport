/**
 * @description Creates a new reservation for a diner (Invocable action for Flows/Agents)
 */
public with sharing class AgentAction_CreateReservation {

    /**
     * Invocable entry point to create reservations in bulk.
     *
     * @param requests List of CreateRequest inputs
     * @return List of CreateResult responses (one per input)
     */
    @InvocableMethod(label='Create Reservation'
                     description='Creates a new restaurant reservation for a diner'
                     category='Agent Actions')
    public static List<CreateResult> createReservation(List<CreateRequest> requests) {
        List<CreateResult> results = new List<CreateResult>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        // Collect emails and restaurant names for bulk queries
        Set<String> emails = new Set<String>();
        Set<String> restaurantNames = new Set<String>();
        Set<Id> restaurantIds = new Set<Id>();

        for (CreateRequest req : requests) {
            if (!String.isBlank(req.userEmail)) {
                emails.add(req.userEmail.trim().toLowerCase());
            }
            if (!String.isBlank(req.restaurantName)) {
                restaurantNames.add(req.restaurantName.trim());
            }
            if (req.restaurantId != null) {
                restaurantIds.add(req.restaurantId);
            }
        }

        // Bulk query: Diner__c by email (via Contact__r.Email or Diner__c.Email__c)
        Map<String, Diner__c> dinerByEmail = new Map<String, Diner__c>();
        if (!emails.isEmpty()) {
            for (Diner__c d : [
                SELECT Id, Name, Contact__r.Email, Email__c
                FROM Diner__c
                WHERE Contact__r.Email IN :emails OR Email__c IN :emails
                LIMIT 200
            ]) {
                if (d.Contact__r != null && !String.isBlank(d.Contact__r.Email)) {
                    dinerByEmail.put(d.Contact__r.Email.trim().toLowerCase(), d);
                }
                if (!String.isBlank(d.Email__c)) {
                    dinerByEmail.put(d.Email__c.trim().toLowerCase(), d);
                }
            }
        }

        // Bulk query: Restaurant__c by Id (exact) or by name/address (fuzzy)
        Map<Id, Restaurant__c> restaurantById = new Map<Id, Restaurant__c>();
        List<Restaurant__c> allRestaurants = new List<Restaurant__c>();
        if (!restaurantIds.isEmpty()) {
            for (Restaurant__c r : [
                SELECT Id, Name, Total_Capacity__c, Address__c, City_Test__c, Cuisine_Type__c
                FROM Restaurant__c
                WHERE Id IN :restaurantIds
                LIMIT 200
            ]) {
                restaurantById.put(r.Id, r);
            }
        }
        if (!restaurantNames.isEmpty()) {
            // Query all restaurants once; we'll do fuzzy matching in memory
            allRestaurants = [
                SELECT Id, Name, Total_Capacity__c, Address__c, City_Test__c, Cuisine_Type__c
                FROM Restaurant__c
                ORDER BY Name ASC
                LIMIT 200
            ];
        }

        List<Reservation__c> toInsert = new List<Reservation__c>();
        // Track which result index corresponds to which reservation-to-insert index
        Map<Integer, Integer> resultIndexToInsertIndex = new Map<Integer, Integer>();

        for (Integer i = 0; i < requests.size(); i++) {
            CreateRequest req = requests[i];
            CreateResult result = new CreateResult();
            result.success = false;
            result.message = '';

            // Validate required fields
            if (String.isBlank(req.userEmail)) {
                result.message = 'Missing userEmail.';
                results.add(result);
                continue;
            }
            if (req.requestedDateTime == null) {
                result.message = 'Missing requestedDateTime.';
                results.add(result);
                continue;
            }
            if (req.partySize == null || req.partySize <= 0) {
                result.message = 'Missing or invalid partySize.';
                results.add(result);
                continue;
            }
            if (req.partySize > 20) {
                result.message = 'For parties above 20, I will escalate this to a human concierge for special handling.';
                results.add(result);
                continue;
            }

            // Validate date is in the future
            if (req.requestedDateTime <= System.now()) {
                result.message = 'Requested date/time must be in the future.';
                results.add(result);
                continue;
            }

            // Resolve Diner
            String emailKey = req.userEmail.trim().toLowerCase();
            if (!dinerByEmail.containsKey(emailKey)) {
                result.message = 'No Diner record found for email: ' + req.userEmail + '. Please ensure a Diner account exists.';
                results.add(result);
                continue;
            }
            Diner__c diner = dinerByEmail.get(emailKey);

            // Resolve Restaurant
            Restaurant__c restaurant = null;
            if (req.restaurantId != null && restaurantById.containsKey(req.restaurantId)) {
                restaurant = restaurantById.get(req.restaurantId);
            } else if (!String.isBlank(req.restaurantName)) {
                String searchTerm = req.restaurantName.trim().toLowerCase();
                // Fuzzy match: check Name and Address__c with substring matching
                Restaurant__c bestMatch = null;
                for (Restaurant__c r : allRestaurants) {
                    String rName = r.Name != null ? r.Name.toLowerCase() : '';
                    String rAddr = r.Address__c != null ? r.Address__c.toLowerCase() : '';
                    String rCity = r.City_Test__c != null ? r.City_Test__c.toLowerCase() : '';
                    // Exact name match is strongest
                    if (rName == searchTerm) {
                        bestMatch = r;
                        break;
                    }
                    // Substring match on name or address
                    if (bestMatch == null && (rName.contains(searchTerm) || searchTerm.contains(rName) || rAddr.contains(searchTerm) || rCity.contains(searchTerm))) {
                        bestMatch = r;
                    }
                }
                restaurant = bestMatch;
            }

            if (restaurant == null) {
                result.message = 'Restaurant not found. Please share city and cuisine and I can suggest alternatives.';
                results.add(result);
                continue;
            }

            // Validate party size against capacity
            if (restaurant.Total_Capacity__c != null && req.partySize > restaurant.Total_Capacity__c) {
                result.message = 'Party size of ' + String.valueOf(req.partySize.intValue()) +
                    ' exceeds ' + restaurant.Name + '\'s capacity of ' +
                    String.valueOf(restaurant.Total_Capacity__c.intValue()) + '.';
                results.add(result);
                continue;
            }

            // Build the reservation record
            Reservation__c newRes = new Reservation__c();
            newRes.Diner__c = diner.Id;
            newRes.Restaurant__c = restaurant.Id;
            newRes.Booking_DateTime__c = req.requestedDateTime;
            newRes.Party_Size__c = req.partySize;
            newRes.Status__c = 'Confirmed';
            if (!String.isBlank(req.specialRequests)) {
                newRes.Special_Requests__c = req.specialRequests;
            }

            resultIndexToInsertIndex.put(results.size(), toInsert.size());
            toInsert.add(newRes);
            result.restaurantName = restaurant.Name;
            results.add(result);
        }

        // Bulk DML insert
        if (!toInsert.isEmpty()) {
            Database.SaveResult[] sResults = Database.insert(toInsert, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!resultIndexToInsertIndex.containsKey(i)) {
                    continue;
                }
                Integer insertIdx = resultIndexToInsertIndex.get(i);
                Database.SaveResult sr = sResults[insertIdx];
                if (sr.isSuccess()) {
                    results[i].success = true;
                    results[i].reservationId = sr.getId();
                    // Re-query to get the auto-generated Name (confirmation code)
                    results[i].message = 'Reservation created successfully at ' + results[i].restaurantName + '!';
                } else {
                    results[i].success = false;
                    results[i].message = 'Failed to create reservation: ' +
                        (sr.getErrors().size() > 0 ? sr.getErrors()[0].getMessage() : 'Unknown error');
                }
            }

            // Re-query to populate confirmation codes (auto-number Name field)
            if (!toInsert.isEmpty()) {
                Set<Id> insertedIds = new Set<Id>();
                for (Integer i = 0; i < results.size(); i++) {
                    if (results[i].success && results[i].reservationId != null) {
                        insertedIds.add(results[i].reservationId);
                    }
                }
                if (!insertedIds.isEmpty()) {
                    Map<Id, Reservation__c> insertedMap = new Map<Id, Reservation__c>(
                        [SELECT Id, Name FROM Reservation__c WHERE Id IN :insertedIds]
                    );
                    for (CreateResult r : results) {
                        if (r.success && r.reservationId != null && insertedMap.containsKey(r.reservationId)) {
                            r.confirmationCode = insertedMap.get(r.reservationId).Name;
                            r.message = 'Reservation confirmed! Your confirmation code is: ' +
                                r.confirmationCode + '. Restaurant: ' + r.restaurantName + '.';
                        }
                    }
                }
            }
        }

        return results;
    }

    public class CreateRequest {
        @InvocableVariable(required=true label='User Email')
        public String userEmail;

        @InvocableVariable(required=true label='Requested Date Time')
        public DateTime requestedDateTime;

        @InvocableVariable(required=true label='Party Size')
        public Decimal partySize;

        @InvocableVariable(label='Restaurant Id')
        public Id restaurantId;

        @InvocableVariable(label='Restaurant Name')
        public String restaurantName;

        @InvocableVariable(label='Special Requests')
        public String specialRequests;
    }

    public class CreateResult {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Reservation Id')
        public Id reservationId;

        @InvocableVariable(label='Confirmation Code')
        public String confirmationCode;

        @InvocableVariable(label='Restaurant Name')
        public String restaurantName;
    }
}
