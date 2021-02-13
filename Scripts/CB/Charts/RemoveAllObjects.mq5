//+------------------------------------------------------------------+
//|                                             RemoveAllObjects.mq4 |
//|                                  Copyright 2017,, Christof Blank |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,, Christof Blank"
#property link      ""
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
    int cnt = ObjectsDeleteAll(0);
    Comment("");
 //   MessageBox(StringFormat("%d objects removed!",cnt),"Info");
  }
//+------------------------------------------------------------------+
