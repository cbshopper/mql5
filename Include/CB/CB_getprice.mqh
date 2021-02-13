//+------------------------------------------------------------------+
//|                                                  CB_getprice.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

enum enPrices
  {
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+oprn+close)/4
   pr_haclose,    // Heiken ashi close
   pr_haopen,     // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage   // Heiken ashi average
  };


double workHa[][4];
double getPrice(enPrices price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars)
  {
   if(price>=pr_haclose && price<=pr_haaverage)
     {
      if(ArrayRange(workHa,0)!= bars)
         ArrayResize(workHa,bars);

      double haOpen;
      if(i>0)
         haOpen  = (workHa[i-1][2] + workHa[i-1][3])/2.0;
      else
         haOpen  = open[i]+close[i];
      double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
      double haLow   = MathMin(low[i], MathMin(haOpen,haClose));

      if(haOpen  <haClose)
        {
         workHa[i][0] = haLow;
         workHa[i][1] = haHigh;
        }
      else
        {
         workHa[i][0] = haHigh;
         workHa[i][1] = haLow;
        }
      workHa[i][2] = haOpen;
      workHa[i][3] = haClose;

      switch(price)
        {
         case pr_haclose:
            return(haClose);
         case pr_haopen:
            return(haOpen);
         case pr_hahigh:
            return(haHigh);
         case pr_halow:
            return(haLow);
         case pr_hamedian:
            return((haHigh+haLow)/2.0);
         case pr_hatypical:
            return((haHigh+haLow+haClose)/3.0);
         case pr_haweighted:
            return((haHigh+haLow+haClose+haClose)/4.0);
         case pr_haaverage:
            return((haHigh+haLow+haClose+haOpen)/4.0);
        }
     }
//

   switch(price)
     {
      case pr_close:
         return(close[i]);
      case pr_open:
         return(open[i]);
      case pr_high:
         return(high[i]);
      case pr_low:
         return(low[i]);
      case pr_median:
         return((high[i]+low[i])/2.0);
      case pr_typical:
         return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:
         return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:
         return((high[i]+low[i]+close[i]+open[i])/4.0);
     }
   return(0);
  }
