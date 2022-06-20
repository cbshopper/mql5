//+------------------------------------------------------------------+
//|                                                        4Hull.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <CB/CB_Commons.mqh>
#include <CB/CB_Utils.mqh>

#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   8
#property indicator_color1  LightBlue
#property indicator_color2  PaleVioletRed
#property indicator_color3  LightBlue
#property indicator_color4  PaleVioletRed
#property indicator_color5  LightBlue
#property indicator_color6  PaleVioletRed
#property indicator_color7  LightBlue
#property indicator_color8  PaleVioletRed
#property indicator_minimum 0
#property indicator_maximum 5

//

input ENUM_TIMEFRAMES TimeFrame1            = PERIOD_CURRENT;
input ENUM_TIMEFRAMES TimeFrame2            = PERIOD_CURRENT;
input ENUM_TIMEFRAMES TimeFrame3            = PERIOD_CURRENT;
input ENUM_TIMEFRAMES TimeFrame4            = PERIOD_CURRENT;
input int    HullPeriod            = 12;
input int    HullPrice             =  5;
input string UniqueID              = "4xHMA Trend";
input int    LinesWidth            =  0;
input color  LabelsColor           = clrBlack;
input int    LabelsHorizontalShift = 0;
input double LabelsVerticalShift   = 0.0;
input int    BarCount              = 10000;
//input bool   alertsOn              = false;
//input int    alertsLevel           = 3;
//input bool   alertsMessage         = true;
//input bool   alertsSound           = false;
//input bool   alertsEmail           = false;

//
double hulltre1u[];
double hulltre1d[];
double hulltre2u[];
double hulltre2d[];
double hulltre3u[];
double hulltre3d[];
double hulltre4u[];
double hulltre4d[];

ENUM_TIMEFRAMES    timeFrames[4];
int    limits[4];
int    returnBarsArr[4];
int    HullPtr[4];
bool   returnBars;
bool   calculateValue;
string MAIndicatorFileName = "CB/ma/CB_Hull";
string LimitIndicatorFileName = "CB/TotalBars";
double trend[][2];
int MaPtr;

bool initialized = false;
#define _up 0
#define _dn 1
#define COUNT_BUFFER 2

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  ArraySetAsSeries(hulltre1u, true);
  ArraySetAsSeries(hulltre1d, true);
  ArraySetAsSeries(hulltre2u, true);
  ArraySetAsSeries(hulltre2d, true);
  ArraySetAsSeries(hulltre3u, true);
  ArraySetAsSeries(hulltre3d, true);
  ArraySetAsSeries(hulltre4u, true);
  ArraySetAsSeries(hulltre4d, true);
  ArrayInitialize(hulltre1u, EMPTY_VALUE);
  ArrayInitialize(hulltre1d, EMPTY_VALUE);
  ArrayInitialize(hulltre2u, EMPTY_VALUE);
  ArrayInitialize(hulltre2d, EMPTY_VALUE);
  ArrayInitialize(hulltre3u, EMPTY_VALUE);
  ArrayInitialize(hulltre3d, EMPTY_VALUE);
  ArrayInitialize(hulltre4u, EMPTY_VALUE);
  ArrayInitialize(hulltre4d, EMPTY_VALUE);
//--- indicator buffers mapping
  SetIndexBuffer(0, hulltre1u, INDICATOR_DATA);
  SetIndexBuffer(1, hulltre1d, INDICATOR_DATA);
  SetIndexBuffer(2, hulltre2u, INDICATOR_DATA);
  SetIndexBuffer(3, hulltre2d, INDICATOR_DATA);
  SetIndexBuffer(4, hulltre3u, INDICATOR_DATA);
  SetIndexBuffer(5, hulltre3d, INDICATOR_DATA);
  SetIndexBuffer(6, hulltre4u, INDICATOR_DATA);
  SetIndexBuffer(7, hulltre4d, INDICATOR_DATA);
  PlotIndexSetString(0, PLOT_LABEL, "hulltre1u");
  PlotIndexSetString(1, PLOT_LABEL, "hulltre1d");
  PlotIndexSetString(2, PLOT_LABEL, "hulltre2u");
  PlotIndexSetString(3, PLOT_LABEL, "hulltre2d");
  PlotIndexSetString(4, PLOT_LABEL, "hulltre3u");
  PlotIndexSetString(5, PLOT_LABEL, "hulltre3d");
  PlotIndexSetString(6, PLOT_LABEL, "hulltre4u");
  PlotIndexSetString(7, PLOT_LABEL, "hulltre4d");
//
  for(int i = 0; i < 8; i++)
   {
    PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_ARROW);
    PlotIndexSetInteger(i, PLOT_ARROW, 110);
   }
  if(TimeFrame1 == PERIOD_CURRENT)
    timeFrames[0] = Period();
  else
    timeFrames[0] = TimeFrame1;
  timeFrames[1] = NextTimeFrame(timeFrames[0], TimeFrame1);
  timeFrames[2] = NextTimeFrame(timeFrames[1], TimeFrame2);
  timeFrames[3] = NextTimeFrame(timeFrames[2], TimeFrame3);
  /* Parameters of CB_HULL
  input int                 HMAPeriod = 12;         // Period
  input ENUM_APPLIED_PRICE  InpMAPrice = 5;         // Price
  input double              Divisor = 2.0;
  input int     Filter         = 0;
  input bool    Color          = true;
  input int     ColorBarBack   = 0;
  iCust = iCustom(NULL, mTimeFrame, indicatorFileName,  HMAPeriod, InpMAPrice, Divisor, Filter, Color, 0);
  */
  HullPtr[0] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[0], MAIndicatorFileName,  HullPeriod, HullPrice, 2.0, 0, 0, 0);
  HullPtr[1] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[1], MAIndicatorFileName,  HullPeriod, HullPrice, 2.0, 0, 0, 0);
  HullPtr[2] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[2], MAIndicatorFileName,   HullPeriod, HullPrice, 2.0, 0, 0, 0);
  HullPtr[3] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[3], MAIndicatorFileName,   HullPeriod, HullPrice, 2.0, 0, 0, 0);
// MaPtr = iMA(NULL, 0, 1, 0, MODE_SMA, HullPrice);
// alertsLevel = MathMin(MathMax(alertsLevel, 3), 4);
  IndicatorSetString(INDICATOR_SHORTNAME, UniqueID);
  initialized = false;
// return(0);
//---
  return(INIT_SUCCEEDED);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
  for(int t = 0; t < 4; t++)
    ObjectDelete(0, UniqueID + (string)t);
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
  int  counted_bars = prev_calculated;
  if(counted_bars < 0)
    return(-1);
  if(counted_bars > 0)
    counted_bars--;
  int limit = MathMin(rates_total - counted_bars + 1, rates_total - 1);
  if(prev_calculated > rates_total || prev_calculated <= 0)
    limit = rates_total - 1;   // k+1-Indizierung
  else
   {
    limit = rates_total - prev_calculated + 1;
   }
  limit = BarCount;
  if (limit > rates_total - 1) limit= rates_total - 1;
//
//
//
//
  if(!initialized)
   {
    //initialized = true;
    int window = ChartWindowFind(0, UniqueID);
    for(int t = 0; t < 4; t++)
     {
      string label = EnumToString(timeFrames[t]); // timeFrameToString(timeFrames[t]);
      string name = UniqueID + (string)t;
      bool ok = ObjectCreate(0, name, OBJ_TEXT, window,  iTime(NULL, 0, 1),  t + 1  + LabelsVerticalShift);
      ok = ObjectSetInteger(0, name, OBJPROP_COLOR, (int)LabelsColor);
      ok = ObjectSetDouble(0, name, OBJPROP_PRICE,  t + 1 + LabelsVerticalShift);
      ok = ObjectSetString(0, name, OBJPROP_TEXT, label);
      ok = ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
      ok = ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      // ObjectSetInteger(0, name, OBJPROP_TIME,  iTime(NULL, 0, 0) + Period()*LabelsHorizontalShift *10);  //*60
      initialized = true;
     }
   }
  for(int t = 0; t < 4; t++)
   {
    string name = UniqueID +  (string)t;
    ObjectSetInteger(0, name, OBJPROP_TIME,  iTime(NULL, PERIOD_CURRENT, 0) + PeriodSeconds()*LabelsHorizontalShift);   //*60
   }
  double val1 = 0;
  double val0 = 0;
  for(int i = limit; i >= 0; i--)
   {
    //   trend[r][_up] = 0;
    //   trend[r][_dn] = 0;
    datetime curtime = iTime(NULL, 0, i);
    for(int k = 0; k < 4; k++)
     {
      int y = i;
       int cnt = BarsCalculated(HullPtr[k]);
            if (cnt <0 ) return 0;
      if(Period() != timeFrames[k])
       {
        y = iBarShift(NULL, (ENUM_TIMEFRAMES)timeFrames[k], curtime, true);// + 1;  //adjust color!
        //      int error = GetLastError();
        //      Print(__FUNCTION__, " ERROR:", error, " - ", ErrorMsg(error));
       }
      if(y > -1)
       {
        val1 = GetIndicatorValue(HullPtr[k], 0, y + 1);;
        val0 = GetIndicatorValue(HullPtr[k], 0, y);;
        bool isUp = (val0 > val1);
        switch(k)
         {
          case 0 :
            if(isUp)
             {
              hulltre1u[i] = k + 1;
              hulltre1d[i] = EMPTY_VALUE;
             }
            else
             {
              hulltre1d[i] = k + 1;
              hulltre1u[i] = EMPTY_VALUE;
             }
            break;
          case 1 :
            if(isUp)
             {
              hulltre2u[i] = k + 1;
              hulltre2d[i] = EMPTY_VALUE;
             }
            else
             {
              hulltre2d[i] = k + 1;
              hulltre2u[i] = EMPTY_VALUE;
             }
            break;
          case 2 :
            if(isUp)
             {
              hulltre3u[i] = k + 1;
              hulltre3d[i] = EMPTY_VALUE;
             }
            else
             {
              hulltre3d[i] = k + 1;
              hulltre3u[i] = EMPTY_VALUE;
             }
            break;
          case 3 :
            if(isUp)
             {
              hulltre4u[i] = k + 1;
              hulltre4d[i] = EMPTY_VALUE;
             }
            else
             {
              hulltre4d[i] = k + 1;
              hulltre4u[i] = EMPTY_VALUE;
             }
            break;
         }
       }
     }
   }
// manageAlerts();
//--- return value of prev_calculated for next call
  return(rates_total);
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES NextTimeFrame(ENUM_TIMEFRAMES prev, ENUM_TIMEFRAMES def)
 {
  ENUM_TIMEFRAMES ret = def;
  if(def == PERIOD_CURRENT)
   {
    if(prev == PERIOD_CURRENT)
      prev = Period();
    ret = (ENUM_TIMEFRAMES)TimeFrameInc(prev);
   }
  return ret;
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIndicatorValue(int handle, int buffer, int index)
 {
  double ret = 0;
  double vals[1];
  int n = CopyBuffer(handle, buffer, index, 1, vals);
  if(n > -1)
   {
    ret = vals[0];
   }
  return ret;
 }

//+------------------------------------------------------------------+
