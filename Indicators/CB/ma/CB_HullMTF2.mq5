//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


#property version   "1.00"


#include  <CB/hullMA.mqh>
CHull iHull;
//CHull iHull2;

//The Hull Moving Average (HMA), developed by Alan Hull, is an extreme-
//ly fast and smooth moving average that almost eliminates lag altoge-
//ther and manages to improve smoothing at the same time.To calculate
//it, firts, you have to calculate a difference between two LWMA of
//periods p/2 and p and then calculate another LWMA from this differen-
//ce but with a period of square root of p

//--- indicator settings
#property indicator_chart_window
#property indicator_plots   2 //must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 3 //must set, can be bigger than necessary
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  2
#property indicator_type2   DRAW_LINE
#property indicator_color2  Blue
#property indicator_width2  2


//---- input parameters
input  ENUM_TIMEFRAMES    TimeFrame = PERIOD_CURRENT;  // Timeframe
input int                 HMAPeriod = 12;         // Period
input ENUM_APPLIED_PRICE  InpMAPrice = 5;         // Price
input double              Divisor = 2.0;
input int     Filter         = 0;
input bool    Color          = true;
input int     ColorBarBack   = 0;

//---- indicator buffers
double MABuffer[];
double UpBuffer[];

string indicatorFileName;
int iCust = 0;
ENUM_TIMEFRAMES mTimeFrame;
//--- right input parameters flag
#define COUNT_BUFFER 2
#define TREND_BUFFER 3
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
   {
    IndicatorSetInteger(INDICATOR_DIGITS, Digits());
    mTimeFrame         = fmax(TimeFrame, _Period);
    ArraySetAsSeries(MABuffer, true);
    ArraySetAsSeries(UpBuffer, true);
    SetIndexBuffer(0, MABuffer, INDICATOR_DATA);
    SetIndexBuffer(1, UpBuffer, INDICATOR_DATA);
// SetIndexBuffer(COUNT_BUFFER, barcount, INDICATOR_CALCULATIONS);
//--- drawing settings
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetString(0, PLOT_LABEL, EnumToString(mTimeFrame) + ":HMA MTF2");
    PlotIndexSetString(1, PLOT_LABEL, "Up");
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, HMAPeriod);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, HMAPeriod);
    indicatorFileName = "CB\\MA\\CB_Hull";
    /* Parameters of CB_HULL
    input int                 HMAPeriod = 12;         // Period
    input ENUM_APPLIED_PRICE  InpMAPrice = 5;         // Price
    input double              Divisor = 2.0;
    input int     Filter         = 0;
    input bool    Color          = true;
    input int     ColorBarBack   = 0;
    */
    iCust = iCustom(NULL, mTimeFrame, indicatorFileName,  HMAPeriod, InpMAPrice, Divisor, Filter, Color, 0);
//        trend[shift]= iCustom(NULL,mTimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0);
//  iCust = iMA(NULL,mTimeFrame,HMAPeriod,0,MODE_EMA,InpMAPrice);
    if(iCust < 0)
       {
        Comment("Init Failed!");
        return(INIT_FAILED);
       }
//--- name for indicator label
    string myname = StringFormat("%s (%s,%d,%1.1f", MQLInfoString(MQL_PROGRAM_NAME), EnumToString(mTimeFrame), HMAPeriod, Divisor);
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
    IndicatorRelease(iCust);
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
    long k, n, shift;
    int calculated = BarsCalculated(iCust);
    if(calculated < 0)
       {
        Print("Not all data of Indicator are calculated (", calculated, "bars ). Error", GetLastError());
        return(0);
       }
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(time, true);
//---
    if(rates_total <= HMAPeriod)
        return(0);
//  limit = MathMin(rates_total-prev_calculated-1,rates_total-2);
//--- we can copy not all data
    if(prev_calculated > rates_total || prev_calculated <= 0)
        limit = rates_total - 2;
    else
       {
        limit = rates_total - prev_calculated + 1;
       }
    if(limit <= 0)
        limit = 1;
    if(mTimeFrame != _Period)
       {
        int barcount = calculated;
        //     barcount =   GetIndicatorBufferValue(iCust, 1, 0); // iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,COUNT_BUFFER,0);
        //if(barcount < 0)
        //   {
        //    Print(__FUNCTION__, ": mTimeFrame=", mTimeFrame, " limit=", limit); ;
        //    barcount = 100;   // case of errior
        //   }
        int limit2 = MathMax(limit, MathMin(Bars(NULL, 0) - 1, barcount * mTimeFrame / Period()));
        for(shift = limit2; shift >= 0; shift--)
           {
            MABuffer[shift] = EMPTY_VALUE;
            UpBuffer[shift] = EMPTY_VALUE;
            int y = iBarShift(NULL, mTimeFrame, time[shift], false);
            if(y > -1)
               {
                double val, up, tr;
                val  = GetIndicatorBufferValue(iCust, y, 0); // iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,0,y);
                up =  GetIndicatorBufferValue(iCust, y, 1); // iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,TREND_BUFFER,y);
                //   double tr =  GetIndicatorBufferValue(iCust, y, TREND_BUFFER); // iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,TREND_BUFFER,y);
                if(val > 0 && up > 0)
                   {
                    MABuffer[shift] = val;
                    UpBuffer[shift] = up;
                    // glätten
                    datetime ftime = iTime(NULL, mTimeFrame, y);
                    for(n = 1; shift + n < iBars(_Symbol, mTimeFrame) - 1 && time[shift + n] >= ftime; n++)
                        continue;
                    for(k = 1; k < n; k++)
                       {
                        MABuffer[shift + k] = MABuffer[shift]  + (MABuffer[shift + n] - MABuffer[shift]) * k / n;
                        if(UpBuffer[shift + k ] != EMPTY_VALUE)
                            UpBuffer[shift + k] = MABuffer[shift + k];
                       }
                   }
               }
           }
       }
    else
       {
        //  Print(__FUNCTION__,": CALCULATIONG: TimeFrame=",_Period, " limit=",limit); ;
        //--- hull moving average 1st buffer
        for(shift = limit; shift >= 0; shift--)
           {
            //  barcount[shift] = limit;
            MABuffer[shift] = EMPTY_VALUE;
            UpBuffer[shift] = EMPTY_VALUE;
            double val  = GetIndicatorBufferValue(iCust, shift, 0);
            double up = GetIndicatorBufferValue(iCust, shift, 1);
            double tr =    GetIndicatorBufferValue(iCust, shift, TREND_BUFFER);
            MABuffer[shift] = val ; //open[shift]; // hullval;
            UpBuffer[shift] = up;
            //   Print(__FUNCTION__,": CALCULATIONG: TimeFrame=",_Period," shift=", shift," Time=",time[shift], " Hull=",hullval);
           }
       }
//--- done
    return(rates_total);
   }
//+------------------------------------------------------------------+
