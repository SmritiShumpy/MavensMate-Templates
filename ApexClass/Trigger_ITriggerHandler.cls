public interface Trigger_ITriggerHandler {
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the bulk operations. 
	*/
	void bulkBefore();  
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after the bulk operations.
	*/
	void bulkAfter();
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after completing the bulk operations.
	*/
	void andFinally();

	void execute(Trigger_Parameters tp, String context); 
}