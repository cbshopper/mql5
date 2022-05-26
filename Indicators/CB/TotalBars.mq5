//+------------------------------------------------------------------+
//|                                                    TotalBars.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
double Values[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- indicator buffers mapping
  ArraySetAsSeries(Values, true);
  SetIndexBuffer(0, Values, INDICATOR_DATA);

//---
  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
 {
//---
  int limit;
  if(prev_calculated > rates_total || prev_calculated <= 0)
    limit = rates_total - 1;
  else
   {
    limit = rates_total - prev_calculated + 1;
   }
  if(limit <= 0)
    limit = 1;
  Values[0] = limit;
  
   for(int shift = limit; shift >= 0; shift--)
      {
         //--- hull moving average 1st buffer
         Values[shift] = limit;
      }
      
//--- return value of prev_calculated for next call
  return(rates_total);
    return(0);
 }
//+------------------------------------------------------------------+
