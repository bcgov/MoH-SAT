public class SampleOmniScriptapex implements omnistudio.VlocityOpenInterface {

    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName.equals('getAccounts')) {
                getAccounts(input, outMap, options);
            } else {
                outMap.put('result', ''); // Corrected variable name to outMap
            }
        } catch (Exception e) {
            return false;
        }
        return result;
    }

    public void getAccounts(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        List<Account> firstAccountList = [SELECT Id, Name, Website, Phone FROM Account LIMIT 10]; // Corrected field name Phonr to Phone
        outMap.put('result', firstAccountList); // Corrected variable name to outMap
    }
}