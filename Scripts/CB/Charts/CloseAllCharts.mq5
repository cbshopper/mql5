//+------------------------------------------------------------------+
//|                                               CloseAllCharts.mq4 |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof blank"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   bool ok=false;
   long  CID=ChartID();

   long  ID=ChartFirst();
   while(ID!=-1)
     {
      if(ID!=CID)
        {
         ok = ChartClose(ID);
         if(!ok)
           {
            Alert("Failed to close Chart ID: "+ ID + "\nerror code: " + GetLastError());
            break;
           }
        }
      ID=ChartNext(ID);
     }
     ok = ChartClose(CID);
  }
//+------------------------------------------------------------------+
