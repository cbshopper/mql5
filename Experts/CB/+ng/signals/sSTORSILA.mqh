//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int                  EntryLevel = 25;              // Entry Level
#include <CB/calcrsisto.mqh>

//+---------------------------------- - +
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
#define CUSTOMNAME2  "CB\\Laguerre\\CB_laq"
// C:\ProgrammeXL\Office\MetaTrader5.dev\MQL5\Indicators\CB\Laguerre\CB_colorlaguerre.mq5

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStochRSILaq
   {

protected:
    int               RSIHandle;
    int               CustHandle;

    double           KBuffer[];
    double           DBuffer[];
    double           RSIBuffer[];
    double           StochBuffer[];


public:

    bool              Init()
       {


        ArraySetAsSeries(StochBuffer, true);
        ArraySetAsSeries(KBuffer, true);
        ArraySetAsSeries(DBuffer, true);
        ArraySetAsSeries(RSIBuffer, true);
        RSIHandle = iRSI(Symbol(), PERIOD_CURRENT, InpRSIPeriod, InpRSIAppliedPrice);

        int rates = DoCalc(100);


        CustHandle = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME2,
                             gamma, HighLevel, MiddleLevel, LowLevel);


        return (rates > 0);
       }

    int              DoCalc(int cnt)
       {
        int               rates;
        int              barcount;

        barcount = iBars(Symbol(), PERIOD_CURRENT);
        ArrayResize(RSIBuffer, barcount);

        rates = CopyBuffer(RSIHandle, 0, 0, barcount, RSIBuffer);
        //       Print(__FUNCTION__, ": rates=", rates);

        if(cnt  < rates)
            rates = cnt;
        CalcValues(rates, RSIBuffer, StochBuffer, KBuffer, DBuffer);
        return rates;
       }


    double            Value(int shift)
       {

        double ret = KBuffer[shift];
        return ret;
       }
    double            Signal(int shift)
       {

        double ret = DBuffer[shift];
        return ret;
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

        DoCalc(100);

        double sto0  =  Value(shift + 0);
        double sto1  =  Value(shift + 1);
        double sto_sig0  =  Signal(shift + 0);
        double sto_sig1  =  Signal(shift + 1);
        double laq0  =  LagVal(shift + 0);
        double laq1  =  LagVal(shift + 1);
        double laq2  =  LagVal(shift + 2);
        double laq3 =  LagVal(shift + 3);
        bool buyok = laq0 < LowLevel || laq1 < LowLevel || laq2 < LowLevel || laq3 < LowLevel ;
        bool sellok = laq0 > HighLevel || laq1 > HighLevel || laq2 > HighLevel || laq3 > HighLevel ;
        enable_buy = sto0 > sto_sig0 && sto1 < sto_sig1 && sto0 < EntryLevel && buyok;
        enable_sell = sto0 < sto_sig0 && sto1 > sto_sig1 && sto0 > 100 - EntryLevel && sellok;
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
