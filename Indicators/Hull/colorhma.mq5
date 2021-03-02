//+------------------------------------------------------------------+
//|                                                     ColorHMA.mq5 |
//|                               Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the directory: terminal_data_folder\\MQL5\Include             |
//+------------------------------------------------------------------+
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only one plot is used
#property indicator_plots   1
//---- drawing the indicator as a line
#property indicator_type1   DRAW_COLOR_LINE
//---- Gray, MediumPurple and Red colors are used for three-color line
#property indicator_color1  Gray,MediumPurple,Red
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  2
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int HMA_Period=13;  // Moving average period
input int HMA_Shift=0;    // Horizontal shift of the average in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtLineBuffer[];
double ColorExtLineBuffer[];
//---- declaration of integer variables
int Hma2_Period,Sqrt_Period;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   Hma2_Period=int(MathFloor(HMA_Period/2));
   Sqrt_Period=int(MathFloor(MathSqrt(HMA_Period)));
//---- initialization of variables of the start of data calculation
   min_rates_total=HMA_Period+Sqrt_Period;

//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- set ExtLineBuffer [] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the moving average horizontally by HMAShift
   PlotIndexSetInteger(0,PLOT_SHIFT,HMA_Shift);
//---- shifting the start of drawing of the HMAPeriod indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- set ColorExtLineBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- name for the data window and the label for sub-windows 
   string short_name="HMA";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name+"("+string(HMA_Period)+")");
//----
  }
//---- CMoving_Average class description
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,     // number of bars in history at the current tick
                const int prev_calculated, // number of bars calculated at previous call
                const int begin,           // bars reliable counting beginning index
                const double &price[])     // price array for calculation of the indicator
  {
   int begin0=min_rates_total+begin;
//---- checking the number of bars to be enough for the calculation
   if(rates_total<begin0) return(0);

//---- declarations of local variables 
   int first,bar,begin1;
   double lwma1,lwma2,dma;
   begin1=HMA_Period+begin;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated==0) // checking for the first start of the indicator calculation
     {
      first=begin;        // starting index for calculation of all bars      
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin0+1);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,begin0+1);
      for(bar=0; bar<=begin0; bar++) ColorExtLineBuffer[bar]=0;
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of variable of the CMoving_Average class from the SmoothAlgorithms.mqh file
   static CMoving_Average MA1,MA2,MA3;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      lwma1=MA1.LWMASeries(begin,prev_calculated,rates_total,Hma2_Period,price[bar],bar,false);
      lwma2=MA2.LWMASeries(begin,prev_calculated,rates_total,HMA_Period, price[bar],bar,false);
      dma=2*lwma1-lwma2;
      ExtLineBuffer[bar]=MA3.LWMASeries(begin1,prev_calculated,rates_total,Sqrt_Period,dma,bar,false);
     }

//---- recalculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=begin0;

//---- main loop of the signal line coloring
   for(bar=first; bar<rates_total; bar++)
     {
      ColorExtLineBuffer[bar]=0;
      if(ExtLineBuffer[bar-1]<ExtLineBuffer[bar]) ColorExtLineBuffer[bar]=1;
      if(ExtLineBuffer[bar-1]>ExtLineBuffer[bar]) ColorExtLineBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+