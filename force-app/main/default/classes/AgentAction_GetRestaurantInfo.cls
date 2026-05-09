/**
 * @description Simplified restaurant information retrieval for Agentforce.
 * Returns complete restaurant records based on city or cuisine.
 */
public with sharing class AgentAction_GetRestaurantInfo {

    @InvocableMethod(label='Get Restaurant Info' 
                     description='Finds restaurants by city or cuisine and returns full record details.'
                     category='Agent Actions')
    public static List<RestaurantInfoResult> getRestaurants(List<RestaurantInfoRequest> requests) {
        List<RestaurantInfoResult> results = new List<RestaurantInfoResult>();
        
        for (RestaurantInfoRequest req : requests) {
            RestaurantInfoResult res = new RestaurantInfoResult();
            
            // Prepare inputs
            String city = req.city;

            // Build dynamic query to handle optional filters
            String query = 'SELECT Id, Name, Cuisine_Type__c, City__c, Address__c, Phone__c, ' +
                           'Price_Range__c, Avg_Rating__c, Total_Capacity__c, ' +
                           'Accepts_Walkins__c, Dietary_Accommodations__c, ' +
                           'Menu_URL__c, Reservation_Policy__c, ' +
                           'Cancellation_Window_Hours__c, Partner_Tier__c ' +
                           'FROM Restaurant__c';
            
            List<String> filters = new List<String>();
            if (String.isNotBlank(city)) {
                filters.add('City__c = :city');
            }
            
            if (!filters.isEmpty()) {
                query += ' WHERE ' + String.join(filters, ' AND ');
            }
            
            query += ' ORDER BY Avg_Rating__c DESC LIMIT 50';

            // Execute query with bind variables
            res.restaurants = Database.query(query);
            
            results.add(res);
        }
        return results;
    }

    /**
     * @description Input parameters for the restaurant search
     */
    public class RestaurantInfoRequest {
        @InvocableVariable(label='City' description='Filter by city name' required=true)
        public String city;
    }

    /**
     * @description Output result containing the list of matching restaurant records
     */
    public class RestaurantInfoResult {
        @InvocableVariable(label='Restaurants' description='List of matching restaurant records with all fields')
        public List<Restaurant__c> restaurants;
    }
}