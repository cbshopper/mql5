//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int                  EntryLevel = 25;              // Entry Level

//+---------------------------------- - +
//| Indicator input parameters        |
//+-----------------------------------+
input double gamma = 0.7;
input int HighLevel = 85;
 int MiddleLevel = 50;
input int LowLevel = 15;

input int                     InpStockKPeriod               = 3;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpRSIPeriod                  = 14;                                  // RSI Period


#define CUSTOMNAME1  "CB\\RSI\\CB_StochRSISimple"
#define CUSTOMNAME2  "CB\\Laguerre\\CB_laq"
// C:\ProgrammeXL\Office\MetaTrader5.dev\MQL5\Indicators\CB\Laguerre\CB_colorlaguerre.mq5

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStochRSILaq
   {

protected:
    int               RSISTOHandle;
    int               LAQHandle;



public:

    bool              Init()
       {


        RSISTOHandle = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME1,
                               InpStockKPeriod, InpStockDPeriod, InpRSIPeriod);

        LAQHandle = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME2,
                            gamma, HighLevel, MiddleLevel, LowLevel);


        return (LAQHandle > 0 && RSISTOHandle > 0);
       }




    double            Value(int shift)
       {

        double ret  = GetIndicatorBufferValue(RSISTOHandle, shift, 0);
        return ret;
       }
    double            Signal(int shift)
       {

        double ret = GetIndicatorBufferValue(RSISTOHandle, shift, 1);
        return ret;
       }

    double            LagVal(int shift)
       {
        double ret = GetIndicatorBufferValue(LAQHandle, shift, 0);
        return ret;
       }

    int              GetSignal(int shift)
       {


        double sto0  =  Value(shift + 0);
        double sto1  =  Value(shift + 1);
        double sto_sig0  =  Signal(shift + 0);
        double sto_sig1  =  Signal(shift + 1);
        double laq0  =  LagVal(shift + 0);
        double laq1  =  LagVal(shift + 1);
        double laq2  =  LagVal(shift + 2);
        double laq3 =  LagVal(shift + 3);

        bool buyok = laq0 < MiddleLevel || laq1 < MiddleLevel ;//|| laq2 < LowLevel || laq3 < LowLevel ;
        bool sellok = laq0 > MiddleLevel || laq1 > MiddleLevel ; //|| laq2 > HighLevel || laq3 > HighLevel ;
        buyok = sellok = true;

        bool selllag = laq0 < HighLevel && (laq1 > HighLevel || laq2 > HighLevel);
        bool buylaq  = laq0 > LowLevel && (laq1 < LowLevel || laq2 < LowLevel);


        bool buyrsi = sto0 > sto_sig0 && sto1 < sto_sig1  && sto0 < EntryLevel;
        bool sellrsi = sto0 < sto_sig0 && sto1 > sto_sig1 && sto0 > 100 - EntryLevel;


        bool enable_buy = (buyrsi && buyok) || buylaq;
        bool enable_sell = (sellrsi && sellok) || selllag;

        if(enable_buy)
            return 1;
        if(enable_sell)
            return -1;
        return 0;

       }

                     CStochRSILaq(void) { };
                    ~CStochRSILaq(void) {};
   };
//+------------------------------------------------------------------+
