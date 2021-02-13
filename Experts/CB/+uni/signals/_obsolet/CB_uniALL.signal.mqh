//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <CB_Commons.mqh>
#include <CB_Draw.mqh>
#include <CB_IMAX.mqh>



#include "CB_uniSignalLib.mqh"

/*

string IndicatorInfo()
  {
   string ret = StringFormat("%d %d %d",  Ma1Period,  Trend_period,Trend_mindiff);
   return ret;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitSignal()
  {
  }


//+------------------------------------------------------------------+
string ParameterInfo()
  {

   string msg = StringFormat(": MaPeriod=%d; Ma2Factor=%.1f; MaMethod=%d; MaPrice=%d;"
                             + "Trend_period=%d;Trend_mindiff=%d;"
                             + "TP=%d;SL=%d;"
                             + "check_Trend=%d;"
                             + "open_sar_step=%.1f; open_sar_max=%.1f;"
                             + "stopma_period=%d; stopma_method=%d; stopma_price=%d;",
                             Ma1Period,Ma2Factor, Ma1Method,Ma1Price,
                             Trend_period,Trend_mindiff,
                             TakeProfit,StopLoss,
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

//*===========================================================================================


//*===========================================================================================
// Signals Section
//*===========================================================================================

*/

/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetValuesX(int shift, double &IndBuffer0[],double &IndBuffer1[],double &IndBuffer2[],
               double &IndBuffer3[],double &IndBuffer4[],double &IndBuffer5[],
               double &Help0[],double &Help1[])
  {
// IndBuffer0: ma1
// IndBuffer1; ma2
// indBuffer2: ma3
// indBuffer3:
// IndBuffer4: trend
// IndBuffer5: stop

   IndBuffer0[shift]=EMPTY_VALUE;
   IndBuffer1[shift]=EMPTY_VALUE;
   IndBuffer2[shift]=EMPTY_VALUE;
   IndBuffer3[shift]=EMPTY_VALUE;
   IndBuffer4[shift] = EMPTY_VALUE;
   IndBuffer5[shift] = EMPTY_VALUE;

   double  ma =iMAX(Ma1Period,Ma1Method,Ma1Price,Filter,shift,0);
   IndBuffer0[shift]=ma;

   if(Signal3MACross || Signal2MACross)
     {
      ma =iMAX(Ma1Period*Ma2Factor,Ma2Method,Ma2Price,Filter,shift,1);
      IndBuffer1[shift]=ma;
     }
   if(Signal3MACross)
     {
      ma =iMAX(Ma1Period*Ma3Factor,Ma3Method,Ma3Price,Filter,shift,2);
      IndBuffer2[shift]=ma;
     }
   
   double  val = iSAR(NULL,0,open_sar_step,open_sar_max,shift);
   IndBuffer3[shift]=val;
   
    
   if(Trend_period > 0)
     {
      double  val =iMAX(Trend_period,Trend_method,Trend_price,Trend_mindiff,shift,2);
      IndBuffer4[shift] = val;
     }
   if(stopma_period > 0)
     {
      double stopma=iMAX(stopma_period,stopma_method,stopma_price,shift);
      IndBuffer5[shift] = stopma;
     }
     
  }
*/


//+------------------------------------------------------------------+
