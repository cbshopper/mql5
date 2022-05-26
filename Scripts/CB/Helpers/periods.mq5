//+------------------------------------------------------------------+
//|                                                      periods.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
 {
//---
  Print("H1", "=", PERIOD_H1);
  Print("H2", "=", PERIOD_H2);
  Print("H4", "=", PERIOD_H4);
  Print("D1", "=", PERIOD_D1);
  Print("W1", "=", PERIOD_W1);
  Print("MN1", "=", PERIOD_MN1);
 }
//+------------------------------------------------------------------+
