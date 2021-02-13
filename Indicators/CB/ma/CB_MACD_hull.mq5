//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property description "Moving Averages bases on NonLagMA"

#include "hullMA.mqh"
#include <MovingAverages.mqh>


//--- indicator settings
#property  indicator_separate_window
#property indicator_plots   2 //must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 2 //must set, can be bigger than necessary
//#property  indicator_buffers 2
//#property  indicator_color1  Silver
//#property  indicator_color2  Red
//#property  indicator_width1  2
//--- indicator parameters
input int InpFastEMA=12;   // Fast EMA Period
input int InpSlowEMA=26;   // Slow EMA Period
input int InpSignalSMA=9;  // Signal SMA Period
input double Divisor = 2.0;
input bool InPoints= true;
//--- indicator buffers
double    ExtMacdBuffer[];
double    ExtSignalBuffer[];
//--- right input parameters flag
bool      ParametersOK=false;
CHull iHullFast;
CHull iHullSlow;
int iMa1=0;
int iMa2=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
  
   ArraySetAsSeries(ExtMacdBuffer,true);
   ArraySetAsSeries(ExtSignalBuffer,true);
   
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- drawing settings

   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,2);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,2);

//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtSignalBuffer,INDICATOR_DATA);

//--- indicator buffers coloring
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrAliceBlue);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrRed);

// --- indicator labeling
   PlotIndexSetString(0,PLOT_LABEL,"HULL MACD");
   PlotIndexSetString(1,PLOT_LABEL,"Signal");

//--- check for input parameters
   if(InpFastEMA<=1 || InpSlowEMA<=1 || InpSignalSMA<=1 || InpFastEMA>=InpSlowEMA)
     {
      Print("Wrong input parameters");
      ParametersOK=false;
      return(INIT_FAILED);
     }
   else
      ParametersOK=true;

//--- name for DataWindow and indicator subwindow label
   string myname = "MACD HULL Test("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,myname);


   iHullFast.init(InpFastEMA,Divisor,PRICE_CLOSE);
   iHullSlow.init(InpSlowEMA,Divisor,PRICE_CLOSE);

   iMa1=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE);
   iMa2=iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE);
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
   int i,limit;
//---
    if (prev_calculated == 0)
    limit = rates_total - InpSlowEMA + 1 ;
   else limit = prev_calculated - 1;

   for(i=limit; i>=0; i--)
     {
        double mafast =  iHullFast.calculate(i)  ;
        double maslow =  iHullSlow.calculate(i);
      //double mafast = GetIndicatorValue(iMa1,i);
      //double maslow = GetIndicatorValue(iMa2,i);

    //  ExtMacdBuffer[i]= mafast ; //high[i]; // mafast;
    //  ExtSignalBuffer[i]=maslow ; // low[i];
    
            ExtMacdBuffer[i] = mafast - maslow;
            if(InPoints)
              {
               ExtMacdBuffer[i] = ExtMacdBuffer[i]/Point();
              }
              
     }
 
//--- signal line counted in the 2-nd buffer
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
