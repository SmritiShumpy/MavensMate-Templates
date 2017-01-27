/**
* @date 11/9/2014
* @description This factory creates the correct handler and dispatches the trigger event(s) to the appropriate 
*				event handler(s). The handlers are automatically created using the Type API, hence handler 
*				registration is not required for each handler.
*/
public with sharing class Trigger_Factory
{
    public static Boolean FakeException = false; 
    public static Boolean KillSwitchEnabled = Trigger_SettingsSupport.KillSwitchEnabled; 
    public static String KillList = Trigger_SettingsSupport.KillList;

    /**  
	* @date 11/9/2014
	* @description Creates the appropriate handler and dispatches the trigger event to the handler's event handler method.
	* @param Schema.sObjectType Object type to process (SObject.sObjectType)
	*/
    public static void createTriggerHandler(Schema.sObjectType soType){
        String soTypeName = soType.getDescribe().getName();
        Set<String> deactivatedObjects = new Set<String>();
        if (KillList != null && KillList != ''){
            deactivatedObjects = new Set<String>(KillList.split('\n'));
        }
        Set<String> deactivatedObjectsNoWhitespace = new Set<String>();
        for (String s: deactivatedObjects){
            deactivatedObjectsNoWhitespace.add(s.deleteWhitespace()); 
        }

        if (!(KillSwitchEnabled || (KillList != null ? deactivatedObjectsNoWhitespace.contains(soTypeName) : false))){  
            // Initial Push to Diagnostic Log
            String beforeOrAfter = 'before';
            if (Trigger.isAfter)
                beforeOrAfter = 'after';
            String dmlState = 'Insert';
            if (Trigger.isUpdate){
                dmlState = 'Update';
            }
            else if (Trigger.isDelete){
                dmlState = 'Delete';
            }
            else if (Trigger.isUndelete){
                dmlState = 'Undelete';
            }
            Trigger_DiagnosticsInstrumentation.Push(beforeOrAfter + dmlState + ' Trigger for ' + soTypeName + ' Object');
            try{
                Trigger_ITriggerHandler handler = getTriggerHandler(soType); 
                if (handler == null || FakeException)
                    throw new Trigger_FrameworkException('No Trigger handler registered for Object Type: ' + soType); 
                execute(handler, soTypeName, beforeOrAfter+dmlState);
                // Final Pop from Diagnostic Log
                Trigger_DiagnosticsInstrumentation.Pop();
            }
            catch(Exception ex){
                Trigger_DiagnosticsInstrumentation.DebugException(ex);
                Trigger_DiagnosticsInstrumentation.PopAll();
                if (!Trigger_SettingsSupport.DiagnosticsEnabled && Trigger_SettingsSupport.ThrowExceptions){
                    throw ex;
                }
            }
        }
    }

    /** 
    * @date 11/9/2014
    * @description Dispatches to the handler's event handlers.
    * @param ITriggerhandler A Trigger handler that dispatches to the appropriate handlers
    */ 
    private static void execute(Trigger_ITriggerHandler handler, String soTypeName, String context){
        Trigger_Parameters tp = new Trigger_Parameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap,
                                    Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, 
                                    Trigger.isInsert, Trigger.isUpdate, Trigger.isUnDelete, Trigger.isExecuting);
        // Handle before trigger events
        if (Trigger.isBefore) {
            Trigger_DiagnosticsInstrumentation.Push(soTypeName + 'Triggerhandler.bulkBefore');
            handler.bulkBefore();
            Trigger_DiagnosticsInstrumentation.Pop();
        }
        // Handle after trigger events
        else {
            Trigger_DiagnosticsInstrumentation.Push(soTypeName + 'Triggerhandler.bulkAfter');
            handler.bulkAfter();
            Trigger_DiagnosticsInstrumentation.Pop();
        }

        handler.execute(tp, context);

        Trigger_DiagnosticsInstrumentation.Push(soTypeName + 'Triggerhandler.andFinally');
        handler.andFinally();
        Trigger_DiagnosticsInstrumentation.Pop();
    } 

    /** 
    * @date 11/9/2014
    * @description Gets the appropriate handler based on the SObject. It constructs the instance of the handler
    *               dynamically using the Type API. The name of the handler has to follow this format:
    *               <ObjectName>Triggerhandler. For e.g. for the Account object, the handler has to be named
    *               as AccountTriggerhandler. For the custom object Custom__c, the name should be CustomTriggerhandler.
    * @param Schema.sObjectType Object type to create the handler
    * @return Trigger_ITriggerHandler A trigger handler if one exists, otherwise null.
    */
    private static Trigger_ITriggerHandler getTriggerHandler(Schema.sObjectType soType){ 
        String originalTypeName = soType.getDescribe().getName();
        String handlerTypeName = null;
        String handlerName;
        if (originalTypeName.toLowerCase().endsWith('__c')) {
            Integer index = originalTypeName.toLowerCase().indexOf('__c');
            handlerName = originalTypeName.substring(0, index);
        }
        else {
            handlerName = originalTypeName;
        }
        if (handlerName.length() > 23){
            handlerName = handlerName.substring(0,23);
        }
        //handlerTypeName = 'SL_' + handlerName + 'TriggerHandler';    
        /*Commented to remove the SL_ prefix*/
        handlerTypeName = handlerName + 'TriggerHandler'; 
        System.debug(LoggingLevel.error, handlerTypeName); 

        Type obType = Type.forName(handlerTypeName);

        Trigger_ITriggerHandler handler = (obType == null) ? null : (Trigger_ITriggerHandler)obType.newInstance();
        return handler;
    }
}