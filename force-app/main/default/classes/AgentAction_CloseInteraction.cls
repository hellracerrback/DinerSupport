/**
 * @description Logs interaction details at the end of a conversation.
 */
public with sharing class AgentAction_CloseInteraction {

    @InvocableMethod(label='Close Interaction'
                     description='Writes conversation closure details to Agent Interaction'
                     category='Agent Actions')
    public static List<CloseInteractionResult> closeInteraction(List<CloseInteractionRequest> requests) {
        List<CloseInteractionResult> results = new List<CloseInteractionResult>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        List<Agent_Interaction__c> toInsert = new List<Agent_Interaction__c>();
        Map<Integer, Integer> resultToInsert = new Map<Integer, Integer>();

        for (CloseInteractionRequest req : requests) {
            CloseInteractionResult res = new CloseInteractionResult();
            res.success = false;

            if (String.isBlank(req.conversationId)) {
                res.message = 'Missing conversationId.';
                results.add(res);
                continue;
            }

            Agent_Interaction__c rec = new Agent_Interaction__c();
            rec.Conversation_ID__c = req.conversationId;
            rec.Start_DateTime__c = req.startDateTime != null ? req.startDateTime : System.now();
            rec.End_DateTime__c = req.endDateTime != null ? req.endDateTime : System.now();
            rec.Transcript__c = req.transcript;
            rec.Topics_Discussed__c = req.topicsDiscussed;
            rec.Resolution_Type__c = req.resolutionType;
            rec.Sentiment_Score__c = req.sentimentScore;
            rec.Reservation__c = req.reservationId;

            resultToInsert.put(results.size(), toInsert.size());
            toInsert.add(rec);
            results.add(res);
        }

        if (!toInsert.isEmpty()) {
            Database.SaveResult[] dmlResults = Database.insert(toInsert, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!resultToInsert.containsKey(i)) {
                    continue;
                }
                Database.SaveResult sr = dmlResults[resultToInsert.get(i)];
                if (sr.isSuccess()) {
                    results[i].success = true;
                    results[i].interactionId = sr.getId();
                    results[i].message = 'Interaction logged successfully.';
                } else {
                    results[i].message = 'Failed to log interaction: ' +
                        (sr.getErrors().isEmpty() ? 'Unknown error' : sr.getErrors()[0].getMessage());
                }
            }
        }

        return results;
    }

    public class CloseInteractionRequest {
        @InvocableVariable(required=true label='Conversation Id')
        public String conversationId;

        @InvocableVariable(label='Start Date Time')
        public Datetime startDateTime;

        @InvocableVariable(label='End Date Time')
        public Datetime endDateTime;

        @InvocableVariable(label='Transcript')
        public String transcript;

        @InvocableVariable(label='Topics Discussed')
        public String topicsDiscussed;

        @InvocableVariable(label='Resolution Type')
        public String resolutionType;

        @InvocableVariable(label='Sentiment Score')
        public Decimal sentimentScore;

        @InvocableVariable(label='Reservation Id')
        public Id reservationId;
    }

    public class CloseInteractionResult {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Interaction Id')
        public Id interactionId;
    }
}