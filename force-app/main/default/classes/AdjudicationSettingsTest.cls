@isTest
public with sharing class AdjudicationSettingsTest {

    @isTest
    static void test_run_time_default() {
        system.assert(AdjudicationSettings.triggersEnabled());
    }

    @isTest
    static void test_enable_triggers() {
        AdjudicationSettings.enableTriggers();
        system.assert(AdjudicationSettings.triggersEnabled());
    }
    
    @isTest
    static void test_disable_triggers() {
        AdjudicationSettings.disableTriggers();
        system.assert(!AdjudicationSettings.triggersEnabled());
    }

}
