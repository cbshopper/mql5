//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property description "Indicator Template"
#define MYNAME "Template"
#include <CB/CB_IndicatorHelper.mqh>



//--- indicator settings
#property  indicator_chart_window
#property indicator_plots 5 //8 // must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 5 //9 // must set, can be bigger than necessary
//--- indicator parameters
input int    period = 20; //ATR Period
input double factor = 10.0;
//input int    TrendPeriod = 100; // Trend-Period


//--- indicator buffers
double    ExtValueBuffer[];
double    ExtUpperBand[];
double    ExtLowerBand[];


int handle0 = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
  
   int bufferindex = 0;
   ArraySetAsSeries(ExtValueBuffer, true);
   SetIndexBuffer(bufferindex, ExtValueBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrBlack);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Value");
   bufferindex++;
   bufferindex=1;
   
   ArraySetAsSeries(ExtUpperBand, true);
   SetIndexBuffer(bufferindex, ExtUpperBand, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrBlue);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Line1");
   
   bufferindex++;
   bufferindex=2;
   ArraySetAsSeries(ExtLowerBand, true);
   SetIndexBuffer(bufferindex, ExtLowerBand, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Line2");
   bufferindex++;
   
//--- check for input parameters
   if(period <= 1)
     {
      Print("Wrong input parameters");
      return(INIT_FAILED);
     }
//--- name for DataWindow and indicator subwindow label
   string myname = MYNAME + "(" + IntegerToString(period) + "," + DoubleToString(factor, 1)  + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, myname);
 //handle0 = iATR(NULL, PERIOD_CURRENT, period);
   handle0 = iMA(NULL, PERIOD_CURRENT, period, 0, MODE_EMA, PRICE_CLOSE);
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
      limit = rates_total - period + 1 ;
   else
      limit = prev_calculated - 1;
//for(i = limit; i >= 0; i--)
   int pos = prev_calculated - 1;
   pos = 0;
   for(i = pos; i < limit && !IsStopped(); i++)
     {
      ExtValueBuffer[i] = GetIndicatorBufferValue(handle0, i, 0);
;
      ExtUpperBand[i] = ExtValueBuffer[i] + factor * Point() * 10; // open[i] ;//+ ExtValueBuffer[i] * factor;
      ExtLowerBand[i] = ExtValueBuffer[i] - factor * Point() * 10; // open[i] ;//- ExtValueBuffer[i] * factor;
     // ExtUpperBand[i] = val + ExtValueBuffer[i] * factor;
     //ExtLowerBand[i] = val - ExtValueBuffer[i] * factor;
    

     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
