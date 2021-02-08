@isTest
public with sharing class SaSettingsTest {

    @isTest
    static void test_run_time_default() {
        system.assert(SaSettings.triggersEnabled());
    }

    @isTest
    static void test_enable_triggers() {
        SaSettings.enableTriggers();
        system.assert(SaSettings.triggersEnabled());
    }
    
    @isTest
    static void test_disable_triggers() {
        SaSettings.disableTriggers();
        system.assert(!SaSettings.triggersEnabled());
    }

    @isTest
    static void test_is_sandbox() {
        system.assertEquals(
            [select IsSandbox from Organization limit 1].IsSandbox,
            SaSettings.isSandbx()
        );
    }

}
