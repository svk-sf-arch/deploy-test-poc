@IsTest
private class BedrockRequestPriorityServiceTest {

    @IsTest
    static void testHighPriorityRequiresReview() {

        BedrockRequestPriorityService.PriorityRequest request =
            new BedrockRequestPriorityService.PriorityRequest();

        request.priority = 'High';

        List<BedrockRequestPriorityService.PriorityRequest> requests =
            new List<BedrockRequestPriorityService.PriorityRequest>{
                request
            };

        Test.startTest();

        List<BedrockRequestPriorityService.PriorityResponse> responses =
            BedrockRequestPriorityService.evaluatePriority(requests);

        Test.stopTest();

        System.assertEquals(
            1,
            responses.size(),
            'One response should be returned'
        );

        System.assertEquals(
            true,
            responses[0].requiresReview,
            'High priority requests should require review'
        );
    }


    @IsTest
    static void testCriticalPriorityRequiresReview() {

        BedrockRequestPriorityService.PriorityRequest request =
            new BedrockRequestPriorityService.PriorityRequest();

        request.priority = 'Critical';

        Test.startTest();

        List<BedrockRequestPriorityService.PriorityResponse> responses =
            BedrockRequestPriorityService.evaluatePriority(
                new List<BedrockRequestPriorityService.PriorityRequest>{
                    request
                }
            );

        Test.stopTest();

        System.assertEquals(
            true,
            responses[0].requiresReview,
            'Critical priority requests should require review'
        );
    }


    @IsTest
    static void testMediumPriorityDoesNotRequireReview() {

        BedrockRequestPriorityService.PriorityRequest request =
            new BedrockRequestPriorityService.PriorityRequest();

        request.priority = 'Medium';

        Test.startTest();

        List<BedrockRequestPriorityService.PriorityResponse> responses =
            BedrockRequestPriorityService.evaluatePriority(
                new List<BedrockRequestPriorityService.PriorityRequest>{
                    request
                }
            );

        Test.stopTest();

        System.assertEquals(
            false,
            responses[0].requiresReview,
            'Medium priority requests should not require review'
        );
    }


    @IsTest
    static void testBulkPriorityEvaluation() {

        BedrockRequestPriorityService.PriorityRequest highRequest =
            new BedrockRequestPriorityService.PriorityRequest();

        highRequest.priority = 'High';

        BedrockRequestPriorityService.PriorityRequest lowRequest =
            new BedrockRequestPriorityService.PriorityRequest();

        lowRequest.priority = 'Low';

        List<BedrockRequestPriorityService.PriorityRequest> requests =
            new List<BedrockRequestPriorityService.PriorityRequest>{
                highRequest,
                lowRequest
            };

        Test.startTest();

        List<BedrockRequestPriorityService.PriorityResponse> responses =
            BedrockRequestPriorityService.evaluatePriority(requests);

        Test.stopTest();

        System.assertEquals(2, responses.size());

        System.assertEquals(
            true,
            responses[0].requiresReview
        );

        System.assertEquals(
            false,
            responses[1].requiresReview
        );
    }
}