//+------------------------------------------------------------------+
//| Module: GraphicalObjects/GraphicalObject.mqh                     |
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
#include <Mql/Lang/Mql.mqh>

//+------------------------------------------------------------------+
//| Base class for all graphical objects                             |
//| This class is abstract. You have to inherit this class to create |
//| a concrete graphical object.                                     |
//+------------------------------------------------------------------+
class GraphicalObject
  {
private:

  
protected:

   const string      m_id;
   const ENUM_OBJECT m_type;
   const long        m_chartId;
   const int         m_subwindow;
   


   long              getInteger(int propId,int propModifier=0) const
     {
      return ObjectGetInteger(m_chartId,m_id,propId,propModifier);
     }
   bool              setInteger(int propId,long value)
     {
      return ObjectSetInteger(m_chartId,m_id,propId,value);
     }
   bool              setInteger(int propId,int propModifier,long value)
     {
      return ObjectSetInteger(m_chartId,m_id,propId,propModifier,value);
     }
   double            getDouble(int propId,int propModifier=0) const
     {
      return ObjectGetDouble(m_chartId,m_id,propId,propModifier);
     }
   bool              setDouble(int propId,double value)
     {
      return ObjectSetDouble(m_chartId,m_id,propId,value);
     }
   bool              setDouble(int propId,int propModifier,double value)
     {
      return ObjectSetDouble(m_chartId,m_id,propId,propModifier,value);
     }
   string            getString(int propId,int propModifier=0) const
     {
      return ObjectGetString(m_chartId,m_id,propId,propModifier);
     }
   bool              setString(int propId,string value)
     {
      return ObjectSetString(m_chartId,m_id,propId,value);
     }
   bool              setString(int propId,int propModifier,string value)
     {
      return ObjectSetString(m_chartId,m_id,propId,propModifier,value);
     }
   bool              create(datetime time=0,double price=0)
     {
      return ObjectCreate(m_chartId,m_id,m_type,m_subwindow,time,price);
     }
   bool              create(datetime time1,double price1,datetime time2,double price2)
     {
      return ObjectCreate(m_chartId,m_id,m_type,m_subwindow,time1,price1,time2,price2);
     }
   bool              create(datetime time1,double price1,datetime time2,double price2,datetime time3,double price3)
     {
      return ObjectCreate(m_chartId,m_id,m_type,m_subwindow,time1,price1,time2,price2,time3, price3);
     }

                     GraphicalObject(ENUM_OBJECT type,string id,long chartId=0,int subwindow=0):m_type(type),m_id(id),m_chartId(chartId==0?ChartID():chartId),m_subwindow(subwindow) {}
public:
                    ~GraphicalObject() {ObjectDelete(m_chartId,m_id);}
                    
   string            getId() const {return m_id;};
   int               getSubwindow() const {return m_subwindow;};
                  

   ENUM_OBJECT       getUnderlyingObjectType() const {return(ENUM_OBJECT)getInteger(OBJPROP_TYPE);}
   datetime          getCreateTime() const {return(datetime)getInteger(OBJPROP_CREATETIME);}

   string            getText() const {return getString(OBJPROP_TEXT);}
   bool              setText(string value) {return setString(OBJPROP_TEXT,value);}

   string            getTooltip() const {return getString(OBJPROP_TOOLTIP);}
   bool              setTooltip(string value) {return setString(OBJPROP_TOOLTIP,value);}

   long              getSelected() const {return getInteger(OBJPROP_SELECTED);}
   bool              setSelected(long value) {return setInteger(OBJPROP_SELECTED,value);}

   bool              isSelectable() const {return (getInteger(OBJPROP_SELECTABLE)==true);}
   bool              setSelectable(const bool value) {return setInteger(OBJPROP_SELECTABLE,value);}


   //--- visibility
   long              getVisibility() const {return getInteger(OBJPROP_TIMEFRAMES);}
   bool              setVisibility(long value) {return setInteger(OBJPROP_TIMEFRAMES,value);}

   bool              isVisible() const {return getVisibility()>OBJ_NO_PERIODS;}
   bool              setVisible(bool value) {return setVisibility(value?OBJ_ALL_PERIODS:OBJ_NO_PERIODS);}

   bool              isVisibleOn(long flag) const {return(getVisibility()&flag)==flag;}
   bool              setVisibleOn(long flag) {return setVisibility(getVisibility()|flag);}
   bool              setInvisibleOn(long flag) {return setVisibility(getVisibility()&(~flag));}

   //--- color
   bool              setColor(int value) {return setInteger(OBJPROP_COLOR,value);}
   color             getColor() const {return color(getInteger(OBJPROP_COLOR));}

   //--- style
   bool              setStyle(int value) {return setInteger(OBJPROP_STYLE,value);}
   ENUM_LINE_STYLE   getStyle() const {return ENUM_LINE_STYLE(getInteger(OBJPROP_STYLE));}

   //--- width
   bool              setWidth(const int value) {return bool (setInteger(OBJPROP_WIDTH,value));}
   int               getWidth() const {return int(getInteger(OBJPROP_WIDTH));}

   datetime          getTime1() const {return datetime(getInteger(OBJPROP_TIME1));}
   double            getPrice1() const {return double(getDouble(OBJPROP_PRICE1));}
   datetime          getTime2() const {return datetime(getInteger(OBJPROP_TIME2));}
   double            getPrice2() const {return double(getDouble(OBJPROP_PRICE2));}
   int               getXdistance() const {return int(getInteger(OBJPROP_XDISTANCE));}
   int               getYdistance() const {return int(getInteger(OBJPROP_YDISTANCE));}
   string            getFont() const {return getString(OBJPROP_FONT);}
   int               getFontsize() const {return int(getInteger(OBJPROP_FONTSIZE));}
   double            getAngle() const {return int(getDouble(OBJPROP_ANGLE));}
   ENUM_ANCHOR_POINT               getAnchor() const {return ENUM_ANCHOR_POINT(getInteger(OBJPROP_ANCHOR));}
   int               getBack() const {return int(getInteger(OBJPROP_BACK));}

   //--- static

   //--- style
   static bool          setStyle(const long chartId, const string id, int value) {return ObjectSetInteger(chartId, id, OBJPROP_STYLE,value);}
   static ENUM_LINE_STYLE getStyle(const long chartId, const string id) {return ENUM_LINE_STYLE(ObjectGetInteger(chartId,id,OBJPROP_STYLE));}

   //--- width
   static bool       setWidth(const long chartId, const string id, int value) {return bool (ObjectSetInteger(chartId, id, OBJPROP_WIDTH,value));}
   static int        getWidth(const long chartId, const string id) {return int(ObjectGetInteger(chartId,id,OBJPROP_WIDTH));}


   static string     getText(const long chartId, const string id) {return ObjectGetString(chartId,id,OBJPROP_TEXT);}
   static datetime   getTime1(const long chartId, const string id) {return datetime(ObjectGetInteger(chartId,id,OBJPROP_TIME1));}
   static double     getPrice1(const long chartId, const string id) {return double(ObjectGetDouble(chartId,id,OBJPROP_PRICE1));}
   static datetime   getTime2(const long chartId, const string id) {return datetime(ObjectGetInteger(chartId,id,OBJPROP_TIME2));}
   static double     getPrice2(const long chartId, const string id) {return double(ObjectGetDouble(chartId,id,OBJPROP_PRICE2));}
   static string     getFont(const long chartId, const string id) {return ObjectGetString(chartId,id,OBJPROP_FONT);}
   static int        getFontsize(const long chartId, const string id) {return int(ObjectGetInteger(chartId,id,OBJPROP_FONTSIZE));}
   static color      getColor(const long chartId, const string id) {return color(ObjectGetInteger(chartId,id,OBJPROP_COLOR));}
   static double     getAngle(const long chartId, const string id) {return int(ObjectGetDouble(chartId,id,OBJPROP_ANGLE));}
   static ENUM_ANCHOR_POINT        getAnchor(const long chartId, const string id) {return ENUM_ANCHOR_POINT(ObjectGetInteger(chartId,id,OBJPROP_ANCHOR));}
   static int        getBack(const long chartId, const string id) {return int(ObjectGetInteger(chartId,id,OBJPROP_BACK));}

   static int        getXdistance(const long chartId, const string id) {return int(ObjectGetInteger(chartId,id,OBJPROP_XDISTANCE));}
   static int        getYdistance(const long chartId, const string id) {return int(ObjectGetInteger(chartId,id,OBJPROP_YDISTANCE));}

   // --- toString()
   virtual string             toString() const { return StringFormat("%s,%d,%d,%d", m_id, (int)m_type, m_chartId, m_subwindow);}
   static  bool               fromString(const string csvStream, string &id, ENUM_OBJECT &type, long &chartId, int &subwindow);
   static  GraphicalObject*   fromString(const string csvStream) {return NULL;};
   
   virtual void      draw() const =0;//{};
   
   
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool GraphicalObject::fromString(const string csvStream, string &id, ENUM_OBJECT &type, long &chartId, int &subwindow)
  {
   string line=csvStream;
   string words[];
   StringSplit(line,',',words);
   int len=ArraySize(words);
   if(len>=4)
     {
      // validat
      id=words[0];
      type=(ENUM_OBJECT)StringToInteger(words[1]);
      chartId=StringToInteger(words[2]);
      subwindow=(int)StringToInteger(words[3]);

      //,(int)StringToInteger(words[4]),(int)StringToInteger(words[5]),(int)StringToInteger(words[6]),(datetime)StringToTime(words[6]));
      return true;
     }
   return false;
  }


//+------------------------------------------------------------------+
