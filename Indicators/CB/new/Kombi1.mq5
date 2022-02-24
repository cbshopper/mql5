//+------------------------------------------------------------------+
//|                                                       Kombi1.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   2


//--- plot Main
#property indicator_label1  "Buy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- plot Signal
#property indicator_label2  "Sell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5

input int                     InpStochastikPeriod           = 5;                                  // Stochastic Period
input int                     InpStockKPeriod               = 3;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpStockLevel                 = 20;                                  // Stochatic Level
input int                     InpRSIPeriod                  = 14;                                  // RSI Period
input int                     InpRSILevel                   = 30;                                  // RSI Level
input int                     InpRVIMaPeriod                = 10;                                  // RVI Ma Period

input int                     InpBarRange                   = 5 ;                                  // Bars within signals
input int                     InpMinScore                   = 2;                                   // minimum Signals in BarRange


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double         SellSignalBuffer[];
double         BuySignalBuffer[];
double         RSIValue[];
double         RVIValue[];
double         STOValue[];
double         RVISignal[];
double         STOSignal[];
double            STOMarker[];
double            RVIMarker[];
double            RSIMarker[];
int            RSIHandle, STOHandle, RVIHandle;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//--- indicator buffers mapping
   SetIndexBuffer(0, BuySignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SellSignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, RSIValue, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, RVIValue, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, STOValue, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, RVISignal, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, STOSignal, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, STOMarker, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, RVIMarker, INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, RSIMarker, INDICATOR_CALCULATIONS);
//--- Define the symbol code for drawing in PLOT_ARROW
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
//--- Set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 25);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -25);
//--- Set as an empty value 0
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);
//--- getting RSI handle
   RSIHandle = iRSI(_Symbol, PERIOD_CURRENT, InpRSIPeriod, PRICE_CLOSE);
   STOHandle = iStochastic(_Symbol, PERIOD_CURRENT, InpStockKPeriod, InpStockDPeriod, 3, MODE_EMA, STO_CLOSECLOSE);
   RVIHandle = iRVI(_Symbol, PERIOD_CURRENT, InpRVIMaPeriod);
//--- setting the arrays in timeseries
   ArraySetAsSeries(BuySignalBuffer, true);
   ArraySetAsSeries(SellSignalBuffer, true);
   ArraySetAsSeries(RSIValue, true);
   ArraySetAsSeries(STOValue, true);
   ArraySetAsSeries(RVIValue, true);
   ArraySetAsSeries(RVISignal, true);
   ArraySetAsSeries(STOSignal, true);
   ArraySetAsSeries(STOMarker, true);
   ArraySetAsSeries(RVIMarker, true);
   ArraySetAsSeries(RSIMarker, true);
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
   int calculated = BarsCalculated(RSIHandle);
   if(calculated < rates_total)
     {
      Print("Not all data of RSIHandle is calculated (", calculated, "bars ). Error", GetLastError());
      //    return(0);
     }
   int to_copy;
   if(prev_calculated > rates_total || prev_calculated < 0)
      to_copy = rates_total;
   else
     {
      to_copy = rates_total - prev_calculated;
      if(prev_calculated > 0)
         to_copy++;
     }
//    to_copy=1000;
   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(RSIHandle, 0, 0, to_copy, RSIValue) <= 0)
     {
      Print("Getting RSIValue is failed! Error", GetLastError());
      return(0);
     }
   if(CopyBuffer(RVIHandle, 0, 0, to_copy, RVIValue) <= 0)
     {
      Print("Getting RVIValue is failed! Error", GetLastError());
      return(0);
     }
   if(CopyBuffer(RVIHandle, 1, 0, to_copy, RVISignal) <= 0)
     {
      Print("Getting RVISignal is failed! Error", GetLastError());
      return(0);
     }
   if(CopyBuffer(STOHandle, 0, 0, to_copy, STOValue) <= 0)
     {
      Print("Getting STOValue is failed! Error", GetLastError());
      return(0);
     }
   if(CopyBuffer(STOHandle, 1, 0, to_copy, STOSignal) <= 0)
     {
      Print("Getting STOSignal is failed! Error", GetLastError());
      return(0);
     }
   int limit = BarsCalculated(STOHandle) - 2;
   limit = to_copy - 2;
   for(int shift = limit; shift >= 0; shift--)
     {
      STOMarker[shift] = 0;
      RVIMarker[shift] = 0;
      RSIMarker[shift] = 0;
      if(STOValue[shift + 1] > STOSignal[shift + 1] && STOValue[shift] < STOSignal[shift] && STOValue[shift] > 100 - InpStockLevel)
         STOMarker[shift] = -1;
      if(STOValue[shift + 1] < STOSignal[shift + 1] && STOValue[shift] > STOSignal[shift] && STOValue[shift] < InpStockLevel)
         STOMarker[shift] = 1;
   
      if(RVIValue[shift + 1] > RVISignal[shift + 1] && RVIValue[shift] < RVISignal[shift] && RVIValue[shift + 1] > RVIValue[shift])
         RVIMarker[shift] = -1;
      if(RVIValue[shift + 1] < RVISignal[shift + 1] && RVIValue[shift] > RVISignal[shift] && RVIValue[shift + 1] < RVIValue[shift])
         RVIMarker[shift] = 1;
     
      if(RSIValue[shift + 1] > 100 - InpRSILevel && RSIValue[shift] > 100 - InpRSILevel && RSIValue[shift + 1] > RSIValue[shift ])
         RSIMarker[shift] = -1;
      if(RSIValue[shift + 1] < InpRSILevel && RSIValue[shift] < InpRSILevel && RSIValue[shift + 1] < RSIValue[shift ])
         RSIMarker[shift] = 1;
     }
   for(int shift = limit - InpBarRange; shift >= 0; shift--)
     {
      BuySignalBuffer[shift]   = EMPTY_VALUE;
      SellSignalBuffer[shift] = EMPTY_VALUE;
     }
   for(int shift = limit - InpBarRange; shift >= 0; shift--)
     {
      int scale = 0;
      for(int i = 0; i < InpBarRange; i++)
        {
         scale += (int)(RVIMarker[shift + i] + STOMarker[shift + i]  + RSIMarker[shift + i]);
        }
      Print(__FUNCTION__, " scale=", scale, " shift=", shift);
      if(scale > InpMinScore)
        {
         BuySignalBuffer[shift] = iOpen(NULL, PERIOD_CURRENT, shift);
         shift = shift - InpBarRange;
        }
      if(scale < -InpMinScore)
        {
         SellSignalBuffer[shift] = iOpen(NULL, PERIOD_CURRENT, shift);
         shift = shift - InpBarRange;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
