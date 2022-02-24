//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


#property version   "1.00"

#include <CB/CB_Utils.mqh>
#include <CB/hullMA.mqh>

//CHull iHull2;

//The Hull Moving Average (HMA), developed by Alan Hull, is an extreme-
//ly fast and smooth moving average that almost eliminates lag altoge-
//ther and manages to improve smoothing at the same time.To calculate
//it, firts, you have to calculate a difference between two LWMA of
//periods p/2 and p and then calculate another LWMA from this differen-
//ce but with a period of square root of p

//--- indicator settings
#property indicator_chart_window
#property indicator_plots   3 //must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 5 //must set, can be bigger than necessary



//---- input parameters
input int                 HMAPeriod = 12;         // Period
//input int                 HMAShift = 0;           // Shift
input ENUM_APPLIED_PRICE  InpMAPrice = 5;         // Price
input double              Divisor = 2.0;
input int     Filter         = 0;
input bool    Color          = true;
input int     ColorBarBack   = 0;

//---- indicator buffers
double MABuffer[];
double UpBuffer[];
double trend[];

int iCust = 0;
int testMA = 0;
CHull iHull;
CHullEA iHullEA;
ENUM_TIMEFRAMES mTimeFrame;
//--- right input parameters flag
#define COUNT_BUFFER 3
#define TREND_BUFFER 2
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   ArraySetAsSeries(MABuffer, true);
   ArraySetAsSeries(UpBuffer, true);
   ArraySetAsSeries(trend, true);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
//--- drawing settings
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   SetIndexBuffer(0, MABuffer, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrBlue);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   SetIndexBuffer(1, UpBuffer, INDICATOR_DATA);
   ArraySetAsSeries(UpBuffer, true);
   SetIndexBuffer(TREND_BUFFER, trend, INDICATOR_CALCULATIONS);
   PlotIndexSetString(0, PLOT_LABEL, timeFrameToString(mTimeFrame) + ":Hull Moving Average");
   PlotIndexSetString(1, PLOT_LABEL, "Up");
   iHull.init(HMAPeriod, Divisor, InpMAPrice);
   iHullEA.init(HMAPeriod, Divisor, InpMAPrice);
   testMA = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE);
   string indicatorFileName = "CB\\MA\\" + MQLInfoString(MQL_PROGRAM_NAME);
//--- name for indicator label
   string myname = StringFormat("%s (%s,%d,%1.1f,%d", indicatorFileName, timeFrameToString(mTimeFrame), HMAPeriod, Divisor);//, HMAShift);
   IndicatorSetString(INDICATOR_SHORTNAME, myname);
//--- check for input parameters
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Hull Moving Average                                              |
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
   long limit;
   long shift;
//---
   if(rates_total <= HMAPeriod)
      return(0);
   limit = MathMin(rates_total - prev_calculated - 1, rates_total - 2);
  
 //  Print(__FILE__, __FUNCTION__," rates_total=",rates_total," prev_calculated=",prev_calculated," limit=", limit );
   for(shift = limit; shift >= 0; shift--)
     {
      //--- hull moving average 1st buffer
      MABuffer[shift] = EMPTY_VALUE;
      UpBuffer[shift] = EMPTY_VALUE;
      double hullval = iHull.calculate(shift);  //iHull.calculate(price,shift,Bars);
      if (hullval>0)
      {
      MABuffer[shift] = hullval;
      }
      else
      {
         MABuffer[shift]= MABuffer[shift + 1];
      }
      if(Filter > 0)
        {
         if(MathAbs(MABuffer[shift] - MABuffer[shift + 1]) < Filter * Point())
            MABuffer[shift] = MABuffer[shift + 1];
        }
      trend[shift] = trend[shift + 1];
      if(MABuffer[shift] - MABuffer[shift + 1] > 0) // Filter * Point())
         trend[shift] = 1;
      if(MABuffer[shift + 1] - MABuffer[shift] > 0) //Filter * Point())
         trend[shift] = -1;
     }
   if(Color)
     {
      if (limit < ColorBarBack) limit = ColorBarBack+1;
      for(shift = limit - ColorBarBack; shift >= 0; shift--)
        {
         //    Print(__FUNCTION__,": shift=",shift," trend=",trend[shift]);
         if(trend[shift] > 0)
           {
            UpBuffer[shift] = MABuffer[shift];
            if(trend[shift + ColorBarBack] < 0)
               UpBuffer[shift + ColorBarBack] = MABuffer[shift + ColorBarBack];
           }
        }
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
