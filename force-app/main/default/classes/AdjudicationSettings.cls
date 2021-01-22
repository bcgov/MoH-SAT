public with sharing class AdjudicationSettings {
    private static Boolean ENABLE_TRIGGERS = true;

    public static void enableTriggers() {
        ENABLE_TRIGGERS = true;
    }

    public static void disableTriggers() {
        ENABLE_TRIGGERS = false;
    }

    public static Boolean triggersEnabled() {
        return ENABLE_TRIGGERS;
    }
}
