//+------------------------------------------------------------------+
//|                                                    Stoch RSI.mq5 |
//|                                    Copyright 2020, Hossein Nouri |
//|                           https://www.mql5.com/en/users/hsnnouri |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Hossein Nouri"
#property description "Fully Coded By Hossein Nouri"
#property description "Email : hsn.nouri@gmail.com"
#property description "Skype : hsn.nouri"
#property description "Telegram : @hypernova1990"
#property description "Website : http://www.metatraderprogrammer.ir"
#property description "MQL5 Profile : https://www.mql5.com/en/users/hsnnouri"
#property description " "
#property description "Feel free to contact me for MQL4/MQL5 coding."
#property link      "https://www.mql5.com/en/users/hsnnouri"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- plot Main
#property indicator_label1  "Value"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2


input int                     InpStockKPeriod               = 3;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpRSIPeriod                  = 14;                                  // RSI Period
input int                     InpStochastikPeriod           = 14;                                  // Stochastic Period
input ENUM_APPLIED_PRICE      InpRSIAppliedPrice            = PRICE_CLOSE;                         // RSI Applied Price


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

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
  //--- indicator buffers mapping
   SetIndexBuffer(0,KBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,RSIBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,StochBuffer,INDICATOR_CALCULATIONS);

   //--- getting RSI handle
   RSIHandle=iRSI(_Symbol,_Period,InpRSIPeriod,InpRSIAppliedPrice);
   //--- setting the arrays in timeseries
   ArraySetAsSeries(KBuffer,true);
   ArraySetAsSeries(DBuffer,true);
   ArraySetAsSeries(RSIBuffer,true);
   ArraySetAsSeries(StochBuffer,true);
//---
   return(INIT_SUCCEEDED);
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

   int calculated=BarsCalculated(RSIHandle);
   if(calculated<rates_total)
   {
      Print("Not all data of RSIHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
   }

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
   {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
   }
   if(IsStopped()) return(0); //Checking for stop flag

   if(CopyBuffer(RSIHandle,0,0,to_copy,RSIBuffer)<=0)
   {
      Print("Getting RSIBuffer is failed! Error",GetLastError());
      return(0);
   }

   int limit = prev_calculated==0?rates_total-(InpRSIPeriod+1):rates_total-prev_calculated+1;
   for(int i=limit; i>=0; i--)
   {
      if(i<rates_total-(InpRSIPeriod+2))                 StochBuffer[i]=Stoch(RSIBuffer, RSIBuffer, RSIBuffer, InpStochastikPeriod,i,rates_total);
      if(StochBuffer[i+InpStockKPeriod-1]!=EMPTY_VALUE)  KBuffer[i]=SimpleMA(i,InpStockKPeriod,StochBuffer,rates_total);
      if(KBuffer[i+InpStockDPeriod-1]!=EMPTY_VALUE)      DBuffer[i]=SimpleMA(i,InpStockDPeriod,KBuffer,rates_total);
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| calculating stochastic                                           |
//+------------------------------------------------------------------+
double Stoch(const double &source[], double &high[], double &low[], int length, int shift, const int &rates_total)
{
   if(shift+length>rates_total)           return EMPTY_VALUE;
   double Highest = Highest(high,length,shift);
   double Lowest = Lowest(low,length,shift);
   if(Highest-Lowest==0)         return EMPTY_VALUE;
   return 100 * (source[shift] - Lowest) / (Highest-Lowest);
}
//+------------------------------------------------------------------+
//| find lowest value in prev. X periods                             |
//+------------------------------------------------------------------+
double Lowest(double &low[], int length, int shift)
{
   double Result=0;
   for(int i=shift; i<=shift+length; i++)
   {
      if(Result==0 || (low[i]<Result && low[i]!=EMPTY_VALUE))
      {
         Result=low[i];
      }
   }

   return Result;
}
//+------------------------------------------------------------------+
//| find highest value in prev. X periods                            |
//+------------------------------------------------------------------+
double Highest(double &high[], int length, int shift)
{
   double Result=0;
   for(int i=shift; i<=shift+length; i++)
   {
      if(Result==0 || (high[i]>Result && high[i]!=EMPTY_VALUE))
      {
         Result=high[i];
      }
   }

   return Result;
}
//+------------------------------------------------------------------+
//| calculating simple moving average of an array                    |
//+------------------------------------------------------------------+
double SimpleMA(const int position,const int period,const double &price[], const int &rates_total)
{
//---
   double result=0.0;
   if(position<=rates_total-period && period>0)
   {
      for(int i=0; i<period; i++)
      {
         if(price[position+i]!=EMPTY_VALUE)
         {
            result+=price[position+i];
         }
      }
      result/=period;
   }
   return(result);
}
//+------------------------------------------------------------------+