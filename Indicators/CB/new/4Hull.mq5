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
//
//
//
//

input ENUM_TIMEFRAMES TimeFrame1            = PERIOD_CURRENT;
input ENUM_TIMEFRAMES TimeFrame2            = PERIOD_CURRENT;
input ENUM_TIMEFRAMES TimeFrame3            = PERIOD_CURRENT;
input ENUM_TIMEFRAMES TimeFrame4            = PERIOD_CURRENT;
input int    HullPeriod            = 12;
input int    HullPrice             =  5;
input string UniqueID              = "4 Time hull trend";
input int    LinesWidth            =  0;
input color  LabelsColor           = clrBlack;
input int    LabelsHorizontalShift = 0;
input double LabelsVerticalShift   = 0.0;
input bool   alertsOn              = false;
input int    alertsLevel           = 3;
input bool   alertsMessage         = true;
input bool   alertsSound           = false;
input bool   alertsEmail           = false;

//
//
//
//
//

double hulltre1u[];
double hulltre1d[];
double hulltre2u[];
double hulltre2d[];
double hulltre3u[];
double hulltre3d[];
double hulltre4u[];
double hulltre4d[];
//double hullValues1[];
//double hullValues2[];
//double hullValues3[];
//double hullValues4[];




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

bool initialized =false;
#define _up 0
#define _dn 1
#define COUNT_BUFFER 2

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
 // ArraySetAsSeries(hullValues1, true);
 // ArraySetAsSeries(hullValues2, true);
 // ArraySetAsSeries(hullValues3, true);
 // ArraySetAsSeries(hullValues4, true);
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
  //SetIndexBuffer(9, hullValues1, INDICATOR_CALCULATIONS);
  //SetIndexBuffer(10, hullValues1, INDICATOR_CALCULATIONS);
  //SetIndexBuffer(11, hullValues1, INDICATOR_CALCULATIONS);
  //SetIndexBuffer(12, hullValues1, INDICATOR_CALCULATIONS);
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
  if (TimeFrame1 == PERIOD_CURRENT)  timeFrames[0] = Period(); 
  else  timeFrames[0] = TimeFrame1;
  timeFrames[1] = NextTimeFrame(timeFrames[0], TimeFrame1);
  timeFrames[2] = NextTimeFrame(timeFrames[1], TimeFrame2);
  timeFrames[3] = NextTimeFrame(timeFrames[2], TimeFrame3);
  
  
 
  /*
  returnBarsArr[0] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[0], LimitIndicatorFileName);
  returnBarsArr[1] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[1], LimitIndicatorFileName);
  returnBarsArr[2] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[2], LimitIndicatorFileName);
  returnBarsArr[3] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[3], LimitIndicatorFileName);
  */
  /*
  HullPtr[0] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[0], indicatorFileName, "calculateValue", "", "", "", HullPeriod, HullPrice);
  HullPtr[1] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[1], indicatorFileName, "calculateValue", "", "", "", HullPeriod, HullPrice);
  HullPtr[2] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[2], indicatorFileName, "calculateValue", "", "", "", HullPeriod, HullPrice);
  HullPtr[3] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[3], indicatorFileName, "calculateValue", "", "", "", HullPeriod, HullPrice);
  */
  
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
  
  
  
 initialized=false;
   
   
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
  limit=10000;
  int ret=0; 
  /*
  if(timeFrames[0] != Period())
   {
    ret = (int)GetIndicatorValue(HullPtr[0], 0, COUNT_BUFFER);
    limits[0] = MathMax(limit, MathMin(rates_total - 1, ret * timeFrames[0] / Period()));
   }
  else
   {
    limits[0] = limit;
   }
  if(timeFrames[1] != Period())
   {
    ret = (int)GetIndicatorValue(HullPtr[1], 0, COUNT_BUFFER);
    limits[1] = MathMax(limit, MathMin(rates_total - 1, ret * timeFrames[1] / Period()));
   }
   {
    limits[1] = limit;
   }
  if(timeFrames[2] != Period())
   {
    ret = (int)GetIndicatorValue(HullPtr[2], 0, COUNT_BUFFER);
    limits[2] = MathMax(limit, MathMin(rates_total - 1, ret * timeFrames[2] / Period()));
   }
   {
    limits[2] = limit;
   }
  if(timeFrames[3] != Period())
   {
    ret =(int) GetIndicatorValue(HullPtr[3], 0, COUNT_BUFFER);
    limits[3] = MathMax(limit, MathMin(rates_total - 1, ret * timeFrames[3] / Period()));
   }
   {
    limits[3] = limit;
   }
   */
  //if(ArrayRange(trend, 0) != rates_total)
  //  ArrayResize(trend, rates_total);
    
    /*
  for(int k = 0; k < 4; k++)
   {
    int max = 0;
    while(!CheckBarCount(HullPtr[k], 1000) && max < 10)
     {
      Sleep(100);
      max++;
     }
   }
   */
   /*
  if(CopyBuffer(HullPtr[0], 0, 0, limits[0] + 1, hullValues1) <= 0)
   {
    Print("Getting Hull 1 is failed! Error", ErrorMsg(GetLastError()));
   }
  if(CopyBuffer(HullPtr[1], 0, 0, limits[1] + 1, hullValues2) <= 0)
   {
    Print("Getting Hull 2 is failed! Error", ErrorMsg(GetLastError()));
   }
  if(CopyBuffer(HullPtr[2], 0, 0, limits[2] + 1, hullValues3) <= 0)
   {
    Print("Getting Hull 3 is failed! Error", ErrorMsg(GetLastError()));
   }
  if(CopyBuffer(HullPtr[3], 0, 0, limits[3] + 1, hullValues4) <= 0)
   {
    Print("Getting Hull 4 is failed! Error", ErrorMsg(GetLastError()));
   }
   */
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
      string name = UniqueID +t;
      bool ok = ObjectCreate(0, name, OBJ_TEXT, window,  iTime(NULL, 0, 1),  t+1  + LabelsVerticalShift);
      ok = ObjectSetInteger(0, name, OBJPROP_COLOR, (int)LabelsColor);
      ok = ObjectSetDouble(0, name, OBJPROP_PRICE,  t+1 + LabelsVerticalShift);
      ok = ObjectSetString(0, name, OBJPROP_TEXT, label);
      ok = ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
      ok = ObjectSetString(0, name, OBJPROP_FONT, "Arial");
     // ObjectSetInteger(0, name, OBJPROP_TIME,  iTime(NULL, 0, 0) + Period()*LabelsHorizontalShift *10);  //*60
      initialized=true;
     }
   }
  
  for(int t = 0; t < 4; t++)
   {
    string name = UniqueID +t;
    ObjectSetInteger(0, name, OBJPROP_TIME,  iTime(NULL, PERIOD_CURRENT, 0) + PeriodSeconds()*LabelsHorizontalShift );  //*60
   }

      double val1=0;
      double val0=0;

   for (int i = limit; i>=0;i--)
   {
 //   trend[r][_up] = 0;
 //   trend[r][_dn] = 0;
    datetime curtime = iTime(NULL, 0, i);
    for(int k = 0; k < 4; k++)
     {
      int y = i;
      
      if(Period() != timeFrames[k])
       {
        y = iBarShift(NULL, (ENUM_TIMEFRAMES)timeFrames[k], curtime, true);
        //      int error = GetLastError();
        //      Print(__FUNCTION__, " ERROR:", error, " - ", ErrorMsg(error));
       }
      if(y > -1)
       {
        // double state = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[k], indicatorFileName, "calculateValue", "", "", "", HullPeriod, HullPrice, 0, y);
     //   double state = GetIndicatorValue(HullPtr[k], 0, y);
          val1 = GetIndicatorValue(HullPtr[k], 0, y+1);;
        //val1 = val0;
        val0 = GetIndicatorValue(HullPtr[k], 0, y);;

        /*
        if(k == 0 && y < limits[0] - 1)
         {
          val1 = hullValues1[y + 1];
          val0 = hullValues1[y];
         }
        if(k == 1 && y < limits[1] - 1)
         {
          val1 = hullValues2[y + 1];
          val0 = hullValues2[y];
         }
        if(k == 2 && y < limits[2] - 1)
         {
          val1 = hullValues3[y + 1];
          val0 = hullValues3[y];
         }
        if(k == 3 && y < limits[3] - 1)
         {
          val1 = hullValues4[y + 1];
          val0 = hullValues4[y];
         }
         */
        bool isUp = (val0 >= val1);
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
         /*
        if(isUp)
          trend[r][_up] += 1;
        else
          trend[r][_dn] += 1;
          */
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckBarCount(int handle, int bars)
 {
  int cal = BarsCalculated(handle);
  if(cal < bars)
   {
    //Print("Not all data is calculated (",cal,"bars ). Error",GetLastError());
    return (false);
   }
  return (true);
 }
//+------------------------------------------------------------------+
