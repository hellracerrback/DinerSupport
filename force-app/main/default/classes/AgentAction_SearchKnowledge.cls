/**
 * @description Action to search the Knowledge Base for restaurant policies and info
 */
public with sharing class AgentAction_SearchKnowledge {

    @InvocableMethod(label='Search Knowledge Base'
                     description='Searches the knowledge base for policies, procedures, and restaurant information.'
                     category='Agent Actions')
    public static List<SearchResult> searchKnowledge(List<SearchRequest> requests) {
        List<SearchResult> results = new List<SearchResult>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        for (SearchRequest req : requests) {
            SearchResult result = new SearchResult();
            result.articles = new List<String>();
            
            if (String.isBlank(req.query)) {
                results.add(result);
                continue;
            }

            // Perform SOSL search
            String soslQuery = 'FIND \'' + String.escapeSingleQuotes(req.query) + '*\' IN ALL FIELDS RETURNING Knowledge__kav(Title, Summary, Body__c WHERE PublishStatus = \'Online\' AND IsLatestVersion = true LIMIT 3)';
            List<List<SObject>> searchResults = Search.query(soslQuery);
            
            List<Knowledge__kav> articles = (List<Knowledge__kav>)searchResults[0];
            
            if (articles.isEmpty()) {
                result.message = 'No relevant articles found for: ' + req.query;
            } else {
                result.message = 'Found ' + articles.size() + ' relevant articles:';
                for (Knowledge__kav art : articles) {
                    String summary = String.isNotBlank(art.Summary) ? art.Summary : '';
                    result.articles.add('TITLE: ' + art.Title + '\nSUMMARY: ' + summary + '\nCONTENT: ' + art.Body__c);
                }
            }
            results.add(result);
        }

        return results;
    }

    public class SearchRequest {
        @InvocableVariable(required=true label='Search Query' description='The keywords or question to search for in the knowledge base')
        public String query;
    }

    public class SearchResult {
        @InvocableVariable(label='Articles' description='The list of formatted articles found')
        public List<String> articles;

        @InvocableVariable(label='Message' description='Status message or summary of results')
        public String message;
    }
}