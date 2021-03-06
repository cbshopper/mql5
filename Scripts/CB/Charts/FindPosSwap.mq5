//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
#property version "0.91"
#property script_show_inputs true
#include <cb\CBUtils5.mqh>
#include <Arrays\ArrayString.mqh>

extern ENUM_TIMEFRAMES ChartTimeFrame=PERIOD_M15;
extern string Template="SwapInfo.tpl";
extern double SwapMinValue=1;
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
   string msglong="Long Swaps:\n";
   string msgshort="Short Swaps:\n";
   string msg="";
   long ChartID=0;
   int Hwnd=0;
   
   
   
   if (!OnlyBuy && !OnlySell)
   {
     OnlyBuy=true;
     OnlySell=true;
   }
   
   int length=getAvailableCurrencyPairs(pairs);
   for(int i=0; i<length; i++)
     {
      Comment("checking " + pairs[i] + " ...");
      SymbolSelect(pairs[i],true);
      swap_long=SymbolInfoDouble(pairs[i],SYMBOL_SWAP_LONG);
      swap_short=SymbolInfoDouble(pairs[i],SYMBOL_SWAP_SHORT);
      ask=SymbolInfoDouble(pairs[i],SYMBOL_ASK);
      //     error=GetLastError();
      bid=SymbolInfoDouble(pairs[i],SYMBOL_BID);
      //      error = GetLastError();
      spread=SymbolInfoInteger(pairs[i],SYMBOL_SPREAD);
      //      error = GetLastError();
      //if(spread>0 && spread<1000)
      ENUM_SYMBOL_TRADE_MODE trademode=SymbolInfoInteger(pairs[i],SYMBOL_TRADE_MODE);
      //  trademode = SYMBOL_TRADE_MODE_DISABLED;

      int hma0=iMA(pairs[i],PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE);
    
      if(trademode==SYMBOL_TRADE_MODE_FULL)
        {

     
     
         bool ok=false;
         if(swap_long>SwapMinValue && OnlyBuy)
           {
            double ma0=   GetIndicatorValue(hma0,1); // iMA(pairs[i],PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,1);
            double ma1=  GetIndicatorValue(hma0,10); // iMA(pairs[i],PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,10);

            ok=ma0>ma1;
            msglong=msglong+StringFormat("%s: %f (%f/%f) ok=%d\n",pairs[i],swap_long,ma0,ma1,ok);
            if(ok)
              {
               msg=StringFormat("BUY: %s (Swap=%f)",pairs[i],swap_long);
               //             Alert(msg);
               //             Print(msg);
               //             ChartID=ChartOpen(pairs[i],ChartTimeFrame);
               //             ChartApplyTemplate(ChartID,Template);
              }
           }
         if(swap_short>SwapMinValue && OnlySell)
           {
             double ma0=   GetIndicatorValue(hma0,1); // iMA(pairs[i],PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,1);
            double ma1=  GetIndicatorValue(hma0,10); // iMA(pairs[i],PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,10);

            ok=ma0<ma1;
            msgshort=msgshort+StringFormat("%s: %f (%f/%f) ok=%d\n",pairs[i],swap_short,ma0,ma1,ok);
            if(ok)
              {
               msg=StringFormat("SELL: %s (Swap=%f)",pairs[i],swap_short);
               //              Alert(msg);
               //              Print(msg);
               //              ShowChart(pairs[i],ChartTimeFrame);
               //             ChartID=ChartOpen(pairs[i],ChartTimeFrame);
               //             ChartApplyTemplate(ChartID,Template);
              }
           }
         if(ok)
           {
            Print(msg);
            ShowChart(pairs[i],ChartTimeFrame);
           }
         if(AllSymbols)
           {
            if(!(swap_short>SwapMinValue || swap_long>SwapMinValue))
              {
               AddToRemove(pairs[i]);
              }
           }
         else
           {
            if (!ok) AddToRemove(pairs[i]);
           }

        }
      else
        {
         // AddToRemove(pairs[i]);
         SymbolSelect(pairs[i],false);
        }
      ChartRedraw();
      //     Alert("Pair #", i+1, ": ", pairs[i]);
     }
   RemoveSymbols();
   MessageBox(msglong+"\n"+msgshort);
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
long ShowChart(string symbol,ENUM_TIMEFRAMES period)
  {
   long id=FindChart(symbol,period);
   if(id==-1)
     {
      id=ChartOpen(symbol,ChartTimeFrame);

     }
   ChartApplyTemplate(id,Template);
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
