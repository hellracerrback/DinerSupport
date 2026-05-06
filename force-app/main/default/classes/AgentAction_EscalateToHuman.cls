/**
 * @description Escalates to a human agent by creating a Case (Invocable action for Flows/Agents)
 */
public with sharing class AgentAction_EscalateToHuman {

    @InvocableMethod(label='Escalate to Human Agent'
                     description='Creates a support case and escalates the conversation to a human agent'
                     category='Agent Actions')
    public static List<EscalateResult> escalateToHuman(List<EscalateRequest> requests) {
        List<EscalateResult> results = new List<EscalateResult>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        // Collect emails to resolve Contact links
        Set<String> emails = new Set<String>();
        for (EscalateRequest req : requests) {
            if (!String.isBlank(req.userEmail)) {
                emails.add(req.userEmail.trim().toLowerCase());
            }
        }

        // Try to find Contact by email for case linking
        Map<String, Id> contactIdByEmail = new Map<String, Id>();
        if (!emails.isEmpty()) {
            for (Contact c : [
                SELECT Id, Email
                FROM Contact
                WHERE Email IN :emails
                LIMIT 200
            ]) {
                if (c.Email != null) {
                    contactIdByEmail.put(c.Email.trim().toLowerCase(), c.Id);
                }
            }
        }

        List<Case> casesToInsert = new List<Case>();
        Map<Integer, Integer> resultIdxToCaseIdx = new Map<Integer, Integer>();

        for (Integer i = 0; i < requests.size(); i++) {
            EscalateRequest req = requests[i];
            EscalateResult result = new EscalateResult();
            result.success = false;

            if (String.isBlank(req.userEmail)) {
                result.message = 'Missing userEmail.';
                results.add(result);
                continue;
            }

            Case newCase = new Case();
            newCase.Status = 'New';
            newCase.Priority = 'High';
            newCase.Origin = 'Chat';

            // Set subject
            if (!String.isBlank(req.subject)) {
                newCase.Subject = req.subject;
            } else {
                newCase.Subject = 'Diner Support Escalation – ' + req.userEmail;
            }

            // Build description from conversation summary
            String caseDescription = '';
            if (!String.isBlank(req.conversationSummary)) {
                caseDescription += 'Conversation Summary:\n' + req.conversationSummary + '\n\n';
            }
            if (!String.isBlank(req.issueType)) {
                caseDescription += 'Issue Type: ' + req.issueType + '\n';
                newCase.Type = req.issueType;
            }
            caseDescription += 'Customer Email: ' + req.userEmail;
            newCase.Description = caseDescription;

            // Link contact if found
            String emailKey = req.userEmail.trim().toLowerCase();
            if (contactIdByEmail.containsKey(emailKey)) {
                newCase.ContactId = contactIdByEmail.get(emailKey);
            }

            resultIdxToCaseIdx.put(results.size(), casesToInsert.size());
            casesToInsert.add(newCase);
            results.add(result);
        }

        // Bulk DML
        if (!casesToInsert.isEmpty()) {
            Database.SaveResult[] sResults = Database.insert(casesToInsert, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!resultIdxToCaseIdx.containsKey(i)) continue;
                Integer caseIdx = resultIdxToCaseIdx.get(i);
                Database.SaveResult sr = sResults[caseIdx];
                if (sr.isSuccess()) {
                    results[i].success = true;
                    results[i].caseId = sr.getId();
                } else {
                    results[i].success = false;
                    results[i].message = 'Failed to create case: ' +
                        (sr.getErrors().size() > 0 ? sr.getErrors()[0].getMessage() : 'Unknown error');
                }
            }

            // Re-query to get auto-generated CaseNumber
            Set<Id> insertedCaseIds = new Set<Id>();
            for (EscalateResult r : results) {
                if (r.success && r.caseId != null) {
                    insertedCaseIds.add(r.caseId);
                }
            }
            if (!insertedCaseIds.isEmpty()) {
                Map<Id, Case> caseMap = new Map<Id, Case>(
                    [SELECT Id, CaseNumber FROM Case WHERE Id IN :insertedCaseIds]
                );
                for (EscalateResult r : results) {
                    if (r.success && r.caseId != null && caseMap.containsKey(r.caseId)) {
                        r.caseNumber = caseMap.get(r.caseId).CaseNumber;
                        r.message = 'You have been successfully escalated to a human agent. '
                            + 'Your case number is: ' + r.caseNumber + '. '
                            + 'An agent will reach out to you shortly. '
                            + 'Thank you for your patience.';
                    }
                }
            }
        }

        return results;
    }

    public class EscalateRequest {
        @InvocableVariable(required=true label='User Email')
        public String userEmail;

        @InvocableVariable(label='Subject')
        public String subject;

        @InvocableVariable(label='Conversation Summary')
        public String conversationSummary;

        @InvocableVariable(label='Issue Type')
        public String issueType;
    }

    public class EscalateResult {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Case Id')
        public Id caseId;

        @InvocableVariable(label='Case Number')
        public String caseNumber;
    }
}
