//+------------------------------------------------------------------+
//|                                                 Modify SL TP.mq4 |
//+------------------------------------------------------------------+
#property strict
#property script_show_inputs
#include <cb\CB_OrderFunctions.mqh>
input int StopLoss=20; // StopLoss Points
input int TakeProfit=20; //TakeProfit Points
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int     Slippage=0.0;
   color   clr=clrNONE;


   //if(Digits()==5 || Digits()==3)
   //  {
   //   TakeProfit*=10;
   //   StopLoss*=10;
   //  }
   if(OrdersTotal()==0)  return;

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){Alert("Autotrade is NOT allowed.");  return;}

   if(StopLoss==0 && TakeProfit==0){Alert(" No SL/TP need to be modified");return;}

  
        OrderMachine.OrderSetSLTP(0,StopLoss,TakeProfit);
 


  }
//+------------------------------------------------------------------+
