public with sharing class BedrockRequestPriorityService {

    public class PriorityRequest {
        @InvocableVariable(
            required=true
            label='Priority'
            description='Priority of the Bedrock request'
        )
        public String priority;
    }

    public class PriorityResponse {
        @InvocableVariable(
            label='Requires Review'
            description='Indicates whether the request requires review'
        )
        public Boolean requiresReview;
    }

    @InvocableMethod(
        label='Evaluate Bedrock Request Priority'
        description='Determines whether a Bedrock request requires review based on priority'
    )
    public static List<PriorityResponse> evaluatePriority(
        List<PriorityRequest> requests
    ) {
        List<PriorityResponse> responses = new List<PriorityResponse>();

        for (PriorityRequest request : requests) {

            PriorityResponse response = new PriorityResponse();

            response.requiresReview =
                request.priority == 'High' ||
                request.priority == 'Critical';

            responses.add(response);
        }

        return responses;
    }
}