//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//#include "_uni\CB_uni.globals.mqh"
#include <cb\CB_Commons.mqh>
#include <cb\CB_Draw.mqh>
#include <cb\CB_IMAX.mqh>





#ifndef CLOSE_SETTINGS
input string _CLOSE_SETTINGS2_ = " ==================  Close Signals ==================  ";
input int CloseByStopMa = 0;
input int CloseByMaCross = 0;
input int CloseBySAR=0;
input int CloseByOpositeSignal=0;
input int CloseByTimeSignal=0;
#endif
#include <cb\CB_SLTPCalculator.mqh>


input string STOPMA_Settings = " ------  Stop MA Settings ------------";
input ENUM_MMA_METHOD stopma_method = MMODE_SMA;
ENUM_APPLIED_PRICE stopma_price = PRICE_OPEN;
input int stopma_period = 34;
input string STOPSAR_Settings = " ------  Stop SAR Settings ------------";

input double close_sar_step = 0.0045;
input double close_sar_max = 0.1;

input string STOPTIME_Settings = " ------  Stop by Time Settings ------------";
input int max_ordertimeH = 7*24;

input string STOPGEN_Settings = " ------  Stop General Settings ------------";
input bool DontExitOrdersWithTPSL=false;

CiMAX iMax;
int StopSARPtr=INVALID_HANDLE;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitStopSignals()
  {
   if(StopSARPtr==INVALID_HANDLE)
     {
      StopSARPtr = iSAR(NULL,0,close_sar_step,close_sar_max);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeInitStopSignals()
  {
   if(StopSARPtr != INVALID_HANDLE)
     {
      IndicatorRelease(StopSARPtr);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckExitSettings()
  {
   int sum = CloseByFixSL+CloseByRiskSL+CloseByATRSL+ClosebyHILOSL+CloseByStopMa+CloseByMaCross+CloseBySAR+CloseByOpositeSignal+CloseByTimeSignal;
   return sum > 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderHasTPSL(int ticket)
  {
   if(OrderSelect(ticket))
     {
      double tp = OrderGetDouble(ORDER_TP); // (  OrderTakeProfit();
      double sl = OrderGetDouble(ORDER_SL); //OrderStopLoss();
      return sl != 0 || tp != 0;

     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetEACloseSignal(int shift, int mode,int ticket)
  {
   int signal =0;
   
    Print(__FUNCTION__,": Time=", TimeToString(iTime(NULL,0,shift)), " Mode=", mode, " ticket=",ticket);
    
   if(DontExitOrdersWithTPSL && OrderHasTPSL(ticket))
      return 0;

   if(CloseByStopMa > 0)
      signal +=  GetCloseSignalStopMA(shift,mode)*CloseByStopMa;

   if(CloseByMaCross > 0)
      signal +=  GetCloseSignalStopMA2(shift,mode)*CloseByMaCross;

   if(CloseBySAR > 0)
      signal +=  GetCloseSignalSAR(shift,mode)*CloseBySAR;

   if(CloseByOpositeSignal > 0)
      signal +=  GetCloseByOpositeSignal(shift,mode)*CloseByOpositeSignal;

   if(CloseByTimeSignal>0)
      signal +=  GetCloseByTimeSignal(shift,mode,ticket)*CloseByTimeSignal;
   if(signal != 0)
     {
      Print(__FUNCTION__,": Time=", TimeToString(iTime(NULL,0,shift)), " Mode=", mode, " Signal=",signal);
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignal4Tester(int shift, int mode,datetime open_time, double open_price)
  {
   int signal =0;

   if(CloseByFixSL>0)
      signal = -1;
   if(ClosebyFixTP>0)
      signal = -1;
   if(ClosebyHILOSL>0)
      signal = -1;
   if(ClosebyHILOTP>0)
      signal = -1;
   if(CloseByATRSL>0)
      signal = -1;
   if(CloseByATRTP>0)
      signal = -1;
   if(CloseByRiskSL>0)
      signal = -1;
   if(CloseByRiskTP>0)
      signal = -1;

   if(signal == 0)
     {
      signal =  GetEACloseSignal(shift,  mode, 0);
      if(CloseByTimeSignal>0)
         signal += getCloseByTimeSignal(shift,mode, open_time,open_price);
     }
   if(signal != 0)
     {
      Print(__FUNCTION__,": Time=", TimeToString(iTime(NULL,0,shift)), " Mode=", mode, " Signal=",signal);
     }
   return signal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseByOpositeSignal(int shift, int mode)
  {
   int ret=0;
   int sig = GetSignal(shift);
   Print(__FUNCTION__,": ret = ",ret);
   if(mode == OP_BUY && sig < 0)
      ret = 1;
   if(mode == OP_SELL && sig > 0)
      ret = 1;
   return ret;
  }



//+------------------------------------------------------------------+
//| Check for close order conditions                                  |
//+------------------------------------------------------------------+
int GetCloseSignalSAR(int shift, int mode)
  {
   int   signal = 0;
   bool close_buy = false;
   bool close_sell = false;
   int offset=0;
   int diff=1;

   //if (StopSARPtr == INVALID_HANDLE)
   //{
   //   InitStopSignals();
   //}
   
   
   double sar0 = GetIndicatorValue(StopSARPtr,shift+offset);
   double sar1 = GetIndicatorValue(StopSARPtr,shift+offset +1);
   double CLOSE0=iClose(NULL,0,shift+offset);
   double CLOSE1=iClose(NULL,0,shift+offset+diff);

// close_buy =  stop_sar > CLOSE || (trade_sar < CLOSE && stop_sar < CLOSE);
// close_sell = stop_sar < CLOSE || (trade_sar > CLOSE && stop_sar > CLOSE) ;
   close_buy = SarSignal(sar0,sar1,CLOSE0,CLOSE1) < 0;
   close_sell = SarSignal(sar0,sar1,CLOSE0,CLOSE1) >0;
   if(mode == OP_BUY && close_buy)
      signal=1;
   if(mode == OP_SELL && close_sell)
      signal=1;
   if(signal > 0)
     {
      Print(__FUNCTION__,": Time=", iTime(NULL,0,shift), " price0=",CLOSE0);
     }
   return signal;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignalStopMA(int shift, int mode)
  {
   int   signal = 0;
   double t0,t1;
   if(stopma_period >0)
     {
      iMax.Init(stopma_period,(ENUM_MMA_METHOD)stopma_method,PRICE_OPEN);
      double ma0 = iMax.calculate(shift+1);// iMA(NULL,0,period,0,stopma_method,stopma_price,shift);
      // double ma1 = iMAX(stopma_period,stopma_method,stopma_price,shift+1);//iMA(NULL,0,period,0,stopma_method,stopma_price,shift+1);
      // double ma2 = iMAX(stopma_period,stopma_method,stopma_price,shift+2);// iMA(NULL,0,period,0,stopma_method,stopma_price,shift+2);
      double CLOSE=iClose(NULL,0,shift+1);


      bool close_buy = CLOSE < ma0;
      bool close_sell = CLOSE > ma0;


      if(mode == OP_BUY && close_buy)
         signal=1;
      if(mode == OP_SELL && close_sell)
         signal=1;
     }
// Print(__FUNCTION__,": Time=", iTime(NULL,0,shift), " Trend=",trend);
   return signal;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignalStopMA2(int shift, int mode)
  {
   int   signal = 0;
   double t0,t1;
   if(stopma_period >0)
     {
      //     CiMAX iMax;
      iMax.Init(stopma_period,(ENUM_MMA_METHOD)stopma_method,PRICE_OPEN);

      double ma0 = iMax.calculate(shift);// iMA(NULL,0,period,0,stopma_method,stopma_price,shift);
      double ma1 = iMax.calculate(shift+2);//iMA(NULL,0,period,0,stopma_method,stopma_price,shift+1);
      double ma2 = iMax.calculate(shift+4);// iMA(NULL,0,period,0,stopma_method,stopma_price,shift+2);

      bool close_buy = ma2 < ma1 && ma0 < ma1;
      bool close_sell = ma2 > ma1 && ma0 > ma1;


      if(mode == OP_BUY && close_buy)
         signal=1;
      if(mode == OP_SELL && close_sell)
         signal=1;
     }
// Print(__FUNCTION__,": Time=", iTime(NULL,0,shift), " Trend=",trend);
   return signal;
  }
//+-----
//+------------------------------------------------------------------+
int GetCloseByTimeSignalBAJ(int shift,int mode,int ticket)
  {
   int   signal = 0;
   if(OrderSelect(ticket))
     {
      double open_price = OrderGetDouble(ORDER_PRICE_OPEN); // OrderOpenPrice();
      datetime open_time = (datetime) OrderGetInteger(ORDER_TIME_SETUP); //OrderOpenTime();
      double cur_price = iClose(NULL,0,shift);
      if(PositionSelectByTicket(ticket))
        {
         double win = PositionGetDouble(POSITION_PROFIT);
         if(open_time - iTime(NULL,0,shift) > max_ordertimeH*60*60)
           {
            if(win < 0)
               signal = 1;
           }
        }
     }


   return signal;
  }
//+------------------------------------------------------------------+
int GetCloseByTimeSignal(int shift,int mode,int ticket)
  {
   int   signal = 0;
   if(OrderSelect(ticket))
     {
      double open_price = OrderGetDouble(ORDER_PRICE_OPEN); // OrderOpenPrice();
      datetime open_time =(datetime) OrderGetInteger(ORDER_TIME_SETUP); //OrderOpenTime();
      signal = getCloseByTimeSignal(shift,mode, open_time,open_price);

     }


   return signal;
  }
//+------------------------------------------------------------------+
int getCloseByTimeSignal(int shift, int mode, datetime open_time, int open_price)
  {
   int   signal = 0;
   double win = 0;
   if(open_time - iTime(NULL,0,shift) > max_ordertimeH*60*60)
     {
      if(mode == OP_BUY)
        {
         win = iClose(NULL,0,shift) - open_price;
        }
      else
        {
         win =   open_price-iClose(NULL,0,shift);
        }
      if(win < 0)
         signal = 1;
     }
   return signal;

  }



//+------------------------------------------------------------------+
