//+------------------------------------------------------------------+
//|                                         SetAllChartsTemplate.mq4 |
//|                                                   Christof Blank |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#property link      ""
#property version   "1.00"
#property strict

#include <cb\CB_SetTemplates.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   long ID =ChartID();
   Copy2Tester(ID);
  }
//+------------------------------------------------------------------+
