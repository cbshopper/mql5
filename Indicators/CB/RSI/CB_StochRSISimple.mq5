//+------------------------------------------------------------------+
//|                                                    Stoch RSI.mq5 |
//|                                    Copyright 2020, Hossein Nouri |
//|                           https://www.mql5.com/en/users/hsnnouri |
//+------------------------------------------------------------------+
//#include <CB/CB_Drawing.mqh>
//#include <CB/CB_Notify.mqh>
#include <CB/CB_IndicatorHelper.mqh>

#define MARKER_LABEL "sigSTORSI"

#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 4
#property indicator_plots  2
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- plot Main
#property indicator_label1  "Value (K)"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal (D)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "RSI"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot Signal
#property indicator_label4  "STOonRSI"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2


#include <CB/calcrsisto.mqh>
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double         KBuffer[];
double         DBuffer[];
double         RSIBuffer[];
double         StochBuffer[];
int            RSIHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
   {
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//--- indicator buffers mapping
    SetIndexBuffer(0, KBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, DBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, RSIBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(3, StochBuffer, INDICATOR_CALCULATIONS);
//--- getting RSI handle
    RSIHandle = iRSI(Symbol(), PERIOD_CURRENT, InpRSIPeriod, InpRSIAppliedPrice);
//--- setting the arrays in timeseries
ArraySetAsSeries(KBuffer, true);
ArraySetAsSeries(DBuffer, true);
ArraySetAsSeries(RSIBuffer, true);
ArraySetAsSeries(StochBuffer, true);
//---
    return(INIT_SUCCEEDED);
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
   {
    ObjectsDeleteAll(0, MARKER_LABEL);
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
    int ret = CopyBuffer(RSIHandle, 0, 0, to_copy, RSIBuffer);
    if(ret <= 0)
       {
        Print("Getting RSIBuffer is failed! Error", GetLastError());
        return(0);
       }
    int limit = prev_calculated == 0 ? rates_total - (InpRSIPeriod + 1) : rates_total - prev_calculated + 1;
//if(limit > rates_total - InpRSIPeriod + 1)
//    limit =  rates_total - InpRSIPeriod + 1;
    Print(__FUNCTION__, ": ************** limit=", limit, " prev_calculated=", prev_calculated, " rates_total=", rates_total, " calculated=", calculated, " to_copy=", to_copy, " ret=", ret);
// for(int i = limit; i >= 0; i--)
    /*
    limit -=1;
    double SB[], KB[], DB[];
    CalcValues(limit, RSIBuffer, SB, KB, DB);
    for(int i = 0; i < limit; i++)
       {
        StochBuffer[i] = SB[i];
        KBuffer[i] = KB[i];
        DBuffer[i] = DB[i];
        Print(__FUNCTION__, ": i=", i, " stochBuffer[i]=", StochBuffer[i], " KBuffer[i]=", KBuffer[i], " DBuffer[i]=", DBuffer[i], " Time=", iTime(Symbol(),PERIOD_CURRENT,i));
       }
       */

//  for(int i = 0; i < limit; i++)
    for(int i = limit; i >= 0; i--)
       {
        if(i < rates_total - (InpRSIPeriod + 1))
            StochBuffer[i] = Stoch(RSIBuffer, RSIBuffer, RSIBuffer, InpStochastikPeriod, i, rates_total);

        //      if(i <  rates_total - InpStockKPeriod + 1)
        if(StochBuffer[i + InpStockKPeriod - 1] != EMPTY_VALUE)
            KBuffer[i] = SimpleMA(i, InpStockKPeriod, StochBuffer, rates_total);
        //      if(i <  rates_total - InpStockDPeriod + 1)
        if(KBuffer[i + InpStockDPeriod - 1] != EMPTY_VALUE)
            DBuffer[i] = SimpleMA(i, InpStockDPeriod, KBuffer, rates_total);
        Print(__FUNCTION__, ": i=", i,  " RSIBuffer=", RSIBuffer[i], " StochBuffer[i]=", StochBuffer[i], " Time=", iTime(Symbol(), PERIOD_CURRENT, i));
        Print(__FUNCTION__, ": i=", i,  " Value[i]=", KBuffer[i], " Signal[i]=", DBuffer[i], " Time=", iTime(Symbol(), PERIOD_CURRENT, i));

       }

//--- return value of prev_calculated for next call
    return(rates_total);
   }


/**

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalcValues(int limit, double &rSIBuffer[], double &stochBuffer[], double &kBuffer[], double &dBuffer[] )
   {

   const int rates_total = limit;
    ArrayResize(stochBuffer, limit);
    ArrayResize(kBuffer, limit);
    ArrayResize(dBuffer, limit);
    ArraySetAsSeries(stochBuffer, true);
    ArraySetAsSeries(kBuffer, true);
    ArraySetAsSeries(dBuffer, true);

    for(int i = 0; i < limit; i++)
       {
        //   if(i < rates_total - (InpRSIPeriod + 2))
        stochBuffer[i] = Stoch(rSIBuffer, rSIBuffer, rSIBuffer, InpStochastikPeriod, i, rates_total);
 //       Print(__FUNCTION__, ": i=", i, " StochBuffer[i]=", stochBuffer[i], " RSIBuffer=", rSIBuffer[i], " Time=", TimeAsString(i));
       }
    for(int i = limit; i >= 0; i--)
       {
        //   if(i < rates_total - (InpRSIPeriod + 2))
        //  StochBuffer[i] = Stoch(RSIBuffer, RSIBuffer, RSIBuffer, InpStochastikPeriod, i, rates_total);
        if(i <  rates_total - InpStockKPeriod + 1)
            if(stochBuffer[i + InpStockKPeriod - 1] != EMPTY_VALUE)
                kBuffer[i] = SimpleMA(i, InpStockKPeriod, stochBuffer, rates_total);
        if(i <  rates_total - InpStockDPeriod + 1)
            if(kBuffer[i + InpStockDPeriod - 1] != EMPTY_VALUE)
                dBuffer[i] = SimpleMA(i, InpStockDPeriod, kBuffer, rates_total);
       // Print(__FUNCTION__, ": i=", i, " stochBuffer[i]=", stochBuffer[i], " kBuffer[i]=", kBuffer[i], " dBuffer[i]=", dBuffer[i]);
       }
    return limit;
   }



//+------------------------------------------------------------------+
//| calculating stochastic                                           |
//+------------------------------------------------------------------+
double Stoch(const double &source[], double &high[], double &low[], int length, int shift, const int &rates_total)
   {
    if(shift + length > rates_total)
        return EMPTY_VALUE;
    double Highest = Highest(high, length, shift);
    double Lowest = Lowest(low, length, shift);
    if(Highest - Lowest == 0)
        return EMPTY_VALUE;
    return 100 * (source[shift] - Lowest) / (Highest - Lowest);
   }
//+------------------------------------------------------------------+
//| find lowest value in prev. X periods                             |
//+------------------------------------------------------------------+
double Lowest(double &low[], int length, int shift)
   {
    double Result = 0;
    if(shift + length > ArraySize(low) - 1)
        length = ArraySize(low) - shift - 1;
    for(int i = shift; i <= shift + length; i++)
       {
        if(Result == 0 || (low[i] < Result && low[i] != EMPTY_VALUE))
           {
            Result = low[i];
           }
       }
    return Result;
   }
//+------------------------------------------------------------------+
//| find highest value in prev. X periods                            |
//+------------------------------------------------------------------+
double Highest(double &high[], int length, int shift)
   {
    double Result = 0;
    if(shift + length > ArraySize(high) - 1)
        length = ArraySize(high) - shift - 1;;
    for(int i = shift; i <= shift + length; i++)
       {
        if(Result == 0 || (high[i] > Result && high[i] != EMPTY_VALUE))
           {
            Result = high[i];
           }
       }
    return Result;
   }
//+------------------------------------------------------------------+
//| calculating simple moving average of an array                    |
//+------------------------------------------------------------------+
double SimpleMA(const int position, const int period, const double &price[], const int &rates_total)
   {
//---
    double result = 0.0;
    if(position <= rates_total - period && period > 0)
       {
        for(int i = 0; i < period; i++)
           {
            if(price[position + i] != EMPTY_VALUE)
               {
                result += price[position + i];
               }
           }
        result /= period;
       }
    return(result);
   }
//+------------------------------------------------------------------+
*/
