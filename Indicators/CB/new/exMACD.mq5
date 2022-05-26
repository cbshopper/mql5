//+------------------------------------------------------------------+
//|                                                         MACD.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2020, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Moving Average Convergence/Divergence"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   6
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_type5   DRAW_HISTOGRAM
#property indicator_type6   DRAW_HISTOGRAM

#property indicator_color1  clrBlack
#property indicator_color2  clrBlack
#property indicator_color3  clrDarkBlue
#property indicator_color4  clrDarkRed
#property indicator_color5  clrLightBlue
#property indicator_color6  clrRed

#property indicator_width1  2
#property indicator_width2  1
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2

#property indicator_label1  "MACD"
#property indicator_label2  "Signal"
#property indicator_label3  "Buy+"
#property indicator_label4  "Sell+"
#property indicator_label5  "Buy-"
#property indicator_label6  "Sell-"



//--- input parameters
input int                InpFastEMA = 12;             // Fast EMA period
input int                InpSlowEMA = 26;             // Slow EMA period
input int                InpSignalSMA = 9;            // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; // Applied price
//--- indicator buffers
double ExtMacdBuffer[];
double ExtSignalBuffer[];
double ExtBuyBuffer[];
double ExtSellBuffer[];
double ExtBuyBuffer2[];
double ExtSellBuffer2[];

int    MacdHandle;
//int    ExtSlowMaHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
 {
//--- indicator buffers mapping
  SetIndexBuffer(0, ExtMacdBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, ExtSignalBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, ExtBuyBuffer, INDICATOR_DATA);
  SetIndexBuffer(3, ExtSellBuffer, INDICATOR_DATA);
  SetIndexBuffer(4, ExtBuyBuffer2, INDICATOR_DATA);
  SetIndexBuffer(5, ExtSellBuffer2, INDICATOR_DATA);
  
  ArraySetAsSeries(ExtMacdBuffer, true);
  ArraySetAsSeries(ExtSignalBuffer, true);
  ArraySetAsSeries(ExtBuyBuffer, true);
  ArraySetAsSeries(ExtSellBuffer, true);
  ArraySetAsSeries(ExtBuyBuffer2, true);
  ArraySetAsSeries(ExtSellBuffer2, true);
   
//--- sets first bar from what index will be drawn
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpSignalSMA - 1);
//--- name for indicator subwindow label
  string short_name = StringFormat("exMACD(%d,%d,%d)", InpFastEMA, InpSlowEMA, InpSignalSMA);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
//--- get MA handles
  MacdHandle = iMACD(NULL, 0, InpFastEMA, InpSlowEMA, InpSignalSMA, InpAppliedPrice);
//  ExtSlowMaHandle=iMA(NULL,0,InpSlowEMA,0,MODE_EMA,InpAppliedPrice);
  IndicatorSetInteger(INDICATOR_DIGITS,2); 
  IndicatorSetDouble(INDICATOR_LEVELVALUE,0,100); 
  
 }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
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
  if(rates_total < InpSignalSMA)
    return(0);
//--- not all data may be calculated
  int calculated = BarsCalculated(MacdHandle);
  if(calculated < rates_total)
   {
    Print("Not all data of MacdHandle is calculated (", calculated, " bars). Error ", GetLastError());
    return(0);
   }
//--- we can copy not all data
  int to_copy;
  if(prev_calculated > rates_total || prev_calculated <= 0)
    to_copy = rates_total-1;
  else
   {
    to_copy = rates_total - prev_calculated+1;
   }
//--- get Fast EMA buffer
  if(IsStopped()) // checking for stop flag
    return(0);
  if(CopyBuffer(MacdHandle, 0, 0, to_copy, ExtMacdBuffer) <= 0)
   {
    Print("Getting fast EMA is failed! Error ", GetLastError());
    return(0);
   }
//--- get SlowSMA buffer
  if(IsStopped()) // checking for stop flag
    return(0);
  if(CopyBuffer(MacdHandle, 1, 0, to_copy, ExtSignalBuffer) <= 0)
   {
    Print("Getting slow SMA is failed! Error ", GetLastError());
    return(0);
   }
//---
  int start = to_copy-1;
//--- calculate MACD
  for(int i = start; i >= 0 && !IsStopped(); i--)
   {
    ExtBuyBuffer[i] = EMPTY_VALUE;
    ExtSellBuffer[i] = EMPTY_VALUE;
    ExtBuyBuffer2[i] = EMPTY_VALUE;
    ExtSellBuffer2[i] = EMPTY_VALUE;
    if(ExtMacdBuffer[i] > 0)
     {
      if(ExtMacdBuffer[i] > ExtMacdBuffer[i + 1])
        ExtBuyBuffer[i] = ExtMacdBuffer[i];
      else
        ExtBuyBuffer2[i] = ExtMacdBuffer[i];
     }
     if(ExtMacdBuffer[i] < 0)
     {
      if(ExtMacdBuffer[i] < ExtMacdBuffer[i + 1])
        ExtSellBuffer[i] = ExtMacdBuffer[i];
      else
        ExtSellBuffer2[i] = ExtMacdBuffer[i];
     }
   }
//--- OnCalculate done. Return new prev_calculated.
  return(rates_total);
 }
//+------------------------------------------------------------------+
