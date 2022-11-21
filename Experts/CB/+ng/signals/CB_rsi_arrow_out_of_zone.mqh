//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int                  Inp_RSI_ma_period    = 14;          // RSI: averaging period
input ENUM_APPLIED_PRICE   Inp_RSI_applied_price = PRICE_CLOSE; // RSI: type of price
input int                  Inp_MA_period        = 100;         // Trend MA Period
input int                  Inp_MA_shift         = 2;           // Trend MA Shift
input int                  Inp_RSO_Level_shift  = 10;          // RSO Level Shift depending on Trend
input int                  Inp_RSI_Level_Down   = 35.0;        // RSI: Value Level Down
input double               Inp_RSI_Level_Up     = 65.0;        // RSI: Value Level Up
#define CUSTOMNAME   "CB\\RSI\\CB_rsi_arrow_out_of_zone"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CArrowOutOfZone
  {
  
protected:  
 int               data_ptr;

public:
  
   bool              Init()
     {
 //     data_ptr = iCustom(NULL, PERIOD_CURRENT, CUSTOMNAME, InpStockKPeriod, InpStockDPeriod, InpRSIPeriod, InpStochastikPeriod, InpRSIAppliedPrice);
      data_ptr = iCustom(NULL, Period(), CUSTOMNAME,
                            Inp_RSI_ma_period,
                            Inp_RSI_applied_price,
                            Inp_MA_period,
                            Inp_MA_shift,
                            Inp_RSO_Level_shift,
                            Inp_RSI_Level_Down,
                            Inp_RSI_Level_Up
                           );
      return (data_ptr > 0);
     }
   double            OverSold(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 0);
      return ret;
     }
   double            Overbought(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 1);
      return ret;
     }

   


                     CArrowOutOfZone(void) { };
                    ~CArrowOutOfZone(void) {};
  };
//+------------------------------------------------------------------+
