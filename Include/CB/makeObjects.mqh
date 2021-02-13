void makeButton(
		const string name,
		const string title,
		const int x,
		const int y,
		const int w,
		const int h
) {
	ObjectCreate(0,name, OBJ_BUTTON, 0, 0, 0);
	ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x + w);
	ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
	ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
	ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
	ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
	ObjectSetString(0, name, OBJPROP_TEXT, title);
	ObjectSetString(0, name, OBJPROP_FONT, "Arial");
	ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 12);
	ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
	ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrCadetBlue);
	ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrNONE);
	ObjectSetInteger(0, name, OBJPROP_BACK, false);
	ObjectSetInteger(0, name, OBJPROP_STATE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
	ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
	ObjectSetInteger(0, name, OBJPROP_ZORDER, 100);
	Print (__FUNCTION__,": Button created:", name);
}

bool isButtonPressed(
	const string name
) {
	return (ObjectGetInteger(0, name, OBJPROP_STATE) == true);
}

void setButtonPressed(
	const string name,
	const bool pressed = true
) {
	ObjectSetInteger(0, name, OBJPROP_STATE, pressed);
}

void makeText(
		const string name,
		const string title,
		const int x,
		const int y,
		const int w,
		const int h,
		const int size = 10,
		const color clr = clrWhite
) {
	ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
	ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x + w);
	ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
	ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
	ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
	ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
	ObjectSetInteger(0, name, OBJPROP_BACK, false);
	ObjectSetInteger(0, name, OBJPROP_STATE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
	ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
	ObjectSetInteger(0, name, OBJPROP_ZORDER, 20);
	ObjectSetString(0,name, OBJPROP_TEXT, title);
	  ObjectSetString(0,name, OBJPROP_FONT, "Arial");
	  ObjectSetInteger(0,name, OBJPROP_FONTSIZE, size);
	  ObjectSetInteger(0,name, OBJPROP_COLOR, clr);
}

void setText(
		const string name,
		const string title,
		const int size = 10,
		const color clr = clrWhite
) {
	  ObjectSetString(0,name, OBJPROP_TEXT, title);
	  ObjectSetString(0,name, OBJPROP_FONT, "Arial");
	  ObjectSetInteger(0,name, OBJPROP_FONTSIZE, size);
	  ObjectSetInteger(0,name, OBJPROP_COLOR, clr);
}

void makeBox(
		const string name,
		const int x,
		const int y,
		const int w,
		const int h
) {
	ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
	ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x + w);
	ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
	ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
	ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
	ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
	ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrBlack);
	ObjectSetInteger(0, name, OBJPROP_STYLE, 0); 
	ObjectSetInteger(0, name, OBJPROP_WIDTH, 0); 
	ObjectSetInteger(0, name, OBJPROP_FILL, true);
	ObjectSetInteger(0, name, OBJPROP_BACK, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
	ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
	ObjectSetInteger(0, name, OBJPROP_ZORDER, 10);
}


void drawHLine(
		const string name,
		const double price,
		const color lineColor = clrCadetBlue,
		const int lineStyle = STYLE_DASH,
		const int lineWidth = 1
) {
	ObjectDelete(0,name);

	if (price > 0) {
		ObjectCreate(0,name, OBJ_HLINE, 0, 0, price);
		ObjectSetInteger(0,name, OBJPROP_STYLE, lineStyle);
		ObjectSetInteger(0,name, OBJPROP_COLOR, lineColor);
		ObjectSetInteger(0,name, OBJPROP_WIDTH, lineWidth);
		ObjectSetInteger(0,name, OBJPROP_BACK, true);
	}
}

void drawVLine(
		const string name,
		const int pos,
		const color lineColor = clrCadetBlue,
		const int lineStyle = STYLE_DASH,
		const int lineWidth = 1
) {
	ObjectDelete(0,name);

	if (pos > 0) {
		ObjectCreate(0,name, OBJ_VLINE, 0, iTime(NULL, 0, pos), 0);
		ObjectSetInteger(0,name, OBJPROP_STYLE, lineStyle);
		ObjectSetInteger(0,name, OBJPROP_COLOR, lineColor);
		ObjectSetInteger(0,name, OBJPROP_WIDTH, lineWidth);
		ObjectSetInteger(0,name, OBJPROP_BACK, true);
	}
}