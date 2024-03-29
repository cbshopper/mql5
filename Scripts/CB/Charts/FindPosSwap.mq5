//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#property script_show_inputs true

#include <cb\CB_IndicatorHelper.mqh>
#include <cb\ChartFunctions.mqh>


input double SwapMinValue = 1;
input bool AllSymbols = false;
input bool OnlyBuy = true;
input bool OnlySell = true;
input string Template = "SwapInfo.tpl";
input int   CheckMAPeriod = 100;


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   double swap_long, swap_short;
   long spread = 0;
   string pairs[];
   int error = 0;
   string msglong = "Long Swaps:\n";
   string msgshort = "Short Swaps:\n";
   string msg = "";
   long ChartID = 0;
   int Hwnd = 0;
   int length = getAvailableCurrencyPairs(pairs);
   for(int i = 0; i < length; i++)
     {
      Comment("checking " + pairs[i] + " ...");
      SymbolSelect(pairs[i], true);
      swap_long = SymbolInfoDouble(pairs[i], SYMBOL_SWAP_LONG);
      swap_short = SymbolInfoDouble(pairs[i], SYMBOL_SWAP_SHORT);
      spread = SymbolInfoInteger(pairs[i], SYMBOL_SPREAD);
      ENUM_SYMBOL_TRADE_MODE trademode = (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(pairs[i], SYMBOL_TRADE_MODE);
      if(trademode == SYMBOL_TRADE_MODE_FULL  && (swap_long > 0 || swap_short > 0))
        {
         bool ok = false;
         int hma0 = iMA("EURUSD", 0, CheckMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
         // hma0      =iMA(name,period,ma_period,ma_shift,ma_method,applied_price);
         Sleep(50);
         int calculated = BarsCalculated(hma0);
         if(calculated > 100)
           {
            double ma0 = GetIndicatorBufferValue(hma0, 1, 0);
            double ma1 = GetIndicatorBufferValue(hma0, 10, 0);
            if(swap_long > SwapMinValue && OnlyBuy)
              {
               ok = ma0 > ma1;
            //   ok = true;
               msglong = msglong + StringFormat("%s: %f (%f/%f) ok=%d\n", pairs[i], swap_long, ma0, ma1, ok);
               if(ok)
                 {
                  msg = StringFormat("BUY: %s (Swap=%f)", pairs[i], swap_long);
                 }
              }
            if(swap_short > SwapMinValue && OnlySell)
              {
               ok = ma0 < ma1;
           //    ok = true;
               msgshort = msgshort + StringFormat("%s: %f (%f/%f) ok=%d\n", pairs[i], swap_short, ma0, ma1, ok);
               if(ok)
                 {
                  msg = StringFormat("SELL: %s (Swap=%f)", pairs[i], swap_short);
                 }
              }
            if(ok)
              {
               Print(msg);
               ShowChart(pairs[i], ChartTimeFrame, Template);
              }
            if(AllSymbols)
              {
               if(!(swap_short > SwapMinValue || swap_long > SwapMinValue))
                 {
                  AddToRemove(pairs[i]);
                 }
              }
            else
              {
               if(!ok)
                  AddToRemove(pairs[i]);
              }
           }
        }
      else
        {
         // AddToRemove(pairs[i]);
         SymbolSelect(pairs[i], false);
        }
      ChartRedraw();
      //     Alert("Pair #", i+1, ": ", pairs[i]);
     }
   RemoveSymbols();
   MessageBox(msglong + "\n" + msgshort);
  }
//+------------------------------------------------------------------+
