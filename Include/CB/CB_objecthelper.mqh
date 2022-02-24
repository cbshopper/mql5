//+------------------------------------------------------------------+
//|                                              CB_objecthelper.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


bool ObjectSetText(int WindowID,string name, string text, int font_size, string font_name=NULL, color text_color=CLR_NONE)
  {
   int tmpObjType=(int)ObjectGetInteger(WindowID,name,OBJPROP_TYPE);
   if(tmpObjType!=OBJ_LABEL && tmpObjType!=OBJ_TEXT)
   {
   //   return(false);
   }
   if(StringLen(text)>0 && font_size>0)
     {
      if(ObjectSetString(WindowID,name,OBJPROP_TEXT,text)==true
         && ObjectSetInteger(WindowID,name,OBJPROP_FONTSIZE,font_size)==true)
        {
         if((StringLen(font_name)>0)
            && ObjectSetString(WindowID,name,OBJPROP_FONT,font_name)==false)
            return(false);
         if(text_color!=CLR_NONE
            && ObjectSetInteger(WindowID,name,OBJPROP_COLOR,text_color)==false)
            return(false);
         return(true);
        }
      return(false);
     }
   return(false);
  }
