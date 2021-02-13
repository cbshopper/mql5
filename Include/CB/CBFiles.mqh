//+------------------------------------------------------------------+
//|                                                      CBFiles.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
string FileExtension(string fn)
  {
   string ret = "";
   int dotpos = 0;
   string parts[];
   int dotcnt= StringSplit(fn,'.',parts);
   if(dotcnt > 0)
     {
      ret = parts[dotcnt-1];
     }

   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BaseFileName(string fn)
  {
   string ret = fn;
   string ext = FileExtension(fn);
   StringReplace(ret,"."+ext,"");

   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenFile(string fn,int mode)
  {
   int handle=INVALID_HANDLE;
   if(fn!="")
     {
      ResetLastError();
      handle=FileOpen(fn,mode,0);
      if(handle==INVALID_HANDLE)
        {
         int errno=GetLastError();
         PrintFormat("Failed to open %s file, Error code = %d",fn,errno);
        }
     }
   return handle;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseFile(int &handle)
  {

   FileClose(handle);
   handle=0;
   return true;
  }
//+------------------------------------------------------------------+
int OpenFileTxt2W(string fn)
  {
   int ret=0;
   ret=OpenFile(fn,FILE_WRITE|FILE_TXT);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenFileTxt2R(string fn)
  {
   int ret=0;
   ret=OpenFile(fn,FILE_READ|FILE_TXT);
   return ret;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetValueStr(int f_handle,string keyword, string &ret)
  {
   int str_size=0;
   ret="";
   string str="";
   string substr[];
   FileSeek(f_handle,0,SEEK_SET);
   while(!FileIsEnding(f_handle))
     {
      //--- read the string
      str=FileReadString(f_handle,str_size);
      int cnt=StringSplit(str,'=',substr);
      if(cnt==2)
        {
         if(StringCompare(substr[0],keyword,false)==0)
           {
            ret=substr[1];
            break;
           }
        }
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetValueInt(int f_handle,string keyword, int &ret)
  {
   string s;
   ret=(int)StringToInteger(GetValueStr(f_handle,keyword,s));
   return ret;

   return ret;
  }
//+------------------------------------------------------------------+
double GetValueDouble(int f_handle,string keyword,double &ret)
  {
   string s;
   ret=StringToDouble(GetValueStr(f_handle,keyword,s));
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetValueBool(int f_handle,string keyword,bool &ret)
  {
   string s;
   ret=false;
   int i=(int)StringToInteger(GetValueStr(f_handle,keyword,s));
   if(i !=0)
      ret= true;
   return ret;
  }


