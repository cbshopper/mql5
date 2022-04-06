//+------------------------------------------------------------------+
//|                                                     test dll.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

#include <MetatraderToExcel.mqh>
input string path="D:\\1Pdat\\06 Finanzen\\Boerse\\Trading\\Logs";
string xlsfile="C:\\temp\\Book1.xlsx"; //Excel File
extern string logfile="Log.txt";    //Log file
input bool showExcel=true;
input bool closeExcel=false;
//input int HistoryDays=100;
input int FirstRow=2;
input int TicketCol=2;
input int TicketMaxSearchCount=999999;
input string sheet="Tabelle1";
bool isnew=false;
string AccountNo="";
string Broker="";
string AccountTyp="";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   AccountNo = (string)AccountInfoInteger(ACCOUNT_LOGIN);
   Broker=AccountInfoString(ACCOUNT_COMPANY);
   ENUM_ACCOUNT_TRADE_MODE tradeMode=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);

   switch(tradeMode)
     {
      case(ACCOUNT_TRADE_MODE_DEMO):
         Print("This is a demo account");
         AccountTyp ="DEMO";
         break;
      case(ACCOUNT_TRADE_MODE_CONTEST):
         Print("This is a competition account");
         AccountTyp ="COMPETITION";
         break;
      default:
         Print("This is a real account!");
         AccountTyp ="REAL";
         break;
     }

   xlsfile=path + "\\"+"" + Broker + " #" + AccountNo + " (" + AccountTyp + ").xlsx";
   logfile=path + "\\" +logfile;
   int ret = Start(xlsfile,logfile,showExcel);
   if(ret == 1)
      isnew=true;

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(closeExcel || showExcel==false)
     {
      DeInit();
     }
   Comment(" ");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnStart()
  {
   Main();
//---
  }
//+------------------------------------------------------------------+
string ColName(int col)
  {
   int start = StringGetChar("A",0);
   string ret = StringSetChar(" ",0,start+col);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CellName(int row, int col)
  {
   string ret = ColName(col) + (string) row;
   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Part(string range, string &part1, string &part2)
  {
   part1="";
   part2="";
   for(int i =0; i < StringLen(range); i++)
     {
      ushort A = StringGetChar("A",0);
      ushort zero = StringGetChar("0",0);
      ushort c = StringGetChar(range,i);
      if(c >='A' && c <='Z')
         part1 = part1+(string)(c -A+1);
      else
         part2=part2+StringSetChar("",0,c);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetRow(string range)
  {
   string p1,p2;
   Part(range,p1,p2);
   return StringToInteger(p2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCol(string range)  //A-Z only!
  {
   string p1,p2;
   Part(range,p1,p2);
   int ret = StringToInteger(p1) -StringGetChar("A",0);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Main()
  {


   int col=0;
   int row=0;

   string curTime = TimeToString(TimeLocal());
   PutStr_intidx(StringFormat("%s Account# %s (%s) Date: %s", Broker,AccountNo,AccountTyp,curTime),sheet,FirstRow,1);
   row = FirstRow+1;
   col =1;

     {
      PutStr_intidx("State",sheet,row,col++);
      PutStr_intidx("Ticket",sheet,row,col++);
      PutStr_intidx("Symbol",sheet,row,col++);
      PutStr_intidx("Typ",sheet,row,col++);
      PutStr_intidx("OpenTime",sheet,row,col++);
      PutStr_intidx("CloseTime",sheet,row,col++);
      PutStr_intidx("OpenPrice",sheet,row,col++);
      PutStr_intidx("ClosePrice",sheet,row,col++);
      PutStr_intidx("Lots",sheet,row,col++);
      PutStr_intidx("Profit",sheet,row,col++);
      PutStr_intidx("Comment",sheet,row,col++);
     }
// retrieving info from trade history
   int i,hstTotal=OrdersHistoryTotal();
   for(i=0; i<hstTotal; i++)
     {
      //---- check selection result
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
        {
         MessageBox("Access to history failed with error (",GetLastError(),")");
         break;
        }
        /*
      if(HistoryDays > 0)
        {
         if(OrderCloseTime() < TimeLocal()-HistoryDays*60 * 60 * 24)
            continue;
        }
        */
      col =1;
      int ticket = OrderTicket();  
      Print(ticket);
      if(ticket == 86275440)
        {
         int debug1=1;
        }
      string found = FindInCols(sheet,TicketCol,FirstRow+2,TicketMaxSearchCount,ticket);  
    //   string found = Find(sheet,ticket);  
      if(found != "")
        {
         row = GetRow(found);
         string state = GetStr_intidx(sheet,row,1);
         //  if (state == "closed") continue;  // bei state==closed nicht machen, sonst aktualisieren, da state vorher open war!
        }
      else
        {
         string s =GetStr_intidx(sheet,row,col);
         while(s != "" && s != NULL)
           {
            row++;
            s =GetStr_intidx(sheet,row,col);
           }
        }
      Export(sheet,row,col,"closed");
      /*
      PutStr(OrderTicket(),sheet,row,col++);
      PutStr(OrderSymbol(),sheet,row,col++);
      PutStr(TimeToStr(OrderOpenTime()),sheet,row,col++);
      PutStr(TimeToStr(OrderCloseTime()),sheet,row,col++);
      PutStr(OrderOpenPrice(),sheet,row,col++);
      PutStr(OrderOpenPrice(),sheet,row,col++);
      PutStr(OrderLots(),sheet,row,col++);
      PutStr(OrderProfit(),sheet,row,col++);
      PutStr(OrderComment(),sheet,row,col++);

      */
     }
   int cnt=OrdersTotal();
   for(i=0; i<cnt; i++)
     {
      //---- check selection result
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
        {
         MessageBox("Access to tades failed with error (",GetLastError(),")");
         break;
        }
      col =1;
      // row++;
      int ticket = OrderTicket();
      if(ticket == 8583538)
        {
         int debug2=1;
        }
      //string found = Find(sheet,ticket);
       string found = FindInCols(sheet,TicketCol,FirstRow+2,TicketMaxSearchCount,ticket);  
      if(found != "")
        {
         row = GetRow(found);
        }
      else
        {
        string s =GetStr_intidx(sheet,row,col);
         while(s != "" && s != NULL)
           {
            row++;
            s =GetStr_intidx(sheet,row,col);
           }
        }
      Export(sheet,row,col,"open");
      /*
      PutStr(OrderTicket(),sheet,row,col++);
      PutStr(OrderSymbol(),sheet,row,col++);
      PutStr(TimeToStr(OrderOpenTime()),sheet,row,col++);
      PutStr(TimeToStr(OrderCloseTime()),sheet,row,col++);
      PutStr(OrderOpenPrice(),sheet,row,col++);
      PutStr(OrderOpenPrice(),sheet,row,col++);
      PutStr(OrderLots(),sheet,row,col++);
      PutStr(OrderProfit(),sheet,row,col++);
      PutStr(OrderComment(),sheet,row,col++);

      */
     }
     MessageBox("Finished!");


  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Export(string sheet,int row, int col,string state)
  {
   PutStr(state,sheet,row,col++);
   PutInt(OrderTicket(),sheet,row,col++);
   PutStr(OrderSymbol(),sheet,row,col++);
   PutStr(GetTypeString(OrderType()),sheet,row,col++);
   PutStr(TimeToStr(OrderOpenTime()),sheet,row,col++);
   datetime closetime = OrderCloseTime();
   string s = TimeToStr(closetime);
   if(closetime == 0)
      s = "";
   PutStr(s,sheet,row,col++);
   PutDouble(OrderOpenPrice(),sheet,row,col++);
   PutDouble(OrderClosePrice(),sheet,row,col++);
   PutDouble(OrderLots(),sheet,row,col++);
   PutDouble(OrderProfit(),sheet,row,col++);
   PutStr(OrderComment(),sheet,row,col++);
   Sleep(100);
  }
//+------------------------------------------------------------------+
string GetTypeString(int ordertype)
  {
   switch(ordertype)
     {
      case OP_BUY:
         return "OP_BUY";
      case OP_SELL:
         return "OP_SELL";
      case OP_BUYLIMIT:
         return "OP_BUYLIMIT";
      case OP_SELLLIMIT:
         return "OP_SELLLIMIT";
      case OP_BUYSTOP:
         return "OP_BUYSTOP";
      case OP_SELLSTOP:
         return "OP_SELLSTOP";
     }
   return "?";
  }

//+------------------------------------------------------------------+
