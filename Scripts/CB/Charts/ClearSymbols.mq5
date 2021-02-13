//+------------------------------------------------------------------+
//|                                                 ClearSymbols.mq4 |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof blank"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
string pairs[];
int paircount;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {

   paircount = getAvailableCurrencyPairs(pairs);
   RemoveSymbols();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveSymbols()
  {
   for(int i = paircount - 1; i >= 0; i--)
     {
      string sym = pairs[i];
      Comment("removing " + sym + " ...");
      bool ok = SymbolSelect(sym, false);
      if(ok)
        {

        }
     }
   ChartRedraw();
  }
//+------------------------------------------------------------------+
int getAvailableCurrencyPairs(string &availableCurrencyPairs[])
  {
//---
   bool selected = true;
   const int symbolsCount = SymbolsTotal(selected);
   int currencypairsCount;
   ArrayResize(availableCurrencyPairs, symbolsCount);
   int idxCurrencyPair = 0;
   for(int idxSymbol = 0; idxSymbol < symbolsCount; idxSymbol++)
     {
      string symbol = SymbolName(idxSymbol, selected);
      string firstChar = StringSubstr(symbol, 0, 1);
      if(firstChar != "#" && StringLen(symbol) == 6)
        {
         availableCurrencyPairs[idxCurrencyPair++] = symbol;
        }
     }
   currencypairsCount = idxCurrencyPair;
   ArrayResize(availableCurrencyPairs, currencypairsCount);
   return currencypairsCount;
  }
//+------------------------------------------------------------------+
