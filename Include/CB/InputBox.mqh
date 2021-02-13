//+------------------------------------------------------------------+
//|                                                     InputBox.mqh |
//|                                                   Christof Blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
#import "inputbox.dll"
string InputBoxText(string title,string prompt,string def);
string InputBoxDoubleStr(string title,string prompt,string def);
int InputBoxInt(string title,string prompt,int def);
#import

string InputBoxDouble(string title, string prompt, double def)
{
   string defstr = (string) def;
   string ret = InputBoxText(title,prompt,defstr);
   return ret;
}