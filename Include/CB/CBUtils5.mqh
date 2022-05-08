//+------------------------------------------------------------------+
//|                                                     CBUtils5.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObjectFind(string name)
{
   return ObjectFind(0, name);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObjectDelete(string name)
{
   return ObjectDelete(0, name);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  ObjectCreate(string name, ENUM_OBJECT obj, int subwindow, datetime time, double value)
{
   return ObjectCreate(0, name, obj, subwindow, time, value);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIndicatorValue(int handle,int buffer, int index)
{
   double ret = 0;
   double vals[1];
   if (CopyBuffer(handle, buffer, index, 1, vals) > -1)
      {
         ret = vals[0];
      }
   return ret;
}
//+------------------------------------------------------------------+
