//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";

input int                  EntryLevel = 25;              // Entry Level

#define CUSTOMNAME  "CB\\RSI\\CB_StochRSISimple"
#include <CB/calcrsisto.mqh>

//+------------------------------------------------------------------+
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
      data_ptr = iCustom(Symbol(), PERIOD_CURRENT, CUSTOMNAME, InpStockKPeriod, InpStockDPeriod, InpRSIPeriod);
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

   
 int              GetSignal(int shift)
       {

        //DoCalc(100);

        double sto0  =  Value(shift + 0);
        double sto1  =  Value(shift + 1);
        double sto_sig0  =  Signal(shift + 0);
        double sto_sig1  =  Signal(shift + 1);
        Print(__FUNCTION__, " sto0=", sto0, " sto1=", sto1, " sto_sig0=", sto_sig0, " sto_sig1=", sto_sig1, " shift=", shift);


        bool enable_buy = sto0 > sto_sig0 && sto1 < sto_sig1 && sto0 < EntryLevel;
        bool enable_sell = sto0 < sto_sig0 && sto1 > sto_sig1 && sto0 > 100 - EntryLevel;

        if(enable_buy)
            return 1;
        if(enable_sell)
            return -1;
        return 0;

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


    int              GetSignal(int shift)
       {

        DoCalc(100);

        double sto0  =  Value(shift + 0);
        double sto1  =  Value(shift + 1);
        double sto_sig0  =  Signal(shift + 0);
        double sto_sig1  =  Signal(shift + 1);
        Print(__FUNCTION__, " sto0=", sto0, " sto1=", sto1, " sto_sig0=", sto_sig0, " sto_sig1=", sto_sig1, " shift=", shift);


        bool enable_buy = sto0 > sto_sig0 && sto1 < sto_sig1 && sto0 < EntryLevel;
        bool enable_sell = sto0 < sto_sig0 && sto1 > sto_sig1 && sto0 > 100 - EntryLevel;

        if(enable_buy)
            return 1;
        if(enable_sell)
            return -1;
        return 0;

       }

                     CStochRSIX(void) { };
                    ~CStochRSIX(void) {};
   };
//+------------------------------------------------------------------+
