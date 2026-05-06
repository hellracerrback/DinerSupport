@IsTest
public class AgentAction_SearchKnowledgeTest {
    @IsTest
    static void testSearch() {
        // We can't easily create Knowledge articles in a test without more setup (need to publish)
        // So we just test the entry point
        AgentAction_SearchKnowledge.SearchRequest req = new AgentAction_SearchKnowledge.SearchRequest();
        req.query = 'test';
        
        Test.startTest();
        List<AgentAction_SearchKnowledge.SearchResult> results = AgentAction_SearchKnowledge.searchKnowledge(new List<AgentAction_SearchKnowledge.SearchRequest>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
    }
}
