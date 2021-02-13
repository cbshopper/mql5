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
   SetTemplates2This();
/*************
   bool ok=false;
   long  CID=ChartID();

   long  ID=ChartFirst();
   string fn="_current.tpl";

   ok=ChartSaveTemplate(CID,fn);

   while(ID!=-1)
     {
      if(ID!=CID)
        {
         ok=ChartApplyTemplate(ID,fn);
         if(!ok)
           {
            Alert(StringConcatenate("Failed to apply: ",fn," error code: ",GetLastError()));
            break;
           }
        }
      ID=ChartNext(ID);
     }
     ***************/

  }
//+------------------------------------------------------------------+
