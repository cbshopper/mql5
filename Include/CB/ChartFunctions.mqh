#include <Arrays\ArrayString.mqh>



extern ENUM_TIMEFRAMES ChartTimeFrame=PERIOD_M15;

CArrayString removelist;
//+------------------------------------------------------------------+
int getAvailableAllSymbols(string &availableCurrencyPairs[])
  {
//---   
   bool selected=false;
   const int symbolsCount=SymbolsTotal(selected);
   int currencypairsCount;
   ArrayResize(availableCurrencyPairs,symbolsCount);
   int idxCurrencyPair=0;
   for(int idxSymbol=0; idxSymbol<symbolsCount; idxSymbol++)
     {
      string symbol=SymbolName(idxSymbol,selected);
      string firstChar=StringSubstr(symbol,0,1);
      if(firstChar!="#") // && StringLen(symbol)==6)
        {
         availableCurrencyPairs[idxCurrencyPair++]=symbol;
        }
     }
   currencypairsCount=idxCurrencyPair;
   ArrayResize(availableCurrencyPairs,currencypairsCount);
   return currencypairsCount;
  }
//+------------------------------------------------------------------+
int getAvailableCurrencyPairs(string &availableCurrencyPairs[])
  {
//---   
   bool selected=false;
   const int symbolsCount=SymbolsTotal(selected);
   int currencypairsCount;
   ArrayResize(availableCurrencyPairs,symbolsCount);
   int idxCurrencyPair=0;
   for(int idxSymbol=0; idxSymbol<symbolsCount; idxSymbol++)
     {
      string symbol=SymbolName(idxSymbol,selected);
      string firstChar=StringSubstr(symbol,0,1);
      if(firstChar!="#" && StringLen(symbol)==6)
        {
         availableCurrencyPairs[idxCurrencyPair++]=symbol;
        }
     }
   currencypairsCount=idxCurrencyPair;
   ArrayResize(availableCurrencyPairs,currencypairsCount);
   return currencypairsCount;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long ShowChart(string symbol,ENUM_TIMEFRAMES period, string templatefile)
  {
   long id=FindChart(symbol,period);
   if(id==-1)
     {
      id=ChartOpen(symbol,ChartTimeFrame);

     }
   ChartApplyTemplate(id,templatefile);
   return id;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long FindChart(string symbol,ENUM_TIMEFRAMES period)
  {
   long ret= -1;
   long  ID=ChartFirst();
   while(ID!=-1)
     {
      string sym=ChartSymbol(ID);
      ENUM_TIMEFRAMES tf=ChartPeriod(ID);
      if(sym==symbol && tf==period)
        {
         ret=ID;
         break;
        }
      ID=ChartNext(ID);
     }
   return ret;
  }
//+------------------------------------------------------------------+
void AddToRemove(string s)
  {

   removelist.Add(s);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveSymbols()
  {

   bool deleted=false;
   do
     {
      Sleep(2000);
      deleted=false;
      int i=0;
      int max=removelist.Total();
      while(i<max)
        {
   //      Sleep(200);
         
         string sym=removelist.At(i);
         Comment("removing " + sym + " ...");
         bool ok=SymbolSelect(sym,false);
         if(ok)
           {
            ok=removelist.Delete(i);
            if(!deleted)
              {
               deleted=true;
              }
           }
         i++;
        }
      ChartRedraw();
     }
   while(deleted);
  }
//+------------------------------------------------------------------+
