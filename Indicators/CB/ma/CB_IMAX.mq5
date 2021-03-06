//+------------------------------------------------------------------+
//|                                                      CB_IMAX |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


#property version   "0.01"



//CHull1 iHull;
//--- indicator settings
#property indicator_chart_window
#property indicator_plots   2 //must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 5 //must set, can be bigger than necessary
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  2
#property indicator_type2   DRAW_LINE
#property indicator_color2  Blue
#property indicator_width2  2

#include <cb\CB_IMAX.mqh>

//---- input parameters
// input string __IMAXINDICATOR_SETTINGS_ = " ---------------- IMAX INDICATOR SETTINGS -------------------";
input ENUM_TIMEFRAMES     TimeFrame = PERIOD_CURRENT;
input int MAPeriod = 12;
input ENUM_MMA_METHOD MAMethod = MODE_EMA;
input int MAPprice = PRICE_CLOSE;
input int Filter = 0;
input bool    Color          = true;
input int     ColorBarBack   = 0;




ENUM_TIMEFRAMES mTimeFrame;
//---- indicator buffers
double MABuffer[];
double UpBuffer[];
double trend[];
double barcount[];
string indicatorFileName;
bool calculateValue = true;
bool returnBars = false;
double BufferVal=0;
int MAHandle = INVALID_HANDLE;

//--- right input parameters flag
#define COUNT_BUFFER 3
#define TREND_BUFFER 2
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {

   mTimeFrame         = fmax(TimeFrame,_Period);

   ArraySetAsSeries(MABuffer,true);
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(trend,true);
   ArraySetAsSeries(barcount,true);


   SetIndexBuffer(0, MABuffer,INDICATOR_DATA);
   SetIndexBuffer(1, UpBuffer,INDICATOR_DATA);

   SetIndexBuffer(TREND_BUFFER,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(COUNT_BUFFER,barcount,INDICATOR_CALCULATIONS);

   IndicatorSetInteger(INDICATOR_DIGITS,Digits());

   PlotIndexSetString(0,PLOT_LABEL,EnumToString(mTimeFrame) + ":IMax UP");
   PlotIndexSetString(1,PLOT_LABEL,EnumToString(mTimeFrame) + ":IMax DOWN");


//  iHull.init(HMAPeriod,Divisor,InpMAPrice);
//  iHull2.init(HMAPeriod,1.0,InpMAPrice);
   indicatorFileName = "CB\\MA\\" +MQLInfoString(MQL_PROGRAM_NAME);

//--- name for indicator label
   string myname = StringFormat("%s (%s,%d,%1.1f,%d)",indicatorFileName,EnumToString(mTimeFrame),MAPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,myname);

   if(mTimeFrame != _Period)
     {
      /*
      input ENUM_TIMEFRAMES     TimeFrame = PERIOD_CURRENT;
      input int MAPeriod = 12;
      input int MAMethod = MODE_EMA;
      input int MAPprice = PRICE_CLOSE;
      input int Filter = 0;

      input bool    Color          = true;
      input int     ColorBarBack   = 0;
      */

      MAHandle=  iCustom(NULL, mTimeFrame, indicatorFileName, PERIOD_CURRENT, MAPeriod, MAMethod,  MAPprice, Filter,0,0);
     }
//--- check for input parameters
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Hull Moving Average                                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit;
   int k, n, shift;
//---
   if(rates_total <= MAPeriod)
      return(0);

   limit = MathMin(rates_total - prev_calculated - 1, rates_total - 2);



   barcount[0] = limit;


   if(mTimeFrame != _Period)
     {

      int barcount = GetIndicatorBufferValue(MAHandle,COUNT_BUFFER,0); //iCustom(NULL, TimeFrame, indicatorFileName, "",PERIOD_CURRENT, Color,ColorBarBack,"",MaMethod,Filter, MaPeriod,  MaShift, MaPrice, COUNT_BUFFER, 0);
      limit = MathMax(limit, MathMin(Bars - 1, barcount * TimeFrame / Period()));

      for(shift = limit; shift >= 0; shift--)
        {
         MABuffer[shift]=EMPTY_VALUE;
         UpBuffer[shift]=EMPTY_VALUE;
         trend[shift]= EMPTY_VALUE;

         int y = iBarShift(NULL, TimeFrame, time[shift]);
         MABuffer[shift] =GetIndicatorBufferValue(MAHandle,0,y);  // iCustom(NULL, TimeFrame, indicatorFileName, "",PERIOD_CURRENT, Color,ColorBarBack,"",MaMethod,Filter, MaPeriod,  MaShift, MaPrice, 0, y);
         trend[shift] = GetIndicatorBufferValue(MAHandle,TREND_BUFFER,y);  //iCustom(NULL, TimeFrame, indicatorFileName, "",PERIOD_CURRENT, Color,ColorBarBack,"",MaMethod,Filter, MaPeriod,  MaShift, MaPrice, TREND_BUFFER, y);

         // glätten
         datetime ftime = iTime(NULL, TimeFrame, y);
         for(n = 1; shift + n < Bars - 1 && time[shift + n] >= ftime; n++)
            continue;
         for(k = 1; k < n; k++)
           {
            MABuffer[shift + k] = MABuffer[shift]  + (MABuffer[shift + n] - MABuffer[shift]) * k / n;
           }
        }

     }
   else
     {
      for(shift = limit; shift >= 0; shift--)
        {
         MABuffer[shift]=EMPTY_VALUE;
         UpBuffer[shift]=EMPTY_VALUE;
         trend[shift]= EMPTY_VALUE;


         MABuffer[shift]=iMAX(MAPeriod,MAMethod,MAPprice,Filter,shift);
         trend[shift] = trend[shift + 1];

         if(MABuffer[shift] - MABuffer[shift + 1] > 0) //Filter * Point())
            trend[shift] = 1;
         if(MABuffer[shift + 1] - MABuffer[shift] > 0) // Filter * Point())
            trend[shift] = -1;

        }
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Color)
     {
      for(shift = limit; shift >= 0; shift--)
        {
         if(trend[shift] >= 0)
           {
            UpBuffer[shift] = MABuffer[shift];
            if(trend[shift + ColorBarBack] < 0)
               UpBuffer[shift + ColorBarBack] = MABuffer[shift + ColorBarBack];
           }

        }
     }
//--- done
   return(rates_total);
  }
