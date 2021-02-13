//+------------------------------------------------------------------+
//|                                               CloseAllCharts.mq4 |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof blank"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   bool ok = false;
   bool close_me = false;
   long  CID = ChartID();
   string list[];
   OpenSymbols(list);
   long  ID = ChartFirst();
   ENUM_TIMEFRAMES tf = ChartPeriod(CID);
   while(ID != -1)
     {
      string sym = ChartSymbol(ID);
      ENUM_TIMEFRAMES tf = ChartPeriod();
      bool match = IsInList(sym, list);

      if(!match)
        {
         if(ID != CID)
           {
            ok = true; //debug!
            ok = ChartClose(ID);
            if(!ok)
              {
               Alert("Failed to close Chart ID: "+ ID+ "\nerror code: "+ GetLastError());
               break;
              }
           }

         else
           {
            close_me = true;
           }
        }
      ID = ChartNext(ID);
     }



// next: open Charts
   for(int i  = 0; i < ArraySize(list); i++)
     {
      bool match=false;
      string sym="";
      long  ID = ChartFirst();
      while(ID != -1)
        {
         sym = ChartSymbol(ID);
         match = sym == list[i];
         if(match)
            break;
         ID = ChartNext(ID);
        }
      if(!match)
        {
         ChartOpen(list[i],tf);
        }
     }

// last: close current if match
   if(close_me)
     {
      ok = ChartClose(CID);
     }
  }




//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenSymbols(string &list[])
  {
   int cnt = OrdersTotal();
   int asize =0;
   ArrayResize(list, asize);
   for(int i = 0; i < OrdersTotal(); i++)
     {
      //---
      if(OrderSelect(i))
        {
         string sym = OrderGetString(ORDER_SYMBOL); //OrderSymbol();
         bool found = false;
         asize = ArraySize(list);
         for(int i = 0; i < asize; i++)
           {
            if(list[i] == sym)
              {
               found =true;
               break;
              }
           }
         if(!found)
           {
            asize++;
            ArrayResize(list,asize);
            list[asize-1]=sym;
           }
        }
     }
   return asize;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsInList(string sym, string &list[])
  {
   for(int i = 0; i < ArraySize(list); i++)
     {
      if(sym == list[i])
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
