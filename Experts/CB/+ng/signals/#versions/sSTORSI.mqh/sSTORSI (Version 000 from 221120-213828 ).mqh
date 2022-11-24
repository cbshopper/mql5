//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";

//input int                     InpStockKPeriod               = 3;                                   // K
//input int                     InpStockDPeriod               = 3;                                   // D
//input int                     InpRSIPeriod                  = 14;                                  // RSI Period
//input int                     InpStochastikPeriod           = 14;                                  // Stochastic Period
//input ENUM_APPLIED_PRICE      InpRSIAppliedPrice            = PRICE_CLOSE;                         // RSI Applied Price

#define CUSTOMNAME  "CB\\RSI\\CB_StochRSISimple"
#include <CB/calcrsisto.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStochRSI
   {

protected:
    int               data_ptr;

public:

    bool              Init()
       {
        data_ptr = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME,
                           InpStockKPeriod, InpStockDPeriod, InpRSIPeriod, InpStochastikPeriod, InpRSIAppliedPrice);
        return (data_ptr > 0);
       }
    double            Value(int shift)
       {
        double ret = GetIndicatorBufferValue(data_ptr, shift, 0);
        return ret;
       }
    double            Signal(int shift)
       {
        double ret = GetIndicatorBufferValue(data_ptr, shift, 1);
        return ret;
       }




                     CStochRSI(void) { };
                    ~CStochRSI(void) {};
   };
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStochRSIX
   {

protected:
    int               RSIHandle;

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

        if (cnt  < rates) rates = cnt;
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




                     CStochRSIX(void) { };
                    ~CStochRSIX(void) {};
   };
//+------------------------------------------------------------------+
