/**  
* \arg ClassName        : Debug_InfoTriggerHandler
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       :  
* \arg Description      : Handler class for SL_Debug_Info object.
*/
global class Debug_InfoTriggerHandler extends Trigger_HandlerBase{ 

    public override void beforeInsert(List<SObject> newListGeneric){
        List<Debug_Info__c> newList = (List<Debug_Info__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
          
        /*BEFORE INSERT METHODS END*/
    }  
    
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Debug_Info__c> oldMap = (Map<Id, Debug_Info__c>) oldMapGeneric;
        Map<Id, Debug_Info__c> newMap = (Map<Id, Debug_Info__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        
        /*BEFORE UPDATE METHODS END*/
    }
    
    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Debug_Info__c> oldMap = (Map<Id, Debug_Info__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/
        
        /*BEFORE DELETE METHODS END*/
    }
    
    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        Map<Id, Debug_Info__c> newMap = (Map<Id, Debug_Info__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        
        /*AFTER INSERT METHODS END*/
    }
    
    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Debug_Info__c> oldMap = (Map<Id, Debug_Info__c>) oldMapGeneric;
        Map<Id, Debug_Info__c> newMap = (Map<Id, Debug_Info__c>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/
        
        /*AFTER UPDATE METHODS END*/
    }
    
    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Debug_Info__c> oldMap = (Map<Id, Debug_Info__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/
        
        /*AFTER DELETE METHODS END*/
    }
    
    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, Debug_Info__c> newMap = (Map<Id, Debug_Info__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/
        
        /*AFTER UNDELETE METHODS END*/
    }
    
}