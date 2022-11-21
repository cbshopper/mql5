//+------------------------------------------------------------------+
//|                                                         MACD.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//--- indicator settings
#property indicator_separate_window



#property indicator_level1     0
#property indicator_levelcolor clrBlack
#property indicator_levelstyle STYLE_DOT


#property indicator_buffers 6
#property indicator_plots   6
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_ARROW
#property indicator_type6   DRAW_ARROW




#property indicator_color1  clrGreen
#property indicator_color2  clrBlack
#property indicator_color3  clrDarkBlue
#property indicator_color4  clrDarkRed
#property indicator_color5  clrBlue
#property indicator_color6  clrRed

#property indicator_width1  2
#property indicator_width2  1
#property indicator_width3  2
#property indicator_width4  1
#property indicator_width5  4
#property indicator_width6  4

#property indicator_label1  "MACD1"
#property indicator_label2  "Signal1"
#property indicator_label3  "MACD2"
#property indicator_label4  "Signal2"
#property indicator_label5  "Buy"
#property indicator_label6  "Sell"


#include <CB/CB_Drawing.mqh>
#include <CB/CB_Notify.mqh>
//--- input parameters
input int                InpFastEMA1 = 10;             // Fast EMA1 period
input int                InpSlowEMA1 = 20;             // Slow EMA1 period
input int                InpSignalSMA1 = 9;            // Signal SMA1 period

input int                InpFastEMA2 = 50;             // Fast EMA2 period
input int                InpSlowEMA2 = 100;             // Slow EMA2 period
input int                InpSignalSMA2 = 9;            // Signal SMA2 period


input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; // Applied price
input bool DrawBuySellMarker = false;
//--- indicator buffers
double Macd1Buffer[];
double Signal1Buffer[];
double Macd2Buffer[];
double Signal2Buffer[];
double BuyBuffer[];
double SellBuffer[];
double BuyBuffer2[];
double SellBuffer2[];

int    Macd1Handle;
int    Macd2Handle;

//int    SlowMaHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, Macd1Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, Signal1Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, Macd2Buffer, INDICATOR_DATA);
   SetIndexBuffer(3, Signal2Buffer, INDICATOR_DATA);
   SetIndexBuffer(4, BuyBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, SellBuffer, INDICATOR_DATA);
   ArraySetAsSeries(Macd1Buffer, true);
   ArraySetAsSeries(Signal1Buffer, true);
   ArraySetAsSeries(Macd2Buffer, true);
   ArraySetAsSeries(Signal2Buffer, true);
   ArraySetAsSeries(BuyBuffer, true);
   ArraySetAsSeries(SellBuffer, true);
   ArrayInitialize(Macd1Buffer, EMPTY_VALUE);
   ArrayInitialize(Signal1Buffer, EMPTY_VALUE);
   ArrayInitialize(Signal2Buffer, EMPTY_VALUE);
   ArrayInitialize(Signal2Buffer, EMPTY_VALUE);
   ArrayInitialize(BuyBuffer, EMPTY_VALUE);
   ArrayInitialize(SellBuffer, EMPTY_VALUE);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpSignalSMA2 - 1);
//--- name for indicator subwindow label
   string short_name = StringFormat("2MACD(%d,%d,%d - %d,%d,%d)", InpFastEMA1, InpSlowEMA1, InpSignalSMA1, InpFastEMA2, InpSlowEMA2, InpSignalSMA2);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
//--- get MA handles
   Macd1Handle = iMACD(NULL, 0, InpFastEMA1, InpSlowEMA1, InpSignalSMA1, InpAppliedPrice);
   Macd2Handle = iMACD(NULL, 0, InpFastEMA2, InpSlowEMA2, InpSignalSMA2, InpAppliedPrice);
//  SlowMaHandle=iMA(NULL,0,InpSlowEMA,0,MODE_EMA,InpAppliedPrice);
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 100);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "sigexMACD");
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
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
   if(rates_total < InpSignalSMA2)
      return(0);
//--- not all data may be calculated
   int calculated = MathMin(BarsCalculated(Macd1Handle), BarsCalculated(Macd2Handle));
   if(calculated < rates_total)
     {
      Print("Not all data of MacdHandle is calculated (", calculated, " bars). Error ", GetLastError());
      return(0);
     }
//--- we can copy not all data
   int to_copy;
   if(prev_calculated > rates_total || prev_calculated <= 0)
      to_copy = rates_total - 1;
   else
     {
      to_copy = rates_total - prev_calculated + 1;
     }
   if(IsStopped()) // checking for stop flag
      return(0);
   if(CopyBuffer(Macd1Handle, 0, 0, to_copy, Macd1Buffer) <= 0)
     {
      Print("Getting fast EMA1 is failed! Error ", GetLastError());
      return(0);
     }
   if(CopyBuffer(Macd2Handle, 0, 0, to_copy, Macd2Buffer) <= 0)
     {
      Print("Getting fast EMA2 is failed! Error ", GetLastError());
      return(0);
     }
  
      if(CopyBuffer(Macd1Handle, 1, 0, to_copy, Signal1Buffer) <= 0)
        {
         Print("Getting slow SMA1 is failed! Error ", GetLastError());
         return(0);
        }

      if(CopyBuffer(Macd2Handle, 1, 0, to_copy, Signal2Buffer) <= 0)
        {
         Print("Getting slow SMA2 is failed! Error ", GetLastError());
         return(0);
        }
  
//---
   int start = to_copy - 2;
//--- calculate MACD
   for(int i = start; i >= 0 && !IsStopped(); i--)
     {
      BuyBuffer[i] = EMPTY_VALUE;
      SellBuffer[i] = EMPTY_VALUE;
      if(Macd1Buffer[i + 1] < Macd2Buffer[i + 1] && Macd1Buffer[i] > Macd2Buffer[i])
        {
         BuyBuffer[i] = Macd1Buffer[i];
        }
      if(Macd1Buffer[i + 1] > Macd2Buffer[i + 1] && Macd1Buffer[i] < Macd2Buffer[i])
        {
         SellBuffer[i] = Macd1Buffer[i];
        }
      if(DrawBuySellMarker)
        {
         if(SellBuffer[i] != EMPTY_VALUE)
           {
            int bar = i;
            // SELL
            DrawArrowXL("sigexMACD" + bar, bar + 1, iOpen(NULL, 0, bar), 234, 15, clrRed);
            if(bar == 0)
               DoAlertX(bar, "exMACD: SELL");
           }
         if(BuyBuffer[i] != EMPTY_VALUE)
           {
            int bar = i;
            // BUY
            DrawArrowXL("sigexMACD" + bar, bar + 1, iOpen(NULL, 0, bar), 233, 15, clrBlue);
            if(bar == 0)
               DoAlertX(bar, "exMACD: BUY");
           }
        }
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
