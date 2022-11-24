//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";

input int                     InpStockKPeriod               = 3;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpRSIPeriod                  = 14;                                  // RSI Period
input int                     InpStochastikPeriod           = 14;                                  // Stochastic Period
input ENUM_APPLIED_PRICE      InpRSIAppliedPrice            = PRICE_CLOSE;                         // RSI Applied Price

#define CUSTOMNAME1  "CB\\RSI\\CB_StochRSISimple"


//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input double gamma = 0.7;
input int HighLevel = 85;
input int MiddleLevel = 50;
input int LowLevel = 15;
//input bool DrawBuySellMarker = false;
//input int checkbars = 5;
//input int checkMaPeriod=5;
//input ENUM_MA_METHOD checkMaMethod = MODE_EMA;
//input ENUM_APPLIED_PRICE checkMaPrice = PRICE_CLOSE;
#define CUSTOMNAME2  "CB\\Laguerre\\CB_colorlaguerre"
// C:\ProgrammeXL\Office\MetaTrader5.dev\MQL5\Indicators\CB\Laguerre\CB_colorlaguerre.mq5
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSTORSILAQ
   {

protected:
    int               data_ptr1;
    int               data_ptr2;
    int               RSIHandle;

public:

    bool              Init()
       {
       data_ptr1 = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME1,
                            InpStockKPeriod, InpStockDPeriod, InpRSIPeriod,InpStochastikPeriod, InpRSIAppliedPrice);
 //       data_ptr1 = iRSI(Symbol(), PERIOD_CURRENT, InpRSIPeriod, InpRSIAppliedPrice);
        
        data_ptr2 = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME2,
                            gamma, HighLevel, MiddleLevel, LowLevel, false, 5, 5, MODE_SMA, PRICE_CLOSE);
        return (data_ptr1 > 0 && data_ptr2 > 0);
       }
    double            RSIVal(int shift)
       {
        double ret = GetIndicatorBufferValue(data_ptr1, shift, 0);
        return ret;
       }
    double            RSISignal(int shift)
       {
        double ret = GetIndicatorBufferValue(data_ptr1, shift, 1);
        return ret;
       }
    double            LagVal(int shift)
       {
        double ret = GetIndicatorBufferValue(data_ptr2, shift, 0);
        return ret;
       }



                     CSTORSILAQ(void) { };
                    ~CSTORSILAQ(void) {};
   };
//+------------------------------------------------------------------+
