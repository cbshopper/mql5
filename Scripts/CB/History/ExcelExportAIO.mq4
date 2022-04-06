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
input string file="AllAccounts";   //Filename without extension
extern string logfile="Log.txt";    //Log file
input bool showExcel=true;
input bool closeExcel=false;
//input int HistoryDays=100;
input int FirstRow=2;

int BrokerCol=1;
int AccountCol=2;
int AcTypeCol=3;
int StateCol=4;
int TicketCol=5;
int SymbolCol=6;
int TypCol=7;
int OpenTimeCol=8;
int CloseTimeCol=9;
int OpenPriceCol=10;
int ClosePriceCol=11;
int LotsCol=12;
int ProfitCol=13;
int CommentCol=14;






input int TicketMaxSearchCount=999999;
input string sheet="Tabelle1";
bool isnew=false;
string AccountNo="";
string Broker="";
string AccountTyp="";
string xlsfile="";
int last_row=FirstRow+2;
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

   xlsfile=path + "\\"+"" + file + ".xlsx";
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
   PutStr_intidx(StringFormat("Last Update Date: %s", curTime),sheet,FirstRow,1);
   row = FirstRow+1;
   col =1;

   ExportHeader(sheet,row);
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
      col =1;
      int ticket = OrderTicket();
      Print(ticket);
      if(ticket == 86275440)
        {
         int debug1=1;
        }

      row = FindTicket(ticket);
      last_row=row;
      //   string state = GetStr_intidx(sheet,row,StateCol);
      /*********** OLD STUFF
      string found = FindInCols(sheet,TicketCol,FirstRow+2,TicketMaxSearchCount,ticket);

      if(found != "")
        {
         row = GetRow(found);
         string state = GetStr_intidx(sheet,row,1);
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
      */

      ExportData(sheet,row,"closed");

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
      row = FindTicket(ticket);
      /***************** OLD STUFF
      bool found=false;
      row = FirstRow+2;
      while(!found)
      {
       string fstr = FindInCols(sheet,TicketCol,FirstRow+2,TicketMaxSearchCount,ticket);
       if(fstr != "")
         {
          row = GetRow(fstr);
         }
       else
         {
          found=true;

         }
      }

      if(fstr != "")
      {
       row = GetRow(fstr);
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

      ********/


      ExportData(sheet,row,"open");

     }
   MessageBox("Finished!");


  }
//+------------------------------------------------------------------+
int FindTicket(string ticket)
  {
   bool done = false;
   int row =0;
   while(!done)
     {
      string fstr = FindInCols(sheet,TicketCol,FirstRow+2,TicketMaxSearchCount,ticket);
      if(fstr != "")
        {
         row = GetRow(fstr);
         int  s =GetStr_intidx(sheet,row,AccountCol);
         if( s==AccountNo)
           {
            done=true;
           }
         else
           {
            row =0;
           }
        }
      else
        {
         done=true;
         row=0;
        }
     }

   if(row ==0)
     {
      row = last_row;
      int  s =GetStr_intidx(sheet,row,TicketCol);
      while(s != "" && s != NULL)
        {
         row++;
         s =GetStr_intidx(sheet,row,TicketCol);
        }
     }
   return row;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExportHeader(string sheet,int row)
  {
   PutStr_intidx("Broker",sheet,row,BrokerCol);   //1
   PutStr_intidx("Account#",sheet,row,AccountCol);  //2
   PutStr_intidx("Type",sheet,row,AcTypeCol);  // 3

   PutStr_intidx("State",sheet,row,StateCol);  //4
   PutStr_intidx("Ticket",sheet,row,TicketCol); //5  => TicketCol
   PutStr_intidx("Symbol",sheet,row,SymbolCol);
   PutStr_intidx("Typ",sheet,row,TypCol);
   PutStr_intidx("OpenTime",sheet,row,OpenTimeCol);
   PutStr_intidx("CloseTime",sheet,row,CloseTimeCol);
   PutStr_intidx("OpenPrice",sheet,row,OpenPriceCol);
   PutStr_intidx("ClosePrice",sheet,row,ClosePriceCol);
   PutStr_intidx("Lots",sheet,row,LotsCol);
   PutStr_intidx("Profit",sheet,row,ProfitCol);
   PutStr_intidx("Comment",sheet,row,CommentCol);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExportData(string sheet,int row, string state)
  {


   PutStr(Broker +" ",sheet,row,BrokerCol);
   PutStr(AccountNo+" ",sheet,row,AccountCol);
   PutStr(AccountTyp+ " ",sheet,row,AcTypeCol);

   PutStr(state,sheet,row,StateCol);
   PutInt(OrderTicket(),sheet,row,TicketCol);
   PutStr(OrderSymbol(),sheet,row,SymbolCol);
   PutStr(GetTypeString(OrderType()),sheet,row,TypCol);
   PutStr(TimeToStr(OrderOpenTime()),sheet,row,OpenTimeCol);
   datetime closetime = OrderCloseTime();
   string s = TimeToStr(closetime);
   if(closetime == 0)
      s = "";
   PutStr(s,sheet,row,CloseTimeCol);
   PutDouble(OrderOpenPrice(),sheet,row,OpenPriceCol);
   PutDouble(OrderClosePrice(),sheet,row,ClosePriceCol);
   PutDouble(OrderLots(),sheet,row,LotsCol);
   PutDouble(OrderProfit(),sheet,row,ProfitCol);
   PutStr(OrderComment(),sheet,row,CommentCol);
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
