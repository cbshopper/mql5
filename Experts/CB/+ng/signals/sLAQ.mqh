//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>
#include <CB\CBiLaquerre.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";

//+---------------------------------- - +
//| Indicator input parameters        |
//+-----------------------------------+

//input bool DrawBuySellMarker = false;
//input int checkbars = 5;
//input int checkMaPeriod=5;
//input ENUM_MA_METHOD checkMaMethod = MODE_EMA;
//input ENUM_APPLIED_PRICE checkMaPrice = PRICE_CLOSE;
#define CUSTOMNAME1 "Laguerre\\laguerre"
#define CUSTOMNAME2 "CB\\Laguerre\\CB_laq"
// C:\ProgrammeXL\Office\MetaTrader5.dev\MQL5\Indicators\CB\Laguerre\CB_colorlaguerre.mq5

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLaq
   {

protected:
    int               CustHandle;

    double gamma ;
    int HighLevel;
    int LowLevel;
    int MiddleLevel;

public:

    bool              Init(double g, int hi, int lo)
       {

        gamma = g;
        HighLevel = hi;
        LowLevel=lo;
        //
        CustHandle = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME2, gamma, HighLevel, MiddleLevel, LowLevel);
        return (CustHandle > 0);
       }


    double            LagVal(int shift)
       {
        double ret = GetIndicatorBufferValue(CustHandle, shift, 0);
        return ret;
       }

    int              GetSignal(int shift)
       {
        bool enable_sell = false;
        bool enable_buy = false;

        //  int ret = refresh(100);
        //     {
        double laq0  =  LagVal(shift + 0);
        double laq1  =  LagVal(shift + 1);
        double laq2  =   LagVal(shift + 2);
        double laq3 =  LagVal(shift + 3);
        enable_sell = laq0 < HighLevel && laq1 > HighLevel && laq2 > HighLevel;
        enable_buy = laq0 > LowLevel && laq1 < LowLevel && laq2 < LowLevel;

        //Print(__FUNCTION__, ": " + iTime(Symbol(), PERIOD_CURRENT, shift) + " laq0=", laq0, " laq1=", laq1, " laq2=", laq2, " laq3=", laq3, " shift=", shift, " enable_buy=", enable_buy, " enable_sell=", enable_sell, " HighLevel=", HighLevel, " LowLevel=", LowLevel);

        //if(enable_buy || enable_sell)
        //    Print(__FUNCTION__, " laq0=", laq0, " laq1=", laq1, " laq2=", laq2, " laq3=", laq3, " shift=", shift, " Time=", iTime(Symbol(), PERIOD_CURRENT, shift));
        if(enable_buy)
            return 1;
        if(enable_sell)
            return -1;
        //    }
        return 0;

       }

                     CLaq(void): gamma(0.7),HighLevel(80), MiddleLevel(50),LowLevel(30) { } ;
                    ~CLaq(void) {};
   };
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
