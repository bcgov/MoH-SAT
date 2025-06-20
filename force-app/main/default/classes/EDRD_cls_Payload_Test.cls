@isTest
public class EDRD_cls_Payload_Test {
    @isTest
    static void testParseMethod() {
        // Sample JSON that matches the expected structure
        String sampleJson = '{"inputs":[{"assessmentId":"12345"}]}';

        // Call the parse method
        EDRD_cls_Payload result = EDRD_cls_Payload.parse(sampleJson);

        // Assertions to verify correct parsing
        System.assertNotEquals(null, result, 'Parsed payload should not be null');
        System.assertNotEquals(null, result.inputs, 'Inputs list should not be null');
        System.assertEquals(1, result.inputs.size(), 'Inputs list should contain one element');
        System.assertEquals('12345', result.inputs[0].assessmentId, 'AssessmentId should match expected value');
    }
}
