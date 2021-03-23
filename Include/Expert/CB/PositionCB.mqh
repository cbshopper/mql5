//+------------------------------------------------------------------+
//|                                                   PositionXL.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Trade\PositionInfo.mqh>

//+------------------------------------------------------------------+
class CPositionInfoCB : public CPositionInfo
  {

protected:
   //int               v_stoploss;
   //int               v_takeprofit;
   bool              checkTime(int delay);
   bool              checkPrice(bool take, double diff);


public:
                     CPositionInfoCB(void);
                    ~CPositionInfoCB(void);
   //int               VStopLoss(void) {return v_stoploss;}
   //int               VTakeProfit(void) {return v_takeprofit;}
   //void              VStopLoss(int value) { v_stoploss = value; }
   //void              VTakeProfit(int value) { v_takeprofit = value; }
   
   bool              CheckTakeProfit(int tp, int delay);
   bool              CheckStopLoss(int sl, int delay);
   bool              CheckClose(int delay, int take, int stop);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPositionInfoCB::CPositionInfoCB(void) //: v_stoploss(0),v_takeprofit(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPositionInfoCB::~CPositionInfoCB(void)
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPositionInfoCB::checkTime(int delay)
  {
   bool ret=false;
   datetime now = iTime(NULL,0,0);
   datetime open = Time();
   int age = now-open;
   int diff = delay;  //PeriodSeconds(PERIOD_CURRENT);

   ret = age > diff;
   Print(__FUNCTION__,": age=",age, " delay=",delay," diff=",diff," ret=",ret);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPositionInfoCB::checkPrice(bool take, double diff)
  {
   bool ret=false;
   double swp=Swap();
   swp=0;
   double price = PriceCurrent();
   double limit = 0;
   double open=PriceOpen();
   ENUM_POSITION_TYPE type=PositionType();
 
   if(take)
     {

      if(type == POSITION_TYPE_BUY)
        {
         limit = open + swp +diff*Point() ;
         ret = price > limit;
        }
      else
        {
         limit = open - swp -diff*Point() ;
         ret=price < limit;
        }
     }
   else
     {
      if(type == POSITION_TYPE_BUY)
        {
         limit =   open -diff*Point() ;  //- swp 
         ret=price < limit;
        }
      else
        {
         limit = open  + diff*Point() ;  //+ swp
         ret = price > limit;
        }
     }
  Print(__FUNCTION__,": take=",take," limit=",limit," price=",price," type=",type);
   return ret;
  }
//+------------------------------------------------------------------+
bool     CPositionInfoCB:: CheckTakeProfit(int tp, int delay)
  {
   bool ret=false;

//   int tp = VTakeProfit();
   if(tp==0)
      return false;
   /*
   double swp=Swap();
   double price = PriceCurrent();
   double tp_price = 0;
   ENUM_POSITION_TYPE type=PositionType();
   if(type == POSITION_TYPE_BUY)
     {
      tp_price =   PriceOpen() + swp +tp*Point() ;
     }
   else
     {
      tp_price = PriceOpen() - swp -tp*Point() ;
     }

   datetime now = iTime(NULL,0,0);
   datetime open = Time();
   int age = now-open;
   int diff = PeriodSeconds(PERIOD_CURRENT);
   //  Print(__FUNCTION__,": age=",age, " diff=",diff," tp_price=",tp_price," price=",price," type=",type);
   if(age > diff)
     {
      ret = price > tp_price;
     }
     */

   if(checkTime(delay))
     {
      ret = checkPrice(true,tp); //price > limit;
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool      CPositionInfoCB:: CheckStopLoss(int sl,int delay)
  {
   bool ret= false;
   if(sl==0)
      return false;

   if(checkTime(delay))
     {
      ret =  checkPrice(false,sl);  //price < limit;
     }

   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool      CPositionInfoCB:: CheckClose(int delay, int take, int stop)
  {
   bool ret= false;
     Print(__FUNCTION__,": delay=", delay," take=",take, " stop=",stop," Ticket=",Ticket());
   ret = CheckTakeProfit(take, delay);
   if(!ret)
     {
      ret = CheckStopLoss(stop,delay);
      if(ret)
         Print(__FUNCTION__,": *****  closing order by VStop ",Ticket());
     }
   else
     {
      Print(__FUNCTION__,": *****  closing order by VTake ",Ticket());
     }
   return(ret);
  }
//+------------------------------------------------------------------+
