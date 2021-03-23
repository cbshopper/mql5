//+------------------------------------------------------------------+
//|                                                     Laguerre.mq5 |
//|                             Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//--- only one plot is used
#property indicator_plots   1
//--- drawing of the indicator as a line
#property indicator_type1   DRAW_LINE
//--- Magenta color is used for the indicator line
#property indicator_color1  Magenta
//--- values of indicator's horizontal levels
#property indicator_level2 0.75
#property indicator_level3 0.45
#property indicator_level4 0.15
//--- blue color is used as the color of the horizontal level
#property indicator_levelcolor Blue
//--- line style
#property indicator_levelstyle STYLE_DASHDOTDOT
//--- indicator input parameters
input double gamma=0.7;
//--- declaration of dynamic array that further
//--- will be used as indicator buffers
double ExtLineBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- set ExtLineBuffer[] dynamic array as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//--- prepare a variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Laguerre(",gamma,")");
//--- create label to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//--- creating name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- set accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- set empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars, calculated at previous call
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[])    // price array for calculation of the indicator
  {
//--- checking the number of bars to be enough for the calculation
   if(rates_total<begin) return(0);
//--- declarations of local variables 
   int first,bar;
   double L0,L1,L2,L3,L0A,L1A,L2A,L3A,LRSI=0,CU,CD;
//--- declaration of static variables for storing real values of coefficients
   static double L0_,L1_,L2_,L3_,L0A_,L1A_,L2A_,L3A_;
//--- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=begin; // starting number for calculation of all bars
      //--- the starting initialization of calculated coefficients
      L0_ = price[first];
      L1_ = price[first];
      L2_ = price[first];
      L3_ = price[first];
      L0A_ = price[first];
      L1A_ = price[first];
      L2A_ = price[first];
      L3A_ = price[first];
     }
   else first=prev_calculated-1; // starting number for calculation of new bars
//--- restore values of the variables
   L0 = L0_;
   L1 = L1_;
   L2 = L2_;
   L3 = L3_;
   L0A = L0A_;
   L1A = L1A_;
   L2A = L2A_;
   L3A = L3A_;

//--- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      //--- memorize values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         L0_ = L0;
         L1_ = L1;
         L2_ = L2;
         L3_ = L3;
         L0A_ = L0A;
         L1A_ = L1A;
         L2A_ = L2A;
         L3A_ = L3A;
        }

      L0A = L0;
      L1A = L1;
      L2A = L2;
      L3A = L3;
      //---
      L0 = (1 - gamma) * price[bar] + gamma * L0A;
      L1 = - gamma * L0 + L0A + gamma * L1A;
      L2 = - gamma * L1 + L1A + gamma * L2A;
      L3 = - gamma * L2 + L2A + gamma * L3A;
      //---
      CU = 0;
      CD = 0;
      //--- 
      if(L0 >= L1) CU  = L0 - L1; else CD  = L1 - L0;
      if(L1 >= L2) CU += L1 - L2; else CD += L2 - L1;
      if(L2 >= L3) CU += L2 - L3; else CD += L3 - L2;
      //---
      if(CU+CD!=0) LRSI=CU/(CU+CD);

      //--- set value to ExtLineBuffer[]
      ExtLineBuffer[bar]=LRSI;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
