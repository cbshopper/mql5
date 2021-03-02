//+------------------------------------------------------------------+
//|                                                 CB_uniSignal.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <cb\CB_IMAX.mqh>
//extern int Trend_period,Trend_method,Trend_price,Trend_mindiff,stopma_period,stopma_method,stopma_price;
//extern double IndBuffer0[], IndBuffer1[], IndBuffer2[], IndBuffer3[], IndBuffer4[], IndBuffer5[];
//extern double trend0,trend1;
//extern bool check_Trend;

int FirstBar=3;

//---- input parameters
string IndNames[6] = {"Ma1","Ma2","Ma3","SAR","TrendMA","StopMA"};
color IndColors[6] = {clrRed, clrBlue,clrDarkOliveGreen,clrBlack,clrGreen,clrBlack};

//*===========================================================================================
// global vars for Indicator
//*===========================================================================================
int IndType[6] = {DRAW_LINE,DRAW_LINE,DRAW_LINE,DRAW_LINE,DRAW_LINE,DRAW_LINE};
int IndStyles[6] = {STYLE_SOLID,STYLE_SOLID,STYLE_SOLID,STYLE_DOT,STYLE_SOLID,STYLE_SOLID};
int IndWidths[6] = {2,2,2,1,1,1};



#ifndef SIGNAL_SETTINGS

#ifdef SIGNALS_MA
input int Signal1MATurn0=0;
input int Signal1MATurn=0;
input int Signal2MACross=0;
input int Signal3MACross=0;
#else
int Signal1MATurn0=0;
int Signal1MATurn=0;
int Signal2MACross=0;
int Signal3MACross=0;
#endif

#ifdef SIGNALS_SAR
input int SignalSAR=0;
#else
int SignalSAR=0;
#endif

#ifdef SIGNALS_MACD
input int SignalMACD=0;
#else
int SignalMACD=0;
#endif

#ifdef SIGNALS_STO
input int SignalSTO=0;
//int SignalRSISTO=0;
//int SignalMASTO=0;
#else
int SignalSTO=0;
//int SignalRSISTO=0;
//int SignalMASTO=0;
#endif

#endif



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetValues(int shift, double &IndBuffer0[],double &IndBuffer1[],double &IndBuffer2[],
               double &IndBuffer3[],double &IndBuffer4[],double &IndBuffer5[],
               double &Help0[],double &Help1[])
  {
// IndBuffer0: ma1
// IndBuffer1; ma2
// indBuffer2: ma3
// indBuffer3:
// IndBuffer4: trend
// IndBuffer5: stop
 
 
   double nulval =0; //EMPTY_VALUE
   IndBuffer0[shift]=nulval;
   IndBuffer1[shift]=nulval;
   IndBuffer2[shift]=nulval;
   IndBuffer3[shift]=nulval;
   IndBuffer4[shift] = nulval;
   IndBuffer5[shift] = nulval;

   double val=0;

   if(Signal1MATurn0>0 ||Signal1MATurn>0 || Signal2MACross>0 || Signal3MACross>0)
     {
      //  CiMAX iMax1;
      //  iMax1.init((Ma1Period,Ma1Method,Ma1Price);
      val =iMAX(Ma1Period,Ma1Method,Ma1Price,Filter,shift);
      IndBuffer0[shift]=val;
      if(Signal2MACross>0 )
        {
         val =iMAX(Ma1Period*Ma2Factor,Ma2Method,Ma2Price,Filter,shift);;
         IndBuffer1[shift]=val;
        }
      if(Signal3MACross>0 )
        {
         val =iMAX(Ma1Period*Ma3Factor,Ma3Method,Ma3Price,Filter,shift);
         IndBuffer2[shift]=val;
        }
     }
  
   if(SignalSAR>0)
     {
      val = GetIndicatorValue(Sar1Ptr,shift);
      IndBuffer3[shift]=val;
     }

   if(Trend_period > 0)
     {
      val =iMAX(Trend_period,Trend_method,Trend_price,Trend_mindiff,shift);
      IndBuffer4[shift] = val;
     }
   
   if(stopma_period > 0)
     {
      val=iMAX(stopma_period,stopma_method,stopma_price,0,shift);
      IndBuffer5[shift] = val;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSignal(int shift)
  {
   int signal=0;


   double ma00 = IndBuffer0[shift];
   double ma01 = IndBuffer0[shift + 1];
   double ma02 = IndBuffer0[shift + 2];
//  double ma03 = IndBuffer0[shift + 3];

// global Variable, don't forget!!
   trend0 = IndBuffer4[shift];
   trend1 = IndBuffer4[shift+1];

   double ma10 = IndBuffer1[shift];
   double ma11 = IndBuffer1[shift+1];
   double ma12 = IndBuffer1[shift+2];
   double ma20 = IndBuffer2[shift];
   double ma21 = IndBuffer2[shift+1];
   double ma22 = IndBuffer2[shift+2];

 if(Signal1MATurn0 > 0)
      signal += GetSignalSingleRAW(ma00, ma01,ma02,  shift)*Signal1MATurn0;
      
   if(Signal1MATurn > 0)
      signal += GetSignalSingle(ma00, ma01,ma02, ma20,ma21,  shift)*Signal1MATurn;

   if(Signal2MACross > 0)
      signal += GetSignalCross(ma00, ma01,ma02, ma10,ma11,ma12,   shift)*Signal2MACross;

   if(Signal3MACross > 0)
      signal += GetSignal3MA(ma00,ma01,ma10,ma12,ma20,ma21,shift)*Signal3MACross;

   if(SignalMACD > 0)
      signal += GetSignalMACD(shift)*SignalMACD;

   if(SignalSAR > 0)
      signal += GetSignalSAR(shift)*SignalSAR;

   if(SignalSTO > 0)
      signal += getSignalSTO(shift)*SignalSTO;
   /*
      if(SignalRSISTO > 0)
         signal += getSignalRSISTO(shift)*SignalRSISTO;

      if(SignalMASTO > 0)
         signal += GetSignalMASTO(trend1,shift)*SignalMASTO;
         */

//   if(SignalTrend > 0)
//     signal += GetSignalTrend(shift)*SignalTrend;
   return signal;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string IndicatorInfo()
  {
   string ret = StringFormat("%d %d %d",  Ma1Period,  Trend_period,Trend_mindiff);
   return ret;
  }





//+------------------------------------------------------------------+
string ParameterInfo()
  {

   string msg = StringFormat(": MaPeriod=%d; Ma2Factor=%.1f; Ma1Method=%d; Ma1Price=%d;"
                             + "Trend_period=%d;Trend_mindiff=%d;"
                         //    + "TP=%d;SL=%d;"
                             + "check_Trend=%d;"
                             + "open_sar_step=%.1f; open_sar_max=%.1f;"
                             + "stopma_period=%d; stopma_method=%d; stopma_price=%d;",
                             Ma1Period,Ma2Factor, Ma1Method,Ma1Price,
                             Trend_period,Trend_mindiff,
                        //     TakeProfit,StopLoss,
                             check_Trend,
                             open_sar_step,open_sar_max,
                             stopma_period, stopma_method,stopma_price);

   return msg;
// Print(__FUNCTION__,msg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckParameters()
  {

   TesterHideIndicators(false);
   SignalInfo="";
   return true;
  }
//+-----------------------