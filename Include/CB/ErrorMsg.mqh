//+------------------------------------------------------------------+
//|                                                     ErrorMsg.mqh |
//|                                                   Christof Blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ErrorMsgOLD(int error_code)
 {
  string error_string;
//----
  switch(error_code)
   {
    //---- codes returned from trade server
    case 0:
    case 1:
      error_string = "no error";
      break;
    case 2:
      error_string = "common error";
      break;
    case 3:
      error_string = "invalid trade parameters";
      break;
    case 4:
      error_string = "trade server is busy";
      break;
    case 5:
      error_string = "old version of the client terminal";
      break;
    case 6:
      error_string = "no connection with trade server";
      break;
    case 7:
      error_string = "not enough rights";
      break;
    case 8:
      error_string = "too frequent requests";
      break;
    case 9:
      error_string = "malfunctional trade operation";
      break;
    case 64:
      error_string = "account disabled";
      break;
    case 65:
      error_string = "invalid account";
      break;
    case 128:
      error_string = "trade timeout";
      break;
    case 129:
      error_string = "invalid price";
      break;
    case 130:
      error_string = "invalid stops";
      break;
    case 131:
      error_string = "invalid trade volume";
      break;
    case 132:
      error_string = "market is closed";
      break;
    case 133:
      error_string = "trade is disabled";
      break;
    case 134:
      error_string = "not enough money";
      break;
    case 135:
      error_string = "price changed";
      break;
    case 136:
      error_string = "off quotes";
      break;
    case 137:
      error_string = "broker is busy";
      break;
    case 138:
      error_string = "requote";
      break;
    case 139:
      error_string = "order is locked";
      break;
    case 140:
      error_string = "long positions only allowed";
      break;
    case 141:
      error_string = "too many requests";
      break;
    case 145:
      error_string = "modification denied because order too close to market";
      break;
    case 146:
      error_string = "trade context is busy";
      break;
    //---- mql4 errors
    case 4000:
      error_string = "no error";
      break;
    case 4001:
      error_string = "wrong function pointer";
      break;
    case 4002:
      error_string = "array index is out of range";
      break;
    case 4003:
      error_string = "no memory for function call stack";
      break;
    case 4004:
      error_string = "recursive stack overflow";
      break;
    case 4005:
      error_string = "not enough stack for parameter";
      break;
    case 4006:
      error_string = "no memory for parameter string";
      break;
    case 4007:
      error_string = "no memory for temp string";
      break;
    case 4008:
      error_string = "not initialized string";
      break;
    case 4009:
      error_string = "not initialized string in array";
      break;
    case 4010:
      error_string = "no memory for array\' string";
      break;
    case 4011:
      error_string = "too long string";
      break;
    case 4012:
      error_string = "remainder from zero divide";
      break;
    case 4013:
      error_string = "zero divide";
      break;
    case 4014:
      error_string = "unknown command";
      break;
    case 4015:
      error_string = "wrong jump (never generated error)";
      break;
    case 4016:
      error_string = "not initialized array";
      break;
    case 4017:
      error_string = "dll calls are not allowed";
      break;
    case 4018:
      error_string = "cannot load library";
      break;
    case 4019:
      error_string = "cannot call function";
      break;
    case 4020:
      error_string = "expert function calls are not allowed";
      break;
    case 4021:
      error_string = "not enough memory for temp string returned from function";
      break;
    case 4022:
      error_string = "system is busy (never generated error)";
      break;
    case 4023:
      error_string = "DLL-function call critical error";
      break;
    case 4024:
      error_string = "Internal error";
      break;
    case 4050:
      error_string = "invalid function parameters count";
      break;
    case 4051:
      error_string = "invalid function parameter value";
      break;
    case 4052:
      error_string = "string function internal error";
      break;
    case 4053:
      error_string = "some array error";
      break;
    case 4054:
      error_string = "incorrect series array using";
      break;
    case 4055:
      error_string = "custom indicator error";
      break;
    case 4056:
      error_string = "arrays are incompatible";
      break;
    case 4057:
      error_string = "global variables processing error";
      break;
    case 4058:
      error_string = "global variable not found";
      break;
    case 4059:
      error_string = "function is not allowed in testing mode";
      break;
    case 4060:
      error_string = "function is not confirmed";
      break;
    case 4061:
      error_string = "send mail error";
      break;
    case 4062:
      error_string = "string parameter expected";
      break;
    case 4063:
      error_string = "integer parameter expected";
      break;
    case 4064:
      error_string = "double parameter expected";
      break;
    case 4065:
      error_string = "array as parameter expected";
      break;
    case 4066:
      error_string = "requested history data in update state";
      break;
    case 4099:
      error_string = "end of file";
      break;
    case 4100:
      error_string = "some file error";
      break;
    case 4101:
      error_string = "wrong file name";
      break;
    case 4102:
      error_string = "too many opened files";
      break;
    case 4103:
      error_string = "cannot open file";
      break;
    case 4104:
      error_string = "incompatible access to a file";
      break;
    case 4105:
      error_string = "no order selected";
      break;
    case 4106:
      error_string = "unknown symbol";
      break;
    case 4107:
      error_string = "invalid price parameter for trade function";
      break;
    case 4108:
      error_string = "invalid ticket";
      break;
    case 4109:
      error_string = "trade is not allowed";
      break;
    case 4110:
      error_string = "longs are not allowed";
      break;
    case 4111:
      error_string = "shorts are not allowed";
      break;
    case 4200:
      error_string = "object is already exist";
      break;
    case 4201:
      error_string = "unknown object property";
      break;
    case 4202:
      error_string = "object is not exist";
      break;
    case 4203:
      error_string = "unknown object type";
      break;
    case 4204:
      error_string = "no object name";
      break;
    case 4205:
      error_string = "object coordinates error";
      break;
    case 4206:
      error_string = "no specified subwindow";
      break;
    default:
      error_string = "unknown error";
   }
//----
  return(error_string);
 }
//+------------------------------------------------------------------+
//+-----------------------------------------------------------------------------------------------------------------+
//| Error description function                                                                                      |
//+-----------------------------------------------------------------------------------------------------------------+
string ErrorMsg(int ErrorCode)
 {
//--- Local variable
  string ErrorMsg;
  switch(ErrorCode)
   {
    //--- Codes returned from trade server
    case 0:
      ErrorMsg = "No error returned.";
      break;
    case 1:
      ErrorMsg = "No error returned, but the result is unknown.";
      break;
    case 2:
      ErrorMsg = "Common error.";
      break;
    case 3:
      ErrorMsg = "Invalid trade parameters.";
      break;
    case 4:
      ErrorMsg = "Trade server is busy.";
      break;
    case 5:
      ErrorMsg = "Old version of the client terminal.";
      break;
    case 6:
      ErrorMsg = "No connection with trade server.";
      break;
    case 7:
      ErrorMsg = "Not enough rights.";
      break;
    case 8:
      ErrorMsg = "Too frequent requests.";
      break;
    case 9:
      ErrorMsg = "Malfunctional trade operation.";
      break;
    case 64:
      ErrorMsg = "Account disabled.";
      break;
    case 65:
      ErrorMsg = "Invalid account.";
      break;
    case 128:
      ErrorMsg = "Trade timeout.";
      break;
    case 129:
      ErrorMsg = "Invalid price.";
      break;
    case 130:
      ErrorMsg = "Invalid stops.";
      break;
    case 131:
      ErrorMsg = "Invalid trade volume.";
      break;
    case 132:
      ErrorMsg = "Market is closed.";
      break;
    case 133:
      ErrorMsg = "Trade is disabled.";
      break;
    case 134:
      ErrorMsg = "Not enough money.";
      break;
    case 135:
      ErrorMsg = "Price changed.";
      break;
    case 136:
      ErrorMsg = "Off quotes.";
      break;
    case 137:
      ErrorMsg = "Broker is busy.";
      break;
    case 138:
      ErrorMsg = "Requote.";
      break;
    case 139:
      ErrorMsg = "Order is locked.";
      break;
    case 140:
      ErrorMsg = "Buy orders only allowed.";
      break;
    case 141:
      ErrorMsg = "Too many requests.";
      break;
    case 145:
      ErrorMsg = "Modification denied because order is too close to market.";
      break;
    case 146:
      ErrorMsg = "Trade context is busy.";
      break;
    case 147:
      ErrorMsg = "Expirations are denied by broker.";
      break;
    case 148:
      ErrorMsg = "The amount of open and pending orders has reached the limit.";
      break;
    case 149:
      ErrorMsg = "An attempt to open an order opposite when hedging is disabled.";
      break;
    case 150:
      ErrorMsg = "An attempt to close an order contravening the FIFO rule.";
      break;
    //--- Mql4 errors
    case 4000:
      ErrorMsg = "No error returned.";
      break;
    case 4001:
      ErrorMsg = "Wrong function pointer.";
      break;
    case 4002:
      ErrorMsg = "Array index is out of range.";
      break;
    case 4003:
      ErrorMsg = "No memory for function call stack.";
      break;
    case 4004:
      ErrorMsg = "Recursive stack overflow.";
      break;
    case 4005:
      ErrorMsg = "Not enough stack for parameter.";
      break;
    case 4006:
      ErrorMsg = "No memory for parameter string.";
      break;
    case 4007:
      ErrorMsg = "No memory for temp string.";
      break;
    case 4008:
      ErrorMsg = "Not initialized string.";
      break;
    case 4009:
      ErrorMsg = "Not initialized string in array.";
      break;
    case 4010:
      ErrorMsg = "No memory for array string.";
      break;
    case 4011:
      ErrorMsg = "Too long string.";
      break;
    case 4012:
      ErrorMsg = "Remainder from zero divide.";
      break;
    case 4013:
      ErrorMsg = "Zero divide.";
      break;
    case 4014:
      ErrorMsg = "Unknown command.";
      break;
    case 4015:
      ErrorMsg = "Wrong jump (never generated error).";
      break;
    case 4016:
      ErrorMsg = "Not initialized array.";
      break;
    case 4017:
      ErrorMsg = "Dll calls are not allowed.";
      break;
    case 4018:
      ErrorMsg = "Cannot load library.";
      break;
    case 4019:
      ErrorMsg = "Cannot call function.";
      break;
    case 4020:
      ErrorMsg = "Expert function calls are not allowed.";
      break;
    case 4021:
      ErrorMsg = "Not enough memory for temp string returned from function.";
      break;
    case 4022:
      ErrorMsg = "System is busy (never generated error).";
      break;
    case 4023:
      ErrorMsg = "Dll-function call critical error.";
      break;
    case 4024:
      ErrorMsg = "Internal error.";
      break;
    case 4025:
      ErrorMsg = "Out of memory.";
      break;
    case 4026:
      ErrorMsg = "Invalid pointer.";
      break;
    case 4027:
      ErrorMsg = "Too many formatters in the format function.";
      break;
    case 4028:
      ErrorMsg = "Parameters count exceeds formatters count.";
      break;
    case 4029:
      ErrorMsg = "Invalid array.";
      break;
    case 4030:
      ErrorMsg = "No reply from chart.";
      break;
    case 4050:
      ErrorMsg = "Invalid function parameters count.";
      break;
    case 4051:
      ErrorMsg = "Invalid function parameter value.";
      break;
    case 4052:
      ErrorMsg = "String function internal error.";
      break;
    case 4053:
      ErrorMsg = "Some array error.";
      break;
    case 4054:
      ErrorMsg = "Incorrect series array using.";
      break;
    case 4055:
      ErrorMsg = "Custom indicator error.";
      break;
    case 4056:
      ErrorMsg = "Arrays are incompatible.";
      break;
    case 4057:
      ErrorMsg = "Global variables processing error.";
      break;
    case 4058:
      ErrorMsg = "Global variable not found.";
      break;
    case 4059:
      ErrorMsg = "Function is not allowed in testing mode.";
      break;
    case 4060:
      ErrorMsg = "Function is not allowed for call.";
      break;
    case 4061:
      ErrorMsg = "Send mail error.";
      break;
    case 4062:
      ErrorMsg = "String parameter expected.";
      break;
    case 4063:
      ErrorMsg = "Integer parameter expected.";
      break;
    case 4064:
      ErrorMsg = "Double parameter expected.";
      break;
    case 4065:
      ErrorMsg = "Array as parameter expected.";
      break;
    case 4066:
      ErrorMsg = "Requested history data is in updating state.";
      break;
    case 4067:
      ErrorMsg = "Internal trade error.";
      break;
    case 4068:
      ErrorMsg = "Resource not found.";
      break;
    case 4069:
      ErrorMsg = "Resource not supported.";
      break;
    case 4070:
      ErrorMsg = "Duplicate resource.";
      break;
    case 4071:
      ErrorMsg = "Custom indicator cannot initialize.";
      break;
    case 4072:
      ErrorMsg = "Cannot load custom indicator.";
      break;
    case 4073:
      ErrorMsg = "No history data.";
      break;
    case 4074:
      ErrorMsg = "No memory for history data.";
      break;
    case 4075:
      ErrorMsg = "Not enough memory for indicator calculation.";
      break;
    case 4099:
      ErrorMsg = "End of file.";
      break;
    case 4100:
      ErrorMsg = "Some file error.";
      break;
    case 4101:
      ErrorMsg = "Wrong file name.";
      break;
    case 4102:
      ErrorMsg = "Too many opened files.";
      break;
    case 4103:
      ErrorMsg = "Cannot open file.";
      break;
    case 4104:
      ErrorMsg = "Incompatible access to a file.";
      break;
    case 4105:
      ErrorMsg = "No order selected.";
      break;
    case 4106:
      ErrorMsg = "Unknown symbol.";
      break;
    case 4107:
      ErrorMsg = "Invalid price.";
      break;
    case 4108:
      ErrorMsg = "Invalid ticket.";
      break;
    case 4109:
      ErrorMsg = "Trade is not allowed in the Expert Advisor properties.";
      break;
    case 4110:
      ErrorMsg = "Longs are not allowed in the Expert Advisor properties.";
      break;
    case 4111:
      ErrorMsg = "Shorts are not allowed in the Expert Advisor properties.";
      break;
    case 4112:
      ErrorMsg = "Automated trading disabled by trade server.";
      break;
    case 4200:
      ErrorMsg = "Object already exists.";
      break;
    case 4201:
      ErrorMsg = "Unknown object property.";
      break;
    case 4202:
      ErrorMsg = "Object does not exist.";
      break;
    case 4203:
      ErrorMsg = "Unknown object type.";
      break;
    case 4204:
      ErrorMsg = "No object name.";
      break;
    case 4205:
      ErrorMsg = "Object coordinates error.";
      break;
    case 4206:
      ErrorMsg = "No specified subwindow.";
      break;
    case 4207:
      ErrorMsg = "Graphical object error.";
      break;
    case 4210:
      ErrorMsg = "Unknown chart property.";
      break;
    case 4211:
      ErrorMsg = "Chart not found.";
      break;
    case 4212:
      ErrorMsg = "Chart subwindow not found.";
      break;
    case 4213:
      ErrorMsg = "Chart indicator not found.";
      break;
    case 4220:
      ErrorMsg = "Symbol select error.";
      break;
    case 4250:
      ErrorMsg = "Notification error.";
      break;
    case 4251:
      ErrorMsg = "Notification parameter error.";
      break;
    case 4252:
      ErrorMsg = "Notifications disabled.";
      break;
    case 4253:
      ErrorMsg = "Notification send too frequent.";
      break;
    case 4260:
      ErrorMsg = "FTP server is not specified.";
      break;
    case 4261:
      ErrorMsg = "FTP login is not specified.";
      break;
    case 4262:
      ErrorMsg = "FTP connection failed.";
      break;
    case 4263:
      ErrorMsg = "FTP connection closed.";
      break;
    case 4264:
      ErrorMsg = "FTP path not found on server.";
      break;
    case 4265:
      ErrorMsg = "File not found in the Files directory to send on FTP server.";
      break;
    case 4266:
      ErrorMsg = "Common error during FTP data transmission.";
      break;
    case 4401:
      ErrorMsg = "Requested history not found.";
      break;
    case 4402:
      ErrorMsg = "Wrong ID of the history property.";
      break;
    case 4403:
      ErrorMsg = "Exceeded history request timeout.";
      break;
    case 4404:
      ErrorMsg = "Number of requested bars limited by terminal settings.";
      break;
    case 4405:
      ErrorMsg = "Multiple errors when loading history.";
      break;
    case 4407:
      ErrorMsg = "Receiving array is too small to store all requested data.";
      break;
    case 5001:
      ErrorMsg = "Too many opened files.";
      break;
    case 5002:
      ErrorMsg = "Wrong file name.";
      break;
    case 5003:
      ErrorMsg = "Too long file name.";
      break;
    case 5004:
      ErrorMsg = "Cannot open file.";
      break;
    case 5005:
      ErrorMsg = "Text file buffer allocation error.";
      break;
    case 5006:
      ErrorMsg = "Cannot delete file.";
      break;
    case 5007:
      ErrorMsg = "Invalid file handle (file closed or was not opened).";
      break;
    case 5008:
      ErrorMsg = "Wrong file handle (handle index is out of handle table).";
      break;
    case 5009:
      ErrorMsg = "File must be opened with FILE_WRITE flag.";
      break;
    case 5010:
      ErrorMsg = "File must be opened with FILE_READ flag.";
      break;
    case 5011:
      ErrorMsg = "File must be opened with FILE_BIN flag.";
      break;
    case 5012:
      ErrorMsg = "File must be opened with FILE_TXT flag.";
      break;
    case 5013:
      ErrorMsg = "File must be opened with FILE_TXT or FILE_CSV flag.";
      break;
    case 5014:
      ErrorMsg = "File must be opened with FILE_CSV flag.";
      break;
    case 5015:
      ErrorMsg = "File read error.";
      break;
    case 5016:
      ErrorMsg = "File write error.";
      break;
    case 5017:
      ErrorMsg = "String size must be specified for binary file.";
      break;
    case 5018:
      ErrorMsg = "Incompatible file (for string arrays-TXT, for others-BIN).";
      break;
    case 5019:
      ErrorMsg = "File is directory, not file.";
      break;
    case 5020:
      ErrorMsg = "File does not exist.";
      break;
    case 5021:
      ErrorMsg = "File cannot be rewritten.";
      break;
    case 5022:
      ErrorMsg = "Wrong directory name.";
      break;
    case 5023:
      ErrorMsg = "Directory does not exist.";
      break;
    case 5024:
      ErrorMsg = "Specified file is not directory.";
      break;
    case 5025:
      ErrorMsg = "Cannot delete directory.";
      break;
    case 5026:
      ErrorMsg = "Cannot clean directory.";
      break;
    case 5027:
      ErrorMsg = "Array resize error.";
      break;
    case 5028:
      ErrorMsg = "String resize error.";
      break;
    case 5029:
      ErrorMsg = "Structure contains strings or dynamic arrays.";
      break;
    case 5200:
      ErrorMsg = "Invalid URL.";
      break;
    case 5201:
      ErrorMsg = "Failed to connect to specified URL.";
      break;
    case 5202:
      ErrorMsg = "Timeout exceeded.";
      break;
    case 5203:
      ErrorMsg = "HTTP request failed.";
      break;
    default:
      ErrorMsg = "Unknown error.";
   }
  ErrorMsg = ErrorMsg + " (#" + string(ErrorCode) + ")";
  return(ErrorMsg);
 }

//+-----------------------------------------------------------------------------------------------------------------+
//| Error description function                                                                                      |
//+-----------------------------------------------------------------------------------------------------------------+
string ErrorDescription(int ErrorCode)
 {
//--- Local variable
  string ErrorMsg;
  switch(ErrorCode)
   {
    //--- Codes returned from trade server
    case 0:
      ErrorMsg = "No error returned.";
      break;
    case 1:
      ErrorMsg = "No error returned, but the result is unknown.";
      break;
    case 2:
      ErrorMsg = "Common error.";
      break;
    case 3:
      ErrorMsg = "Invalid trade parameters.";
      break;
    case 4:
      ErrorMsg = "Trade server is busy.";
      break;
    case 5:
      ErrorMsg = "Old version of the client terminal.";
      break;
    case 6:
      ErrorMsg = "No connection with trade server.";
      break;
    case 7:
      ErrorMsg = "Not enough rights.";
      break;
    case 8:
      ErrorMsg = "Too frequent requests.";
      break;
    case 9:
      ErrorMsg = "Malfunctional trade operation.";
      break;
    case 64:
      ErrorMsg = "Account disabled.";
      break;
    case 65:
      ErrorMsg = "Invalid account.";
      break;
    case 128:
      ErrorMsg = "Trade timeout.";
      break;
    case 129:
      ErrorMsg = "Invalid price.";
      break;
    case 130:
      ErrorMsg = "Invalid stops.";
      break;
    case 131:
      ErrorMsg = "Invalid trade volume.";
      break;
    case 132:
      ErrorMsg = "Market is closed.";
      break;
    case 133:
      ErrorMsg = "Trade is disabled.";
      break;
    case 134:
      ErrorMsg = "Not enough money.";
      break;
    case 135:
      ErrorMsg = "Price changed.";
      break;
    case 136:
      ErrorMsg = "Off quotes.";
      break;
    case 137:
      ErrorMsg = "Broker is busy.";
      break;
    case 138:
      ErrorMsg = "Requote.";
      break;
    case 139:
      ErrorMsg = "Order is locked.";
      break;
    case 140:
      ErrorMsg = "Buy orders only allowed.";
      break;
    case 141:
      ErrorMsg = "Too many requests.";
      break;
    case 145:
      ErrorMsg = "Modification denied because order is too close to market.";
      break;
    case 146:
      ErrorMsg = "Trade context is busy.";
      break;
    case 147:
      ErrorMsg = "Expirations are denied by broker.";
      break;
    case 148:
      ErrorMsg = "The amount of open and pending orders has reached the limit.";
      break;
    case 149:
      ErrorMsg = "An attempt to open an order opposite when hedging is disabled.";
      break;
    case 150:
      ErrorMsg = "An attempt to close an order contravening the FIFO rule.";
      break;
    //--- Mql4 errors
    case 4000:
      ErrorMsg = "No error returned.";
      break;
    case 4001:
      ErrorMsg = "Wrong function pointer.";
      break;
    case 4002:
      ErrorMsg = "Array index is out of range.";
      break;
    case 4003:
      ErrorMsg = "No memory for function call stack.";
      break;
    case 4004:
      ErrorMsg = "Recursive stack overflow.";
      break;
    case 4005:
      ErrorMsg = "Not enough stack for parameter.";
      break;
    case 4006:
      ErrorMsg = "No memory for parameter string.";
      break;
    case 4007:
      ErrorMsg = "No memory for temp string.";
      break;
    case 4008:
      ErrorMsg = "Not initialized string.";
      break;
    case 4009:
      ErrorMsg = "Not initialized string in array.";
      break;
    case 4010:
      ErrorMsg = "No memory for array string.";
      break;
    case 4011:
      ErrorMsg = "Too long string.";
      break;
    case 4012:
      ErrorMsg = "Remainder from zero divide.";
      break;
    case 4013:
      ErrorMsg = "Zero divide.";
      break;
    case 4014:
      ErrorMsg = "Unknown command.";
      break;
    case 4015:
      ErrorMsg = "Wrong jump (never generated error).";
      break;
    case 4016:
      ErrorMsg = "Not initialized array.";
      break;
    case 4017:
      ErrorMsg = "Dll calls are not allowed.";
      break;
    case 4018:
      ErrorMsg = "Cannot load library.";
      break;
    case 4019:
      ErrorMsg = "Cannot call function.";
      break;
    case 4020:
      ErrorMsg = "Expert function calls are not allowed.";
      break;
    case 4021:
      ErrorMsg = "Not enough memory for temp string returned from function.";
      break;
    case 4022:
      ErrorMsg = "System is busy (never generated error).";
      break;
    case 4023:
      ErrorMsg = "Dll-function call critical error.";
      break;
    case 4024:
      ErrorMsg = "Internal error.";
      break;
    case 4025:
      ErrorMsg = "Out of memory.";
      break;
    case 4026:
      ErrorMsg = "Invalid pointer.";
      break;
    case 4027:
      ErrorMsg = "Too many formatters in the format function.";
      break;
    case 4028:
      ErrorMsg = "Parameters count exceeds formatters count.";
      break;
    case 4029:
      ErrorMsg = "Invalid array.";
      break;
    case 4030:
      ErrorMsg = "No reply from chart.";
      break;
    case 4050:
      ErrorMsg = "Invalid function parameters count.";
      break;
    case 4051:
      ErrorMsg = "Invalid function parameter value.";
      break;
    case 4052:
      ErrorMsg = "String function internal error.";
      break;
    case 4053:
      ErrorMsg = "Some array error.";
      break;
    case 4054:
      ErrorMsg = "Incorrect series array using.";
      break;
    case 4055:
      ErrorMsg = "Custom indicator error.";
      break;
    case 4056:
      ErrorMsg = "Arrays are incompatible.";
      break;
    case 4057:
      ErrorMsg = "Global variables processing error.";
      break;
    case 4058:
      ErrorMsg = "Global variable not found.";
      break;
    case 4059:
      ErrorMsg = "Function is not allowed in testing mode.";
      break;
    case 4060:
      ErrorMsg = "Function is not allowed for call.";
      break;
    case 4061:
      ErrorMsg = "Send mail error.";
      break;
    case 4062:
      ErrorMsg = "String parameter expected.";
      break;
    case 4063:
      ErrorMsg = "Integer parameter expected.";
      break;
    case 4064:
      ErrorMsg = "Double parameter expected.";
      break;
    case 4065:
      ErrorMsg = "Array as parameter expected.";
      break;
    case 4066:
      ErrorMsg = "Requested history data is in updating state.";
      break;
    case 4067:
      ErrorMsg = "Internal trade error.";
      break;
    case 4068:
      ErrorMsg = "Resource not found.";
      break;
    case 4069:
      ErrorMsg = "Resource not supported.";
      break;
    case 4070:
      ErrorMsg = "Duplicate resource.";
      break;
    case 4071:
      ErrorMsg = "Custom indicator cannot initialize.";
      break;
    case 4072:
      ErrorMsg = "Cannot load custom indicator.";
      break;
    case 4073:
      ErrorMsg = "No history data.";
      break;
    case 4074:
      ErrorMsg = "No memory for history data.";
      break;
    case 4075:
      ErrorMsg = "Not enough memory for indicator calculation.";
      break;
    case 4099:
      ErrorMsg = "End of file.";
      break;
    case 4100:
      ErrorMsg = "Some file error.";
      break;
    case 4101:
      ErrorMsg = "Wrong file name.";
      break;
    case 4102:
      ErrorMsg = "Too many opened files.";
      break;
    case 4103:
      ErrorMsg = "Cannot open file.";
      break;
    case 4104:
      ErrorMsg = "Incompatible access to a file.";
      break;
    case 4105:
      ErrorMsg = "No order selected.";
      break;
    case 4106:
      ErrorMsg = "Unknown symbol.";
      break;
    case 4107:
      ErrorMsg = "Invalid price.";
      break;
    case 4108:
      ErrorMsg = "Invalid ticket.";
      break;
    case 4109:
      ErrorMsg = "Trade is not allowed in the Expert Advisor properties.";
      break;
    case 4110:
      ErrorMsg = "Longs are not allowed in the Expert Advisor properties.";
      break;
    case 4111:
      ErrorMsg = "Shorts are not allowed in the Expert Advisor properties.";
      break;
    case 4112:
      ErrorMsg = "Automated trading disabled by trade server.";
      break;
    case 4200:
      ErrorMsg = "Object already exists.";
      break;
    case 4201:
      ErrorMsg = "Unknown object property.";
      break;
    case 4202:
      ErrorMsg = "Object does not exist.";
      break;
    case 4203:
      ErrorMsg = "Unknown object type.";
      break;
    case 4204:
      ErrorMsg = "No object name.";
      break;
    case 4205:
      ErrorMsg = "Object coordinates error.";
      break;
    case 4206:
      ErrorMsg = "No specified subwindow.";
      break;
    case 4207:
      ErrorMsg = "Graphical object error.";
      break;
    case 4210:
      ErrorMsg = "Unknown chart property.";
      break;
    case 4211:
      ErrorMsg = "Chart not found.";
      break;
    case 4212:
      ErrorMsg = "Chart subwindow not found.";
      break;
    case 4213:
      ErrorMsg = "Chart indicator not found.";
      break;
    case 4220:
      ErrorMsg = "Symbol select error.";
      break;
    case 4250:
      ErrorMsg = "Notification error.";
      break;
    case 4251:
      ErrorMsg = "Notification parameter error.";
      break;
    case 4252:
      ErrorMsg = "Notifications disabled.";
      break;
    case 4253:
      ErrorMsg = "Notification send too frequent.";
      break;
    case 4260:
      ErrorMsg = "FTP server is not specified.";
      break;
    case 4261:
      ErrorMsg = "FTP login is not specified.";
      break;
    case 4262:
      ErrorMsg = "FTP connection failed.";
      break;
    case 4263:
      ErrorMsg = "FTP connection closed.";
      break;
    case 4264:
      ErrorMsg = "FTP path not found on server.";
      break;
    case 4265:
      ErrorMsg = "File not found in the Files directory to send on FTP server.";
      break;
    case 4266:
      ErrorMsg = "Common error during FTP data transmission.";
      break;
    case 4701:
      ErrorMsg = "Wrong account property ID" ;
      break;
    case 4751:
      ErrorMsg = "Wrong trade property ID" ;
      break;
    case 4752:
      ErrorMsg = "Trading by Expert Advisors prohibited" ;
      break;
    case 4753:
      ErrorMsg = "Position not found" ;
      break;
    case 4754:
      ErrorMsg = "Order not found" ;
      break;
    case 4755:
      ErrorMsg = "Deal not found" ;
      break;
    case 4756:
      ErrorMsg = "Trade request sending failed" ;
      break;
    case 4758:
      ErrorMsg = "Failed to calculate profit or margin" ;
      break;
    case 5001:
      ErrorMsg = "Too many opened files.";
      break;
    case 5002:
      ErrorMsg = "Wrong file name.";
      break;
    case 5003:
      ErrorMsg = "Too long file name.";
      break;
    case 5004:
      ErrorMsg = "Cannot open file.";
      break;
    case 5005:
      ErrorMsg = "Text file buffer allocation error.";
      break;
    case 5006:
      ErrorMsg = "Cannot delete file.";
      break;
    case 5007:
      ErrorMsg = "Invalid file handle (file closed or was not opened).";
      break;
    case 5008:
      ErrorMsg = "Wrong file handle (handle index is out of handle table).";
      break;
    case 5009:
      ErrorMsg = "File must be opened with FILE_WRITE flag.";
      break;
    case 5010:
      ErrorMsg = "File must be opened with FILE_READ flag.";
      break;
    case 5011:
      ErrorMsg = "File must be opened with FILE_BIN flag.";
      break;
    case 5012:
      ErrorMsg = "File must be opened with FILE_TXT flag.";
      break;
    case 5013:
      ErrorMsg = "File must be opened with FILE_TXT or FILE_CSV flag.";
      break;
    case 5014:
      ErrorMsg = "File must be opened with FILE_CSV flag.";
      break;
    case 5015:
      ErrorMsg = "File read error.";
      break;
    case 5016:
      ErrorMsg = "File write error.";
      break;
    case 5017:
      ErrorMsg = "String size must be specified for binary file.";
      break;
    case 5018:
      ErrorMsg = "Incompatible file (for string arrays-TXT, for others-BIN).";
      break;
    case 5019:
      ErrorMsg = "File is directory, not file.";
      break;
    case 5020:
      ErrorMsg = "File does not exist.";
      break;
    case 5021:
      ErrorMsg = "File cannot be rewritten.";
      break;
    case 5022:
      ErrorMsg = "Wrong directory name.";
      break;
    case 5023:
      ErrorMsg = "Directory does not exist.";
      break;
    case 5024:
      ErrorMsg = "Specified file is not directory.";
      break;
    case 5025:
      ErrorMsg = "Cannot delete directory.";
      break;
    case 5026:
      ErrorMsg = "Cannot clean directory.";
      break;
    case 5027:
      ErrorMsg = "Array resize error.";
      break;
    case 5028:
      ErrorMsg = "String resize error.";
      break;
    case 5029:
      ErrorMsg = "Structure contains strings or dynamic arrays.";
      break;
    case 5200:
      ErrorMsg = "Invalid URL.";
      break;
    case 5201:
      ErrorMsg = "Failed to connect to specified URL.";
      break;
    case 5202:
      ErrorMsg = "Timeout exceeded.";
      break;
    case 5203:
      ErrorMsg = "HTTP request failed.";
      break;
    default:
      ErrorMsg = "Unknown error.";
   }
  return(ErrorMsg);
 }
//+------------------------------------------------------------------+
