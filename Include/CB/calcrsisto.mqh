//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
input int                     InpStockKPeriod               = 3;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpRSIPeriod                  = 14;                                  // RSI Period
int                     InpStochastikPeriod           = 14;                                  // Stochastic Period
ENUM_APPLIED_PRICE      InpRSIAppliedPrice            = PRICE_CLOSE;                         // RSI Applied Price
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



int CalcValues(int limit, double &rSIBuffer[], double &stochBuffer[], double &kBuffer[], double &dBuffer[])
   {
    InpStochastikPeriod = InpRSIPeriod;
    const int rates_total = limit + MathMax(InpRSIPeriod,InpStockKPeriod);
    ArrayResize(stochBuffer, rates_total + 1);
    ArrayResize(kBuffer, rates_total + 1);
    ArrayResize(dBuffer, rates_total + 1);
    ArraySetAsSeries(stochBuffer, true);
    ArraySetAsSeries(kBuffer, true);
    ArraySetAsSeries(dBuffer, true);
    ArrayInitialize(stochBuffer, EMPTY_VALUE);
    ArrayInitialize(kBuffer, EMPTY_VALUE);
    ArrayInitialize(dBuffer, EMPTY_VALUE);

    for(int i = limit; i >= 0; i--)
       {
   //     if(i < rates_total - (InpRSIPeriod + 1))
            stochBuffer[i] = Stoch(rSIBuffer, rSIBuffer, rSIBuffer, InpStochastikPeriod, i, rates_total);

   //     if(stochBuffer[i + InpStockKPeriod - 1] != EMPTY_VALUE)
            kBuffer[i] = SimpleMA(i, InpStockKPeriod, stochBuffer, rates_total);

   //     if(kBuffer[i + InpStockDPeriod - 1] != EMPTY_VALUE)
            dBuffer[i] = SimpleMA(i, InpStockDPeriod, kBuffer, rates_total);
       }
    return limit;
   }



//+------------------------------------------------------------------+
//| calculating stochastic                                           |
//+------------------------------------------------------------------+
double Stoch(const double &source[], double &high[], double &low[], int length, int shift, const int &rates_total)
   {
    if(shift + length > rates_total)
        return EMPTY_VALUE;
    double Highest = Highest(high, length, shift);
    double Lowest = Lowest(low, length, shift);
    if(Highest - Lowest == 0)
        return EMPTY_VALUE;
    return 100 * (source[shift] - Lowest) / (Highest - Lowest);
   }
//+------------------------------------------------------------------+
//| find lowest value in prev. X periods                             |
//+------------------------------------------------------------------+
double Lowest(double &low[], int length, int shift)
   {
    double Result = 0;
    if(shift + length > ArraySize(low) - 1)
        length = ArraySize(low) - shift - 1;
    for(int i = shift; i <= shift + length; i++)
       {
        if(Result == 0 || (low[i] < Result && low[i] != EMPTY_VALUE))
           {
            Result = low[i];
           }
       }
    return Result;
   }
//+------------------------------------------------------------------+
//| find highest value in prev. X periods                            |
//+------------------------------------------------------------------+
double Highest(double &high[], int length, int shift)
   {
    double Result = 0;
    if(shift + length > ArraySize(high) - 1)
        length = ArraySize(high) - shift - 1;;
    for(int i = shift; i <= shift + length; i++)
       {
        if(Result == 0 || (high[i] > Result && high[i] != EMPTY_VALUE))
           {
            Result = high[i];
           }
       }
    return Result;
   }
//+------------------------------------------------------------------+
//| calculating simple moving average of an array                    |
//+------------------------------------------------------------------+
double SimpleMA(const int position, const int period, const double &price[], const int &rates_total)
   {
//---
    double result = 0.0;
    if(position <= rates_total - period && period > 0)
       {
        for(int i = 0; i < period; i++)
           {
            if(price[position + i] != EMPTY_VALUE)
               {
                result += price[position + i];
               }
           }
        result /= period;
       }
    return(result);
   }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
