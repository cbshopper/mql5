//+------------------------------------------------------------------+
//|                                                ColorLaguerre.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers 2
#property indicator_buffers 2 
//--- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing of the indicator as a three-colored line
#property indicator_type1 DRAW_COLOR_LINE
//--- the following colors are used for a three-colored line
#property indicator_color1 CLR_NONE,Lime,Red
//--- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is equal to 2
#property indicator_width1 2
//--- displaying label of the signal line
#property indicator_label1  "Signal Line"
//--- blue color is used as the color of the horizontal levels line
#property indicator_levelcolor Blue
//--- line style
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input double gamma=0.7;
input int HighLevel=85;
input int MiddleLevel=50;
input int LowLevel=15;
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ColorBuffer[],ExtLineBuffer[];
//+------------------------------------------------------------------+
//| Painting the indicator in two colors                             |
//+------------------------------------------------------------------+ 
void PointIndicator(int Min_rates_total,
                    double &IndBuffer[],
                    double &ColorIndBuffer[],
                    double HighLevel_,
                    double MiddleLevel_,
                    double LowLevel_,
                    int bar)
  {
//---
   if(bar<Min_rates_total+1) return;

   enum LEVEL
     {
      EMPTY,
      HighLev,
      HighLevMiddle,
      LowLevMiddle,
      LowLev
     };

   LEVEL Level0=EMPTY,Level1=EMPTY;
   double IndVelue;

//--- indicator coloring
   IndVelue=IndBuffer[bar];
   if(IndVelue>HighLevel_) Level0=HighLev; else if(IndVelue>MiddleLevel_)Level0=HighLevMiddle;
   if(IndVelue<LowLevel_) Level0=LowLev;  else if(IndVelue<=MiddleLevel_)Level0=LowLevMiddle;

   IndVelue=IndBuffer[bar-1];
   if(IndVelue>HighLevel_) Level1=HighLev; else if(IndVelue>MiddleLevel_)Level1=HighLevMiddle;
   if(IndVelue<LowLevel_) Level1=LowLev;  else if(IndVelue<=MiddleLevel_)Level1=LowLevMiddle;

   switch(Level0)
     {
      case HighLev: ColorIndBuffer[bar]=1; break;

      case HighLevMiddle:
         switch(Level1)
           {
            case  HighLev: ColorIndBuffer[bar]=2; break;
            case  HighLevMiddle: ColorIndBuffer[bar]=ColorIndBuffer[bar-1]; break;
            case  LowLevMiddle: ColorIndBuffer[bar]=1; break;
            case  LowLev: ColorIndBuffer[bar]=1; break;
           }
         break;

      case  LowLevMiddle:
         switch(Level1)
           {
            case  HighLev: ColorIndBuffer[bar]=2; break;
            case  HighLevMiddle: ColorIndBuffer[bar]=2; break;
            case  LowLevMiddle: ColorIndBuffer[bar]=ColorIndBuffer[bar-1]; break;
            case  LowLev: ColorIndBuffer[bar]=1; break;
           }
         break;

      case LowLev: ColorIndBuffer[bar]=2; break;
     }
//---  
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- set ExtLineBuffer[] dynamic array as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//--- initializations of a variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Laguerre(",gamma,")");
//--- create label to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//--- creating name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- set empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set ColorBuffer[] dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//--- number of indicator's horizontal levels 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//--- values of indicator's horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//--- gray and magenta colors are used as the colors of the horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,Magenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,Gray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,Magenta);
//--- line style of horizontal level line
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
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
      first=begin+1; // starting number for calculation of all bars
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
//--- main calculation
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

      LRSI*=100;
      //--- set value to ExtLineBuffer[]
      ExtLineBuffer[bar]=LRSI;
      //--- indicator coloring
      PointIndicator(31,ExtLineBuffer,ColorBuffer,HighLevel,MiddleLevel,LowLevel,bar);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
