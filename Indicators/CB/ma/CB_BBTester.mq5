//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property description "Bollinger Bands based on Hull MA"

#include <CB\\hullMA.mqh>
#include <MovingAverages.mqh>


//--- indicator settings
#property  indicator_chart_window
#property indicator_plots 3 //8 // must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 3 //9 // must set, can be bigger than necessary

//--  MA-Types
enum MA_MODES
{
   _MODE_SMA, _MODE_EMA,_MODE_SMMA,_MODE_LWMA,_MODE_HULL, _MODE_DEMA, _MODE_AMA
};


//--- indicator parameters
input int    BBPeriod = 20; // MA Period for Hull & Band
input double Deviation = 2.0;
input MA_MODES MAMode = MODE_SMA;  
input ENUM_MA_METHOD StdDevMAMode = MODE_SMA;
input bool  UseATR=false;
int Divisor = 2;

int    ArrowDistance = 1;

//input int    TrendPeriod = 100; // Trend-Period


//--- indicator buffers
double    ExtMiddleBand[];
double    ExtUpperBand[];
double    ExtLowerBand[];

int strdev_ptr = 0;
int atr_ptr = 0;
int ma_ptr = 0;
int dev_ptr=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   MathSrand(clrRed);
   int clr = clrRed; //rand();
   int bufferindex = 0;
   ArraySetAsSeries(ExtMiddleBand, true);
   SetIndexBuffer(bufferindex, ExtMiddleBand, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrBrown);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Middle Band");
   bufferindex++;
   ArraySetAsSeries(ExtUpperBand, true);
   SetIndexBuffer(bufferindex, ExtUpperBand, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clr);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Upper Band");
   bufferindex++;
   ArraySetAsSeries(ExtLowerBand, true);
   SetIndexBuffer(bufferindex, ExtLowerBand, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clr);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Lower Band");
   bufferindex++;
   
   /*
   ArraySetAsSeries(ExtTriggerLineSlow, true);
   SetIndexBuffer(bufferindex, ExtTriggerLineSlow, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrBlue);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Triggerline slow");
   bufferindex++;
   ArraySetAsSeries(ExtTriggerLineFast, true);
   SetIndexBuffer(bufferindex, ExtTriggerLineFast, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Trendline fast");
   bufferindex++;
   ArraySetAsSeries(SignalBUY, true);
   SetIndexBuffer(bufferindex, SignalBUY, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 5);
   PlotIndexSetInteger(bufferindex, PLOT_ARROW, 117);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrDarkBlue);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Buy Signal");
   bufferindex++;
   ArraySetAsSeries(SignalSELL, true);
   SetIndexBuffer(bufferindex, SignalSELL, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 5);
   PlotIndexSetInteger(bufferindex, PLOT_ARROW, 117);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrHotPink);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Sell Signal");
   bufferindex++;
   ArraySetAsSeries(ExtTrendLine, true);
   SetIndexBuffer(bufferindex, ExtTrendLine, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrBlack);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Trend Line");
   bufferindex++;
   ArraySetAsSeries(FillA, true);
   SetIndexBuffer(bufferindex, FillA, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_FILLING);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Outer Area");
   bufferindex++;
   ArraySetAsSeries(FillB, true);
  
   SetIndexBuffer(bufferindex, FillB, INDICATOR_DATA);
   
    */

//--- check for input parameters
   if(BBPeriod <= 1)
     {
      Print("Wrong input parameters");
      return(INIT_FAILED);
     }
//--- name for DataWindow and indicator subwindow label
   string myname = "BolleringBandTeser(" + IntegerToString(BBPeriod) + "," +  DoubleToString(Deviation, 1)  + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, myname);
  
  
  
   strdev_ptr = iStdDev(NULL, PERIOD_CURRENT, BBPeriod, 0, StdDevMAMode, PRICE_CLOSE);
   atr_ptr = iATR(NULL, PERIOD_CURRENT, BBPeriod);
   
   if (UseATR)
   {
     dev_ptr = atr_ptr;
   }
   else
   {
     dev_ptr = strdev_ptr;
   }
   
   switch (MAMode)
   {
      case _MODE_SMA: ma_ptr = iMA(NULL,PERIOD_CURRENT,BBPeriod,0,MODE_SMA,PRICE_CLOSE); break;
      case _MODE_EMA:  ma_ptr = iMA(NULL,PERIOD_CURRENT,BBPeriod,0,MODE_EMA,PRICE_CLOSE);break;
      case _MODE_SMMA: ma_ptr = iMA(NULL,PERIOD_CURRENT,BBPeriod,0,MODE_SMMA,PRICE_CLOSE); break;
      case _MODE_LWMA: ma_ptr = iMA(NULL,PERIOD_CURRENT,BBPeriod,0,MODE_LWMA,PRICE_CLOSE); break;
      case _MODE_HULL: ma_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_Hull", BBPeriod, 0, PRICE_CLOSE, Divisor, 0, 0, 0); break; 
      case _MODE_DEMA:  ma_ptr = iDEMA(NULL,PERIOD_CURRENT,BBPeriod,0,PRICE_MEDIAN);;break;
      case _MODE_AMA: ma_ptr = iAMA(NULL, PERIOD_CURRENT, BBPeriod, 2, 30, 0, PRICE_CLOSE);break;
   }
   
   
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
//---
   if(prev_calculated == 0)
      limit = rates_total - BBPeriod + 1 ;
   else
      limit = prev_calculated - 1;
//for(i = limit; i >= 0; i--)
   int pos = prev_calculated - 1;
   pos = 0;
   
   
   for(i = pos; i < limit && !IsStopped(); i++)
     {
     
     
      double stddev =  GetIndicatorValue(dev_ptr, i);
      double ma = GetIndicatorValue(ma_ptr, i);
      ExtMiddleBand[i] = ma;
      ExtUpperBand[i] = ma + Deviation * stddev ;
      ExtLowerBand[i] = ma - Deviation * stddev ;

     }
//--- done
   return(rates_total);
  }
