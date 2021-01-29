@isTest
public with sharing class AsyncEmpiTest {

    @isTest
    static void test_get_demographics() {
        AsyncEmpi.AsyncQUPA_AR101102_Port stub = new AsyncEmpi.AsyncQUPA_AR101102_Port();
        
        AsyncEmpi.HCIM_IN_GetDemographicsResponseFuture future = stub.beginHCIM_IN_GetDemographics(
            new System.Continuation(1),
            new Empi.II(),
            new Empi.TS(),
            new Empi.CS(),
            new Empi.II(),
            new Empi.CS(),
            new Empi.CS(),
            new Empi.CS(),
            new Empi.MCCI_MT000100_Receiver(),
            new Empi.MCCI_MT000100_Sender(),
            new Empi.HCIM_IN_GetDemographics_QUQI_MT020001_ControlActProcess()
        );

        future.getValue();
    }
    
    @isTest
    static void test_get_related_identifiers() {
        AsyncEmpi.AsyncQUPA_AR101102_Port stub = new AsyncEmpi.AsyncQUPA_AR101102_Port();
        
        AsyncEmpi.HCIM_IN_GetRelatedIdentifiersResponseFuture future = stub.beginHCIM_IN_GetRelatedIdentifiers(
            new System.Continuation(1),
            new Empi.II(),
            new Empi.TS(),
            new Empi.CS(),
            new Empi.II(),
            new Empi.CS(),
            new Empi.CS(),
            new Empi.CS(),
            new Empi.MCCI_MT000100_Receiver(),
            new Empi.MCCI_MT000100_Sender(),
            new Empi.HCIM_IN_GetRelatedIdentifiers_QUQI_MT020001_ControlActProcess()
        );

        future.getValue();
    }

    @isTest
    static void test_find_candidates() {
        AsyncEmpi.AsyncQUPA_AR101102_Port stub = new AsyncEmpi.AsyncQUPA_AR101102_Port();
        
        AsyncEmpi.HCIM_IN_FindCandidatesResponseFuture future = stub.beginHCIM_IN_FindCandidates(
            new System.Continuation(1),
            new Empi.II(),
            new Empi.TS(),
            new Empi.CS(),
            new Empi.II(),
            new Empi.CS(),
            new Empi.CS(),
            new Empi.CS(),
            new Empi.MCCI_MT000100_Receiver(),
            new Empi.MCCI_MT000100_Sender(),
            new Empi.HCIM_IN_FindCandidates_QUQI_MT020001_ControlActProcess()
        );

        future.getValue();
    }

}
