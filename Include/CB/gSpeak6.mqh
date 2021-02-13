 string WordFile ="TTSTranslations.csv";

#import "speak_b6.dll"
	bool gSpeak(string text, int rate, int volume);
#import

string TTSRepacements[][2];
string  TTSPeriods[][2]={   "1", "1 minute",
                              "5", "5 minutes",
                             "15", "15 minutes",
                             "30", "30 minutes",
                             "60", "1 hour",
                            "240", "4 hour",
                           "1440", "Daily",
                          "10080", "Weekly",
                          "43200", "Monthly"};

int TTSInit()
{
   int x=StringArrayLoad(WordFile, TTSRepacements, 2);
   return x;
}




string TTSReplace(string instr)
{
   string ret = instr;
   int max =ArrayRange(TTSRepacements,0);
   for (int i = 0;  i<max ;i++)
   {
      int cnt = StringReplace(ret,TTSRepacements[i][0],TTSRepacements[i][1]);
   }
   return ret;
}
string TTSPeriodBAK(ENUM_TIMEFRAMES period)
{
   string ret = IntegerToString(period);
   
   for (int i = 0;  i< ArraySize(TTSPeriods);i++)
   {
      int cnt = StringReplace(ret,TTSRepacements[i][1],TTSRepacements[i][2]);
      if (cnt > 0) break;
   }
   return ret;
}
string TTSPeriod(int tf)
  {
   string tfs;
//+------------------------------------------------------------------+
//                                                                  
//+------------------------------------------------------------------+
   switch(tf)
     {
      case PERIOD_M1:  tfs="1 minutes"; break;
      case PERIOD_M5:  tfs="1 minutes"; break;
      case PERIOD_M15: tfs="15 minutes"; break;
      case PERIOD_M30: tfs="30 minutes"; break;
      case PERIOD_H1:  tfs="1 hour"; break;
      case PERIOD_H4:  tfs="4 hours"; break;
      case PERIOD_D1:  tfs="Daily"; break;
      case PERIOD_W1:  tfs="Weekly"; break;
      case PERIOD_MN1: tfs="Monthly";
     }
   return(tfs);
  }
//+------------------------------------------------------------------+
//| StringArrayLoad()                                                |
//+------------------------------------------------------------------+
int StringArrayLoad(string sFile, string& A[][], int iColumns) 
  {
    int handle = FileOpen(sFile, FILE_CSV|FILE_READ, ";"), i, iStart, iPos;
//----
    if(handle < 1) 
      {
        Alert("File:", sFile, " error "+GetLastError());
        return(-1);
      }
    string sLine;
    int iRows = ArrayRange(A,0), iLinesRead = 0;
//----
    while(FileIsEnding(handle) == false) 
      {
        sLine = FileReadString(handle);
        iStart = StringLen(sLine);
        //----
        if(iStart < 1 || StringSubstr(sLine,0,2) == "//") 
            continue; // empty strings or comment lines dropped
        //----
        if(iLinesRead >= iRows) 
          {
            if(ArrayResize(A,iRows+1) == 0 ) 
              {
                Alert("StringArrayLoad() error ", GetLastError());
                return(-1);
              }
            iRows += 1;
          }
        //----
        if(StringFind(sLine, ",,", 0) >= 0 || StringSubstr(sLine, iStart - 1, 1) == ",") 
          {
            Alert("File:", sFile, " Line:", iLinesRead, " NULL value");
            break;
          }
        sLine = sLine + ",";
        iStart = 0;
        //----
        for(i = 0; i < iColumns; i++) 
          {
            iPos = StringFind(sLine, ",", iStart);
            A[iLinesRead][i] = StringSubstr(sLine, iStart, iPos - iStart);
            iStart = iPos + 1;
          }
        iLinesRead++;
      }
    FileClose(handle);
    return (iLinesRead);
  }

