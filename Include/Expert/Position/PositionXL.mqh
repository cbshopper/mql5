//+------------------------------------------------------------------+
//|                                                   PositionXL.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Trade\PositionInfo.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
class CPositionInfoXL : public CPositionInfo
  {

protected:
   int               v_stoploss;
   int               v_takeprofit;

public:
                     CPositionInfoXL(void);
                    ~CPositionInfoXL(void);
   int               VStopLoss(void) {return v_stoploss;}
   int               VTakeProfit(void) {return v_takeprofit;}
   void              VStopLoss(int value) { v_stoploss = value; }
   void              VTakeProfit(int value) { v_takeprofit = value; }
   bool              CheckTakeProfit();
   bool              CheckStopLoss();
   bool              CheckClose();

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPositionInfoXL::CPositionInfoXL(void) : v_stoploss(0),v_takeprofit(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPositionInfoXL::~CPositionInfoXL(void)
  {
  }
//+------------------------------------------------------------------+
bool     CPositionInfoXL:: CheckTakeProfit()
  {
   bool ret=false;
   
   int tp = VTakeProfit();
   if (tp==0) return false;
   
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
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool      CPositionInfoXL:: CheckStopLoss()
  {
   bool ret= false;
   int sl = VStopLoss();
   if (sl==0) return false;
   double swp=Swap();
   double price = PriceCurrent();
   double sl_price =  0;
   ENUM_POSITION_TYPE type=PositionType();
   if(type == POSITION_TYPE_BUY)
     {
      sl_price =   PriceOpen() - swp -sl*Point() ;
     }
   else
     {
      sl_price = PriceOpen() + swp + sl*Point() ;
     }

   datetime now = iTime(NULL,0,0);
   datetime open = Time();
   int age = now-open;
   int diff = PeriodSeconds(PERIOD_CURRENT);
  //  Print(__FUNCTION__,": age=",age, " diff=",diff," sl_price=",sl_price," price=",price," type=",type);
   if(age > diff)
     {
      ret = price < sl_price;
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool      CPositionInfoXL:: CheckClose()
  {
   bool ret= false;
   ret = CheckTakeProfit();
   if(!ret)
   {
      ret = CheckStopLoss();
      if (ret) Print(__FUNCTION__,": *****  closing order by VStop ",Ticket());
   }
   else
   {
     Print(__FUNCTION__,": *****  closing order by VTake ",Ticket());
   }
   return(ret);
  }
//+------------------------------------------------------------------+
