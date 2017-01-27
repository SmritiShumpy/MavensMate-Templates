/**
* @date 11/9/2014
* @description This class implements diagnostics for the application
*/
public class Trigger_DiagnosticsInstrumentation {  
	
	public static Boolean DiagnosticsEnabled = Trigger_SettingsSupport.DiagnosticsEnabled;
	public static Boolean EmailDebugInfoEnabled = Trigger_SettingsSupport.EmailDebugInfoEnabled;
	public static String DebugInfoEmailRecipients = Trigger_SettingsSupport.DebugInfoEmailRecipients;
	public static Integer DebugInfoMaxNum = Trigger_SettingsSupport.DebugInfoMaxNum;
	public static Integer DebugInfoMaxAge = Trigger_SettingsSupport.DebugInfoMaxAge; 
	
	private static List<DiagnosticEntry> DiagnosticLog;
	private static Integer CurrentLevel = 0;  

	private static List<String> StackTrace = new List<String>();
	public static String ExceptionTrace = '';

	private class DiagnosticEntry {
		Integer level;
		String description;
		
		private DiagnosticEntry(String entrydescription)
		{
			level = CurrentLevel;
			description = '[' + System.now().format('HH:mm:ss.SSS') + '] {' + UserInfo.getName() + '} ' + entrydescription;
		}
	}

	/** 
	* @date 11/9/2014
	* @description Should be called at the start of every function to increment and update the current execution context level.
	*/
	public static void Push(String functionname){
		Debug('Entering: ' + functionname);
		CurrentLevel+=1;
		StackTrace.add(functionname); 
	}
	
	/** 
	* @date 11/9/2014
	* @description Adds new diagnostic entry to the diagnostic log (if diagnostics are enabled)
	*/
	public static void Debug(String debugstring){
		if (!DiagnosticsEnabled && !EmailDebugInfoEnabled){
			return;
		}
		if(DiagnosticLog==null) DiagnosticLog = new List<DiagnosticEntry>();
		DiagnosticLog.add(new DiagnosticEntry(debugstring));
		if(DiagnosticsEnabled){
			System.Debug(LoggingLevel.Info, debugstring);
		}
	}
	
	/** 
	* @date 11/9/2014
	* @description Called prior to PopAll to add exception info to diagnostic log and object
	*/
	public static void DebugException(Exception ex){ 
		String exceptioninfo = 'Exception occurred line ' + ex.getLineNumber() + ' - ' + ex.getMessage() + ' stack: ' + ex.getStackTraceString();
		Debug(exceptioninfo);
		Debug_Info__c dbg = new Debug_Info__c(DebugData__c = CurrentLog());
		ExceptionTrace = ' Exception occurred line ' + ex.getLineNumber() + ' - ' + ex.getMessage();
		for(String st: StackTrace) ExceptionTrace += ' | ' + st;
		ExceptionTrace += ' |\n ';
		if(DiagnosticsEnabled){
			if (!Test.isRunningTest())
				insert dbg;
			if (DebugInfoMaxNum!=null || DebugInfoMaxAge!=null)
				CheckDebugInfoLog();
		}
		if (EmailDebugInfoEnabled && DebugInfoEmailRecipients!=null && DebugInfoEmailRecipients!=''){
			EmailDebugInfoLog(new List<Debug_Info__c>{dbg}, 'The following exception occured, see attached CSV:\n'+ dbg.DebugData__c);
		}
	}

	/** 
	* @date 11/9/2014
	* @description Should be called on the exit of every function to decrement and update the current execution context level.
	*/
	public static void Pop(){
		if(CurrentLevel>0) CurrentLevel-=1;
		if(CurrentLevel==0) System.Debug(LoggingLevel.Info, 'Diagnostic Log\n' + CurrentLog());
		if(StackTrace.size()>0) StackTrace.remove(StackTrace.size()-1);
	}
	
	/** 
	* @date 11/9/2014
	* @description Used for exception handling
	*/
	public static void PopAll(){
		CurrentLevel=0;
		Pop();
	}
	
	/** 
	* @date 11/9/2014
	* @description Returns multi-line string representation of diagnostic log
	*/
	public static String CurrentLog(){
		if(DiagnosticLog == null) return null;
		String spaces = '                                                                        ';
		String result = '';
		for(DiagnosticEntry de: DiagnosticLog)
		{
			Integer endindex = 3 * de.level;
			if(endindex >= spaces.length()) endindex = spaces.length()-1;
			result += spaces.substring(0,endindex) + de.description + '\n';
		}
		return result;
	}

	/** 
	* @date 11/9/2014
	* @description Checks if DebugInfo log needs clearing
	*/
	public static void CheckDebugInfoLog(){
		list<Debug_Info__c> debugInfoLog = [SELECT Id, CreatedDate, DebugData__c FROM Debug_Info__c ORDER BY CreatedDate ASC];
		if (!debugInfoLog.isEmpty() && DebugInfoMaxNum!=null && debugInfoLog.size()>=DebugInfoMaxNum){
			ClearDebugInfoLog(debugInfoLog);
		}
		if (!debugInfoLog.isEmpty() && DebugInfoMaxAge!=null && (debugInfoLog[0].CreatedDate <= System.now().addDays(-1 * DebugInfoMaxAge)) || Test.isRunningTest()){
			list<Debug_Info__c> debugInfoToDelete = new list<Debug_Info__c>();
			DateTime maxAge = System.now().addDays(-1 * DebugInfoMaxAge);
			for (Debug_Info__c di : debugInfoLog){
				if (di.CreatedDate <= maxAge)
					debugInfoToDelete.add(di);
			}
			ClearDebugInfoLog(debugInfoToDelete);
		}
	}
	
	/** 
	* @date 11/9/2014
	* @description Deletes DebugInfo log records
	* @param list<SL_Debug_Info__c> List of debug info records to be deleted
	*/
	public static void ClearDebugInfoLog(list<Debug_Info__c> expiredDebugInfoLog){
		if (EmailDebugInfoEnabled && DebugInfoEmailRecipients!=null && DebugInfoEmailRecipients!=''){
			EmailDebugInfoLog(expiredDebugInfoLog);
		}
		delete expiredDebugInfoLog;
	}

	public static void EmailDebugInfoLog(list<Debug_Info__c> debugInfoLog){ 
		EmailDebugInfoLog(debugInfoLog, 'Attached is the DebugInfo log that was cleared for ' + UserInfo.getOrganizationName() + '(' + UserInfo.getOrganizationId() + ')');
	}

	/** 
	* @date 11/9/2014
	* @description Emails DebugInfo log
	* @param list<SL_Debug_Info__c> List of debug info records to be emailed
	*/
	public static void EmailDebugInfoLog(list<Debug_Info__c> debugInfoLog, String emailMessage){
		//Define email settings
        Messaging.SingleEmailMessage debugInfoEmail = new Messaging.SingleEmailMessage();                   
        debugInfoEmail.setToAddresses(DebugInfoEmailRecipients.split(';'));
        debugInfoEmail.setSubject('DebugInfo Log for ' + UserInfo.getOrganizationName() + '(' + UserInfo.getOrganizationId() + ')');
        debugInfoEmail.setPlainTextBody(emailMessage);
        debugInfoEmail.setHtmlBody(emailMessage);
        //Generate attachment
        String csvString = new DebugInfoLogAttachment().generate(debugInfoLog);
        transient Blob csvAttachment = Blob.valueOf(csvString);
        transient Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setBody(csvAttachment);
        efa.setContentType('text/csv');
        efa.setFileName(System.today().format()+'_'+UserInfo.getOrganizationName()+'_DebugInfoLog.csv');
        efa.setInline(false);
        debugInfoEmail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        //Send email
        if (!Test.isRunningTest())
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {debugInfoEmail});
	}

	private class DebugInfoLogAttachment {
		
		private String generate(list<Debug_Info__c> diLog) { 
	        String s = line(new String[] {
	                format('DebugInfo Entry'),
	                format('Created Date'),
	                format('Debug Data') 
	                });
	        for (Debug_Info__c di : diLog) {
	            s += line(new String[] {
	                    format(di.Name),
	                    format(di.CreatedDate),
	                    format(di.DebugData__c)
	                    });
	        }
	        return s;
	    }
	    private String line(String[] cells) {
	        return String.join(cells, ',') + '\n';
	    }
	    private String format(DateTime dt)    {
	        return dt != null ? '"' + dt.format().escapeCsv() + '"' : '""';
	    }
	    private String format(String s) {
	        return s != null ? '"' + s.escapeCsv() + '"' : '""';
	    }
	}
	
}