//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property description "Stop Lines based on ATR"
#include <CB/CB_IndicatorHelper.mqh>



//--- indicator settings
#property  indicator_chart_window
#property indicator_plots 2 //8 // must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 3 //9 // must set, can be bigger than necessary


//--- indicator parameters
input int    ATRPeriod = 10; //ATR Period
input double ATRMultiplier = 1.0;
//input int    TrendPeriod = 100; // Trend-Period


//--- indicator buffers
double    ExtATRBuffer[];
double    ExtUpperBand[];
double    ExtLowerBand[];


int atr_ptr = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   int bufferindex = 0;
   ArraySetAsSeries(ExtUpperBand, true);
   SetIndexBuffer(bufferindex, ExtUpperBand, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Upper Stop");
   bufferindex++;
   ArraySetAsSeries(ExtLowerBand, true);
   SetIndexBuffer(bufferindex, ExtLowerBand, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Lower Stop");
   bufferindex++;
   ArraySetAsSeries(ExtATRBuffer, true);
   SetIndexBuffer(bufferindex, ExtATRBuffer, INDICATOR_CALCULATIONS);
//  PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
// PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
// PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrBrown);
// PlotIndexSetString(bufferindex, PLOT_LABEL, "Hull MA");
   bufferindex++;
//--- check for input parameters
   if(ATRPeriod <= 1)
     {
      Print("Wrong input parameters");
      return(INIT_FAILED);
     }
//--- name for DataWindow and indicator subwindow label
   string myname = "ATRStop(" + IntegerToString(ATRPeriod) + "," + DoubleToString(ATRMultiplier, 1)  + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, myname);
   atr_ptr = iATR(NULL, PERIOD_CURRENT, ATRPeriod);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int i, limit;
   ArraySetAsSeries(open, true);
//---
   if(prev_calculated == 0)
      limit = rates_total - ATRPeriod + 1 ;
   else
      limit = prev_calculated - 1;
   int pos = 0;
   for(i = pos; i < limit && !IsStopped(); i++)
     {
      ExtATRBuffer[i] = GetIndicatorBufferValue(atr_ptr, i, 0);
      ExtUpperBand[i] = open[i] + ExtATRBuffer[i] * ATRMultiplier;
      ExtLowerBand[i] = open[i] - ExtATRBuffer[i] * ATRMultiplier;
     }
//--- done
   return(rates_total);
  }
