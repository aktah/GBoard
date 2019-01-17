native CE_Convert(const string[]);
native CE_Convert_Dialog(const string[], style = 0);
native CE_CountTag(const string[]);

static 
	ce_dialog_btn1[32];

stock CE_SendClientMessage(playerid, color, const text[])
{
	static CE_str[144];
	format(CE_str, sizeof CE_str, text);
	CE_Convert(CE_str);
	return SendClientMessage(playerid, color, CE_str);
}

stock CE_SendClientMessageToAll(color, const text[])
{
	static
	    CE_str[144];

	format(CE_str, sizeof CE_str, text);
	CE_Convert(CE_str);
	SendClientMessageToAll(color, CE_str);
	return 1;
}


stock CE_ShowPlayerDialog(playerid, dialogid, style, caption[], info[], button1[], button2[]) {	
	if(strlen(button1) > 1) {
		format(ce_dialog_btn1, sizeof ce_dialog_btn1, button1);
	}
	CE_Convert_Dialog(caption, DIALOG_STYLE_MSGBOX);
	CE_Convert_Dialog(info, style);
	return ShowPlayerDialog(playerid, dialogid, style, caption, info, ce_dialog_btn1, button2);
}	


stock Text3D:CE_Create3DTextLabel(text[], color, Float:X, Float:Y, Float:Z, Float:DrawDistance, virtualworld = -1, testLOS = 0) {	
	CE_Convert_Dialog(text);
	new Text3D:ce_3dtextid = Create3DTextLabel(text, color, X, Y, Z, DrawDistance, virtualworld, testLOS);	
	return ce_3dtextid;
}

stock CE_Update3DTextLabelText(Text3D:id, color, text[]) {
	CE_Convert_Dialog(text);
	Update3DTextLabelText(id, color, text);
}

#if defined _streamer_included
	#if defined CreateDynamic3DTextLabel
		stock STREAMER_TAG_3D_TEXT_LABEL:CE_CreateDynamic3DTextLabel(const text[], color, Float:x, Float:y, Float:z, Float:drawdistance, attachedplayer = INVALID_PLAYER_ID, attachedvehicle = INVALID_VEHICLE_ID, testlos = 0, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = STREAMER_3D_TEXT_LABEL_SD, areaid = -1, priority = 0)	
		{	
			CE_Convert_Dialog(text);	
			new  STREAMER_TAG_3D_TEXT_LABEL:ce_3dtextid = CreateDynamic3DTextLabel(text, color, x, y, z, drawdistance, attachedplayer, attachedvehicle, testlos, worldid, interiorid, playerid, streamdistance, areaid, priority);	
			return ce_3dtextid;	
		}
	#endif
	#if defined UpdateDynamic3DTextLabelText
		stock CE_UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:id, color, const text[])
		{	
			CE_Convert_Dialog(text);	
			UpdateDynamic3DTextLabelText(id, color, text);		
		}
	#endif

	#if defined SetDynamicObjectMaterialText
		stock CE_SetDynamicObjectMaterialText(objectid, materialindex, const text[], materialsize = OBJECT_MATERIAL_SIZE_256x128, const fontface[] = "Arial", fontsize = 24, bold = 1, fontcolor = 0xFFFFFFFF, backcolor = 0, textalignment = 0) {
			new CE_str[512];
			format(CE_str, 512, text);
			CE_Convert(CE_str);
			return SetDynamicObjectMaterialText(objectid, materialindex, CE_str, materialsize, fontface, fontsize, bold, fontcolor, backcolor, textalignment);
		}
	#endif
#endif

#if defined CE_AUTO	

	#if defined _streamer_included

		#if defined CreateDynamic3DTextLabel
			#if defined _ALS_CreateDyn3DTextLabel
				#undef CreateDynamic3DTextLabel
			#else	
				#define _ALS_CreateDyn3DTextLabel
			#endif
			#define CreateDynamic3DTextLabel CE_CreateDynamic3DTextLabel
		#endif

		#if defined UpdateDynamic3DTextLabelText
			#if defined _ALS_UpdateDyn3DTextLabelText
				#undef UpdateDynamic3DTextLabelText
			#else	
				#define _ALS_UpdateDyn3DTextLabelText
			#endif		
			#define UpdateDynamic3DTextLabelText CE_UpdateDynamic3DTextLabelText
		#endif

		#if defined SetDynamicObjectMaterialText
			#if defined _ALS_SetDynObjectMaterialText
				#undef SetDynamicObjectMaterialText
			#else	
				#define _ALS_SetDynObjectMaterialText
			#endif		
			#define SetDynamicObjectMaterialText CE_SetDynamicObjectMaterialText
		#endif
	#endif

	#if defined _ALS_Create3DTextLabel
		#undef Create3DTextLabel	
	#else	
		#define _ALS_Create3DTextLabel
	#endif	
	#define Create3DTextLabel CE_Create3DTextLabel

	#if defined _ALS_Update3DTextLabelText
		#undef Update3DTextLabelText	
	#else	
		#define _ALS_Update3DTextLabelText
	#endif	
	#define Update3DTextLabelText CE_Update3DTextLabelText

	#if defined _ALS_ShowPlayerDialog	
		#undef ShowPlayerDialog	
	#else	
		#define _ALS_ShowPlayerDialog	
	#endif	

	#define ShowPlayerDialog CE_ShowPlayerDialog	

	#if defined _ALS_SendClientMessage	
		#undef SendClientMessage	
	#else	
		#define _ALS_SendClientMessage	
	#endif	
	#define SendClientMessage CE_SendClientMessage


	#if defined _ALS_SendClientMessageToAll
		#undef SendClientMessageToAll
	#else	
		#define _ALS_SendClientMessageToAll
	#endif	
	#define SendClientMessageToAll CE_SendClientMessageToAll
 #endif
