//+------------------------------------------------------------------+
//|                                         SetAllChartsTemplate.mq4 |
//|                                                   Christof Blank |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#include <cb\CB_SetTemplates.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
    long  CID=ChartID();

    SetAllZoom(CID);
/*
   bool ok=false;
   long  CID=ChartID();

   ENUM_TIMEFRAMES  TS=ChartPeriod(CID);
   long  ID=ChartFirst();
 
   while(ID!=-1)
     {
      if(ID!=CID)
        {
         string sym = ChartSymbol(ID);
         ok=ChartSetSymbolPeriod(ID,sym,TS);
         if(!ok)
           {
            Alert(StringConcatenate("Failed to apply Timeframe ",TS," error code: ",GetLastError()));
            break;
           }
        }
      ID=ChartNext(ID);
     }
*/
  }
//+------------------------------------------------------------------+
