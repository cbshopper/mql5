//+------------------------------------------------------------------+
//|                                                    Validator.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 10
#property indicator_plots   4

//--- plot OpenBUY
#property indicator_label1  "OpenBuy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- plot SELL
#property indicator_label2  "OpenSell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5

//--- plot BUY
#property indicator_label3  "CLoseBuy"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot SELL
#property indicator_label4  "CloseSell"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
/*
//--- plot RSI
#property indicator_label5  "RSI"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_DASHDOT
#property indicator_width5  2

//--- plot SLOWMA
#property indicator_label6  "SLOWMA"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_DASHDOT
#property indicator_width6  2
*/

input int                 PBRange = 20;
input double              LevelInvert = 5.0;
input double              LevelFollow = 2.5;
input int                 OrderBarCount = 4;

int indicator_ptr = 0;

#include <CB/CB_Drawing.mqh>
#include <CB/CB_Validator.mqh>

double         PBValues[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   int first = InitSignalBuffers();
//** BUFFERS for used Indictor(s)
//--- indicator buffers mapping
   SetIndexBuffer(first + 0, PBValues, INDICATOR_CALCULATIONS);
//--- setting the arrays in timeseries
   ArraySetAsSeries(PBValues, true);
//  ArraySetAsSeries(MA2Values, true);
//---
   indicator_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/new/PowerBar", PBRange);
   
  //     StartOffset=0;   // wg. Signal an richtiger Position
       
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnDeinit(
   const int  reason         // deinitialization reason code
)
  {
   DeleteTLines();
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
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   int calculated = BarsCalculated(indicator_ptr);
   if(calculated < rates_total)
     {
      return(0);
     }
   /*
   calculated = BarsCalculated(ma2_ptr);
   if(calculated < rates_total)
   {
    return(0);
   }
   */
   int to_copy;
   if(prev_calculated > rates_total || prev_calculated < 0)
      to_copy = rates_total;
   else
     {
      to_copy = rates_total - prev_calculated;
      if(prev_calculated > 0)
         to_copy++;
     }
//   to_copy = rates_total;
//    to_copy=1000;
// Print(__FILE__, __FUNCTION__," rates_total=",rates_total," prev_calculated=",prev_calculated," to_copy=", to_copy, " calculated=",calculated );
//if(IsStopped())
//   return(0); //Checking for stop flag
   if(CopyBuffer(indicator_ptr, 0, 0, to_copy, PBValues) <= 0)
     {
      Print("Getting data_ptr(0) is failed! Error", GetLastError());
      return(0);
     }
   /*
   if(CopyBuffer(ma2_ptr, 0, 0, to_copy, MA2Values) <= 0)
   {
    Print("Getting data_ptr(1) is failed! Error", GetLastError());
    return(0);
   }
   */
   int limit = calculated -2 ;
   for(int shift = limit; shift > 0; shift--)
     {
      BuySignalOpenBuffer[shift] = EMPTY_VALUE;
      SellSignalOpenBuffer[shift] = EMPTY_VALUE;
      BuySignalCloseBuffer[shift] = EMPTY_VALUE;
      SellSignalCloseBuffer[shift] = EMPTY_VALUE;
      int index=shift;
      double val = PBValues[index];
      if(val > LevelInvert )   // invert stategie
        {
         if(open[index] < close[index])
           {
            SellSignalOpenBuffer[shift] = open[shift];
           }
         else
           {
            BuySignalOpenBuffer[shift] = open[shift];
           }
         continue;
        }
      if(val > LevelFollow)   // follow staregie
        {
         if(open[index] < close[index])
           {
            BuySignalOpenBuffer[shift] = open[shift];
           }
         else
           {
            SellSignalOpenBuffer[shift] = open[shift];
           }
         continue;
        }
     }
   for(int shift = limit; shift > 0; shift--)
     {
      int closebar = shift > OrderBarCount ? shift - OrderBarCount : 1;
      if(BuySignalOpenBuffer[shift] != EMPTY_VALUE)
        {
         BuySignalCloseBuffer[closebar] = open[closebar];
        }
      if(SellSignalOpenBuffer[shift] != EMPTY_VALUE)
        {
         SellSignalCloseBuffer[closebar] = open[closebar];
        }
     }
 
    DrawOrderLines();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
