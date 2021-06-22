/*
Copyright (C) 2021 Mateus Matucuma Teixeira

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/
#ifndef MINICHARTS_H
#define MINICHARTS_H
//+------------------------------------------------------------------+
//|                                                  Mini Charts.mq5 |
//|                     Copyright (C) 2021, Mateus Matucuma Teixeira |
//|                                            mateusmtoss@gmail.com |
//| GNU General Public License version 2 - GPL-2.0                   |
//| https://opensource.org/licenses/gpl-2.0.php                      |
//+------------------------------------------------------------------+
// https://github.com/BRMateus2/MiniCharts-Indicator/
//---- Main Properties
#property copyright "2021, Mateus Matucuma Teixeira"
#property link "https://github.com/BRMateus2/MiniCharts-Indicator/"
#property description "This Indicator will create Mini Charts on the Chart Window, it also supports a Sub-Window if you place it inside a Sub-Window.\n"
#property description "Be aware that it is normal for the Mini Charts to have a delay, it is made so the object creation tries to be on the foreground of the chart."
#property version "1.02"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
//---- Definitions
#ifndef ErrorPrint
#define ErrorPrint(Dp_error) Print("ERROR: " + Dp_error + " at \"" + __FUNCTION__ + ":" + IntegerToString(__LINE__) + "\", last internal error: " + IntegerToString(GetLastError()) + " (" + __FILE__ + ")"); ResetLastError(); DebugBreak(); // It should be noted that the GetLastError() function doesn't zero the _LastError variable. Usually the ResetLastError() function is called before calling a function, after which an error appearance is checked.
#endif
//#define INPUT const
#ifndef INPUT
#define INPUT input
#endif
//---- Input Parameters
//---- "Basic Settings"
input group "Basic Settings"
string iName = "MiniCharts";
enum Corner {
    kCornerLeft, // Left Corner of Chart
    kCornerRight // Right Corner of Chart
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
INPUT ENUM_TIMEFRAMES c0PeriodInp = PERIOD_D1; // Mini Chart 0 Period (current = disabled)
INPUT ENUM_TIMEFRAMES c1PeriodInp = PERIOD_M1; // Mini Chart 1 Period (current = disabled)
INPUT ENUM_TIMEFRAMES c2PeriodInp = PERIOD_CURRENT; // Mini Chart 2 Period (current = disabled)
INPUT ENUM_TIMEFRAMES c3PeriodInp = PERIOD_CURRENT; // Mini Chart 3 Period (current = disabled)
INPUT Corner cCorner = kCornerLeft; // Mini Chart Corner
INPUT int cOffsetX = 0; // X Distance or Horizontal Position Offset
INPUT int cOffsetY = 20; // Y Distance or Vertical Position Offset
INPUT int cOffsetYBottom = 20; // Y Space on the Bottom
INPUT int cSizeX = 270; // X (Horizontal) Size in Pixels
INPUT int cSpacingY = 0; // Vertical gap between objects
INPUT bool cShowDate = true; // Show date in Mini Charts
INPUT bool cShowPrice = true; // Show price in Mini Charts
INPUT int cScale = 2; // Mini Chart Scale
INPUT int cDelay = 1; // Creation delay in s (so indicators don't foreground)
INPUT string magicID = "0"; // Magic Identification for multiples of the same indicator
datetime now = 0; // Defined at OnInit()
bool cCreated = false; // Mini Charts are created correctly
const color cColorSelected = clrRed; // Mini Chart color when highlighted (selected)
const ENUM_LINE_STYLE cStyleSelected = STYLE_SOLID; // Mini Chart color when highlighted (selected)
const int cPointSize = 1; // Move Point Size
const bool cBackground = false; // Mini Charts are printed in the background
const bool cSelectable = false; // Mini Charts are selectable
const bool cHidden = true; // Mini Charts are hidden in the Object List
const int cZOrder = 0; // Mini Chart Z Order for mouse click
int chartSizeX = 0; // Size of the Chart X Axis
int chartSizeY = 0; // Size of the Chart Y Axis
int cCount = 0; // Valid Mini Charts counter
//---- Objects
string c0Obj = "MT_Chart0"; // Object Chart 0, used for naming
string c1Obj = "MT_Chart1"; // Object Chart 1, used for naming
string c2Obj = "MT_Chart2"; // Object Chart 2, used for naming
string c3Obj = "MT_Chart3"; // Object Chart 3, used for naming
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// Constructor or initialization function
// https://www.mql5.com/en/docs/basis/function/events
// https://www.mql5.com/en/articles/100
//+------------------------------------------------------------------+
int OnInit()
{
    now = TimeGMT();
    iName = iName + magicID;
    c0Obj = c0Obj + magicID;
    c1Obj = c1Obj + magicID;
    c2Obj = c2Obj + magicID;
    c3Obj = c3Obj + magicID;
    IndicatorSetString(INDICATOR_SHORTNAME, iName);
    ObjectDelete(ChartID(), c0Obj);
    ObjectDelete(ChartID(), c1Obj);
    ObjectDelete(ChartID(), c2Obj);
    ObjectDelete(ChartID(), c3Obj);
// Count the number of valid Mini Charts
    if(c0PeriodInp != PERIOD_CURRENT) {
        cCount = cCount + 1;
    }
    if(c1PeriodInp != PERIOD_CURRENT) {
        cCount = cCount + 1;
    }
    if(c2PeriodInp != PERIOD_CURRENT) {
        cCount = cCount + 1;
    }
    if(c3PeriodInp != PERIOD_CURRENT) {
        cCount = cCount + 1;
    }
    if(cCount == 0) {
        ErrorPrint("All Mini Charts are set to PERIOD_CURRENT, there is nothing to show then, because they are all disabled");
        return INIT_PARAMETERS_INCORRECT;
    }
// Get Chart Attributes
    long chartSizeXTemp;
    if(!ChartGetInteger(ChartID(), CHART_WIDTH_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeXTemp)) {
        ErrorPrint("ChartGetInteger(ChartID(), CHART_WIDTH_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeXTemp)");
        //return INIT_FAILED;
    }
    chartSizeX = (int) chartSizeXTemp;
    long chartSizeYTemp;
    if(!ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeYTemp)) {
        ErrorPrint("ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeYTemp)");
        //return INIT_FAILED;
    }
    chartSizeY = (int) chartSizeYTemp;
    if(!EventSetTimer(1)) {
        ErrorPrint("!EventSetTimer(1)");
        return INIT_FAILED;
    }
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
// Timer function
//+------------------------------------------------------------------+
void OnTimer()
{
// Indicator Sleep() is not allowed, so we are trying to create the chart objects only after all chart indicator data are calculated, to account for the issue of other indicators foregrounding the priority objects
// This is a unfortunate performance cost, to try to enforce those objects as foreground (not guaranteed)
// Issue https://www.mql5.com/en/forum/133175
// Issue https://www.mql5.com/en/forum/133995
// Issue https://www.mql5.com/en/forum/363531
// Issue: Sometimes IsStopped() is set, but the platform still calls for the OnTimer():
//  ERROR: ChartGetInteger(ChartID(), CHART_WIDTH_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeXTemp) at "OnTimer:156", last internal error: 4022 (Mini Charts.mq5)
//  This check attempts to fix that issue
    if(IsStopped()) {
        return;
    }
// Check if Chart size has changed
    long chartSizeXTemp;
    if(!ChartGetInteger(ChartID(), CHART_WIDTH_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeXTemp)) {
        ErrorPrint("ChartGetInteger(ChartID(), CHART_WIDTH_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeXTemp)");
        return;
    }
    if(chartSizeX != (int) chartSizeXTemp) {
        now = TimeGMT();
        cCreated = false;
        chartSizeX = (int) chartSizeXTemp;
    }
    long chartSizeYTemp;
    if(!ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeYTemp)) {
        ErrorPrint("ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeYTemp)");
        return;
    }
    if(chartSizeY != (int) chartSizeYTemp) {
        now = TimeGMT();
        cCreated = false;
        chartSizeY = (int) chartSizeYTemp;
    }
    if(cCreated == false && now < TimeGMT() - cDelay) {
        now = TimeGMT();
        ObjectDelete(ChartID(), c0Obj);
        ObjectDelete(ChartID(), c1Obj);
        ObjectDelete(ChartID(), c2Obj);
        ObjectDelete(ChartID(), c3Obj);
// Create Objects
        long thisY = cOffsetY; // Represents a Y axis position at printing (imagine a pointing arrow at the end of Y axis of the last object created)
        long thisYIncrement = (long) MathRound(((double) chartSizeY / (double) cCount) - ((double) cOffsetYBottom / (double) cCount) - ((double) cOffsetY / (double) cCount)); // Increment the "pointing" for every object created, rounded for precision
        long thisXOffset = (cCorner == kCornerLeft ? cOffsetX : cOffsetX + cSizeX); // MQL5 X axis offset on the left corner works by adding the object position, while on the right corner works by subtracting the object position (The Cartesian Coordinates system with rotation)
        if(c0PeriodInp != PERIOD_CURRENT) {
            ObjectChartCreate(Symbol(), ChartID(), ChartWindowFind(ChartID(), iName), c0Obj, c0PeriodInp,
                              thisXOffset,
                              thisY,
                              cSizeX,
                              thisYIncrement,
                              EnumToEnumBaseCorner(cCorner), cScale, cShowDate, cShowPrice, cColorSelected, cStyleSelected, cPointSize, cBackground, cSelectable, cHidden, cZOrder
                             );
            thisY = thisY + thisYIncrement;
        }
        if(c1PeriodInp != PERIOD_CURRENT) {
            ObjectChartCreate(Symbol(), ChartID(), ChartWindowFind(ChartID(), iName), c1Obj, c1PeriodInp,
                              thisXOffset,
                              thisY,
                              cSizeX,
                              thisYIncrement,
                              EnumToEnumBaseCorner(cCorner), cScale, cShowDate, cShowPrice, cColorSelected, cStyleSelected, cPointSize, cBackground, cSelectable, cHidden, cZOrder
                             );
            thisY = thisY + thisYIncrement;
        }
        if(c2PeriodInp != PERIOD_CURRENT) {
            ObjectChartCreate(Symbol(), ChartID(), ChartWindowFind(ChartID(), iName), c2Obj, c2PeriodInp,
                              thisXOffset,
                              thisY,
                              cSizeX,
                              thisYIncrement,
                              EnumToEnumBaseCorner(cCorner), cScale, cShowDate, cShowPrice, cColorSelected, cStyleSelected, cPointSize, cBackground, cSelectable, cHidden, cZOrder
                             );
            thisY = thisY + thisYIncrement;
        }
        if(c3PeriodInp != PERIOD_CURRENT) {
            ObjectChartCreate(Symbol(), ChartID(), ChartWindowFind(ChartID(), iName), c3Obj, c3PeriodInp,
                              thisXOffset,
                              thisY,
                              cSizeX,
                              thisYIncrement,
                              EnumToEnumBaseCorner(cCorner), cScale, cShowDate, cShowPrice, cColorSelected, cStyleSelected, cPointSize, cBackground, cSelectable, cHidden, cZOrder
                             );
        }
        ChartRedraw(ChartID());
        cCreated = true;
    }
    return;
}
//+------------------------------------------------------------------+
// Calculation function
//+------------------------------------------------------------------+
int OnCalculate(
    const int rates_total, // price[] array size
    const int prev_calculated, // number of handled bars at the previous call
    const int begin, // index number in the price[] array meaningful data starts from
    const double& price[]) // array of values for calculation
{
    return rates_total; // There are no calculations to be executed
}
//+------------------------------------------------------------------+
// Destructor or Deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ObjectDelete(ChartID(), c0Obj);
    ObjectDelete(ChartID(), c1Obj);
    ObjectDelete(ChartID(), c2Obj);
    ObjectDelete(ChartID(), c3Obj);
    EventKillTimer();
    return;
}
//+------------------------------------------------------------------+
// Extra functions, utilities and conversion
//+------------------------------------------------------------------+
ENUM_BASE_CORNER EnumToEnumBaseCorner(Corner e)
{
    if(e == kCornerLeft) return CORNER_LEFT_UPPER;
    else if(e == kCornerRight) return CORNER_RIGHT_UPPER;
    else {
        ErrorPrint("undefined");
        return CORNER_LEFT_UPPER;
    }
}
//+------------------------------------------------------------------+
// PlotIndexConstruct, substitute for common call
// Fixed Issue: the function solves a issue with the platform #property, where every single time the .ex5 file is updated or recompiled, all of the Plot (color, etc) user settings are reset - this function is not made for Levels.
//+------------------------------------------------------------------+
bool PlotIndexConstruct(const int plotIndex,
                        const string plotLabel,
                        const color plotColor,
                        double& plotBuffer[], // Cannot set this to const, because SetIndexBuffer() parameter is not const
                        const ENUM_INDEXBUFFER_TYPE plotIndexType = INDICATOR_DATA,
                        const ENUM_DRAW_TYPE plotDraw = DRAW_LINE,
                        const int plotShift = 0,
                        const ENUM_LINE_STYLE plotStyle = STYLE_SOLID,
                        const int plotWidth = 1,
                        const int plotBegin = 0,
                        const bool plotShowOnDatawindow = true,
                        const double plotEmptyValue = 0.0)
{
    bool success = true;
    if(!SetIndexBuffer(plotIndex, plotBuffer, plotIndexType)) {
        ErrorPrint("!SetIndexBuffer(plotIndex, plotBuffer, plotIndexType)");
        success = false;
    }
    if(!PlotIndexSetString(plotIndex, PLOT_LABEL, plotLabel)) {
        ErrorPrint("!PlotIndexSetString(plotIndex, PLOT_LABEL, plotLabel)");
        success = false;
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, plotColor)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, plotColor)");
        success = false;
    }
    if(plotDraw != DRAW_ARROW) {
        if(!PlotIndexSetInteger(plotIndex, PLOT_DRAW_TYPE, plotDraw)) {
            ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_DRAW_TYPE, plotDraw)");
            success = false;
        }
        if(!PlotIndexSetInteger(plotIndex, PLOT_SHIFT, plotShift)) {
            ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_SHIFT, plotShift)");
            success = false;
        }
    } else {
        if(!PlotIndexSetInteger(plotIndex, PLOT_DRAW_TYPE, plotDraw)) {
            ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_DRAW_TYPE, plotDraw)");
            success = false;
        }
        if(!PlotIndexSetInteger(plotIndex, PLOT_ARROW_SHIFT, plotShift)) {
            ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_ARROW_SHIFT, plotShift)");
            success = false;
        }
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_LINE_STYLE, plotStyle)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_LINE_STYLE, plotStyle)");
        success = false;
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_LINE_WIDTH, plotWidth)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_LINE_WIDTH, plotWidth)");
        success = false;
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_DRAW_BEGIN, plotBegin)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_DRAW_BEGIN, plotBegin)");
        success = false;
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_SHOW_DATA, plotShowOnDatawindow)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_SHOW_DATA, plotShowOnDatawindow)");
        success = false;
    }
    if(!PlotIndexSetDouble(plotIndex, PLOT_EMPTY_VALUE, plotEmptyValue)) {
        ErrorPrint("!PlotIndexSetDouble(plotIndex, PLOT_EMPTY_VALUE, plotEmptyValue)");
        success = false;
    }
    return success;
}
//+------------------------------------------------------------------+
//| Creating Chart object
//+------------------------------------------------------------------+
bool ObjectChartCreate(const string symbol, // Symbol
                       const long chart_ID = 0, // Chart ID
                       const int sub_window = 0, // Subwindow Index
                       const string name = "Chart", // Object Name
                       const ENUM_TIMEFRAMES period = PERIOD_H1, // Period
                       const long x = 0, // X Coordinate
                       const long y = 0, // Y Coordinate
                       const long width = 300, // Width
                       const long height = 200, // Height
                       const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, // Anchoring Corner
                       const long scale = 2, // Scale
                       const bool date_scale = true, // Time Scale display
                       const bool price_scale = true, // Price Scale display
                       const color clr = clrRed, // Border color when highlighted
                       const ENUM_LINE_STYLE style = STYLE_SOLID, // Line Style when highlighted
                       const long point_width = 1, // Move Point size
                       const bool back = false, // In the background
                       const bool selection = false, // Highlight to move
                       const bool hidden = true, // Hidden in the Object List
                       const long z_order = 0) // Priority for mouse click
{
    if(!ObjectCreate(chart_ID, name, OBJ_CHART, sub_window, 0, 0)) {
        ErrorPrint("!ObjectCreate(chart_ID, name, OBJ_CHART, sub_window, 0, 0)");
        return false;
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x)) { // Wont be returning false, because supposedly the ObjectCreate() was successful at this point
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner)");
    }
    if(!ObjectSetString(chart_ID, name, OBJPROP_SYMBOL, symbol)) {
        ErrorPrint("!ObjectSetString(chart_ID, name, OBJPROP_SYMBOL, symbol)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_PERIOD, period)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_PERIOD, period)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_CHART_SCALE, scale)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_CHART_SCALE, scale)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_DATE_SCALE, date_scale)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_DATE_SCALE, date_scale)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_PRICE_SCALE, price_scale)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_PRICE_SCALE, price_scale)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, point_width)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, point_width)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order)");
    }
    return true;
}
//+------------------------------------------------------------------+
//| Header Guard #endif
//+------------------------------------------------------------------+
#endif
//+------------------------------------------------------------------+
