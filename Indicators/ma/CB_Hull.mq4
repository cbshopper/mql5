//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


#property version   "1.00"


#include "hullMA.mqh"
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
#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_width1 2
#property indicator_color2 clrBlue
#property indicator_width2 2
//#property indicator_color3 clrBlack
//#property indicator_width3 1


//---- input parameters
extern ENUM_TIMEFRAMES     TimeFrame=PERIOD_CURRENT;
extern int                 HMAPeriod=12;           // Period
extern int                 HMAShift=0;             // Shift
extern ENUM_APPLIED_PRICE  InpMAPrice=5;           // Price
extern double              Divisor = 2.0;
extern int     Filter         = 0;
extern bool    Color          = true;
extern int     ColorBarBack   = 0;

//---- indicator buffers
double MABuffer[];
double UpBuffer[];
double DnBuffer[];
double trend[];
double barcount[];
double tmpBuffer[];

string indicatorFileName;
bool calculateValue=true;
bool returnBars=false;
//--- right input parameters flag
#define COUNT_BUFFER 3
#define TREND_BUFFER 2
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {


 //  IndicatorBuffers(5);
   IndicatorSetInteger(  INDICATOR_DIGITS,Digits()+1);

//--- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MABuffer);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,UpBuffer);

  // SetIndexStyle(2,DRAW_LINE);
  // SetIndexBuffer(2,tmpBuffer);

  // SetIndexStyle(2,DRAW_LINE);
  // SetIndexBuffer(2,DnBuffer);

   SetIndexBuffer(TREND_BUFFER,trend);
   SetIndexBuffer(COUNT_BUFFER,barcount);


 //  SetIndexEmptyValue(1,EMPTY_VALUE);
 //  SetIndexEmptyValue(2,EMPTY_VALUE);
 //  SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexLabel(0,timeFrameToString(TimeFrame) + ":Hull Moving Average V1");
   SetIndexLabel(1,"Up");
 //  SetIndexLabel(2,"Dn");

   SetIndexDrawBegin(0,HMAPeriod);
   SetIndexDrawBegin(1,HMAPeriod);
   SetIndexDrawBegin(2,HMAPeriod);


   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));

   iHull.init(HMAPeriod,Divisor,InpMAPrice);
 //  iHull2.init(HMAPeriod,1.0,InpMAPrice);
   indicatorFileName = "MA\\" + WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);

//--- name for indicator label
   string myname = StringFormat("%s (%s,%d,%1.1f,%d",indicatorFileName,timeFrameToString(TimeFrame),HMAPeriod,Divisor, HMAShift);
   IndicatorShortName(myname);
//--- check for input parameters
//--- initialization done
   return(INIT_SUCCEEDED);
  }
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
   int k,n, shift;
//---
   if(rates_total<=HMAPeriod)
      return(0);

   int counted_bars = prev_calculated;
   if(counted_bars>0) counted_bars--;
   limit = MathMin(rates_total-prev_calculated-1,rates_total-2);
   
   barcount[0] = limit;
 
 
   if(TimeFrame != _Period)
     {
      int barcount = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,COUNT_BUFFER,0);
      limit = MathMax(limit,MathMin(Bars-1,barcount*TimeFrame/Period()));

      for(shift=limit; shift>=0; shift--)
        {
         int y = iBarShift(NULL,TimeFrame,Time[shift]);
         //input string              TimeFrame="calculate";
         //input int                 HMAPeriod=12;           // Period
         //input int                 HMAShift=0;             // Shift
         //input ENUM_APPLIED_PRICE  InpMAPrice=5;           // Price
         //extern int     Filter         = 0;
         //extern bool    Color          = true;
         //extern int     ColorBarBack   = 0;
         MABuffer[shift] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,0,y);
         trend[shift]= iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HMAPeriod,HMAShift,InpMAPrice,Divisor,Filter,0,0,TREND_BUFFER,y);
         
         // glätten
         datetime ftime = iTime(NULL,TimeFrame,y);
         for(n = 1; shift+n < Bars-1 && Time[shift+n] >= ftime; n++)
            continue;
         for(k = 1; k < n; k++)
           {
            MABuffer[shift+k] = MABuffer[shift]  +(MABuffer[shift+n]-MABuffer[shift])*k/n;
           }
        }

     }
   else
     {
      //--- hull moving average 1st buffer
      for(shift=limit; shift>=0; shift--)
        {
              double price = iMA(NULL,0,1,0,MODE_SMA,InpMAPrice,shift);
         //     double mprice = iHull(price,HMAPeriod,i);

         double mprice1 = iHull.calculate(price,shift,Bars);
         MABuffer[shift]=mprice1;
       //  double mprice2 = iHull2.calculate(mprice1,shift,Bars);
       
        // MABuffer[shift]= 2.0*mprice1- mprice2 ; //iHull(InpMAPrice,HMAPeriod,i);
         if(Filter>0)
           {
            if(MathAbs(MABuffer[shift]-MABuffer[shift+1]) < Filter*Point)
               MABuffer[shift]=MABuffer[shift+1];
           }
         
         trend[shift]=trend[shift+1];

         if(MABuffer[shift]-MABuffer[shift+1] > Filter*Point)
            trend[shift]= 1;
         if(MABuffer[shift+1]-MABuffer[shift] > Filter*Point)
            trend[shift]=-1;

        }
     }



   if(Color)
     {
      for(shift=limit; shift>=0; shift--)
        {
         if(trend[shift]>=0)
           {
            UpBuffer[shift] = MABuffer[shift];
            if(trend[shift+ColorBarBack]<0)
               UpBuffer[shift+ColorBarBack]=MABuffer[shift+ColorBarBack];
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
   tfs = StringUpperCase(tfs);
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
      if(tfs==sTfTable[i] || tfs==""+iTfTable[i])
         return(MathMax(iTfTable[i],Period()));
   return(Period());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
      if(tf==iTfTable[i])
         return(sTfTable[i]);
   return("");
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringUpperCase(string str)
  {
   string   s = str;

   for(int length=StringLen(str)-1; length>=0; length--)
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
