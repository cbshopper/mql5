//+------------------------------------------------------------------+
//|                                                     test dll.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022 Christof Blank."
#property link      "https://????????"
#property version   "1.00"
#property strict
#property script_show_inputs

#include <CB\\MetatraderToExcel.mqh>
input string path = "D:\\1Pdat\\06 Finanzen\\Boerse\\Trading\\Logs";
input string file = "AllAccounts5"; //Filename without extension
extern string logfile = "Log5.txt";  //Log file
input bool showExcel = true;
input bool closeExcel = false;
//input int HistoryDays=100;
input int FirstRow = 2;

int BrokerCol = 1;
int AccountCol = 2;
int AcTypeCol = 3;
int StateCol = 4;
int TicketCol = 5;
int SymbolCol = 6;
int TypCol = 7;
int OpenTimeCol = 8;
int CloseTimeCol = 9;
int OpenPriceCol = 10;
int ClosePriceCol = 11;
int LotsCol = 12;
int ProfitCol = 13;
int CommentCol = 14;






input int TicketMaxSearchCount = 999999;
input string sheet = "Tabelle1";
bool isnew = false;
string AccountNo = "";
string Broker = "";
string AccountTyp = "";
string xlsfile = "";
int last_row = FirstRow + 2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
 {
//---
  AccountNo = (string)AccountInfoInteger(ACCOUNT_LOGIN);
  Broker = AccountInfoString(ACCOUNT_COMPANY);
  ENUM_ACCOUNT_TRADE_MODE tradeMode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
  switch(tradeMode)
   {
    case(ACCOUNT_TRADE_MODE_DEMO):
      Print("This is a demo account");
      AccountTyp = "DEMO";
      break;
    case(ACCOUNT_TRADE_MODE_CONTEST):
      Print("This is a competition account");
      AccountTyp = "COMPETITION";
      break;
    default:
      Print("This is a real account!");
      AccountTyp = "REAL";
      break;
   }
  string f = file;
  if(MQLInfoInteger(MQL_DEBUG))
    f = "testing";
  xlsfile = path + "\\" + "" + file + ".xlsx";
  logfile = path + "\\" + logfile;
  int ret = Start(xlsfile, logfile, showExcel);
  if(ret == 1)
    isnew = true;
//---
  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
//---
  if(closeExcel || showExcel == false)
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
  int start = StringGetCharacter("A", 0);
  string ret = " ";
  StringSetCharacter(ret, 0, start + col);
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
  part1 = "";
  part2 = "";
  for(int i = 0; i < StringLen(range); i++)
   {
    ushort A = StringGetCharacter("A", 0);
    ushort zero = StringGetCharacter("0", 0);
    ushort c = StringGetCharacter(range, i);
    if(c >= 'A' && c <= 'Z')
      part1 = part1 + (string)(c - A + 1);
    else
     {
      string add = "";
      StringSetCharacter(add, 0, c);
      part2 = part2 + add;
     }
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetRow(string range)
 {
  string p1, p2;
  Part(range, p1, p2);
  return StringToInteger(p2);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCol(string range)  //A-Z only!
 {
  string p1, p2;
  Part(range, p1, p2);
  int ret = StringToInteger(p1) - StringGetCharacter("A", 0);
  return ret;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Main()
 {
  int col = 0;
  int row = 0;
  string curTime = TimeToString(TimeLocal());
//PutStr(StringFormat("Last Update Date: %s", curTime), sheet, FirstRow, 1);
  row = FirstRow + 1;
  col = 1;
  ExportHeader(sheet, row);
// retrieving info from trade history
  bool dataok = HistorySelect(0, TimeCurrent());
  if(dataok)
   {
    int i, hstTotal = HistoryOrdersTotal(); //   OrdersHistoryTotal();
    for(i = 0; i < hstTotal; i++)
     {
      int ticket = PositionGetTicket(i);
      //---- check selection result
      //if(PositionGetTicket(i,SELECT_BY_POS,MODE_HISTORY)==false)
      if(ticket < 0)
       {
        MessageBox("Access to history failed with error (", GetLastError(), ")");
        break;
       }
      col = 1;
      Print(ticket);
      if(ticket == 86275440)
       {
        int debug1 = 1;
       }
      row = FindTicket(ticket);
      last_row = row;
      ExportData(sheet, row, "closed", ticket);
     }
    /*
    int cnt = PositionsTotal();
    for(i = 0; i < cnt; i++)
    {
     int ticket = PositionGetTicket(i);
     //---- check selection result
     // if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
     if(ticket < 0)
      {
       MessageBox("Access to tades failed with error (", GetLastError(), ")");
       break;
      }
     col = 1;
     // row++;
     if(ticket == 8583538)
      {
       int debug2 = 1;
      }
     row = FindTicket(ticket);

     ExportData(sheet, row, "open", ticket);
    }
    */
    MessageBox("Finished!");
   }
  else
   {
    MessageBox("No data!");
   }
 }
//+------------------------------------------------------------------+
int FindTicket(string ticket)
 {
  bool done = false;
  int row = 0;
  while(!done)
   {
    string fstr = FindInCols(sheet, TicketCol, FirstRow + 2, TicketMaxSearchCount, ticket);
    if(fstr != "")
     {
      row = GetRow(fstr);
      int  s = GetStr_intidx(sheet, row, AccountCol);
      if(s == AccountNo)
       {
        done = true;
       }
      else
       {
        row = 0;
       }
     }
    else
     {
      done = true;
      row = 0;
     }
   }
  if(row == 0)
   {
    row = last_row;
    int  s = GetStr_intidx(sheet, row, TicketCol);
    while(s != "" && s != NULL)
     {
      row++;
      s = GetStr_intidx(sheet, row, TicketCol);
     }
   }
  return row;
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExportHeader(string sheet, int row)
 {
  PutStr("Broker", sheet, row, BrokerCol); //1
  PutStr("Account#", sheet, row, AccountCol); //2
  PutStr("Type", sheet, row, AcTypeCol); // 3
  PutStr("State", sheet, row, StateCol); //4
  PutStr("Ticket", sheet, row, TicketCol); //5  => TicketCol
  PutStr("Symbol", sheet, row, SymbolCol);
  PutStr("Typ", sheet, row, TypCol);
  PutStr("OpenTime", sheet, row, OpenTimeCol);
  PutStr("CloseTime", sheet, row, CloseTimeCol);
  PutStr("OpenPrice", sheet, row, OpenPriceCol);
  PutStr("ClosePrice", sheet, row, ClosePriceCol);
  PutStr("Lots", sheet, row, LotsCol);
  PutStr("Profit", sheet, row, ProfitCol);
  PutStr("Comment", sheet, row, CommentCol);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExportData(string sheet, int row, string state, int ticket)
 {
  PutStr(Broker + " ", sheet, row, BrokerCol);
  PutStr(AccountNo + " ", sheet, row, AccountCol);
  PutStr(AccountTyp + " ", sheet, row, AcTypeCol);
  PutStr(state, sheet, row, StateCol);
  PutInt(ticket, sheet, row, TicketCol);
  PutStr(HistoryOrderGetString(ticket, ORDER_SYMBOL), sheet, row, SymbolCol);
  PutStr(GetTypeString(HistoryOrderGetInteger(ticket, ORDER_TYPE)), sheet, row, TypCol);
  PutStr(TimeToString(HistoryOrderGetInteger(ticket, ORDER_TIME_SETUP)), sheet, row, OpenTimeCol);
  datetime closetime = HistoryOrderGetInteger(ticket, ORDER_TIME_DONE);
  string s = TimeToString(closetime);
  if(closetime == 0)
    s = "";
  PutStr(s, sheet, row, CloseTimeCol);
  PutDouble(HistoryOrderGetDouble(ticket, ORDER_PRICE_OPEN), sheet, row, OpenPriceCol);
  PutDouble(HistoryOrderGetDouble(ticket, ORDER_PRICE_CURRENT), sheet, row, ClosePriceCol);
  PutDouble(HistoryOrderGetDouble(ticket, ORDER_VOLUME_CURRENT), sheet, row, LotsCol);
  PutDouble(HistoryDealGetDouble(ticket, DEAL_PROFIT), sheet, row, ProfitCol);
  PutStr(HistoryOrderGetString(ticket, ORDER_COMMENT), sheet, row, CommentCol);
  Sleep(100);
 }
//+------------------------------------------------------------------+
string GetTypeString(int ordertype)
 {
  switch(ordertype)
   {
    case POSITION_TYPE_BUY:
      return "BUY";
    case POSITION_TYPE_SELL:
      return "SELL";
   }
  return "?";
 }

//+------------------------------------------------------------------+
