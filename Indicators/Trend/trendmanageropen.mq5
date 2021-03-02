//+------------------------------------------------------------------+ 
//|                                             TrendManagerOpen.mq5 | 
//|                                    Copyright © 2007, Matt Kennel | 
//|                                               mbkennel@gmail.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, Matt Kennel"
#property link "mbkennel@gmail.com"
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used as the indicator colors
#property indicator_color1  clrPaleGreen,clrMagenta
//--- displaying the indicator label
#property indicator_label1  "TrendManagerOpen"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- MediumBlue color is used as the color of the indicator line
#property indicator_color2  clrMediumBlue
//--- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- indicator bullish label display
#property indicator_label2  "TrendManagerOpen Line1"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_LINE
//--- MediumBlue color is used as the color of the indicator line
#property indicator_color3  clrMediumBlue
//--- indicator 3 line width is equal to 1
#property indicator_width3  1
//---- bearish indicator label display
#property indicator_label3 "TrendManagerOpen Line2"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int TM_Period_1=7;
input int TM_Shift_1=2;
input int TM_Period_2=13;
input int TM_Shift_2=1;
input int Shift=0;        // Horizontal shift of the indicator in bars
//+-----------------------------------+
//--- declaration of integer variables for the start of data calculation
int  min_rates_total;
//--- declaration of dynamic arrays which will be used as indicator buffers
double UpBuffer1[];
double DnBuffer1[];
double UpBuffer2[];
double DnBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=MathMax(TM_Period_1+TM_Shift_1,TM_Period_2+TM_Shift_2);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer1,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer1,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer1,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer1,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,UpBuffer2,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer2,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(3,DnBuffer2,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer2,true);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- shifting the indicator horizontally by InpKijun
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- shifting the indicator horizontally by -InpKijun
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"TrendManagerOpen");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declaration of variables with a floating point  
   double M1,M1b,M2,M2b,diff1,diff2;
//--- declaration of integer variables
   int limit;
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1;  // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for calculation of new bars only
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      M1=Get_MiddlePrice(TM_Period_1,bar,High,Low);
      M1b=Get_MiddlePrice(TM_Period_1,bar+TM_Shift_1,High,Low);
      M2=Get_MiddlePrice(TM_Period_2,bar,High,Low);
      M2b=Get_MiddlePrice(TM_Period_2,bar+TM_Shift_2,High,Low);
      //---
      diff1=(M1-M1b); // up or down on short term;
      diff2=(M2-M2b); // up or down on longer term.
      //--- each has three choices, hence six possibilities.
      if(diff1*diff2<=0.0)
        {
         //--- opposite signs
         UpBuffer1[bar]=(M1+M2)*0.5;
         UpBuffer2[bar]=UpBuffer1[bar];
         DnBuffer1[bar]=UpBuffer1[bar]; //Blue bars
         DnBuffer2[bar]=DnBuffer1[bar];
        }
      else
        {
         UpBuffer1[bar]=(M1+M2)*0.5;
         UpBuffer2[bar]=UpBuffer1[bar];
         DnBuffer1[bar]=(M1b+M2b)*0.5;
         DnBuffer2[bar]=DnBuffer1[bar];
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
double Get_MiddlePrice(uint period,int shift,const double &high[],const double &low[])
  {
//---
   double HH=high[ArrayMaximum(high,shift,period)];
   double LL=low[ArrayMinimum(low,shift,period)];
//---
   return((HH+LL)/2.0);
  }
//+------------------------------------------------------------------+
