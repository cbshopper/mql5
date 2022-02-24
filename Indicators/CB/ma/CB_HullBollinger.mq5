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
#property indicator_plots 9 //8 // must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 10 //9 // must set, can be bigger than necessary

//--- indicator parameters
input int    MAPeriod = 40; // MA Period for Hull & Band
input int    TriggerPeriod = 10; // Trigger-Period
input int    TriggerPeriodDelta = 2; // Trigger-Period Delta
input double Divisor = 2.0;
input double Deviation = 1.0;
input int    MinDiff = 1;
input int    TrendPeriod = 20;
input bool   CheckTrend=false;
int    ArrowDistance = 1;
int    StdDevPeriod = MAPeriod; //10;

//input int    TrendPeriod = 100; // Trend-Period


//--- indicator buffers
double    ExtMABuffer[];
double    ExtUpperBand[];
double    ExtLowerBand[];
double    ExtTriggerLineSlow[];
double    ExtTriggerLineFast[];
double    ExtTrendLine[];

//double    ExtTrendLine[];
double    SignalBUY[];
double    SignalSELL[];
double    FillA[];
double    FillB[];

//CHull HullMA;
//CHull TriggerMA;
//CHull TrendMA;
int strdev_ptr = 0;
int atr_ptr = 0;
int hull_ptr = 0;
int triggerslow_ptr = 0;
int triggerfast_ptr = 0;
int trend_ptr = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   int bufferindex = 0;
   ArraySetAsSeries(ExtMABuffer, true);
   SetIndexBuffer(bufferindex, ExtMABuffer, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrBrown);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Hull MA");
   bufferindex++;
   ArraySetAsSeries(ExtUpperBand, true);
   SetIndexBuffer(bufferindex, ExtUpperBand, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Upper Band");
   bufferindex++;
   ArraySetAsSeries(ExtLowerBand, true);
   SetIndexBuffer(bufferindex, ExtLowerBand, INDICATOR_DATA);
   PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetString(bufferindex, PLOT_LABEL, "Lower Band");
   bufferindex++;
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
// PlotIndexSetInteger(bufferindex, PLOT_DRAW_TYPE, DRAW_FILLING);
// PlotIndexSetInteger(bufferindex, PLOT_LINE_COLOR, clrHotPink);
// PlotIndexSetString(bufferindex, PLOT_LABEL, "Attention");
//--- check for input parameters
   if(MAPeriod <= 1)
     {
      Print("Wrong input parameters");
      return(INIT_FAILED);
     }
//--- name for DataWindow and indicator subwindow label
   string myname = "HullBollingerBands(" + IntegerToString(MAPeriod) + "," + DoubleToString(Divisor, 1) + "," + DoubleToString(Deviation, 1) + "," + IntegerToString(TriggerPeriod) + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, myname);
// HullMA.init(MAPeriod, Divisor, PRICE_CLOSE);
// TriggerMA.init(TriggerPeriod, Divisor, PRICE_CLOSE);
//TrendMA.init(TrendPeriod, Divisor, PRICE_CLOSE);
   strdev_ptr = iStdDev(NULL, PERIOD_CURRENT, StdDevPeriod, 0, MODE_EMA, PRICE_CLOSE);
   atr_ptr = iATR(NULL, PERIOD_CURRENT, 48);
//trend_ptr = iDEMA(NULL, PERIOD_CURRENT, TrendPeriod, 0, PRICE_CLOSE);
   hull_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_Hull", MAPeriod, 0, PRICE_CLOSE, Divisor, 0, 0, 0);
   triggerslow_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_Hull", TriggerPeriod, 0, PRICE_CLOSE, Divisor, 0, 0, 0);
   triggerfast_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_Hull", TriggerPeriod - TriggerPeriodDelta, 0, PRICE_CLOSE, Divisor, 0, 0, 0);
   trend_ptr = iAMA(NULL, PERIOD_CURRENT, TrendPeriod, 2, 30, 0, PRICE_CLOSE);
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
      limit = rates_total - MAPeriod + 1 ;
   else
      limit = prev_calculated - 1;
//for(i = limit; i >= 0; i--)
   int pos = prev_calculated - 1;
   pos = 0;
   for(i = pos; i < limit && !IsStopped(); i++)
     {
      double stddev =  GetIndicatorValue(strdev_ptr, i);
      double trend0 = GetIndicatorValue(trend_ptr, i);
      //     double trigger =  TriggerMA.calculate(i);
      double ma = GetIndicatorValue(hull_ptr, i);
      double triggerslow =  GetIndicatorValue(triggerslow_ptr, i);
      double triggerfast =  GetIndicatorValue(triggerfast_ptr, i);
      ExtMABuffer[i] = ma;
      double factor = 1;
      /*
      if(i > 0)
        {
         factor = 1- (MathAbs((ExtMABuffer[i - 1] - ExtMABuffer[i]) / ExtMABuffer[i]) );
         Print(__FUNCTION__," factor=",factor);
        }
        */
      ExtUpperBand[i] = ma + Deviation * stddev * factor;
      ExtLowerBand[i] = ma - Deviation * stddev * factor;
      ExtTriggerLineSlow[i] = triggerslow;
      ExtTriggerLineFast[i] = triggerfast;
      ExtTrendLine[i] = trend0;
      FillA[i] = 0;
      FillB[i] = 0;
      if(triggerslow > ExtUpperBand[i])
        {
         FillB[i] = ExtUpperBand[i];
         FillA[i] = triggerslow;
        }
      if(triggerslow < ExtLowerBand[i])
        {
         FillA[i] = ExtLowerBand[i];
         FillB[i] = triggerslow;
        }
      // Signals for Buy and Sell - optional
      SignalSELL[i] = 0;
      SignalBUY[i] = 0;
      if(ExtTriggerLineSlow[i] > 0 &&  ExtTriggerLineSlow[i + 1] > 0 &&  ExtTriggerLineSlow[i + 2] > 0)
        {
         int signal = 0;
         //signal = GetSignal(ExtTriggerLineSlow[i], ExtTriggerLineSlow[i + 1], ExtTriggerLineSlow[i + 2], ExtLowerBand[i], ExtLowerBand[i + 1], ExtUpperBand[i], ExtUpperBand[i + 1]);
         signal = GetSignal(ExtTriggerLineSlow[i],
                            ExtTriggerLineSlow[i + 1],
                            ExtTriggerLineFast[i],
                            ExtTriggerLineFast[i + 1],
                            ExtLowerBand[i + 1],
                            ExtUpperBand[i + 1],
                            ExtTrendLine[i],
                            ExtTrendLine[i + 1]);
         double Offset = ArrowDistance * GetIndicatorValue(atr_ptr, i);
         if(signal > 0)
           {
            //       if(trend0 > ExtTrendLine[i + 1])
            //  SignalBUY[i] = iOpen(NULL, PERIOD_CURRENT, i); // ExtLowerBand[i] - Offset; //pos ; //ND(pos+ArrowDistancePoints*POINT);
            SignalBUY[i] =  ExtTriggerLineSlow[i] - Offset; //pos ; //ND(pos+ArrowDistancePoints*POINT);
           }
         if(signal < 0)
           {
            //       if(trend0 < ExtTrendLine[i + 1])
            //  SignalSELL[i] = iOpen(NULL, PERIOD_CURRENT, i); //ExtUpperBand[i] + Offset; ; //ND(pos-ArrowDistancePoints*POINT);
            SignalSELL[i] = ExtTriggerLineSlow[i] + Offset; ; //ND(pos-ArrowDistancePoints*POINT);
           }
        }
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
int GetSignal(double trig0, double trig1, double trig2, double lo0, double lo1, double up0, double up1, double trend0, double trend1)
  {
   double offset = MinDiff * Point();
   bool enable_buy = (trig1 <= trig0 - offset && trig1 <= trig2 - offset ); //&& trig1 <= lo1); // && ( trend0 > trend1 || !CheckTrend));
   bool enable_sell = (trig1 >= trig0 + offset  && trig1 >= trig2 + offset); // && trig1 >= up1); // && (trend0 < trend1 || !CheckTrend));
   int ret = 0;
   if(enable_buy)
      ret = 1;
   if(enable_sell)
      ret = -1;
   return ret;
  }
//+------------------------------------------------------------------+
int GetSignal(double tslow0, double tslow1, double tfast0, double tfast1, double lo1,  double up1, double trend0, double trend1)
  {
   double offset = MinDiff * Point();
   bool enable_buy = (tfast0 > tslow0 && tfast1 < tslow1-offset && tslow1 < lo1  && ( trend0 > trend1 || !CheckTrend));
   bool enable_sell = (tfast0 < tslow0 && tfast1 > tslow1+offset && tslow1 > up1  && (trend0 < trend1 || !CheckTrend));
   int ret = 0;
   if(enable_buy)
      ret = 1;
   if(enable_sell)
      ret = -1;
   return ret;
  }
//+------------------------------------------------------------------+
