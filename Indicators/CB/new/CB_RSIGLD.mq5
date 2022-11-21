//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property description "Indicator Template"
#define MYNAME "RSI+GLD"
#include <CB/CB_IndicatorHelper.mqh>
#include <MovingAverages.mqh>

#include <CB/CB_Drawing.mqh>
#include <CB/CB_Notify.mqh>
#define MARKER_LABEL "RSIGDL"

//--- indicator settings

#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1     50.0
#property indicator_level2     70.0
#property indicator_level3     30.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT

#property indicator_separate_window
#property indicator_plots 5 //8 // must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 5 //9 // must set, can be bigger than necessary
//--- indicator parameters
input int    rsiperiod = 5; //RSI Period
input int    maperiod = 20;
input bool  DrawBuySellMarker = true;
input int    RSILevel = 50; // RSI Signal Level


//--- indicator buffers
double    ExtValueBuffer[];
double    ExtSignalBuffer[];
//double    ExtValueBuffer[];


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
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Value");
   bufferindex++;
   bufferindex = 1;
   ArraySetAsSeries(ExtSignalBuffer, true);
   SetIndexBuffer(bufferindex, ExtSignalBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrBlue);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Line1");
   /*
   bufferindex++;
   bufferindex=2;
   ArraySetAsSeries(ExtValueBuffer, true);
   SetIndexBuffer(bufferindex, ExtValueBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Line2");
   bufferindex++;
   */
//--- check for input parameters
   if(rsiperiod <= 1 || maperiod <= 1)
     {
      Print("Wrong input parameters");
      return(INIT_FAILED);
     }
//--- name for DataWindow and indicator subwindow label
   string myname = MYNAME + "(" + IntegerToString(rsiperiod) + "," + IntegerToString(maperiod)  + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, myname);
//handle0 = iATR(NULL, PERIOD_CURRENT, period);
   handle0 = iRSI(NULL, PERIOD_CURRENT, rsiperiod, PRICE_CLOSE);      // iMA(NULL, PERIOD_CURRENT, period, 0, MODE_EMA, PRICE_CLOSE);
//--- initialization done
   ObjectsDeleteAll(0, MARKER_LABEL);
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
// ObjectsDeleteAll(0, MARKER_LABEL);
   int calculated = BarsCalculated(handle0);
   if(calculated < rates_total)
     {
      Print("Not all data of RSIHandle is calculated (", calculated, "bars ). Error", GetLastError());
      return(0);
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
   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(handle0, 0, 0, to_copy, ExtValueBuffer) <= 0)
     {
      Print("Getting RSIBuffer is failed! Error", GetLastError());
      return(0);
     }
//  SimpleMAOnBuffer(rates_total,prev_calculated,0,maperiod,ExtValueBuffer,ExtSignalBuffer);
// for(i = pos; i < limit && !IsStopped(); i++)
   for(i = calculated - maperiod - 1 ; i >= 0 && !IsStopped(); i--)
     {
      ExtSignalBuffer[i] = SimpleMAx(i, maperiod, ExtValueBuffer);
     
      if(DrawBuySellMarker)
        {
         if(ExtValueBuffer[i + 1] >= ExtSignalBuffer[i + 1] &&
            ExtValueBuffer[i] < ExtSignalBuffer[i] &&
            ExtSignalBuffer[i + 1] >= 100 - RSILevel &&
            ExtValueBuffer[i + 1] > ExtValueBuffer[i]
           )
           {
            int bar = i;
            // SELL
            DrawArrowXL(MARKER_LABEL + bar, bar + 1, iOpen(NULL, 0, bar), 234, 15, clrRed);
            if(bar == 0)
               DoAlertX(bar, "RSISTO: SELL");
           }
         if(ExtValueBuffer[i + 1] <= ExtSignalBuffer[i + 1] &&
            ExtValueBuffer[i] > ExtSignalBuffer[i] &&
            ExtSignalBuffer[i + 1] <= RSILevel &&
            ExtValueBuffer[i + 1] < ExtValueBuffer[i]
           )
           {
            int bar = i;
            // BUY
            DrawArrowXL(MARKER_LABEL + bar, bar + 1, iOpen(NULL, 0, bar), 233, 15, clrBlue);
            if(bar == 0)
               DoAlertX(bar, "RSISTO: BUY");
           }
        }
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
double SimpleMAx(const int position, const int period, const double &price[])
  {
   double result = 0.0;
   ArraySetAsSeries(price, true);
//--- check period
   for(int i = 0; i < period; i++)
      result += price[position + i];
   result /= period;
   return(result);
  }
//+------------------------------------------------------------------+
