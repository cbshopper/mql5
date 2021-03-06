//+------------------------------------------------------------------+
//|                                                      CB_IMAX.mqh |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#include <cb\CB_Utils.mqh>
#include <cb\CB_MAUtils.mqh>
#include "..\..\Indicators\cb\Ma\hullMA.mqh"
//#include "..\Indicators\TMA\tma.mqh"

enum ENUM_MMA_METHOD
  {
   MMODE_SMA=0,
   MMODE_EMA=1,
   MMODE_SMMA =2,
   MMODE_LWMA = 3,
   MMODE_HULLMA=4
//,
// MMODE_TMA=5
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiMAX
  {
protected:
   ENUM_TIMEFRAMES   timeframe;
   ENUM_MMA_METHOD   _method;
   ENUM_APPLIED_PRICE _price;
   string            _symbol;
   int               _period;
   int               maptr;
   CHull             iHull;
   double            _lastvalue;
   string            _key;


public:
                     CiMAX();
                    ~CiMAX(void);



   bool              Init(int period,
                          ENUM_MMA_METHOD   method,
                          ENUM_APPLIED_PRICE price);
   double            calculate(int shift);
   double            calculate(int shift, int filter);
   bool              IsInitialized(  int period,ENUM_MMA_METHOD   method,ENUM_APPLIED_PRICE price);
protected:
  ; 
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiMAX::CiMAX()
  {


  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiMAX::~CiMAX(void)
  {
   IndicatorRelease(maptr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiMAX::Init(int period,ENUM_MMA_METHOD   method,ENUM_APPLIED_PRICE price)
  {
   timeframe = timeframe;
   _price=price;
   _method = method;
   _symbol = Symbol();
   _period = period;
   _lastvalue=0;
   _key = StringFormat("%d%d%d",period,method,price);

   switch(method)
     {
      case MMODE_EMA:
      case MMODE_SMA:
      case MMODE_LWMA:
      case MMODE_SMMA:
         maptr = iMA(Symbol(),0,period,0,(ENUM_MA_METHOD)method,price);
         if(maptr==INVALID_HANDLE)
           {
            //--- tell about the failure and output the error code
            PrintFormat("Failed to create handle of the iMA %s indicator: error code %d",
                        EnumToString((ENUM_TIMEFRAMES)period),
                        GetLastError());
            //--- the indicator is stopped early
            return(false);
           }
         //    WaitForData(maptr);

         break;

      case MMODE_HULLMA:

         iHull.init(period,2.0,price);
         break;
         // case MMODE_TMA:
         //    val  = iTma(iMA(NULL,0,1,0,MODE_SMA,price,shift),period,shift);
         //    break;
     }
   return true;
  }
bool CiMAX::IsInitialized(  int period,ENUM_MMA_METHOD   method,ENUM_APPLIED_PRICE price)
{
  string chk =  StringFormat("%d%d%d",period,method,price);
  bool ret = chk==_key;
  return ret;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiMAX::calculate(int shift)
  {
   double val = 0;
   double priceArr[];
   int cnt=_period*2;
   MqlRates rates[];
   ArrayResize(priceArr,cnt);
   ArraySetAsSeries(rates,true);
   ArraySetAsSeries(priceArr,true);

   long copied=0;
//val = iMA(NULL, 0, period, 0, Trend_method, PRICE_OPEN, shift);
   switch(_method)
     {
      case MMODE_EMA:
      case MMODE_SMA:
      case MMODE_LWMA:
      case MMODE_SMMA:
         copied=CopyRates(Symbol(),0,shift,cnt,rates);
         if(copied >= cnt)
           {
            for(int i=0; i<cnt; i++)
              {
               priceArr[i] = _getPrice(_price, rates[i]);
              }
            val = iMAOnArray(priceArr,cnt,_period,0,_method,0);
           }
         //       val = GetIndicatorValue(maptr,shift);
         break;

      case MMODE_HULLMA:
         val= iHull.calculate(shift);
         break;
         // case MMODE_TMA:
         //    val  = iTma(iMA(NULL,0,1,0,MODE_SMA,price,shift),period,shift);
         //    break;
     }

   return val;
  }
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiMAX::calculate(int shift,int filter)
  {

   double ret = calculate(shift);
   if(filter > 0)
     {
      double lastval = calculate(shift+1);

      if(MathAbs(ret - lastval)< filter * Point())
        {
         ret = lastval;
        }
     }
   return ret;
  }
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiMAX::calculate(int shift,int filter)
  {
   double ret=calculate(shift);
   if(filter > 0 && _lastvalue > 0)
     {
      if(MathAbs(ret - _lastvalue) < filter * Point())
        {
         ret = _lastvalue;
        }
     }
   _lastvalue  =ret;
   return ret;

  }

CiMAX imax;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAX(int period,int   method,int price,int filter,int shift)
  {
   double ret=0.1;
   if (!imax.IsInitialized(period,(ENUM_MMA_METHOD)method,(ENUM_APPLIED_PRICE)price))
   {
     imax.Init(period,(ENUM_MMA_METHOD)method,(ENUM_APPLIED_PRICE)price);
   }
   ret = imax.calculate(shift,filter);
   return ret;
  }
//+------------------------------------------------------------------+
