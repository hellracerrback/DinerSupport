/**
 * @description Retrieves restaurant information for a diner (Invocable action for Flows/Agents)
 *
 * Real Restaurant__c fields available:
 *   Accepts_Walkins__c, Address__c, Avg_Rating__c, Cancellation_Window_Hours__c,
 *   Cuisine_Type__c, Dietary_Accommodations__c, Menu_URL__c, Partner_Tier__c,
 *   Phone__c, Price_Range__c, Reservation_Policy__c, Total_Capacity__c
 */
public with sharing class AgentAction_GetRestaurantInfo {

    @InvocableMethod(label='Get Restaurant Info'
                     description='Retrieves detailed information about one or more restaurants'
                     category='Agent Actions')
    public static List<RestaurantInfoResult> getRestaurantInfo(List<RestaurantInfoRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return new List<RestaurantInfoResult>();
        }

        Set<Id> restaurantIds = new Set<Id>();
        for (RestaurantInfoRequest req : requests) {
            if (req.restaurantId != null) {
                restaurantIds.add(req.restaurantId);
            }
        }

        // Query all active restaurants; filter in memory for name searches
        List<Restaurant__c> allRestaurants;
        if (!restaurantIds.isEmpty()) {
            allRestaurants = [
                SELECT Id, Name, Cuisine_Type__c, Address__c, Phone__c,
                       Price_Range__c, Avg_Rating__c, Total_Capacity__c,
                       Accepts_Walkins__c, Dietary_Accommodations__c,
                       Menu_URL__c, Reservation_Policy__c,
                       Cancellation_Window_Hours__c, Partner_Tier__c
                FROM Restaurant__c
                WHERE Id IN :restaurantIds
                LIMIT 50
            ];
        } else {
            allRestaurants = [
                SELECT Id, Name, Cuisine_Type__c, Address__c, Phone__c,
                       Price_Range__c, Avg_Rating__c, Total_Capacity__c,
                       Accepts_Walkins__c, Dietary_Accommodations__c,
                       Menu_URL__c, Reservation_Policy__c,
                       Cancellation_Window_Hours__c, Partner_Tier__c
                FROM Restaurant__c
                ORDER BY Name ASC
                LIMIT 200
            ];
        }

        List<RestaurantInfoResult> results = new List<RestaurantInfoResult>();

        for (RestaurantInfoRequest req : requests) {
            RestaurantInfoResult res = new RestaurantInfoResult();
            res.success = false;
            res.restaurants = new List<String>();
            res.count = 0;

            List<Restaurant__c> matched = new List<Restaurant__c>();
            for (Restaurant__c r : allRestaurants) {
                if (req.restaurantId != null && r.Id == req.restaurantId) {
                    matched.add(r);
                } else if (!String.isBlank(req.searchTerm)) {
                    String searchTerm = req.searchTerm.trim().toLowerCase();
                    // Build a searchable string from ALL text fields
                    List<String> searchFields = new List<String>();
                    if (r.Name != null) searchFields.add(r.Name.toLowerCase());
                    if (r.Address__c != null) searchFields.add(r.Address__c.toLowerCase());
                    if (r.Cuisine_Type__c != null) searchFields.add(r.Cuisine_Type__c.toLowerCase());
                    if (r.Price_Range__c != null) searchFields.add(r.Price_Range__c.toLowerCase());
                    if (r.Phone__c != null) searchFields.add(r.Phone__c.toLowerCase());
                    if (r.Dietary_Accommodations__c != null) searchFields.add(r.Dietary_Accommodations__c.toLowerCase());
                    if (r.Reservation_Policy__c != null) searchFields.add(r.Reservation_Policy__c.toLowerCase());
                    if (r.Partner_Tier__c != null) searchFields.add(r.Partner_Tier__c.toLowerCase());
                    String allText = String.join(searchFields, ' ');
                    if (allText.contains(searchTerm)) {
                        matched.add(r);
                    }
                } else if (req.restaurantId == null && String.isBlank(req.searchTerm)) {
                    matched.add(r);
                }
            }

            if (matched.isEmpty()) {
                res.success = true;
                res.message = 'No restaurants found' +
                    (!String.isBlank(req.searchTerm) ? ' matching "' + req.searchTerm + '"' : '') + '.';
            } else {
                res.count = matched.size();
                res.success = true;
                List<String> summaries = new List<String>();
                for (Restaurant__c r : matched) {
                    summaries.add(buildSummary(r));
                }
                res.restaurants = summaries;
                res.message = 'Found ' + res.count + ' restaurant(s).';
                if (matched.size() == 1) {
                    Restaurant__c f = matched[0];
                    res.restaurantId       = f.Id;
                    res.restaurantName     = f.Name;
                    res.cuisineType        = f.Cuisine_Type__c;
                    res.address            = f.Address__c;
                    res.phone              = f.Phone__c;
                    res.priceRange         = f.Price_Range__c;
                    res.avgRating          = f.Avg_Rating__c;
                    res.totalCapacity      = f.Total_Capacity__c;
                    res.acceptsWalkins     = f.Accepts_Walkins__c;
                    res.dietaryAccommodations = f.Dietary_Accommodations__c;
                    res.menuUrl            = f.Menu_URL__c;
                    res.reservationPolicy  = f.Reservation_Policy__c;
                    res.cancellationWindowHours = f.Cancellation_Window_Hours__c;
                    res.partnerTier        = f.Partner_Tier__c;
                }
            }
            results.add(res);
        }
        return results;
    }

    private static String buildSummary(Restaurant__c r) {
        List<String> parts = new List<String>();
        parts.add('Name: ' + r.Name);
        if (!String.isBlank(r.Cuisine_Type__c))         parts.add('Cuisine: ' + r.Cuisine_Type__c);
        if (!String.isBlank(r.Price_Range__c))           parts.add('Price: ' + r.Price_Range__c);
        if (r.Avg_Rating__c != null)                     parts.add('Rating: ' + r.Avg_Rating__c + '/5');
        if (!String.isBlank(r.Phone__c))                 parts.add('Phone: ' + r.Phone__c);
        if (!String.isBlank(r.Address__c))               parts.add('Address: ' + r.Address__c);
        if (!String.isBlank(r.Dietary_Accommodations__c)) parts.add('Dietary: ' + r.Dietary_Accommodations__c);
        if (!String.isBlank(r.Menu_URL__c))              parts.add('Menu: ' + r.Menu_URL__c);
        if (!String.isBlank(r.Reservation_Policy__c))    parts.add('Reservation Policy: ' + r.Reservation_Policy__c);
        if (r.Accepts_Walkins__c != null)
            parts.add('Walk-ins: ' + (r.Accepts_Walkins__c == true ? 'Yes' : 'No'));
        if (r.Total_Capacity__c != null)
            parts.add('Capacity: ' + String.valueOf(r.Total_Capacity__c));
        return String.join(parts, ' | ');
    }

    public class RestaurantInfoRequest {
        @InvocableVariable(label='Restaurant Id')
        public Id restaurantId;

        @InvocableVariable(label='Search Term')
        public String searchTerm;
    }

    public class RestaurantInfoResult {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Count')
        public Integer count;

        @InvocableVariable(label='Restaurants (formatted summaries)')
        public List<String> restaurants;

        @InvocableVariable(label='Restaurant Id')
        public Id restaurantId;

        @InvocableVariable(label='Restaurant Name')
        public String restaurantName;

        @InvocableVariable(label='Cuisine Type')
        public String cuisineType;

        @InvocableVariable(label='Address')
        public String address;

        @InvocableVariable(label='Phone')
        public String phone;

        @InvocableVariable(label='Price Range')
        public String priceRange;

        @InvocableVariable(label='Average Rating')
        public Decimal avgRating;

        @InvocableVariable(label='Total Capacity')
        public Decimal totalCapacity;

        @InvocableVariable(label='Accepts Walk-ins')
        public Boolean acceptsWalkins;

        @InvocableVariable(label='Dietary Accommodations')
        public String dietaryAccommodations;

        @InvocableVariable(label='Menu URL')
        public String menuUrl;

        @InvocableVariable(label='Reservation Policy')
        public String reservationPolicy;

        @InvocableVariable(label='Cancellation Window Hours')
        public Decimal cancellationWindowHours;

        @InvocableVariable(label='Partner Tier')
        public String partnerTier;
    }
}
