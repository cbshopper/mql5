#include <cb\CB_Commons.mqh>
#property script_show_inputs
input  string comment="";
extern double Sell_Lots = 0.1;
extern int Sell_Slippage = 3;
extern bool SetStop=true;
extern bool SetTP=true;
extern int STOPpips = 10;     // max. Risk in pips
extern int TPpips = 20;   // Take Profit in pips

//+------------------------------------------------------------------+
//| script "trading for all money"                                   |
//+------------------------------------------------------------------+
int OnStart()
  {
//----
   string SL =  DoubleToStr(Sell_Lots,2);
   string SM =  DoubleToStr(Bid,Digits());
   STOPpips=CheckStopLossPips(Symbol(),STOPpips);
   double stoploss=0;
   double TP=0;
   if(SetStop) stoploss=NormalizeDouble(Bid + STOPpips*Point(), Digits());
   if(SetTP) TP= NormalizeDouble(Bid -TPpips*Point(), Digits());
 
   if(MessageBox("SELL: " + OrderMsg(Sell_Lots,stoploss,STOPpips,TP,TPpips),
      "Script",MB_YESNO|MB_ICONQUESTION)!=IDYES) return(1);              
//----
  // if(SetStop) stoploss=Bid + STOPpips*Point;
  // if(SetTP) TP= Bid -TPpis*Point;
   
   int ticket=OrderSend(Symbol(),OP_SELL,Sell_Lots,Bid,Sell_Slippage,stoploss,TP,comment,255,0,CLR_NONE);
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