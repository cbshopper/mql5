//+------------------------------------------------------------------+
//|                                           CB_IndicatorHelper.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#ifndef CB_INDICATOR_HELPER
#define CB_INDICATOR_HELPER
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIndicatorValue(int handle, int index)
  {
   double ret = GetIndicatorBufferValue(handle, index, 0);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIndicatorBufferValue(int handle, int index, int bufferno)
  {
   double ret = -1;
   double vals[2];
   int errno = 0;
  
   if(CopyBuffer(handle, bufferno, index, 2, vals) > 0)
     {
      ret = vals[0];
 //     Print(__FUNCTION__, " ret=", ret, "vals=", vals[0], " index=",index, " bufferno=",bufferno);
     }
   else
     {
      errno = GetLastError();
      Print(__FUNCTION__, " Error=", errno);
     }
   return ret;
  }

#endif
//+------------------------------------------------------------------+
