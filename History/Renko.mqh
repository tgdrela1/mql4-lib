//+------------------------------------------------------------------+
//| Module: History/Renko.mqh                                        |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2015-2017 Li Ding <dingmaotu@126.com>                  |
//|                                                                  |
//| Licensed under the Apache License, Version 2.0 (the "License");  |
//| you may not use this file except in compliance with the License. |
//| You may obtain a copy of the License at                          |
//|                                                                  |
//|     http://www.apache.org/licenses/LICENSE-2.0                   |
//|                                                                  |
//| Unless required by applicable law or agreed to in writing,       |
//| software distributed under the License is distributed on an      |
//| "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,     |
//| either express or implied.                                       |
//| See the License for the specific language governing permissions  |
//| and limitations under the License.                               |
//+------------------------------------------------------------------+
#property strict

#include "HistoryData.mqh"
#include "../Trade/FxSymbol.mqh"

#define RENKO_DEFAULT_BUFFER_SIZE 1000
//+------------------------------------------------------------------+
//| Base class used to generate renko charts                         |
//+------------------------------------------------------------------+
class Renko: public HistoryData
  {
   enum BAR_TYPE     {RANGE_BAR, RENKO_CONTINUOUS, RENKO_NORMAL};
   enum BAR_DIRECTION {UP,DOWN};
private:
   const string      m_symbol;
   const int         m_digits;
   int               m_bars;
   int               m_newBars;
   BAR_TYPE          m_bar_type;
   BAR_DIRECTION     m_bar_direction;

   ObjectAttr(bool,rounding,Rounding);
   


   double            m_open[];
   double            m_high[];
   double            m_low[];
   double            m_close[];
   long              m_volume[];

   //--- dummy arrays for OnUpdate event
   datetime          m_time[];
   long              m_realVolume[];
   int               m_spread[];

   void              resize(const int size);

   void              makeNewBars(double p,const datetime t,double &base[],double &target[],double step,int newBars,long vol);
   int               newBar(double p,const datetime t,long vol);
protected:
   int               move(const double p, const datetime t, const long vol);
   int               moveByRate(MqlRates &r);
public:
   double const      BAR_SIZE;
                     Renko(const string symbol, const int barSize, const BAR_TYPE bar_type, const bool rounding);

   string            getSymbol() const {return m_symbol;}

   int               getBars() const {return m_bars;}
   bool              isNewBar() const {return m_newBars>0;}
   int               getNewBars() const {return m_newBars;}

   double            getHigh(int shift) const {return m_high[m_bars-1-shift];}
   double            getLow(int shift) const {return m_low[m_bars-1-shift];}
   double            getOpen(int shift) const {return m_open[m_bars-1-shift];}
   double            getClose(int shift) const {return m_close[m_bars-1-shift];}
   long              getVolume(int shift) const {return m_volume[m_bars-1-shift];}
   datetime          getTime(int shift) const {return m_time[m_bars-1-shift];}

   virtual void      onNewBar(int total,int bars,datetime const &time[],double const &open[],double const &high[],
                              double const &low[],double const &close[],long const &volume[]);

   //--- Feed data by normal candle bars
   void              updateByRates(MqlRates &r[],int shift,int size);

   //--- update with latest price and vol
   void              update(double price,const datetime time,long vol);
  };
//+------------------------------------------------------------------+
//| Initialize Renko                                                 |
//| Renko Bar size is given in number of ticks (points)              |
//+------------------------------------------------------------------+
Renko::Renko(string symbol,int barSize,BAR_TYPE bar_type, const bool rounding)
   :m_symbol(symbol==""?_Symbol:symbol),
    m_digits(FxSymbol::getDigits(m_symbol)),
    BAR_SIZE(FxSymbol::getPoint(m_symbol)*barSize),
    m_bars(0),
    m_bar_type(bar_type),
    m_bar_direction(UP),
    m_rounding(rounding)
  {
  }
//+------------------------------------------------------------------+
//| Resize all buffers                                               |
//+------------------------------------------------------------------+
void Renko::resize(const int size)
  {
   ArrayResize(m_open,size,RENKO_DEFAULT_BUFFER_SIZE);
   ArrayResize(m_high,size,RENKO_DEFAULT_BUFFER_SIZE);
   ArrayResize(m_low,size,RENKO_DEFAULT_BUFFER_SIZE);
   ArrayResize(m_close,size,RENKO_DEFAULT_BUFFER_SIZE);
   ArrayResize(m_volume,size,RENKO_DEFAULT_BUFFER_SIZE);
   ArrayResize(m_time,size,RENKO_DEFAULT_BUFFER_SIZE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Renko::moveByRate(MqlRates &r)
  {
   int newBars=0;
   long v=r.tick_volume/3;
   newBars+=move(r.open,r.time,0);
   if(r.open>r.close)
     {
      newBars += move(r.high,r.time,v);
      newBars += move(r.low,r.time,v);
     }
   else
     {
      newBars += move(r.low,r.time,v);
      newBars += move(r.high,r.time,v);
     }
   newBars+=move(r.close,r.time,v);
   return newBars;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Renko::move(const double p, const datetime t, long vol)
  {
   if(m_bars==0)
     {
     
      m_bars=1;
      resize(m_bars);
      if(m_rounding){
         m_open[0]=m_high[0]=m_low[0]=m_close[0]=NormalizeDouble(MathFloor(p/BAR_SIZE)*BAR_SIZE,m_digits);
      }
      else
         m_open[0]=m_high[0]=m_low[0]=m_close[0]=p;
      m_bar_direction=DOWN;
      m_volume[0]=vol;
      m_time[0]=t;
      return 0;
     }

   switch(m_bar_type)
     {
      case RENKO_CONTINUOUS:
         if(p>m_open[m_bars-1])
           {
            m_high[m_bars-1]= p;
            m_low[m_bars-1] = m_open[m_bars-1];
           }

         if(p<m_open[m_bars-1])
           {
            m_low[m_bars-1]=p;
            m_high[m_bars-1]=m_open[m_bars-1];
           }

         break;
      case RANGE_BAR:
         if(p>m_high[m_bars-1])
            m_high[m_bars-1]=p;
         if(p<m_low[m_bars-1])
            m_low[m_bars-1]=p;

         break;
      case RENKO_NORMAL:
         if(p>m_high[m_bars-1])
            m_high[m_bars-1]=NormalizeDouble(p, m_digits);
         if(p<m_low[m_bars-1])
            m_low[m_bars-1]=NormalizeDouble(p, m_digits);
         break;
      default:
         DebugBreak();
         Alert("Massive Error in "+IntegerToString(__LINE__));

     }
// New bar check
   switch(m_bar_type)
     {
      case RENKO_CONTINUOUS:
      case RANGE_BAR:
         if(m_high[m_bars-1]-m_low[m_bars-1]>BAR_SIZE)
           {
            return newBar(p,t, vol);
           }

         break;
      case RENKO_NORMAL:
         // Up trend continuation
         if(m_bar_direction==UP && m_high[m_bars-1]-m_open[m_bars-1]>BAR_SIZE)
           {
            return newBar(p,t, vol);
           }
         // Up trend and now a reversal candle
         if(m_bar_direction==UP && m_open[m_bars-1]-m_low[m_bars-1]>2.0*BAR_SIZE)
           {
            return newBar(p,t, vol);
           }
         // Down trend continuation
         if(m_bar_direction==DOWN && m_open[m_bars-1]-m_low[m_bars-1]>BAR_SIZE)
           {
            return newBar(p,t, vol);
           }
         // Down trend and now a reversal candle
         if(m_bar_direction==DOWN && m_high[m_bars-1]-m_open[m_bars-1]>2.0*BAR_SIZE)
           {
            return newBar(p,t, vol);
           }
         break;
      default:
         DebugBreak();
         Alert("Massive Error in "+IntegerToString(__LINE__));
     }

   m_close[m_bars-1]=p;
   m_volume[m_bars-1]+=vol;
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Renko::newBar(double p, const datetime t, long vol)
  {

   switch(m_bar_type)
     {
      case RENKO_CONTINUOUS:
      case RANGE_BAR:
        {
         int newBars=(int)((m_high[m_bars-1]-m_low[m_bars-1])/BAR_SIZE);
         resize(m_bars+newBars);

         if(p-m_low[m_bars-1]>BAR_SIZE)
           {
            makeNewBars(p,t,m_low,m_high,BAR_SIZE,newBars,vol);
           }
         else
            if(m_high[m_bars-1]-p>BAR_SIZE)
              {
               makeNewBars(p,t,m_high,m_low,-BAR_SIZE,newBars,vol);
              }
         return newBars;
        }
      break;
      case RENKO_NORMAL:
        {
         int newUpBars=0, newDnBars=0;

         // Up trend continuation
         if(m_bar_direction==UP && m_high[m_bars-1]-m_open[m_bars-1]>BAR_SIZE)
           {
            newUpBars=(int)((m_high[m_bars-1]-m_open[m_bars-1])/BAR_SIZE);
           }
         // Up trend and now a reversal candle
         if(m_bar_direction==UP && m_open[m_bars-1]-m_low[m_bars-1]>2.0*BAR_SIZE)
           {
            newDnBars=(int)((m_open[m_bars-1]-m_low[m_bars-1])/BAR_SIZE);
            newDnBars--; // Assert newBars>=2
            DebugBreak();
           }
         // Down trend continuation
         if(m_bar_direction==DOWN && m_open[m_bars-1]-m_low[m_bars-1]>BAR_SIZE)
           {
            newDnBars=(int)((m_open[m_bars-1]-m_low[m_bars-1])/BAR_SIZE);
           }
         // Down trend and now a reversal candle
         if(m_bar_direction==DOWN && m_high[m_bars-1]-m_open[m_bars-1]>2.0*BAR_SIZE)
           {
            newUpBars=(int)((m_high[m_bars-1]-m_open[m_bars-1])/BAR_SIZE);
            newUpBars--; // Assert newBars>=2
            DebugBreak();
           }
         resize(m_bars+newUpBars+newDnBars);

         // Up trend continuation
         if(m_bar_direction==UP && m_high[m_bars-1]-m_open[m_bars-1]>BAR_SIZE)
           {
            makeNewBars(p,t,m_open,m_high,BAR_SIZE,newUpBars,vol);
           }
         // Up trend and now a reversal candle
         if(m_bar_direction==UP && m_open[m_bars-1]-m_low[m_bars-1]>2.0*BAR_SIZE)
           {
            makeNewBars(p,t,m_high,m_low,-BAR_SIZE,newDnBars,vol);
           }
         // Down trend continuation
         if(m_bar_direction==DOWN && m_open[m_bars-1]-m_low[m_bars-1]>BAR_SIZE)
           {
            makeNewBars(p,t,m_open,m_low,-BAR_SIZE,newDnBars,vol);
           }
         // Down trend and now a reversal candle
         if(m_bar_direction==DOWN && m_high[m_bars-1]-m_open[m_bars-1]>2.0*BAR_SIZE)
           {
            makeNewBars(p,t,m_open,m_high,BAR_SIZE,newUpBars,vol);
           }
         return (newUpBars+newDnBars);
        }
      break;
      default:
         DebugBreak();
         Alert("Massive Error in "+IntegerToString(__LINE__));
     }

   return 0;

   /*
      // type of bar check
      switch(m_bar_type)
        {
         case RENKO_CONTINUOUS:
         case RANGE_BAR:

            break;
         case RENKO_NORMAL:
            break;
         default:
            DebugBreak();
            Alert("Massive Error in "+IntegerToString(__LINE__));
        }
   */


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::makeNewBars(const double p, const datetime t, double &base[],double &target[],double step,int newBars,long vol)
  {

   switch(m_bar_type)
     {
      case RENKO_CONTINUOUS:
      case RANGE_BAR:
        {
         long v=vol;
         long volPerBar=vol/newBars;
         m_close[m_bars-1]=target[m_bars-1]=base[m_bars-1]+step;
         for(int i=m_bars; i<m_bars+newBars; i++)
           {
            m_time[i]=t;
            m_open[i]=base[i]=m_close[i-1];
            m_close[i]=target[i]=base[i]+step;
            m_volume[i]=volPerBar;
            v-=volPerBar;
           }
         m_volume[m_bars-1]+=v;
         m_bars+=newBars;
         m_close[m_bars-1]=target[m_bars-1]=p;
        }
      break;
      case RENKO_NORMAL:
         // Up trend continuation
         if(m_bar_direction==UP && m_high[m_bars-1]-m_open[m_bars-1]>BAR_SIZE)
           {
            long v=vol;
            long volPerBar=vol/newBars;
            m_close[m_bars-1]=target[m_bars-1]=base[m_bars-1]+step;
            for(int i=m_bars; i<m_bars+newBars; i++)
              {
               m_time[i]=t;
               m_open[i]=base[i]=m_close[i-1];
               m_close[i]=target[i]=base[i]+step;
               m_high[i]=m_close[i]; // Renko Normal
               m_volume[i]=volPerBar;
               v-=volPerBar;
              }
            m_volume[m_bars-1]+=v;
            m_bars+=newBars;
            m_close[m_bars-1]=target[m_bars-1]=p;
           }
         // Up trend and now a reversal candle
         if(m_bar_direction==UP && m_open[m_bars-1]-m_low[m_bars-1]>2.0*BAR_SIZE)
           {
            long v=vol;
            long volPerBar=vol/newBars;
            m_close[m_bars-1]=base[m_bars-1]-step;
            m_open[m_bars]=m_close[m_bars-1]+2.0*step;
            for(int i=m_bars; i<m_bars+newBars; i++)
              {
               m_time[i]=t;
               m_close[i]=target[i]=base[i]+step;
               m_open[i]=m_close[i]-step;
               m_high[i]=m_close[i]; // Renko Normal
               m_volume[i]=volPerBar;
               v-=volPerBar;
              }
            m_volume[m_bars-1]+=v;
            m_bars+=newBars;
            m_close[m_bars-1]=target[m_bars-1]=p;
           }
         // Down trend continuation
         if(m_bar_direction==DOWN && m_open[m_bars-1]-m_low[m_bars-1]>BAR_SIZE)
           {
            long v=vol;
            long volPerBar=vol/newBars;
            m_close[m_bars-1]=target[m_bars-1]=base[m_bars-1]+step;
            for(int i=m_bars; i<m_bars+newBars; i++)
              {
               m_time[i]=t;
               m_open[i]=base[i]=m_close[i-1];
               m_close[i]=target[i]=base[i]+step;
               m_low[i]=m_close[i]; // Renko Normal
               m_volume[i]=volPerBar;
               v-=volPerBar;
              }
            m_volume[m_bars-1]+=v;
            m_bars+=newBars;
            m_close[m_bars-1]=target[m_bars-1]=p;
           }
         // Down trend and now a reversal candle
         if(m_bar_direction==DOWN && m_high[m_bars-1]-m_open[m_bars-1]>2.0*BAR_SIZE)
           {
            // base is open, tarhet is high
            long v=vol;
            long volPerBar=vol/newBars;
            m_close[m_bars-1]=base[m_bars-1]-step;
            m_open[m_bars]=base[m_bars-1];
            for(int i=m_bars; i<m_bars+newBars; i++)
              {
               m_time[i]=t;
               m_close[i]=target[i]=base[i]+step;
               m_open[i]=m_close[i]-step;
               m_high[i]=m_close[i]; // Renko Normal
               m_volume[i]=volPerBar;
               v-=volPerBar;
              }
            m_volume[m_bars-1]+=v;
            m_bars+=newBars;
            m_close[m_bars-1]=target[m_bars-1]=p;
           }
         break;
      default:
         DebugBreak();
         Alert("Massive Error in "+IntegerToString(__LINE__));
     }


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::updateByRates(MqlRates &rs[],int shift,int size)
  {
   m_newBars=0;
   if(ArraySize(rs)>=size && size>0)
     {
      for(int i=shift; i<shift+size; i++)
        {
         m_newBars+=moveByRate(rs[i]);
        }
      OnUpdate.calculate(m_bars,m_time,m_open,m_high,m_low,m_close,m_volume,m_realVolume,m_spread);
      onNewBar(m_bars,m_newBars,m_time, m_open,m_high,m_low,m_close,m_volume);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::update(double price,const datetime time, long vol=0)
  {
   m_newBars=move(price,time,vol);
   OnUpdate.calculate(m_bars,m_time,m_open,m_high,m_low,m_close,m_volume,m_realVolume,m_spread);
   onNewBar(m_bars,m_newBars,m_time, m_open,m_high,m_low,m_close,m_volume);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Renko::onNewBar(int total,int bars,datetime const &time[],double const &open[],double const &high[],
                     double const &low[],double const &close[],long const &volume[])
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
