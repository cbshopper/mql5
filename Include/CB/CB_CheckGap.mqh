//+------------------------------------------------------------------+
//|                                                  CB_CheckGap.mqh |
//|                                                   Christof blank |
//+------------------------------------------------------------------+
#property copyright "Christof blank"
#property strict


bool CheckGap(int backbars, int shift )
{
  bool ret = false;
  
  if (shift > Bars(NULL,0)-backbars) return ret;
  
  for (int i = shift; i < shift + backbars; i++)
  {
    double val1 = NormalizeDouble(iClose(NULL,0,i+1),Digits()-1);
    double val2 = NormalizeDouble( iOpen(NULL,0,i),Digits()-1);
    double maxdiff = (iHigh(NULL,0,i+1)-iLow(NULL,0,i+1));
    maxdiff = NormalizeDouble(maxdiff,Digits()-1);
    double diff = MathAbs(val1-val2);
    diff = NormalizeDouble(diff,Digits()-1);
    if (diff > maxdiff) 
    {
      ret = true;
      break;
    }
  }
  
  
  return ret;
  
}