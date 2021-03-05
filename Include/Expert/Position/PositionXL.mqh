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
   int               VStoploss(void) {return v_stoploss;}
   int               VTakeprofig(void) {return v_takeprofit;}
   void              VStoploss(int value) { v_stoploss = value;}
   void              VTakeprofig(int value) { v_takeprofit = value;}
   bool              CheckTakeprofit();
   bool              CheckStoploss();
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
   bool     CPositionInfoXL:: CheckTakeprofit() 
   {
     bool ret=false;
     double price = PriceCurrent();   
     double tp_price = PriceOpen() + Swap() + VTakeprofig()*Point();
     int age = iTime(NULL,0,0) - Time();
     if (age > PeriodSeconds(PERIOD_CURRENT))
     {
        ret = price > tp_price;
     }
     return(ret);
   }
   bool      CPositionInfoXL:: CheckStoploss()
   {
     bool ret= false;
     double price = PriceCurrent();   
     double sl_price = PriceOpen() + Swap() + VStoploss()*Point();
     int age = iTime(NULL,0,0) - Time();
     if (age > PeriodSeconds(PERIOD_CURRENT))
     {
        ret = price < sl_price;
     }
     return(ret);
   }
   bool      CPositionInfoXL:: CheckClose()
   {
     bool ret= false;
     ret = CheckTakeprofit();
     if (!ret) ret = CheckStoploss();
         return(ret);
   }   