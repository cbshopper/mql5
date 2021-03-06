//+------------------------------------------------------------------+
//|                                                      CB_IMAX |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


#property version   "0.01"



//CHull1 iHull;
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_width1 2
#property indicator_color2 clrBlue
#property indicator_width2 2
//#property indicator_color3 clrBlack
//#property indicator_width3 1


//---- input parameters
input string __IMAXINDICATOR_SETTINGS_ = " ---------------- IMAX INDICATOR SETTINGS -------------------";

extern ENUM_TIMEFRAMES     TimeFrame = PERIOD_CURRENT;
extern bool    Color          = true;
extern int     ColorBarBack   = 0;


#include <CB_IMAX.mqh>


//---- indicator buffers
double MABuffer[];
double UpBuffer[];
double DnBuffer[];
double trend[];
double barcount[];
double tmpBuffer[];
double work1[];
double work2[];
string indicatorFileName;
bool calculateValue = true;
bool returnBars = false;
double BufferVal=0;
//--- right input parameters flag
#define COUNT_BUFFER 3
#define TREND_BUFFER 2
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {


   IndicatorBuffers(6);
   IndicatorDigits(Digits + 1);

//--- drawing settings
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, MABuffer);

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, UpBuffer);

// SetIndexStyle(2,DRAW_LINE);
// SetIndexBuffer(2,tmpBuffer);

// SetIndexStyle(2,DRAW_LINE);
// SetIndexBuffer(2,DnBuffer);

   SetIndexBuffer(TREND_BUFFER, trend);
   SetIndexBuffer(COUNT_BUFFER, barcount);

   SetIndexBuffer(COUNT_BUFFER + 1, work1);
   SetIndexBuffer(COUNT_BUFFER + 2, work2);


   SetIndexLabel(0, timeFrameToString(TimeFrame) + ":IMAX");
   SetIndexLabel(1, "Up");
//  SetIndexLabel(2,"Dn");

   SetIndexDrawBegin(0, MaPeriod);
   SetIndexDrawBegin(1, MaPeriod);
   SetIndexDrawBegin(2, MaPeriod);


   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));

//  iHull.init(HMAPeriod,Divisor,InpMAPrice);
//  iHull2.init(HMAPeriod,1.0,InpMAPrice);
   indicatorFileName = "MA\\" + WindowExpertName();
   TimeFrame         = fmax(TimeFrame, _Period);

//--- name for indicator label
   string myname = StringFormat("%s (TF=%s,Method=%d,Period=%d)", indicatorFileName, timeFrameToString(TimeFrame), MaMethod, MaPeriod);
   IndicatorShortName(myname);
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
   if(rates_total <= MaPeriod)
      return(0);

   int counted_bars = prev_calculated;
   if(counted_bars > 0)
      counted_bars--;
   limit = MathMin(rates_total - prev_calculated - 1, rates_total - 2);



   barcount[0] = limit;


   if(TimeFrame != _Period)
     {
     
     /*  Parameters:
     
     extern ENUM_TIMEFRAMES     TimeFrame = PERIOD_CURRENT;
extern bool    Color          = true;
extern int     ColorBarBack   = 0;
extern ENUM_MMA_METHOD MaMethod = MMODE_HULLMA;
extern int Filter=0;
extern int MaPeriod=10;
extern int MaShift=0;
extern ENUM_APPLIED_PRICE MaPrice=PRICE_CLOSE;

     
     */
     
     
     
     
     
      int barcount = iCustom(NULL, TimeFrame, indicatorFileName, "",PERIOD_CURRENT, Color,ColorBarBack,"",MaMethod,Filter, MaPeriod,  MaShift, MaPrice, COUNT_BUFFER, 0);
      limit = MathMax(limit, MathMin(Bars - 1, barcount * TimeFrame / Period()));

      for(shift = limit; shift >= 0; shift--)
        {
         int y = iBarShift(NULL, TimeFrame, Time[shift]);
         MABuffer[shift] = iCustom(NULL, TimeFrame, indicatorFileName, "",PERIOD_CURRENT, Color,ColorBarBack,"",MaMethod,Filter, MaPeriod,  MaShift, MaPrice, 0, y);
         trend[shift] = iCustom(NULL, TimeFrame, indicatorFileName, "",PERIOD_CURRENT, Color,ColorBarBack,"",MaMethod,Filter, MaPeriod,  MaShift, MaPrice, TREND_BUFFER, y);

         // glätten
         datetime ftime = iTime(NULL, TimeFrame, y);
         for(n = 1; shift + n < Bars - 1 && Time[shift + n] >= ftime; n++)
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
         MABuffer[shift]=iMAX(MaPeriod,MaMethod,Filter,shift,0);
         trend[shift] = trend[shift + 1];

         if(MABuffer[shift] - MABuffer[shift + 1] > Filter * Point)
            trend[shift] = 1;
         if(MABuffer[shift + 1] - MABuffer[shift] > Filter * Point)
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
            DnBuffer[shift] = EMPTY_VALUE;
           }
         /*
          if(trend[shift]<0)
            {
             DnBuffer[shift] = MABuffer[shift];
             if(trend[shift+ColorBarBack]>0)
                DnBuffer[shift+ColorBarBack]=MABuffer[shift+ColorBarBack];
             UpBuffer[shift] = EMPTY_VALUE;
            }
            */
        }
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int    iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
  {
   tfs = StringUpperCase(tfs);
   for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if(tfs == sTfTable[i] || tfs == "" + iTfTable[i])
         return(MathMax(iTfTable[i], Period()));
   return(Period());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if(tf == iTfTable[i])
         return(sTfTable[i]);
   return("");
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringUpperCase(string str)
  {
   string   s = str;

   for(int length = StringLen(str) - 1; length >= 0; length--)
     {
      int char_A = StringGetChar(s, length);
      if((char_A > 96 && char_A < 123) || (char_A > 223 && char_A < 256))
         s = StringSetChar(s, length, char_A - 32);
      else
         if(char_A > -33 && char_A < 0)
            s = StringSetChar(s, length, char_A + 224);
     }
   return(s);
  }
//+------------------------------------------------------------------+
