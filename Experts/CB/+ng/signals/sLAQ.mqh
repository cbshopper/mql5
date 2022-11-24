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
input double gamma = 0.7;
input int HighLevel = 75;
input int MiddleLevel = 50;
input int LowLevel = 15;
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

    double           DataBuffer[];


public:

    bool              Init()
       {


//
       CustHandle = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME2, gamma, HighLevel, MiddleLevel, LowLevel, false, 5, 5, MODE_SMA, PRICE_CLOSE);
//CustHandle = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME1, gamma);

        ArraySetAsSeries(DataBuffer, true);
        return (CustHandle > 0);
       }

    int              refresh(int cnt)
       {
        int               rates;
        int              barcount;

        barcount = iBars(Symbol(), PERIOD_CURRENT);
        if(barcount > cnt)
            barcount = cnt;
        ArrayResize(DataBuffer, barcount);

        rates = CopyBuffer(CustHandle, 0, 0, barcount, DataBuffer);
        //       Print(__FUNCTION__, ": rates=", rates);
        return rates;
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

        int ret = refresh(100);
        if(ret > 10)
           {
           /*
            double laq0  = DataBuffer[shift + 0]; // LagVal(shift + 0);
            double laq1  =   DataBuffer[shift + 1]; //LagVal(shift + 1);
            double laq2  =   DataBuffer[shift + 2]; //LagVal(shift + 2);
            double laq3 =   DataBuffer[shift + 3]; //LagVal(shift + 3);
            */
            double laq0  =  LagVal(shift + 0);
            double laq1  =  LagVal(shift + 1);
            double laq2  =   LagVal(shift + 2);
            double laq3 =  LagVal(shift + 3);
            enable_sell = laq0 < HighLevel && laq1 > HighLevel && laq2 > HighLevel;
            enable_buy = laq0 > LowLevel && laq1 < LowLevel && laq2 < LowLevel;
  
  Print(__FUNCTION__, ": " + iTime(Symbol(),PERIOD_CURRENT,shift) + " laq0=", laq0, " laq1=", laq1, " laq2=", laq2, " laq3=", laq3, " shift=", shift, " enable_buy=",enable_buy, " enable_sell=",enable_sell, " HighLevel=", HighLevel, " LowLevel=",LowLevel);
           
            //if(enable_buy || enable_sell)
            //    Print(__FUNCTION__, " laq0=", laq0, " laq1=", laq1, " laq2=", laq2, " laq3=", laq3, " shift=", shift, " Time=", iTime(Symbol(), PERIOD_CURRENT, shift));
             if(enable_buy)
                return 1;
            if(enable_sell)
                return -1;
           }
        return 0;

       }

                     CLaq(void) { };
                    ~CLaq(void) {};
   };
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLaq2
   {

protected:
    CiLaquerre *              laq;

    double           DataBuffer[];


public:

    bool              Init()
       {



        laq = new CiLaquerre();



        if(!laq.Create(Symbol(), PERIOD_CURRENT, gamma))
           {
            printf(__FUNCTION__ + ": error initializing object");
            return(false);
           }

        return true;
       }

 

    double            LagVal(int shift)
       {
        double ret = laq.Main((shift))*100.0;
        return ret;
       }

    int              GetSignal(int shift)
       {
        bool enable_sell = false;
        bool enable_buy = false;
        laq.Refresh();
        int ret = laq.BarsCalculated();
        if(ret > 10)
           {
            double laq0  =  LagVal((shift));
            double laq1  =    LagVal((shift+1));
            double laq2  =   LagVal((shift+2));
            double laq3 =    LagVal((shift+3));
            enable_sell = laq0 < HighLevel && laq1 > HighLevel && laq2 > HighLevel;
            enable_buy = laq0 > LowLevel && laq1 < LowLevel && laq2 < LowLevel;

Print(__FUNCTION__, ": " + iTime(Symbol(),PERIOD_CURRENT,shift) + " laq0=", laq0, " laq1=", laq1, " laq2=", laq2, " laq3=", laq3, " shift=", shift, " enable_buy=",enable_buy, " enable_sell=",enable_sell, " HighLevel=", HighLevel, " LowLevel=",LowLevel);
           
            //if(enable_buy || enable_sell)
            //    Print(__FUNCTION__, " laq0=", laq0, " laq1=", laq1, " laq2=", laq2, " laq3=", laq3, " shift=", shift, " Time=", iTime(Symbol(), PERIOD_CURRENT, shift));
            if(enable_buy)
                return 1;
            if(enable_sell)
                return -1;
           }
        return 0;

       }

                     CLaq2(void) { };
                    ~CLaq2(void) {};
   };
