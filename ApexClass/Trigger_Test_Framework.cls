/**
* @date 11/9/2014
* @description This class provides unit tests for the framework.
*/
@isTest (oninstall=true seealldata=false)
public with sharing class Trigger_Test_Framework {  
    /** 
    * @date 11/9/2014
    * @description This method tests the framework using the sample account trigger. 
    */ 
    @isTest (oninstall=true seealldata=false)
    public static void testDebugInfoTrigger() {
        Debug_Info__c testRecord = new Debug_Info__c();

        Trigger_Factory.KillList = 'Account';

        insert testRecord;
        //KillSwitch
        Trigger_Factory.KillSwitchEnabled = true;
        update testRecord;
        Trigger_Factory.KillSwitchEnabled = false;
        //Fake Exception
        Trigger_Factory.FakeException = true;
        //DebugInfo Log
        Trigger_DiagnosticsInstrumentation.EmailDebugInfoEnabled = true;
        Trigger_DiagnosticsInstrumentation.DebugInfoMaxAge = 7;
        Trigger_DiagnosticsInstrumentation.DebugInfoEmailRecipients = 'test@test.com';
        try {
            Trigger_SettingsSupport.ThrowExceptions = true;
            update testRecord;
        }
        catch(Exception ex){
            
        } 
        Trigger_FrameworkException.getCoverage();
        Trigger_Factory.FakeException = false;
        update testRecord;
        delete testRecord;
        undelete testRecord;

        //SL_SL_Debug_InfoTriggerHandler handler = new SL_SL_Debug_InfoTriggerHandler();

        /*Map<Id, SObject> mapForTest = new Map<Id, SObject>(new List<SObject>{new SObject(Id='a00000000000000')});  

        SL_Trigger_Parameters tp = new SL_Trigger_Parameters(mapForTest.values(), mapForTest.values(), mapForTest, mapForTest,
                                    true, true, true, 
                                    true, true, true, true);

        handler.execute(tp, 'beforeInsert');
        handler.execute(tp, 'beforeUpdate');
        handler.execute(tp, 'beforeDelete');
        handler.execute(tp, 'afterInsert');
        handler.execute(tp, 'afterUpdate');
        handler.execute(tp, 'afterDelete');
        handler.execute(tp, 'afterUnDelete');
        handler.execute(tp, 'afterUnDelete');*/
    }
}