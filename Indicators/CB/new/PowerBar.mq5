//+------------------------------------------------------------------+
//|                                                     SuperBar.mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022 Christof Blank"
#property link      "https://www.mql5.com/en/blogs/post/657454"
#property version   "1.00"
#property indicator_separate_window


#property indicator_buffers       2
#property indicator_plots         2
#property indicator_type1         DRAW_HISTOGRAM
#property indicator_color1        clrRed
#property indicator_type2         DRAW_HISTOGRAM
#property indicator_color2        clrBlue

#property indicator_level1        0.0
#property indicator_level2        2.5
#property indicator_level3        3.0

// input Values------------------------------
input int  Range = 20;

// global global Vars

double PCValue[];
double PCValue2[];


int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, PCValue, INDICATOR_DATA);
   SetIndexBuffer(1, PCValue2, INDICATOR_DATA);
   ArraySetAsSeries(PCValue, true);
   ArraySetAsSeries(PCValue2, true);
//--- indicator name
   string short_name = StringFormat("PB(%d)", Range);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
//--- indexes draw begin settings
// PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Range - 1);
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
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
//----
   int limit;
//----
   min_rates_total = Range + 2;
//----    limit
   if(prev_calculated > rates_total || prev_calculated <= 0) //
     {
      limit = rates_total - min_rates_total; //
     }
   else
     {
      limit = rates_total - prev_calculated + 1; //
     }
   if(limit < min_rates_total)
      limit = min_rates_total;
   if(IsStopped())
      return 0;
   for(int shift = limit; shift >= 0 ; shift--)
     {
      double sumrange = calculateRange(shift + 1,  high, low);
      double barsize = high[shift] - low[shift];
      sumrange /= Point();
      barsize /= Point();
      if(sumrange > 0)
        {
         PCValue[shift] = barsize / sumrange;
        }
      else
        {
         PCValue[shift] = 0;
        }
      sumrange = calculateRange(shift + 1, close, open);
      barsize = close[shift] - open [shift];
      sumrange /= Point();
      barsize /= Point();
      if(sumrange > 0)
        {
         PCValue2[shift] = barsize / sumrange;
        }
      else
        {
         PCValue2[shift] = 0;
        }  
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateRange(int shift,
                      const double &val1[],
                      const double &val2[]
                    )
  {
   ArraySetAsSeries(val1, true);
   ArraySetAsSeries(val2, true);
   double ret = 0;
   for(int i = shift + Range - 1 ; i >= shift; i--)
     {
      ret +=MathAbs (val1[i] - val2[i]);
     }
   ret /= Range;
   return ret;
  }
  
  
  /*
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateRangeOC(int shift,
                      const double &open[],
                      const double &high[],
                      const double &low[],
                      const double &close[])
  {
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   double ret = 0;
// if (shift + Range > ArraySize(high)) return 0;
   for(int i = shift + Range - 1 ; i >= shift; i--)
     {
        double oc = close[i] - open[i];  // Up: pos, Dn: neg
        ret += oc;
     }
   ret /= Range;
   return ret;
  }
  */