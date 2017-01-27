trigger Debug_Info on Debug_Info__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Factory.createTriggerHandler(Debug_Info__c.sObjectType);
}