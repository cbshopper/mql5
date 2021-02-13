//+------------------------------------------------------------------+
//|                                           CB_IndicatorHelper.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIndicatorValue(int handle, int index)
  {
   double ret = GetIndicatorBufferValue(handle,index,0);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIndicatorBufferValue(int handle, int index,int bufferno)
  {
   double ret =0;
   double vals[1];
   int errno=0;
   if(CopyBuffer(handle,bufferno,index,1,vals) > 0)
     {
      ret = vals[0];
     }
     else
     {
         errno = GetLastError();
     }
   return ret;
  }