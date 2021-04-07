public with sharing class SaSettings {
    private static Boolean ENABLE_TRIGGERS = true;

    private static Boolean IS_SANDBOX {
        get {
            if (IS_SANDBOX == null) {
                IS_SANDBOX = [select IsSandbox from Organization limit 1].IsSandbox;
            }

            return IS_SANDBOX;
        }
        set;
    }

    public static void enableTriggers() {
        ENABLE_TRIGGERS = true;
    }

    public static void disableTriggers() {
        ENABLE_TRIGGERS = false;
    }

    public static Boolean triggersEnabled() {
        return ENABLE_TRIGGERS;
    }

    public static Boolean isSandbx() {
        return IS_SANDBOX;
    }

    public static Id getEformFaultQueueId() {
        return [select Id from Group where DeveloperName = 'eForm_Failure']?.Id;
    }
}
