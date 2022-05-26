//+------------------------------------------------------------------+
//|                                                     BBSpread.mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022 Christof Blank"
#property indicator_separate_window


#property indicator_buffers       5
#property indicator_plots         2
#property indicator_type1         DRAW_LINE
#property indicator_color1        clrGreen
#property indicator_width1        5

#property indicator_type2         DRAW_LINE
#property indicator_color2        clrRed
#property indicator_width2        5

// input Values------------------------------
input int ma_period = 20;
input double deviation = 2.0;


// global global Vars

double BBMiddle[];
double BBUpper[];
double BBLower[];
double SpreadGrowing[];
double SpreadShrinking[];
int BBPtr;

int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- indicator buffers mapping
  SetIndexBuffer(0, SpreadGrowing, INDICATOR_DATA);
  SetIndexBuffer(1, SpreadShrinking, INDICATOR_DATA);
  SetIndexBuffer(2, BBMiddle, INDICATOR_CALCULATIONS);
  SetIndexBuffer(3, BBLower, INDICATOR_CALCULATIONS);
  SetIndexBuffer(4, BBUpper, INDICATOR_CALCULATIONS);
//SetIndexBuffer(5, SpreadShrinking, INDICATOR_CALCULATIONS);
  ArraySetAsSeries(SpreadGrowing, true);
  ArraySetAsSeries(SpreadShrinking, true);
  ArraySetAsSeries(BBMiddle, true);
  ArraySetAsSeries(BBLower, true);
  ArraySetAsSeries(BBUpper, true);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  BBPtr = iBands(NULL, PERIOD_CURRENT, ma_period, 0, deviation, PRICE_CLOSE);
//--- indicator name
  string short_name = StringFormat("BBSpread(%d %2.2f)", ma_period, deviation);
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
  int calculated = BarsCalculated(BBPtr);
  if(calculated < rates_total)
   {
    Print("Not all data of RSIHandle is calculated (", calculated, "bars ). Error", GetLastError());
    //    return(0);
   }
  int to_copy;
  if(prev_calculated > rates_total || prev_calculated <= 0)
    to_copy = rates_total-1;
  else
   {
    to_copy = rates_total - prev_calculated+1;
 //   if(prev_calculated > 0)
  //    to_copy++;
   }
//    to_copy=1000;
  if(IsStopped())
    return(0); //Checking for stop flag
  if(CopyBuffer(BBPtr, 2, 0, to_copy, BBMiddle) <= 0)
   {
    Print("Getting BBMiddle is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(BBPtr, 0, 0, to_copy, BBLower) <= 0)
   {
    Print("Getting BBLower is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(BBPtr, 1, 0, to_copy, BBUpper) <= 0)
   {
    Print("Getting BBUpper is failed! Error", GetLastError());
    return(0);
   }
 // int limit = BarsCalculated(BBPtr) - 2;
 //  limit = to_copy - 2;
  int limit = to_copy-1;
  for(int shift = limit; shift >= 0 ; shift--)
   {
    SpreadGrowing[shift] = EMPTY_VALUE;
    SpreadShrinking[shift] = EMPTY_VALUE;
    double diff0 = BBUpper[shift] - BBLower[shift];
    double diff1 = BBUpper[shift + 1] - BBLower[shift + 1];
    double deltadiff = diff0-diff1;
    
    
  //  SpreadShrinking[shift] = diff0;
    double val=diff0;
    val=0;  // show in den middle!!
    
    SpreadGrowing[shift] = val;
    if(diff0>=diff1)
     {
       SpreadGrowing[shift] = val;
     }
    else
     {
        SpreadShrinking[shift] = val;
     }
     
   }
//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+


//
//+------------------------------------------------------------------+
