//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
#property version "0.90"
#include <Arrays\ArrayString.mqh>

extern ENUM_TIMEFRAMES ChartTimeFrame=PERIOD_M15;
extern bool AllSymbols=false;
extern bool OnlyBuy=true;
extern bool OnlySell=true;

CArrayString removelist;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   double swap_long,swap_short,ask,bid;
   long spread=0;
   string pairs[];

   int error=0;
   string msg="";
   long ChartID=0;
   int Hwnd=0;
   
   
   int length=getSelectedCurrencyPairs(pairs);
   for(int i=0; i<length; i++)
     {
      SymbolSelect(pairs[i],true);
      ShowChart(pairs[i],ChartTimeFrame);
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
int getSelectedCurrencyPairs(string &availableCurrencyPairs[])
  {
//---   
   bool selected=true;
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
//|                                                                  |
//+------------------------------------------------------------------+
long ShowChart(string symbol,ENUM_TIMEFRAMES period)
  {
   long id=FindChart(symbol,period);
   if(id==-1)
     {
      id=ChartOpen(symbol,ChartTimeFrame);

     }
 //  ChartApplyTemplate(id,Template);
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
      if(sym==symbol ) //&& tf==period)
        {
         ret=ID;
         break;
        }
      ID=ChartNext(ID);
     }
   return ret;
  }
//+------------------------------------------------------------------+
