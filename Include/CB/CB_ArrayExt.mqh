//+------------------------------------------------------------------+
//|                                                  CB_ArrayExt.mqh |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof blank"
#property link      "https://www.mql5.com"
#property strict

// shift all array Values by one postion from first to last, forget existing last value
void ArrayShiftDbl( double &arr[])
{
  for (int i =  ArraySize(arr)-1; i > 0   ; i--)
  {
    int q = i-1;
    int z = i;
    arr[z] = arr[q];
  }
}
void ArrayShiftInt(int &arr[])
{
  for (int i =  ArraySize(arr)-1; i > 0   ; i--)
  {
    int q = i-1;
    int z = i;
    arr[z] = arr[q];
  }
}
void ArrayShiftStr( string &arr[])
{
  for (int i =  ArraySize(arr)-1; i > 0   ; i--)
  {
    int q = i-1;
    int z = i;
    arr[z] = arr[q];
  }
}