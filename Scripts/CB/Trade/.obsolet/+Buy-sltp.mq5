//#include <stdlib.mqh>
//#include <WinUser32.mqh>
#include <cb\CB_Commons.mqh>
#include <cb\CBUtils5.mqh>
#property script_show_inputs

// Script: 0-1-Buy   

// Default Inputs: Start
input  string comment="";
extern double Buy_Lots  = 0.1;
extern int Buy_Slippage = 3;
extern bool SetStop=true;
extern bool SetTP=true;
extern int STOPpips=10;     // max. Risk in pips
extern int TPpips=20;   // Take Profit in pips

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                       // Default Inputs: Start

int OnStart()
  {

   string BL =  DoubleToStr(Buy_Lots,2);
   string BM =  DoubleToStr(Ask,Digits());
   STOPpips=CheckStopLossPips(Symbol(),STOPpips);
   double stoploss=0;
   double TP=0;
   if(SetStop) stoploss= NormalizeDouble(Ask-STOPpips*Point(),Digits());
   if(SetTP) TP=NormalizeDouble(Ask+TPpips*Point(),Digits());
   string comment="";
   string defaultvalue="";
   if(MessageBox("BUY : "+ OrderMsg(Buy_Lots,stoploss,STOPpips,TP,TPpips),
      "Script",MB_YESNO|MB_ICONQUESTION)!=IDYES) return(1);
//----
  // if(SetStop) stoploss=Ask-STOPpips*Point;
  // if(SetTP) TP=Ask+TPpis*Point;

   int ticket=OrderSend(Symbol(),OP_BUY,Buy_Lots,Ask,Buy_Slippage,stoploss,TP,comment,255,0,CLR_NONE);
   if(ticket<1)
     {
      int error=GetLastError();
      Print("Error = ",ErrorDescription(error));
      return 1;
     }
//----
   OrderPrint();
   return(0);
  }
//+------------------------------------------------------------------+