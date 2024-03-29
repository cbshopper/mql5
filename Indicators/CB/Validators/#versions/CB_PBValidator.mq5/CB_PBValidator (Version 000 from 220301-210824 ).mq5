//+------------------------------------------------------------------+
//|                                                    Validator.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 10
#property indicator_plots   8

//--- plot OpenBUY
#property indicator_label1  "OpenBuy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- plot SELL
#property indicator_label2  "OpenSell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5

//--- plot BUY
#property indicator_label3  "CLoseBuy"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot SELL
#property indicator_label4  "CloseSell"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
/*
//--- plot RSI
#property indicator_label5  "RSI"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_DASHDOT
#property indicator_width5  2

//--- plot SLOWMA
#property indicator_label6  "SLOWMA"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_DASHDOT
#property indicator_width6  2
*/
input int                 bb_period = 20;
input int                 bb_shift = 0;
input double              bb_deviation = 1.5;
input int                 PBRange = 20;
input bool                UseOC = false;
input double              PBLevel = 3.0;
input int                 OrderBarCount = 4;

int indicator_ptr = 0;
int bb_ptr = 0;

#include <CB/CB_Drawing.mqh>
#include <CB/CB_Validator.mqh>

double         PBValues[];
double         BBUpperValues[];
double         BBMidleValues[];
double         BBLowerValues[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- indicator buffers mapping
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  int first = InitSignalBuffers();
//** BUFFERS for used Indictor(s)
//--- indicator buffers mapping
  SetIndexBuffer(first + 0, PBValues, INDICATOR_CALCULATIONS);
  first++;
  SetIndexBuffer(first + 0, BBUpperValues, INDICATOR_DATA);
  PlotIndexSetString(first, PLOT_LABEL, "Upper");
  PlotIndexSetInteger(first, PLOT_DRAW_TYPE, DRAW_LINE);
  PlotIndexSetInteger(first, PLOT_LINE_COLOR, clrBlack);
  PlotIndexSetInteger(first, PLOT_LINE_STYLE, STYLE_SOLID);
  first++;
  SetIndexBuffer(first + 0, BBMidleValues, INDICATOR_DATA);
  PlotIndexSetString(first, PLOT_LABEL, "Middle");
  PlotIndexSetInteger(first, PLOT_DRAW_TYPE, DRAW_LINE);
  PlotIndexSetInteger(first, PLOT_LINE_COLOR, clrBlack);
  PlotIndexSetInteger(first, PLOT_LINE_STYLE, STYLE_SOLID);
  first++;
  SetIndexBuffer(first + 0, BBLowerValues, INDICATOR_DATA);
  PlotIndexSetString(first, PLOT_LABEL, "Lower");
  PlotIndexSetInteger(first, PLOT_DRAW_TYPE, DRAW_LINE);
  PlotIndexSetInteger(first, PLOT_LINE_COLOR, clrBlack);
  PlotIndexSetInteger(first, PLOT_LINE_STYLE, STYLE_SOLID);
//--- setting the arrays in timeseries
  ArraySetAsSeries(PBValues, true);
  ArraySetAsSeries(BBUpperValues, true);
  ArraySetAsSeries(BBMidleValues, true);
  ArraySetAsSeries(BBLowerValues, true);
//  ArraySetAsSeries(MA2Values, true);
//---
  indicator_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/new/PowerBar", PBRange, UseOC);
  bb_ptr = iBands(NULL, PERIOD_CURRENT, bb_period, bb_shift, bb_deviation, PRICE_CLOSE);
//     StartOffset=0;   // wg. Signal an richtiger Position
  return(INIT_SUCCEEDED);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnDeinit(
  const int  reason         // deinitialization reason code
)
 {
  DeleteTLines();
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
  ArraySetAsSeries(open, true);
  ArraySetAsSeries(close, true);
  int calculated = BarsCalculated(indicator_ptr);
  if(calculated < rates_total)
   {
    return(0);
   }
  /*
  calculated = BarsCalculated(ma2_ptr);
  if(calculated < rates_total)
  {
   return(0);
  }
  */
  int to_copy;
  if(prev_calculated > rates_total || prev_calculated < 0)
    to_copy = rates_total;
  else
   {
    to_copy = rates_total - prev_calculated;
    if(prev_calculated > 0)
      to_copy++;
   }
//   to_copy = rates_total;
//    to_copy=1000;
// Print(__FILE__, __FUNCTION__," rates_total=",rates_total," prev_calculated=",prev_calculated," to_copy=", to_copy, " calculated=",calculated );
//if(IsStopped())
//   return(0); //Checking for stop flag
  if(CopyBuffer(indicator_ptr, 0, 0, to_copy, PBValues) <= 0)
   {
    Print("Getting data_ptr(0) is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(bb_ptr, 0, 0, to_copy, BBUpperValues) <= 0)
   {
    Print("Getting data_ptr(1) is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(bb_ptr, 1, 0, to_copy, BBMidleValues) <= 0)
   {
    Print("Getting data_ptr(1) is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(bb_ptr, 2, 0, to_copy,  BBLowerValues) <= 0)
   {
    Print("Getting data_ptr(1) is failed! Error", GetLastError());
    return(0);
   }
  int limit = calculated - 2 ;
  for(int shift = limit; shift > 0; shift--)
   {
    BuySignalOpenBuffer[shift] = EMPTY_VALUE;
    SellSignalOpenBuffer[shift] = EMPTY_VALUE;
    BuySignalCloseBuffer[shift] = EMPTY_VALUE;
    SellSignalCloseBuffer[shift] = EMPTY_VALUE;
    int index = shift;
    double val = PBValues[index];
    double close_value = close[shift];
    double open_value=open[shift];
    if(val > PBLevel)    // invert stategie
     {
      if(open_value < close_value)     // up candle
       {
        if(close_value < BBLowerValues[shift])   // close unter BBLo ==> SELL
         {
          SellSignalOpenBuffer[shift] = close_value;
         }
        if(open_value < BBUpperValues[shift] && close_value > BBUpperValues[shift])  // close > BBup ==> BUY
         {
          BuySignalOpenBuffer[shift] = close_value;
         }
        if(open_value > BBLowerValues[shift]   && close_value < BBUpperValues[shift])   // Candle between == BUY
         {
          BuySignalOpenBuffer[shift] = close_value;
         }
        if(open_value < BBLowerValues[shift]   && close_value> BBLowerValues[shift])    // Candle crosses BBLo ==> BUY
         {
          BuySignalOpenBuffer[shift] = close_value;
         }
         
                 //if(close_value > BBLowerValues[shift]  && close_value < BBMidleValues[shift])
        // {
        //  BuySignalOpenBuffer[shift] = close_value;
        // }

       }
      else                               // dn Candle
       {
        if(close_value > BBUpperValues[shift])   // close  über BBHi ==> BUY
         {
          BuySignalOpenBuffer[shift] = close_value;
         }
        if(close_value < BBLowerValues[shift] && open_value > BBLowerValues[shift])   // close < BBLo ==> SELL
         {
          SellSignalOpenBuffer[shift] = close_value;
         }
        if(open_value < BBUpperValues[shift]   && close_value > BBLowerValues[shift]) // Candle between == SELL
         {
          SellSignalOpenBuffer[shift] = close_value;
         }
        if(open_value > BBUpperValues[shift]   && close_value < BBUpperValues[shift])   // Candle crosses BBHI ==> SELL
         {
          SellSignalOpenBuffer[shift] = close_value;
         }
         
                 //if(close_value < BBUpperValues[shift]  && close_value > BBMidleValues[shift])
        // {
        //  BuySignalOpenBuffer[shift] = close_value;
        // }

       }
     }
   }
  for(int shift = limit; shift > 0; shift--)
   {
    int closebar = shift > OrderBarCount ? shift - OrderBarCount : 1;
    if(BuySignalOpenBuffer[shift] != EMPTY_VALUE)
     {
      BuySignalCloseBuffer[closebar] = open[closebar];
     }
    if(SellSignalOpenBuffer[shift] != EMPTY_VALUE)
     {
      SellSignalCloseBuffer[closebar] = open[closebar];
     }
   }
  DrawOrderLines();
//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
