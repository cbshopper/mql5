//+------------------------------------------------------------------+
//|                                                   CB_MaUtils.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAOnArray(double &array[], int total, int period, int ma_shift, int ma_method, int shift)
  {
   double buf[],arr[];
   if(total==0)
      total=ArraySize(array);
   if(total>0 && total<=period)
      return(0);
   if(shift>total-period-ma_shift)
      return(0);
   switch(ma_method)
     {
      case MODE_SMA :
        {
         total=ArrayCopy(arr,array,0,shift+ma_shift,period);
         if(ArrayResize(buf,total)<0)
            return(0);
         double sum=0;
         int    i,pos=total-1;
         for(i=1; i<period; i++,pos--)
            sum+=arr[pos];
         while(pos>=0)
           {
            sum+=arr[pos];
            buf[pos]=sum/period;
            sum-=arr[pos+period-1];
            pos--;
           }
         return(buf[0]);
        }
      case MODE_EMA :
        {
         if(ArrayResize(buf,total)<0)
            return(0);
         double pr=2.0/(period+1);
         int    pos=total-2;
         while(pos>=0)
           {
            if(pos==total-2)
               buf[pos+1]=array[pos+1];
            buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_SMMA :
        {
         if(ArrayResize(buf,total)<0)
            return(0);
         double sum=0;
         int    i,k,pos;
         pos=total-period;
         while(pos>=0)
           {
            if(pos==total-period)
              {
               for(i=0,k=pos; i<period; i++,k++)
                 {
                  sum+=array[k];
                  buf[k]=0;
                 }
              }
            else
               sum=buf[pos+1]*(period-1)+array[pos];
            buf[pos]=sum/period;
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_LWMA :
        {
         if(ArrayResize(buf,total)<0)
            return(0);
         double sum=0.0,lsum=0.0;
         double price;
         int    i,weight=0,pos=total-1;
         for(i=1; i<=period; i++,pos--)
           {
            price=array[pos];
            sum+=price*i;
            lsum+=price;
            weight+=i;
           }
         pos++;
         i=pos+period;
         while(pos>=0)
           {
            buf[pos]=sum/weight;
            if(pos==0)
               break;
            pos--;
            i--;
            price=array[pos];
            sum=sum-lsum+price*period;
            lsum-=array[i];
            lsum+=price;
           }
         return(buf[shift+ma_shift]);
        }
      default:
         return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
double _getPrice(int priceType, MqlRates& data)
  {
   double price = 0.0;
   switch(priceType)
     {
      case PRICE_OPEN    :
         price = data.open;
         break;

      case PRICE_HIGH    :
         price = data.high;
         break;

      case PRICE_LOW     :
         price = data.low;
         break;

      case PRICE_MEDIAN  :
         price = (data.high + data.low) / 2.0;
         break;

      case PRICE_TYPICAL :
         price = (data.high + data.low +data.close) / 3.0;
         break;


      case PRICE_WEIGHTED:
         price = (data.high + data.low + 2 *data.close) / 4.0;
         break;



      case PRICE_CLOSE   :
      default            :
         price =data.close;
         break;


     }



   return(price);
  }
