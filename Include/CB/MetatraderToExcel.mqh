//+------------------------------------------------------------------+
//|                                            MetatraderToExcel.mqh |
//|                                               http://no.link.yet |
//+------------------------------------------------------------------+
#property copyright "Christof Blank (c) 2022"
#property strict
#import "MetatraderToExcel.dll"
int Initialize(string wkb,string logfile,bool show);
void DeInit();
void PutDouble_Cell(double dbl,string shts,string cell);
void PutDouble_intidx(double dbl,string shts,int rowindex,int columnindex);
void PutDouble_intCell(double dbl,string shts,int rowindex,string column);
void PutInt_Cell(int Integer,string shts,string cell);
void PutInt_intidx(int Integer,string shts,int rowindex,int columnindex);
void PutInt_intCell(int Integer,string shts,int rowindex,string column);
void PutStr_Cell(string str,string shts,string cell);

void PutStr_intidx(string str,string shts,uint rowindex,uint columnindex);
void PutStr_intidx2(string str,string shts,uint rowindex,uint columnindex);

void PutStr_intCell(string str,string shts,int rowindex,string column);
double GetDouble_Cell(string shts,string cell);
double GetDouble_intidx(string shts,int rowindex,int columnindex);
double GetDouble_intCell(string shts,int rowindex,string column);
int GetInt_Cell(string shts,string cell);
int GetInt_intidx(string shts,int rowindex,int columnindex);
int GetInt_intCell(string shts,int rowindex,string column);
string GetStr_Cell(string shts,string cell);
string GetStr_intidx(string shts,int rowindex,int columnindex);
string GetStr_intCell(string shts,int rowindex,string column);
string Find(string shts,string findme);
string FindInCol(string shts,string findme,int columnindex,int from,int to);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Start(string wkb,string tlogfile,bool show)
  {
   int ret = Initialize(wkb,tlogfile,show);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutDouble(double dbl,string shts,string cell)
  {
   PutDouble_Cell(dbl,shts,cell);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutDouble(double dbl,string shts,int rowindex,int columnindex)
  {
   PutDouble_intidx(dbl,shts,rowindex,columnindex);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutDouble(double dbl,string shts,int rowindex,string column)
  {
   PutDouble_intCell(dbl,shts,rowindex,column);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutInt(int Integer,string shts,string cell)
  {
   PutInt_Cell(Integer,shts,cell);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutInt(int Integer,string shts,int rowindex,int columnindex)
  {
   PutInt_intidx(Integer,shts,rowindex,columnindex);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutInt(int Integer,string shts,int rowindex,string column)
  {
   PutInt_intCell(Integer,shts,rowindex,column);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutStr(string str,string shts,string cell)
  {
   PutStr_Cell(str,shts,cell);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutStr(string str,string shts,int rowindex,int columnindex)
  {
     PutStr_intidx2(str,shts,rowindex,columnindex);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutStr(string str,string shts,int rowindex,string column)
  {
   PutStr_intCell(str,shts,rowindex,column);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetDouble(string shts,string cell)
  {
   return(GetDouble_Cell(shts, cell));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetDouble(string shts,int rowindex,int columnindex)
  {
   return(GetDouble_intidx(shts, rowindex, columnindex));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetDouble(string shts,int rowindex,string column)
  {
   return(GetDouble_intCell(shts, rowindex, column));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetInt(string shts,string cell)
  {
   return(GetInt_Cell(shts, cell));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetInt(string shts,int rowindex,int columnindex)
  {
   return(GetInt_intidx(shts, rowindex, columnindex));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetInt(string shts,int rowindex,string column)
  {
   return(GetInt_intCell(shts, rowindex, column));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetStr(string shts,string cell)
  {
   return(GetStr_Cell(shts, cell));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetStr(string shts,int rowindex,int columnindex)
  {
   return(GetStr_intidx(shts, rowindex, columnindex));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetStr(string shts,int rowindex,string column)
  {
   return(GetStr_intCell(shts, rowindex, column));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FindStr(string shts,string findme)
  {
   return(Find(shts, findme));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FindInCols(string shts,int columnindex,int from, int to, string findme)
  {
   return(FindInCol(shts, findme,columnindex,from,to));
  }  

