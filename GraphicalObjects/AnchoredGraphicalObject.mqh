//+------------------------------------------------------------------+
//| Module: GraphicalObjects/AnchoredGraphicalObject.mqh             |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2017 Li Ding <dingmaotu@126.com>                       |
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
#include "GraphicalObject.mqh"
//+------------------------------------------------------------------+
//| One anchor point for a anchored graphical object                 |
//+------------------------------------------------------------------+
struct AnchorPoint
  {
   datetime          time;
   double            price;
  };
//+------------------------------------------------------------------+
//| Base class for all anchored  graphical objects                   |
//| This class is abstract. You have to inherit this class to create |
//| a concrete graphical object.                                     |
//+------------------------------------------------------------------+
class AnchoredGraphicalObject: public GraphicalObject
  {
protected:
   bool              moveAnchor(int anchorIndex,datetime time,double price) {return ObjectMove(m_chartId,m_id,anchorIndex,time,price);}
   datetime          getTimeByPrice(double price,int lineId=0) const {return ObjectGetTimeByValue(m_chartId,m_id,price,lineId);}
   double            getPriceByTime(datetime time,int lineId=0) const {return ObjectGetValueByTime(m_chartId,m_id,time,lineId);}
public:
                     AnchoredGraphicalObject(ENUM_OBJECT type,string id,long chartId=0,int subwindow=0):GraphicalObject(type,id,chartId,subwindow) {}

   virtual bool      realize()=0;

   bool              setAnchorPoint(const int index,const AnchorPoint &ap)
     {
      ENUM_OBJECT_PROPERTY_INTEGER timeProp;
      ENUM_OBJECT_PROPERTY_DOUBLE priceProp;

      if(index==0)
        {timeProp=OBJPROP_TIME1;priceProp=OBJPROP_PRICE1;}
      else if(index==1)
        {timeProp=OBJPROP_TIME2;priceProp=OBJPROP_PRICE2;}
      else if(index==2)
        {timeProp=OBJPROP_TIME3;priceProp=OBJPROP_PRICE3;}
        else
      return false; 

      if(getInteger(timeProp)==0)
        {
         return setInteger(index, timeProp, ap.time )&& setDouble(index,priceProp,ap.price);
        }
      else
         return moveAnchor(index,ap.time,ap.price);
     }

   bool              getAnchorPoint(int index,AnchorPoint &ap) const
     {
      ENUM_OBJECT_PROPERTY_INTEGER timeProp;
      ENUM_OBJECT_PROPERTY_DOUBLE priceProp;
      if(index==0)
        {timeProp=OBJPROP_TIME1;priceProp=OBJPROP_PRICE1;}
      else if(index==1)
        {timeProp=OBJPROP_TIME2;priceProp=OBJPROP_PRICE2;}
      else if(index==2)
        {timeProp=OBJPROP_TIME3;priceProp=OBJPROP_PRICE3;}
      else return false;
      ap.time=(datetime)getInteger(timeProp);
      ap.price=getDouble(priceProp);
      return true;
     }
  };
//+------------------------------------------------------------------+
//| OBJ_RECTANGLE                                            |
//+------------------------------------------------------------------+
class Rectangle: public AnchoredGraphicalObject
  {
public:
//                     Rectangle(string id,long chartId=0,int subwindow=0):AnchoredGraphicalObject(OBJ_RECTANGLE,id,chartId,subwindow) {realize();}
                     Rectangle(string id,AnchorPoint &ap0,AnchorPoint &ap1,long chartId=0,int subwindow=0):AnchoredGraphicalObject(OBJ_RECTANGLE,id,chartId,subwindow) {create(ap0.time, ap0.price, ap1.time, ap1.price);}

   bool              setBackgroundColor(color value) {return setInteger(OBJPROP_BGCOLOR,value);}
   color             getBackgroundColor() const {return color(getInteger(OBJPROP_BGCOLOR));}

   bool              realize();

   bool              setBorderType(ENUM_BORDER_TYPE value) {return setInteger(OBJPROP_BORDER_TYPE,value);}
   ENUM_BORDER_TYPE  getBorderType() const {return(ENUM_BORDER_TYPE)getInteger(OBJPROP_BORDER_TYPE);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Rectangle::realize(void)
  {
   AnchorPoint ap0,ap1;
   if(getAnchorPoint(0,ap0) && getAnchorPoint(1,ap1))
     {
      return create(ap0.time, ap0.price, ap1.time, ap1.price);
     }
   else return false;
  }

//+------------------------------------------------------------------+
