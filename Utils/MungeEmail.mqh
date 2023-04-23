//+------------------------------------------------------------------+
//|                                                   mungeEmail.mqh |
//|                                                    Lawrence Reid |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Lawrence Reid"
#property link      "https://www.mql5.com"
#property strict

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
string mungeEmailAddress(const string s)
{
   int i = StringFind(s, "@");
   string newString="";


   if(i>=0)
      {
         int startIndex = int(i * .2) ;
         int endIndex   = int(i * .9) ;
         newString = (startIndex>0?StringSubstr(s, 0, startIndex):"");
         for(int j=startIndex; j<endIndex+1; j++)
            {
               newString+="*";
            }
         newString += StringSubstr(s, endIndex+1);
         return newString;
      }
   return s;
}