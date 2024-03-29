//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


#property version   "1.00"


#include  <CB/hullMA.mqh>
CHull iHull;
//CHull iHull2;

//The Hull Moving Average (HMA), developed by Alan Hull, is an extreme-
//ly fast and smooth moving average that almost eliminates lag altoge-
//ther and manages to improve smoothing at the same time.To calculate
//it, firts, you have to calculate a difference between two LWMA of
//periods p/2 and p and then calculate another LWMA from this differen-
//ce but with a period of square root of p

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


//---- input parameters
input  ENUM_TIMEFRAMES    TimeFrame=PERIOD_CURRENT;
input int                 HMAPeriod=12;           // Period
input int                 HMAShift=0;             // Shift
input ENUM_APPLIED_PRICE  InpMAPrice=5;           // Price
input double              Divisor = 2.0;
input int     Filter         = 0;
input bool    Color          = true;
input int     ColorBarBack   = 0;

//---- indicator buffers
double MABuffer[];
double UpBuffer[];
double trend[];
double barcount[];

string indicatorFileName;
bool calculateValue=true;
bool returnBars=false;
int iCust=0;
int testMA=0;
ENUM_TIMEFRAMES mTimeFrame;
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

   IndicatorSetInteger(INDICATOR_DIGITS,Digits());

//--- drawing settings
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
 //  PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrRed);
   SetIndexBuffer(0,MABuffer,INDICATOR_DATA);

   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
 //  PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrBlue);
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
   ArraySetAsSeries(UpBuffer,true);

   SetIndexBuffer(TREND_BUFFER,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(COUNT_BUFFER,barcount,INDICATOR_CALCULATIONS);

   PlotIndexSetString(0,PLOT_LABEL,timeFrameToString(mTimeFrame) + ":Hull Moving Average");
   PlotIndexSetString(1,PLOT_LABEL,"Up");

// PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,HMAPeriod);
// PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,HMAPeriod);

   iHull.init(HMAPeriod,Divisor,InpMAPrice);


   /*
   extern ENUM_TIMEFRAMES     TimeFrame=PERIOD_CURRENT;
   extern int                 HMAPeriod=12;           // Period
   extern int                 HMAShift=0;             // Shift
   extern ENUM_APPLIED_PRICE  InpMAPrice=5;           // Price
   extern double              Divisor = 2.0;
   extern int     Filter         = 0;
   extern bool    Color          = true;
   extern int     ColorBarBack   = 0;
   */
   testMA = iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE);

   indicatorFileName = "CB\\MA\\" +MQLInfoString(MQL_PROGRAM_NAME);

   iCust= iCustom(NULL,mTimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0);
//        trend[shift]= iCustom(NULL,mTimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0);

   if(iCust < 0)
     {
      Comment("Init Failed!");
      return(INIT_FAILED);
     }


//--- name for indicator label
   string myname = StringFormat("%s (%s,%d,%1.1f,%d",indicatorFileName,timeFrameToString(mTimeFrame),HMAPeriod,Divisor, HMAShift);
   IndicatorSetString(INDICATOR_SHORTNAME,myname);
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
   long limit;
   long k,n, shift;
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(time,true);
//---
   if(rates_total<=HMAPeriod)
      return(0);

   limit = MathMin(rates_total-prev_calculated-1,rates_total-2);

   if (limit <=0) limit=1;
   barcount[0] = limit;


   if(mTimeFrame != _Period)
     {
      int barcount =   GetIndicatorBufferValue(iCust,0,COUNT_BUFFER); // iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,COUNT_BUFFER,0);
      limit = MathMax(limit,MathMin(Bars(NULL,0)-1,barcount*mTimeFrame/Period()));

      for(shift=limit; shift>=0; shift--)
        {
         MABuffer[shift]=EMPTY_VALUE;
         trend[shift]= EMPTY_VALUE;
         int y = iBarShift(NULL,mTimeFrame,time[shift]);
         if(y > -1)
           {
            double val  = GetIndicatorBufferValue(iCust,y,0); // iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,0,y);
            double tr =  GetIndicatorBufferValue(iCust,y,TREND_BUFFER); // iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,TREND_BUFFER,y);

            MABuffer[shift]=val;
            trend[shift]=tr;

            // glätten
            datetime ftime = iTime(NULL,mTimeFrame,y);
            for(n = 1; shift+n < Bars(NULL,0)-1 && time[shift+n] >= ftime; n++)
               continue;
            for(k = 1; k < n; k++)
              {
               MABuffer[shift+k] = MABuffer[shift]  +(MABuffer[shift+n]-MABuffer[shift])*k/n;
              }
           }
        }
     }
   else
     {
    //  Print(__FUNCTION__,": CALCULATIONG: TimeFrame=",_Period, " limit=",limit); ;
      //--- hull moving average 1st buffer
      for(shift=limit; shift>=0; shift--)
        {
         MABuffer[shift]=EMPTY_VALUE;
         trend[shift]= EMPTY_VALUE;
         double hullval = iHull.calculate(shift);  //iHull.calculate(price,shift,Bars);
         MABuffer[shift]= hullval ; //open[shift]; // hullval;

         if(Filter>0)
           {
            if(MathAbs(MABuffer[shift]-MABuffer[shift+1]) < Filter*Point())
               MABuffer[shift]=MABuffer[shift+1];
           }

         trend[shift]=trend[shift+1];

         if(MABuffer[shift]-MABuffer[shift+1] > Filter*Point())
            trend[shift]= 1;
         if(MABuffer[shift+1]-MABuffer[shift] > Filter*Point())
            trend[shift]=-1;
         //   Print(__FUNCTION__,": CALCULATIONG: TimeFrame=",_Period," shift=", shift," Time=",time[shift], " Hull=",hullval);

        }
     }



   if(Color)
     {
      for(shift=limit; shift>=0; shift--)
        {
         UpBuffer[shift]=EMPTY_VALUE;
         //    Print(__FUNCTION__,": shift=",shift," trend=",trend[shift]);
         if(trend[shift]>=0)
           {
            UpBuffer[shift] = MABuffer[shift];
            if(trend[shift+ColorBarBack]<0)
               UpBuffer[shift+ColorBarBack]=MABuffer[shift+ColorBarBack];
           }

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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

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
   tfs = StringToUpper(tfs);
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
     {
      if(tfs==sTfTable[i] || tfs==""+iTfTable[i])
         return(MathMax(iTfTable[i],Period()));
     }
   return(Period());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
      if(tf==iTfTable[i])
        {
         return(sTfTable[i]);
        }
   return("M"+PeriodSeconds()/60);
  }

//
//
//
//
//

//+------------------------------------------------------------------+
