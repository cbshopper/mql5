//+------------------------------------------------------------------+
//|                                                        4Hull.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <CB/CB_Commons.mqh>
#include <CB/CB_Utils.mqh>
#include <CB/CB_IndicatorHelper.mqh>
#include <CB/CB_Drawing.mqh>
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 10
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
enum MATYPES
  {
   SMA = 0,
   EMA = 1,
   HULL = 2,
   AMA = 3
  };
enum AlertLevelTYPES
  {
   ONE = 1,
   TWO = 2,
   THREE = 3,
   ALL = 4
  };

//
input MATYPES MAType = EMA;
input bool            MultiTimeFrames       = true;
input ENUM_TIMEFRAMES TimeFrame1            = PERIOD_CURRENT;
input ENUM_TIMEFRAMES TimeFrame2            = PERIOD_CURRENT;
input ENUM_TIMEFRAMES TimeFrame3            = PERIOD_CURRENT;
input ENUM_TIMEFRAMES TimeFrame4            = PERIOD_CURRENT;
input int    MaPeriod1            = 12; // Period
input int    MaPeriod2            = 24; // Period
input int    MaPeriod3            = 50; // Period
input int    MaPeriod4            = 100; // Period
input ENUM_APPLIED_PRICE MaPrice =  PRICE_TYPICAL;  // Price
input string UniqueID              = "4xMA Trend";
input color  LabelsColor           = clrBlack;
input int    LabelsHorizontalShift = 0;
input double LabelsVerticalShift   = 0.0;
input int    BarCount              = 10000;
input bool   DrawBuySellMarker              = true;
input AlertLevelTYPES    alertsLevel           = TWO;  //Alerts Level: count of MA's 1..4
#include <CB/CB_Notify.mqh>

//
double matre1u[];
double matre1d[];
double matre2u[];
double matre2d[];
double matre3u[];
double matre3d[];
double matre4u[];
double matre4d[];
double trendup[];
double trenddn[];
ENUM_TIMEFRAMES    timeFrames[4];
int periods[4];
int    limits[4];
int    returnBarsArr[4];
int    MaHandles[4];
bool   returnBars;
bool   calculateValue;
string MAIndicatorFileName = "CB/ma/CB_Hull";


bool initialized = false;
string UniqueIDName = "";
int alertsLevelINT = 0;
#define COUNT_BUFFER 2
#define ARROW_NAME "4MASig"

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS, 1);
   ArraySetAsSeries(matre1u, true);
   ArraySetAsSeries(matre1d, true);
   ArraySetAsSeries(matre2u, true);
   ArraySetAsSeries(matre2d, true);
   ArraySetAsSeries(matre3u, true);
   ArraySetAsSeries(matre3d, true);
   ArraySetAsSeries(matre4u, true);
   ArraySetAsSeries(matre4d, true);
   ArraySetAsSeries(trenddn, true);
   ArraySetAsSeries(matre4d, true);
   ArrayInitialize(matre1u, EMPTY_VALUE);
   ArrayInitialize(matre1d, EMPTY_VALUE);
   ArrayInitialize(matre2u, EMPTY_VALUE);
   ArrayInitialize(matre2d, EMPTY_VALUE);
   ArrayInitialize(matre3u, EMPTY_VALUE);
   ArrayInitialize(matre3d, EMPTY_VALUE);
   ArrayInitialize(matre4u, EMPTY_VALUE);
   ArrayInitialize(trenddn, 0);
   ArrayInitialize(trendup, 0);
//--- indicator buffers mapping
   SetIndexBuffer(0, matre1u, INDICATOR_DATA);
   SetIndexBuffer(1, matre1d, INDICATOR_DATA);
   SetIndexBuffer(2, matre2u, INDICATOR_DATA);
   SetIndexBuffer(3, matre2d, INDICATOR_DATA);
   SetIndexBuffer(4, matre3u, INDICATOR_DATA);
   SetIndexBuffer(5, matre3d, INDICATOR_DATA);
   SetIndexBuffer(6, matre4u, INDICATOR_DATA);
   SetIndexBuffer(7, matre4d, INDICATOR_DATA);
   SetIndexBuffer(8, trendup, INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, trenddn, INDICATOR_CALCULATIONS);
   PlotIndexSetString(0, PLOT_LABEL, "matre1u");
   PlotIndexSetString(1, PLOT_LABEL, "matre1d");
   PlotIndexSetString(2, PLOT_LABEL, "matre2u");
   PlotIndexSetString(3, PLOT_LABEL, "matre2d");
   PlotIndexSetString(4, PLOT_LABEL, "matre3u");
   PlotIndexSetString(5, PLOT_LABEL, "matre3d");
   PlotIndexSetString(6, PLOT_LABEL, "matre4u");
   PlotIndexSetString(7, PLOT_LABEL, "matre4d");
//
   for(int i = 0; i < 8; i++)
     {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(i, PLOT_ARROW, 110);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, 1);
     }
   if(TimeFrame1 == PERIOD_CURRENT)
      timeFrames[0] = Period();
   else
      timeFrames[0] = TimeFrame1;
   if(MultiTimeFrames)
     {
      timeFrames[1] = NextTimeFrame(timeFrames[0], TimeFrame1);
      timeFrames[2] = NextTimeFrame(timeFrames[1], TimeFrame2);
      timeFrames[3] = NextTimeFrame(timeFrames[2], TimeFrame3);
      periods[0] = MaPeriod1;
      periods[1] = MaPeriod1;
      periods[2] = MaPeriod1;
      periods[3] = MaPeriod1;
     }
   else
     {
      timeFrames[1] = timeFrames[0];
      timeFrames[2] = timeFrames[0];
      timeFrames[3] = timeFrames[0];
      periods[0] = MaPeriod1;
      periods[1] = MaPeriod2;
      periods[2] = MaPeriod3;
      periods[3] = MaPeriod4;
      if(MaPeriod2 == 0)
         periods[1] = MaPeriod1;
      if(MaPeriod3 == 0)
         periods[2] = MaPeriod1;
      if(MaPeriod4 == 0)
         periods[3] = MaPeriod1;
     }
   /* Parameters of CB_HULL
   input int                 HMAPeriod = 12;         // Period
   input ENUM_APPLIED_PRICE  InpMAPrice = 5;         // Price
   input double              Divisor = 2.0;
   input int     Filter         = 0;
   input bool    Color          = true;
   input int     ColorBarBack   = 0;
   iCust = iCustom(NULL, mTimeFrame, indicatorFileName,  HMAPeriod, InpMAPrice, Divisor, Filter, Color, 0);
   */
   switch(MAType)
     {
      case SMA:
         MaHandles[0] = iMA(NULL, (ENUM_TIMEFRAMES) timeFrames[0],  periods[0], 0, MODE_SMA, MaPrice);
         MaHandles[1] =  iMA(NULL, (ENUM_TIMEFRAMES) timeFrames[1],  periods[1], 0, MODE_SMA, MaPrice);
         MaHandles[2] =  iMA(NULL, (ENUM_TIMEFRAMES) timeFrames[2],  periods[2], 0, MODE_SMA, MaPrice);
         MaHandles[3] =  iMA(NULL, (ENUM_TIMEFRAMES) timeFrames[3],  periods[3], 0, MODE_SMA, MaPrice);
         break;
      case EMA:
         MaHandles[0] =  iMA(NULL, (ENUM_TIMEFRAMES) timeFrames[0],  periods[0], 0, MODE_EMA, MaPrice);
         MaHandles[1] =  iMA(NULL, (ENUM_TIMEFRAMES) timeFrames[1],  periods[1], 0, MODE_EMA, MaPrice);
         MaHandles[2] =  iMA(NULL, (ENUM_TIMEFRAMES) timeFrames[2],  periods[2], 0, MODE_EMA, MaPrice);
         MaHandles[3] =  iMA(NULL, (ENUM_TIMEFRAMES) timeFrames[3],  periods[3], 0, MODE_EMA, MaPrice);
         break;
      case HULL:
         MaHandles[0] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[0], MAIndicatorFileName,  periods[0], MaPrice, 2.0, 0, 0, 0);
         MaHandles[1] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[1], MAIndicatorFileName,  periods[1], MaPrice, 2.0, 0, 0, 0);
         MaHandles[2] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[2], MAIndicatorFileName,   periods[2], MaPrice, 2.0, 0, 0, 0);
         MaHandles[3] = iCustom(NULL, (ENUM_TIMEFRAMES) timeFrames[3], MAIndicatorFileName,   periods[3], MaPrice, 2.0, 0, 0, 0);
         break;
      case AMA:
         MaHandles[0] =  iAMA(NULL, (ENUM_TIMEFRAMES) timeFrames[0],  periods[0], 2, 30, 0, MaPrice);
         MaHandles[1] =  iAMA(NULL, (ENUM_TIMEFRAMES) timeFrames[1],  periods[1], 2, 30, 0, MaPrice);
         MaHandles[2] =  iAMA(NULL, (ENUM_TIMEFRAMES) timeFrames[2],  periods[2], 2, 30, 0, MaPrice);
         MaHandles[3] =  iAMA(NULL, (ENUM_TIMEFRAMES) timeFrames[3],  periods[3], 2, 30, 0, MaPrice);
         break;
     }
     
     if (MaHandles[1] == -1 ) MaHandles[1] = MaHandles[0];
     if (MaHandles[2] == -1 ) MaHandles[2] = MaHandles[1];
     if (MaHandles[3] == -1 ) MaHandles[3] = MaHandles[2];
     
// MaPtr = iMA(NULL, 0, 1, 0, MODE_SMA, MaPrice);
// alertsLevel = MathMin(MathMax(alertsLevel, 3), 4);
   UniqueIDName = UniqueID + " " + MAName(MAType) + "(" + MaPeriod1 + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, UniqueIDName);
   OnDeinit(0);
   initialized = false;
   alertsLevelINT = 0;
   switch(alertsLevel)
     {
      case ONE:
         alertsLevelINT = 1;
         break;
      case TWO:
         alertsLevelINT = 3;
         break;
      case THREE:
         alertsLevelINT = 7;
         break;
      case ALL:
         alertsLevelINT = 15;
         break;
     }
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int t = 0; t < 4; t++)
      ObjectDelete(0, UniqueIDName + (string)t);
   ObjectsDeleteAll(0, ARROW_NAME);
   ObjectsDeleteAll(0, UniqueIDName);
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
   if(limit > BarCount)
      limit = BarCount;
//if(limit > rates_total - 1)
//  limit = rates_total - 1;
//
//   Print(__FUNCTION__,": limit=",limit," rates_total=",rates_total, " prev_calculated=",prev_calculated);
//
//
   if(!initialized)
     {
      //initialized = true;
      int window = ChartWindowFind(0, UniqueIDName);
      for(int t = 0; t < 4; t++)
        {
         string label = EnumToString(timeFrames[t]) + "-" + periods[t]; // timeFrameToString(timeFrames[t]);
         string name = UniqueIDName + (string)t;
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
      string name = UniqueIDName + (string)t;
      ObjectSetInteger(0, name, OBJPROP_TIME,  iTime(NULL, PERIOD_CURRENT, 0) + PeriodSeconds()*LabelsHorizontalShift);   //*60
     }
   double val1 = 0;
   double val0 = 0;
   for(int i = limit; i >= 0; i--)
     {
      datetime curtime = iTime(NULL, 0, i);
      trenddn[i] = 0;
      trendup[i] = 0;
      for(int k = 0; k < 4; k++)
        {
         int y = i;
         /*
           for(i = 0; i < 100; i++)
                {
                 if(BarsCalculated(MaHandles[k]) > 0)
                     break;
                 Sleep(50);
                }
                */
         int cnt = BarsCalculated(MaHandles[k]);
         if(cnt < 0)
            return 0;
         if(Period() != timeFrames[k])
           {
            y = iBarShift(NULL, (ENUM_TIMEFRAMES)timeFrames[k], curtime, true) ;
            //      int error = GetLastError();
            //      Print(__FUNCTION__, " ERROR:", error, " - ", ErrorMsg(error));
           }
         if(y > -1 && y < cnt - 1)
           {
            val1 = GetIndicatorBufferValue(MaHandles[k],  y + 1, 0);;
            val0 = GetIndicatorBufferValue(MaHandles[k], y, 0);;
            if(val1 < 0 || val0 < 0)
              {
               val0 = 0;
               val1 = 0;
              }
            bool isUp = (val0 > val1);
            switch(k)
              {
               case 0 :
                  if(isUp)
                    {
                     matre1u[i] = k + 1;
                     matre1d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     matre1d[i] = k + 1;
                     matre1u[i] = EMPTY_VALUE;
                    }
                  break;
               case 1 :
                  if(isUp)
                    {
                     matre2u[i] = k + 1;
                     matre2d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     matre2d[i] = k + 1;
                     matre2u[i] = EMPTY_VALUE;
                    }
                  break;
               case 2 :
                  if(isUp)
                    {
                     matre3u[i] = k + 1;
                     matre3d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     matre3d[i] = k + 1;
                     matre3u[i] = EMPTY_VALUE;
                    }
                  break;
               case 3 :
                  if(isUp)
                    {
                     matre4u[i] = k + 1;
                     matre4d[i] = EMPTY_VALUE;
                    }
                  else
                    {
                     matre4d[i] = k + 1;
                     matre4u[i] = EMPTY_VALUE;
                    }
                  break;
              }
            //     val1 = val0;
            int x = 1 << k;
            if(isUp)
              {
               trendup[i] += x;
              }
            else
              {
               trenddn[i] += x;
              }
           }
         manageArrows(i);
        }
     }
//manageArrows();
   manageAlerts();
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
double GetIndicatorValuexxx(int handle, int buffer, int index)
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
string MAName(MATYPES type)
  {
   string ret = "unknown";
   switch(type)
     {
      case SMA:
         ret = "SMA";
         break;
      case EMA:
         ret = "EMA";
         break;
      case HULL:
         ret = "HULL";
         break;
      case AMA:
         ret = "AMA";
         break;
     }
   return ret;
  }
//+------------------------------------------------------------------+
void manageAlerts()
  {
      int bar = 1;
      if(trendup[bar] >= alertsLevelINT)
         DoAlertX(bar, "4MA: BUY");
      if(trenddn[bar] >= alertsLevelINT)
         DoAlertX(bar, "4MA: SELL");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageArrows()
  {
   if(DrawBuySellMarker)
     {
      //   ObjectsDeleteAll(0, ARROW_NAME);
      //for(int bar = BarCount; bar >= 0; bar--)
      for(int bar = BarCount; bar >= 0; bar--)
        {
         manageArrows(bar);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageArrows(int bar)
  {
   if(DrawBuySellMarker)
     {
      // Print(__FUNCTION__,": i=",bar," UpTrend=",trendup[bar], " DnTrend=",trenddn[bar]);
      string upname = ARROW_NAME + "Up" + bar;
      ObjectDelete(0, upname);
      if(((int)trendup[bar] & alertsLevelINT) == alertsLevelINT  && ((int)trendup[bar + 1] & alertsLevelINT) != alertsLevelINT)   //  trendup[bar] != trendup[bar + 1]) // trenddn[bar + 1] < alertsLevelINT)
        {
         //      if(iOpen(NULL, PERIOD_CURRENT, bar + 1) < iClose(NULL, PERIOD_CURRENT, bar + 1))
         DrawArrowXL(upname, bar + 1, iLow(NULL, 0, bar) - 100 * Point(), 108, 15, clrBlue);
        }
      //  int dn = trenddn[bar];
      //  int t = dn & alertsLevelINT;
      string dnname = ARROW_NAME + "Dn" + bar;
      ObjectDelete(0, dnname);
      if(((int)trenddn[bar] & alertsLevelINT)  == alertsLevelINT && ((int)trenddn[bar + 1] & alertsLevelINT) != alertsLevelINT)   // trendup[bar] != trendup[bar + 1] ) // trenddn[bar + 1] < alertsLevelINT)
        {
         //      if(iOpen(NULL, PERIOD_CURRENT, bar + 1) > iClose(NULL, PERIOD_CURRENT, bar + 1))
         DrawArrowXL(dnname + bar, bar + 1, iHigh(NULL, 0, bar) + 100 * Point(), 108, 15, clrRed);
        }
     }
  }
//+------------------------------------------------------------------+
