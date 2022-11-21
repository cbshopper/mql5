//+------------------------------------------------------------------+
//|                                                    Stoch RSI.mq5 |
//|                                    Copyright 2020, Hossein Nouri |
//|                           https://www.mql5.com/en/users/hsnnouri |
//+------------------------------------------------------------------+
#include <CB/CB_Drawing.mqh>
#include <CB/CB_Notify.mqh>
#include <CB/CB_IndicatorHelper.mqh>

#define MARKER_LABEL "sigSTORSI"

#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 6
#property indicator_plots  4
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

#property indicator_label3  "BuySignal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDarkBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot Signal
#property indicator_label4  "SellSignal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrDarkRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2

input int                     InpStockKPeriod               = 3;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpRSIPeriod                  = 14;                                  // RSI Period
input int                     InpStochastikPeriod           = 14;                                  // Stochastic Period
input ENUM_APPLIED_PRICE      InpRSIAppliedPrice            = PRICE_CLOSE;                         // RSI Applied Price
input bool                    DrawBuySellMarker             = false;
input int                     FilterStochRSILevel                   = 15;
input int                     FilterFastMa                  = 20;
input int                     FilterSlowMa                  = 50;
//input int                     RSIFilterLevel                = 40;
//input int                     RSIMindiff                    = 2;
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double         KBuffer[];
double         DBuffer[];
double         RSIBuffer[];
double         StochBuffer[];
double         SignalBuy[];
double         SignalSell[];
int            RSIHandle;
int            MaHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
   {
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//--- indicator buffers mapping
    SetIndexBuffer(0, KBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, DBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, SignalBuy, INDICATOR_DATA);
    SetIndexBuffer(3, SignalSell, INDICATOR_DATA);
    SetIndexBuffer(4, RSIBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, StochBuffer, INDICATOR_CALCULATIONS);
//--- getting RSI handle
    RSIHandle = iRSI(Symbol(), PERIOD_CURRENT, InpRSIPeriod, InpRSIAppliedPrice);
//--- setting the arrays in timeseries
    ArraySetAsSeries(KBuffer, true);
    ArraySetAsSeries(DBuffer, true);
    ArraySetAsSeries(RSIBuffer, true);
    ArraySetAsSeries(StochBuffer, true);
    ArraySetAsSeries(SignalBuy, true);
    ArraySetAsSeries(SignalSell, true);
    ObjectsDeleteAll(0, MARKER_LABEL);
    MaHandle = iMACD(NULL, PERIOD_CURRENT, FilterFastMa, FilterSlowMa, 9, PRICE_CLOSE);
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
    ObjectsDeleteAll(0, "sigRSISTRO");
    int calculated = BarsCalculated(RSIHandle);
    if(calculated < rates_total)
       {
        Print("Not all data of RSIHandle is calculated (", calculated, "bars ). Error", GetLastError());
        return(0);
       }
    int c = BarsCalculated(MaHandle);
    if(c < rates_total)
       {
        Print("Not all data of MaHandle is calculated (", calculated, "bars ). Error", GetLastError());
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
    if(CopyBuffer(RSIHandle, 0, 0, to_copy, RSIBuffer) <= 0)
       {
        Print("Getting RSIBuffer is failed! Error", GetLastError());
        return(0);
       }
    int limit = prev_calculated == 0 ? rates_total - (InpRSIPeriod + 1) : rates_total - prev_calculated + 1;
    for(int i = limit; i >= 0; i--)
       {
        if(i < rates_total - (InpRSIPeriod + 2))
            StochBuffer[i] = Stoch(RSIBuffer, RSIBuffer, RSIBuffer, InpStochastikPeriod, i, rates_total);
        if(StochBuffer[i + InpStockKPeriod - 1] != EMPTY_VALUE)
            KBuffer[i] = SimpleMA(i, InpStockKPeriod, StochBuffer, rates_total);
        if(KBuffer[i + InpStockDPeriod - 1] != EMPTY_VALUE)
            DBuffer[i] = SimpleMA(i, InpStockDPeriod, KBuffer, rates_total);
        int signal = GetSignal(i);
        if(signal < 0)
            SignalSell[i] = signal < -1 ? 50 : 100;
        else
            SignalSell[i] = EMPTY_VALUE;
        if(signal > 0)
            SignalBuy[i] = signal > 1 ? 50 : 100;
        else
            SignalBuy[i] = EMPTY_VALUE;
        if(DrawBuySellMarker)
           {
            int bar = i;
            // SELL
            if(SignalSell[i] == 100)
               {
                DrawArrowXL(MARKER_LABEL + bar, bar + 1, iOpen(NULL, 0, bar), 234, 15, clrRed);
                if(bar == 0)
                    DoAlertX(bar, "RSISTO: SELL");
               }
            if(SignalSell[i] == 50)
               {
                DrawArrowXL(MARKER_LABEL + bar, bar + 1, iOpen(NULL, 0, bar), 108, 15, clrRed);
               }
            if(SignalBuy[i] == 100)
               {
                DrawArrowXL(MARKER_LABEL + bar, bar + 1, iOpen(NULL, 0, bar), 233, 15, clrBlue);
                if(bar == 0)
                    DoAlertX(bar, "RSISTO: BUY");
               }
            if(SignalBuy[i] == 50)
               {
                DrawArrowXL(MARKER_LABEL + bar, bar + 1, iOpen(NULL, 0, bar), 108, 15, clrBlue);
               }
           }
       }
//--- return value of prev_calculated for next call
    return(rates_total);
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

// -1: strong sell, 1: strong buy, -2 weak sell, 2 weak buy
int GetSignal(int index)
   {
    int ret = 0;
    int trend = 0;
    double macd0 = GetIndicatorBufferValue(MaHandle, index, 0);
    double macd1 = GetIndicatorBufferValue(MaHandle, index + 1, 0);
    double diff = MathAbs(macd0) - MathAbs(macd1);
    if(macd0 > 0)
        trend = 1;
    if(macd0 < 0)
        trend = -1;
  //      diff=1;
//      if(trend != 0)        Print(__FUNCTION__, ": Trend=", trend);
    if(KBuffer[index + 1] > DBuffer[index + 1] &&
       KBuffer[index] <= DBuffer[index] &&
       KBuffer[index] <  KBuffer[index+1] &&
   //    DBuffer[index] <  DBuffer[index+1] &&
       KBuffer[index + 1] >= 100 - FilterStochRSILevel //&&
      )
       {
        int bar = index;
        // SELL
        if(trend < 0 && diff > 0)
           {
            ret = -1;
           }
        else
           {
            ret = -2;
           }
        if(bar == 0)
            DoAlertX(bar, "RSISTO: SELL");
       }
    if(KBuffer[index + 1] < DBuffer[index + 1] &&
       KBuffer[index] >= DBuffer[index] &&
       KBuffer[index] >  KBuffer[index+1] &&
     //  DBuffer[index] >  DBuffer[index+1] &&
       KBuffer[index + 1] <= FilterStochRSILevel //&&
      )
       {
        int bar = index;
        if(trend > 0 && diff > 0)
           {
            ret  = 1;
           }
        else
           {
            ret = 2;
           }
       }
    return ret;
   }
//+------------------------------------------------------------------+
