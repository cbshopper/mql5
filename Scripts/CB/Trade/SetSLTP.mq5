//+------------------------------------------------------------------+
//|                                                      SetSLTP.mq4 |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof blank"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs
#define SCRIPT
input bool             AllSymbols = true;

#include "..\..\..\Experts\CB\AutoClose\CB_TrailingStop.mq5"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
 {
//---
  if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
    Alert("Autotrade is NOT allowed.");
    return;
   }
// DoMyJob(true, false,0);
  DoMyJob(CheckPositions, CheckOrders, 0);
 }
//+------------------------------------------------------------------+
