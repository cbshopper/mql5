//+------------------------------------------------------------------+
//|                                                      CBUtils.mq4 |
//|                                   Copyright 2015, Christof Blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2015, Christof Blank"
#include <CB\ErrorMsg.mqh>
//#include <AddFeatures.mqh>
#import "kernel32.dll"
int GlobalAlloc(int Flags, uint Size);
int GlobalLock(int hMem);
int GlobalUnlock(int hMem);
int GlobalFree(int hMem);
void RtlMoveMemory(int, uint&[], uint);
#import

#import "user32.dll"
int OpenClipboard(uint hOwnerWindow);
int EmptyClipboard();
int CloseClipboard();
int SetClipboardData(uint Format, uint hMem);
int GetParent(int hWnd);
int SendMessageA(int hWnd, int Msg, int wParam, int lParam);

#import





#define GMEM_MOVEABLE   2
#define CF_DIB          8
#define SZBITMAPHEADER  14

bool DoNotDeleteTempFile = false; // temp- Screeshot-File nicht löschen!

#import "user32.dll"
#import

#ifndef WM_MDIACTIVATE
#define WM_MDIACTIVATE 546
#endif


#import "kernel32.dll"
int SystemTimeToFileTime(int& TimeArray[], int& FileTimeArray[]);
int FileTimeToLocalFileTime(int& FileTimeArray[], int& LocalFileTimeArray[]);
void GetSystemTime(int& TimeArray[]);
#import

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetWinLocalDateTime()
 {
  double hundrednSecPerSec = 10.0 * 1000000.0;
  double bit32to64 = 65536.0 * 65536.0;
  double secondsBetween1601And1970 = 11644473600.0;
  int    TimeArray[4];
  int    FileTimeArray[2];   // 100nSec since 1601/01/01 UTC
  int    LocalFileTimeArray[2];   // 100nSec since 1601/01/01 Local
  GetSystemTime(TimeArray);
  SystemTimeToFileTime(TimeArray, FileTimeArray);
  FileTimeToLocalFileTime(FileTimeArray, LocalFileTimeArray);
  double lfLo32 = LocalFileTimeArray[0];
  if(lfLo32 < 0)
    lfLo32 = bit32to64 + lfLo32;
  double ticksSince1601 = LocalFileTimeArray[1] * bit32to64 + lfLo32;
  double secondsSince1601 = ticksSince1601 / hundrednSecPerSec;
  double secondsSince1970 = secondsSince1601 - secondsBetween1601And1970;
  return (datetime)secondsSince1970;
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetWinUtcDateTime()
 {
  double hundrednSecPerSec = 10.0 * 1000000.0;
  double bit32to64 = 65536.0 * 65536.0;
  double secondsBetween1601And1970 = 11644473600.0;
  int    TimeArray[4];
  int    FileTimeArray[2];   // 100nSec since 1601/01/01 UTC
  GetSystemTime(TimeArray);
  SystemTimeToFileTime(TimeArray, FileTimeArray);
  double lfLo32 = FileTimeArray[0];
  if(lfLo32 < 0)
    lfLo32 = bit32to64 + lfLo32;
  double ticksSince1601 = FileTimeArray[1] * bit32to64 + lfLo32;
  double secondsSince1601 = ticksSince1601 / hundrednSecPerSec;
  double secondsSince1970 = secondsSince1601 - secondsBetween1601And1970;
  return (datetime)secondsSince1970;
 }



//+------------------------------------------------------------------+
string TimeFrameToString(int tf)
 {
  string tfs;
//+------------------------------------------------------------------+
//
//+------------------------------------------------------------------+
  switch(tf)
   {
    case PERIOD_M1:
      tfs = "M1";
      break;
    case PERIOD_M5:
      tfs = "M5";
      break;
    case PERIOD_M15:
      tfs = "M15";
      break;
    case PERIOD_M30:
      tfs = "M30";
      break;
    case PERIOD_H1:
      tfs = "H1";
      break;
    case PERIOD_H4:
      tfs = "H4";
      break;
    case PERIOD_D1:
      tfs = "D1";
      break;
    case PERIOD_W1:
      tfs = "W1";
      break;
    case PERIOD_MN1:
      tfs = "MN";
   }
  return(tfs);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodAsString()
 {
  string ret = TimeFrameToString(Period());
  return ret;
 }
//+-----------------------------------------------------------------
//|                                                                  |
//+-----------------------------------------------------------------
void prtAlert(string str = "")
 {
  Print(str);
  Alert(str);
//   SpeechText(str,SPEECH_ENGLISH);
//   SendMail("Subject EA",str);
 }
bool log_debug = false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//extern string note6 = ">>>>>>>>>>>>>> Begin Settings Arrows ============================";
/*
extern string note7 = "Arrow Type";
extern string note8 = "0=Thick, 1=Thin, 2=Hollow, 3=Round";
extern string note9 = "4=Fractal, 5=Diagonal Thin";
extern string note10 = "6=Diagonal Thick, 7=Diagonal Hollow";
extern string note11 = "8=Thumb, 9=Finger";
*/
//extern int ArrowType=1; // 0=Thick, 1=Thin, 2=Hollow, 3=Round,4=Fractal, 5=Diagonal Thin,6=Diagonal Thick, 7=Diagonal Hollow,8=Thumb, 9=Finger
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SelectArrowType(int arrowType, int &Arrow0, int &Arrow1)
 {
  if(arrowType == 0)
   {
    Arrow0 =  233;
    Arrow1 = 234;
   }
  else
    if(arrowType == 1)
     {
      Arrow0 = 225;
      Arrow1 = 226;
     }
    else
      if(arrowType == 2)
       {
        Arrow0 = 241;
        Arrow1 = 242;
       }
      else
        if(arrowType == 3)
         {
          Arrow0 = 221;
          Arrow1 = 222;
         }
        else
          if(arrowType == 4)
           {
            Arrow0 = 217;
            Arrow1 = 218;
           }
          else
            if(arrowType == 5)
             {
              Arrow0 = 228;
              Arrow1 = 230;
             }
            else
              if(arrowType == 6)
               {
                Arrow0 = 236;
                Arrow1 = 238;
               }
              else
                if(arrowType == 7)
                 {
                  Arrow0 = 246;
                  Arrow1 = 248;
                 }
                else
                  if(arrowType == 8)
                   {
                    Arrow0 = 67;
                    Arrow1 = 68;
                   }
                  else
                    if(arrowType == 9)
                     {
                      Arrow0 = 71;
                      Arrow1 = 72;
                     }
 }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Alerts(string AlertText, bool DoShow)
 {
  static datetime timeprev;
  if(timeprev < iTime(NULL, 0, 0) && DoShow)
   {
    timeprev = iTime(NULL, 0, 0);
    Alert(AlertText, " ", Symbol(), " - ", Period(), "  at  ", iClose(NULL, 0, 0), "  -  ", TimeToString(TimeCurrent(), TIME_SECONDS));
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CopyScreenshotToClipboard()
 {
  bool bReturnvalue = false;
  string cid = IntegerToString(ChartID());
  string kid = IntegerToString(GetTickCount());
// Temporary file
  string strFile = "";
  StringConcatenate(strFile, (string)cid, (string)kid, ".bmp");
// Take screenshot
//  if(!ChartScreenShot(0,strFile,(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS),(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS),ALIGN_LEFT))
  int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
  int height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
  if(!ChartScreenShot(0, strFile, width, height, ALIGN_LEFT)) // ALIGN_LEFT!!! sonst wird immer nur das Ende angezeigt!
   {
    // Screenshot failed
   }
  else
   {
    // Open file
    int h = FileOpen(strFile, FILE_BIN | FILE_READ);
    if(h == INVALID_HANDLE)
     {
      // File open failed
     }
    else
     {
      // Get file size
      uint szFile = (uint)FileSize(h);
      // Try grabbing ownership of the clipboard
      if(OpenClipboard(0) == 0)
       {
        // Failed to open the clipboard
       }
      else
       {
        // Try emptying the clipboard
        if(EmptyClipboard() == 0)
         {
          // Failed to empty the clipboard
         }
        else
         {
          // Try allocating a block of global memory to hold the text
          int hMem = GlobalAlloc(GMEM_MOVEABLE, szFile - SZBITMAPHEADER);
          if(hMem == 0)
           {
            // Memory allocation failed
           }
          else
           {
            // Lock the memory
            int ptrMem = GlobalLock(hMem);
            if(ptrMem == 0)
             {
              // Memory lock failed
              GlobalFree(hMem);
             }
            else
             {
              // Skip past the file header
              FileSeek(h, SZBITMAPHEADER, SEEK_SET);
              // Read the file, minus the header, into an array
              uint arrData[];
              ArrayResize(arrData, (szFile - SZBITMAPHEADER) / 4);
              FileReadArray(h, arrData);
              // Copy the array into the memory block, and then release control of the memory
              RtlMoveMemory(ptrMem, arrData, szFile - SZBITMAPHEADER);
              GlobalUnlock(hMem);
              // Try setting the clipboard contents using the global memory
              if(SetClipboardData(CF_DIB, hMem) != 0)
               {
                // Okay
                bReturnvalue = true;
               }
              else
               {
                // Failed to set the clipboard using the global memory
                GlobalFree(hMem);
               }
             }
           }
         }
        CloseClipboard();
       }
      FileClose(h);
     }
    if(DoNotDeleteTempFile == false)
     {
      FileDelete(strFile);
     }
   }
  return bReturnvalue;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeAsString(int shift)
 {
  return TimeToString(iTime(NULL, 0, shift));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PrintTime(int shift)
 {
  return TimeToString(iTime(NULL, 0, shift));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndicatorsDeleteAll(long charid)
 {
  long subwincnt = ChartGetInteger(charid, CHART_WINDOWS_TOTAL, 0);
  while(subwincnt > 1)
   {
    int indicnt = ChartIndicatorsTotal(charid, 1);
    while(indicnt > 0)
     {
      string name = ChartIndicatorName(charid, 1, 0);
      ChartIndicatorDelete(charid, 1, name);
      indicnt = ChartIndicatorsTotal(charid, 1);
     }
    subwincnt = ChartGetInteger(charid, CHART_WINDOWS_TOTAL, 0);
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long FindChartWindow(string symbol, int periode)
 {
  long ret = -1;
  long  ID = ChartFirst();
  while(ID != -1)
   {
    string sym = ChartSymbol(ID);
    ENUM_TIMEFRAMES   peri = ChartPeriod(ID);
    if(sym == symbol && peri == (ENUM_TIMEFRAMES)periode)
     {
      ret = ID;
      break;
     }
    ID = ChartNext(ID);
   }
  return ret;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| The function receives the chart width in bars.                   |
//+------------------------------------------------------------------+
int BarCount(const long chart_ID = 0)
 {
//--- prepare the variable to get the property value
  long result = -1;
//--- reset the error value
  ResetLastError();
//--- receive the property value
  if(!ChartGetInteger(chart_ID, CHART_WIDTH_IN_BARS, 0, result))
   {
    //--- display the error message in Experts journal
    Print(__FUNCTION__ + ", Error Code = ", GetLastError());
   }
//--- return the value of the chart property
  return((int)result);
 }

//+------------------------------------------------------------------+
int Value2Point(double Value)
 {
  int ret = 0;
// ret=NormalizeDouble(Value/POINT(),Digits);
  ret = (int)(Value / Point());
  return ret;
 }
//+------------------------------------------------------------------+
double Point2Value(int Pips)
 {
  double ret = 0;
  ret = NormalizeDouble(Pips * Point(), Digits());
  return ret;
 }

//+------------------------------------------------------------------+
int getSelectedCurrencyPairs(string &availableCurrencyPairs[])
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
    if(firstChar != "#") // && StringLen(symbol)==6)
     {
      availableCurrencyPairs[idxCurrencyPair++] = symbol;
     }
   }
  currencypairsCount = idxCurrencyPair;
  ArrayResize(availableCurrencyPairs, currencypairsCount);
  return currencypairsCount;
 }

string GetRelativeProgramPath()

 {
  int pos2;
//--- get the absolute path to the application
  string path = MQLInfoString(MQL_PROGRAM_PATH);
//--- find the position of "\MQL4\" substring
  int    pos = StringFind(path, "\\MQL4\\");
//--- substring not found - error
  if(pos < 0)
    return(NULL);
//--- skip "\MQL4" directory
  pos += 5;
//--- skip extra '\' symbols
  while(StringGetCharacter(path, pos + 1) == '\\')
    pos++;
//--- if this is a resource, return the path relative to MQL5 directory
  if(StringFind(path, "::", pos) >= 0)
    return(StringSubstr(path, pos));
//--- find a separator for the first MQL4 subdirectory (for example, MQL4\Indicators)
//--- if not found, return the path relative to MQL4 directory
  if((pos2 = StringFind(path, "\\", pos + 1)) < 0)
    return(StringSubstr(path, pos));
//--- return the path relative to the subdirectory (for example, MQL4\Indicators)
  return(StringSubstr(path, pos2 + 1));
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool WaitForData(int IndiPtr)
 {
  int loops = 0;
  ChartSetSymbolPeriod(0, Symbol(), PERIOD_CURRENT);
  int cnt = BarsCalculated(IndiPtr);
  while(cnt < 100 && loops < 1000000)
   {
    Sleep(100);
    cnt = BarsCalculated(IndiPtr);
    if(cnt > 0)
      break;
    loops++;
   }
  return cnt > 0;
 }
/*
//+------------------------------------------------------------------+
double Ask()
 {
  MqlTick last_tick;
  SymbolInfoTick(_Symbol, last_tick);
  return last_tick.ask;
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bid()
 {
  MqlTick last_tick;
  SymbolInfoTick(_Symbol, last_tick);
  return last_tick.bid;
 }
 */

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AskPrice()
 {
  MqlTick Latest_Price; // Structure to get the latest prices
  SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure
// The BID price.
  static double dBid_Price;
// The ASK price.
  static double dAsk_Price;
  dBid_Price = Latest_Price.bid;  // Current Bid price.
  dAsk_Price = Latest_Price.ask;  // Current Ask price.
  return dAsk_Price;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BidPrice()
 {
  MqlTick Latest_Price; // Structure to get the latest prices
  SymbolInfoTick(Symbol(), Latest_Price); // Assign current prices to structure
// The BID price.
  static double dBid_Price;
// The ASK price.
  static double dAsk_Price;
  dBid_Price = Latest_Price.bid;  // Current Bid price.
  dAsk_Price = Latest_Price.ask;  // Current Ask price.
  return dBid_Price;
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  CalcOrderResultValues(int startbar, int stopbar, int signal, int SL, int TP, double &winval)
 {
  double win = 0;
  int pips = 0;
  if(startbar > 0)
   {
    if(signal == 1)
     {
      win = iOpen(NULL, 0, stopbar) - iOpen(NULL, 0, startbar);
     }
    if(signal == -1)
     {
      win = iOpen(NULL, 0, startbar) - iOpen(NULL, 0, stopbar);
     }
    if(win < 0 && SL > 0)
     {
      double v = MathMax(win, SL * Point());
     }
    if(win > 0 && TP > 0)
     {
      double v = MathMax(win, TP * Point());
     }
    win = NormalizeDouble(win, Digits());
    pips = (int)(win / Point());
    double lotsize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE);
    long leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
    if(leverage == 0)
      leverage = 1;
    winval = win * lotsize / leverage;
   }
  return pips;
 }




//+------------------------------------------------------------------+
string sTfTable[] = {"M1", "M5", "M15", "M30", "H1","H2","H4", "D1", "W1", "MN"};
// int    iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};  //MT4?

int    iTfTable[] = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H4,PERIOD_D1,PERIOD_MN1};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
 {
  StringToUpper(tfs);
  for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
   {
    if(tfs == sTfTable[i] || tfs == "" + (string)iTfTable[i])
      return(MathMax(iTfTable[i], Period()));
   }
  return(Period());
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
 {
 if (tf == 0) tf = Period();
  for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
    if(tf == iTfTable[i])
     {
      return(sTfTable[i]);
     }
  return("M" + (string)(PeriodSeconds() / 60));
 }

//
//+------------------------------------------------------------------+
