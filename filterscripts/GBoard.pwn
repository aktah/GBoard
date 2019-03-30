#include <a_samp>
#include <foreach>
#include <sscanf2>
#include <streamer>
// #include <YSF> // Version 2.0 ไม่จำเป็นต้องใช้แล้ว

#define CE_AUTO
#include <CEFix>   // aktah/SAMP-CEFix

#include <a_mysql> // pBlueG/SA-MP-MySQL
#include <zcmd>

// ตั้งค่า
#define MAX_BOARD_RANK 10 // จำนวนสูงสุดที่สร้างได้ในเซิร์ฟเวอร์
#define PICKUP_SLOT 9 // ไอดี SLOT ไอเท็มติดตัว (โปรดเลือกอันที่ใน Gamemode ไม่ได้ใช้)

#define PLAYER_FIELD_NAME   ("Name") // ชื่อฟิลด์ของผู้เล่น
#define PLAYER_TABLE_NAME   ("players") // ชื่อตารางของผู้เล่น

#define SIZE_HEADER		48     // ขนาดหัวข้อ
#define SIZE_TEXT		32       // ขนาดตัวหนังสือ



#define BOARD_TYPE_STATIC 0
#define BOARD_TYPE_RANKING 1

enum BOARD_RANK_DATA {
    boardID,

    Float:bX,
    Float:bY,
    Float:bZ,
    Float:bA,

    bFieldName[32],
    boardInfo[32],
    boardType, // Static, Ranking
    bMaxPlayer,
    bObject,
    bLineText[6],
    bText1[64],
    bText2[64],
    bText3[64],
    bText4[64],
    bText5[64],
    bText6[64]
};

new boardData[MAX_BOARD_RANK][BOARD_RANK_DATA];
new Iterator:Iter_Board<MAX_BOARD_RANK>;

static const
    Float:gboard = 0.08,
    Float:OffPosZ = 1.8
;

new CarryBoard[MAX_PLAYERS]=-1;
new boardTimer;

#define COLOR_GREEN 0x33AA33AA
#define COLOR_GRAD1 0xb4b5b7ff
#define COLOR_GRAD2 0xa2a2a4ff
#define COLOR_LIGHTRED 0xFF6347FF

new MySQL:dbCon;

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" GBoard System Filterscript by Aktah");
    print(" Version 1.0");
	print("--------------------------------------\n");
	
	g_mysql_Init();

	mysql_tquery(dbCon, "SELECT * FROM `board_sys`", "Board_Load", "");

	boardTimer = SetTimer("BoardUpdate", 2000, true);
	return 1;
}

public OnFilterScriptExit()
{
	KillTimer(boardTimer);
	g_mysql_Exit();
	return 1;
}

main() {}

g_mysql_Init()
{
    new SQL_HOST[32], SQL_DB[32], SQL_USER[32], SQL_PASS[32], fileString[128], File: fhConnectionInfo = fopen("mysql.ini", io_read);
	fread(fhConnectionInfo, fileString);
	fclose(fhConnectionInfo);
	sscanf(fileString, "p<|>s[32]s[32]s[32]s[32]", SQL_DB, SQL_HOST, SQL_USER, SQL_PASS);
	mysql_log(ALL);
	dbCon = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS, SQL_DB);
	if (mysql_errno(dbCon)) {
		printf("[SQL] Connection to \"%s\" failed! Please check the connection settings...\a", SQL_HOST);
		SendRconCommand("exit");
		return 1;
	}
	else printf("[SQL] Connection to \"%s\" passed!", SQL_HOST);

	return 1;
}

g_mysql_Exit()
{
	if(dbCon)
		mysql_close(dbCon);
	return 1;
}

CMD:boardcmds(playerid, params[])
{
    SendClientMessage(playerid, COLOR_GREEN, "==========[ ระบบบอร์ดโดย Aktah ]==========");
    SendClientMessage(playerid, COLOR_GRAD1, "คำสั่ง: /createboard, /destroyboard, /moveboard, /settingboard");
	return 1;
}

CMD:createboard(playerid, params[])
{
    new query[256];
    mysql_format(dbCon, query, sizeof query, "INSERT INTO `board_sys` (`boardType`) VALUES(0)");
    mysql_tquery(dbCon, query, "OnBoardCreated", "i", playerid);
	return 1;
}

CMD:moveboard(playerid, params[])
{
    if(CarryBoard[playerid] == -1)
    {
        new id = -1;  
        if((id=Board_Nearest(playerid)) != -1) {
            ApplyAnimation(playerid, "CARRY","liftup", 4.1, 0, 0, 0, 0, 0, 1);
            SetTimerEx("PickBoard", 900, 0, "ii", playerid, id);
            CarryBoard[playerid] = id;
        }
    }
    else {

	    ApplyAnimation(playerid, "CARRY","putdwn", 4.1, 0, 0, 0, 0, 0, 1);
	    SetTimerEx("PutBoard", 900, 0, "i", playerid);
    }
	return 1;
}

forward  PutBoard(playerid);
public PutBoard(playerid)
{
    if(CarryBoard[playerid] != -1) {
        new Float:px, Float:py, Float:pz, Float:pa;
        GetPlayerPos(playerid, px, py, pz);
        GetPlayerFacingAngle(playerid, pa);
        GetXYInFrontOfPlayer(playerid, px, py, 2.0);
        pz -= 1.0;
        pa += 180;
        CreateBoard(CarryBoard[playerid], px, py, pz, pa);
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        RemovePlayerAttachedObject(playerid, PICKUP_SLOT);
        Streamer_Update(playerid, STREAMER_TYPE_OBJECT);
        Board_Save(CarryBoard[playerid]);
        CarryBoard[playerid] = -1;
    }
}

forward PickBoard(playerid, id);
public PickBoard(playerid, id)
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	SetPlayerAttachedObject(playerid, PICKUP_SLOT, 3077, 1, -0.634000,0.475999,-0.005000, 0, 87.1, -9.4, 1.0000, 1.0000, 1.0000);
    DestroyDynamicObject(boardData[id][bObject]);
	DestroyDynamicObject(boardData[id][bLineText][0]);
    DestroyDynamicObject(boardData[id][bLineText][1]);
    DestroyDynamicObject(boardData[id][bLineText][2]);
    DestroyDynamicObject(boardData[id][bLineText][3]);
    DestroyDynamicObject(boardData[id][bLineText][4]);
    DestroyDynamicObject(boardData[id][bLineText][5]);
}

CMD:destroyboard(playerid, params[])
{
    new id = -1, query[128];  
    if((id=Board_Nearest(playerid, 5.0)) != -1) {

		format(query, sizeof(query), "DELETE FROM `board_sys` WHERE `boardId` = %d", boardData[id][boardID]);
		mysql_tquery(dbCon, query, "OnBoardRemove", "ii", playerid, id);
        ApplyAnimation(playerid,"FIGHT_D","FightD_G",4.1, 0, 1, 1, 0, 0, 1);
    }
    else {
        SendClientMessage(playerid, COLOR_LIGHTRED, "ไม่พบบอร์ดอยู่รอบ ๆ ตัวของคุณ");
    }
	return 1;
}


forward OnBoardRemove(playerid, id);
public OnBoardRemove(playerid, id)
{
	DestroyDynamicObject(boardData[id][bObject]);
	DestroyDynamicObject(boardData[id][bLineText][0]);
    DestroyDynamicObject(boardData[id][bLineText][1]);
    DestroyDynamicObject(boardData[id][bLineText][2]);
    DestroyDynamicObject(boardData[id][bLineText][3]);
    DestroyDynamicObject(boardData[id][bLineText][4]);
    DestroyDynamicObject(boardData[id][bLineText][5]);
	SendClientMessage(playerid, -1, "คุณได้ทำลายบอร์ดเรียบร้อยแล้ว !!");
	Iter_Remove(Iter_Board, id);
	return 1;
}

CMD:settingboard(playerid, params[])
{
    new id = -1, boardSTR[128];
    if((id=Board_Nearest(playerid, 5.0)) != -1) {
        new options[64], values[128];
        if (sscanf(params, "s[16]S()[128]", options, values))
        {
            SendClientMessage(playerid, COLOR_GRAD1, "การใช้: /settingboard [ตัวเลือก]");
            if(boardData[id][boardType] == 0) {
                SendClientMessage(playerid, COLOR_GRAD2, "ตัวเลือกที่ใช้งานได้: ประเภท, ข้อความ");
            }
            else {
                SendClientMessage(playerid, COLOR_GRAD2, "ตัวเลือกที่ใช้งานได้: ประเภท, ชื่ออันดับ, ชื่อฟิลด์, รายชื่อสูงสุด(1-5)");
            }
            return 1;
        }

        if(!strcmp(options, "ประเภท", true)) {
            new type = strval(values);
            if(type == 0) {
                SendClientMessage(playerid, COLOR_GRAD1, "การใช้: /settingboard ประเภท [หมายเลข]");
                SendClientMessage(playerid, COLOR_GRAD2, "หมายเลข 1: บอร์ด Static (แก้ไขข้อความบนบอร์ดได้)");
                SendClientMessage(playerid, COLOR_GRAD2, "หมายเลข 2: บอร์ด Ranking (เลือกฟิลด์ผู้เล่นที่มีค่าสูงสุดออกมาแสดง)");
            }
            else {
                type--;    
                boardData[id][boardType] = type;

                switch(boardData[id][boardType]) {
                    case BOARD_TYPE_STATIC: {
                        SetBoardText(id, 0, "การตั้งค่า");
                        SetBoardText(id, 1, "พิมพ์ {ffff00}/settingboard{ffffff} เพื่อตั้งค่า");
                        SetBoardText(id, 2, "\r");
                        SetBoardText(id, 3, "\r");
                        SetBoardText(id, 4, "\r");
                        SetBoardText(id, 5, "\r");

                    }
                    case BOARD_TYPE_RANKING: {
                        boardData[id][bMaxPlayer] = 0;
                        boardData[id][bFieldName][0] = '\0';
                        boardData[id][boardInfo][0] = '\0';

                        UpdateBoardText(id, 0, "การตั้งค่า");
                        UpdateBoardText(id, 1, "พิมพ์ {ffff00}/settingboard{ffffff} เพื่อตั้งค่า");
                        UpdateBoardText(id, 2, "ชื่ออันดับ [{ff0000}X{ffffff}]");
                        UpdateBoardText(id, 3, "ชื่อฟิลด์ [{ff0000}X{ffffff}]");
                        UpdateBoardText(id, 4, "จำนวนผู้เล่นสูงสุด [{ff0000}X{ffffff}]");
                        UpdateBoardText(id, 5, "========================");
                    }
                }

                format(boardSTR, 128, "คุณได้เปลี่ยนบอร์ดไอดี %d เป็นประเภท %s", id, ReturnBoardType(type));
                SendClientMessage(playerid, -1, boardSTR);

                Board_Save(id);
            }
        }
        else {
            if(boardData[id][boardType] == 0) {
                if(!strcmp(options, "ข้อความ", true)) {
                    new lineID, lineText[64];
                    if (sscanf(values, "ds[64]", lineID, lineText))
                    {
                        SendClientMessage(playerid, COLOR_GRAD1, "การใช้: /settingboard ข้อความ [บรรทัด] [ข้อความที่แสดง]");
                        format(boardSTR, 128,"บรรทัด 0: {ffffff}%s", boardData[id][bText1]);
                        SendClientMessage(playerid, COLOR_GRAD2, boardSTR);
                        format(boardSTR, 128,"บรรทัด 1: {ffffff}%s", boardData[id][bText2]);
                        SendClientMessage(playerid, COLOR_GRAD2, boardSTR);
                        format(boardSTR, 128,"บรรทัด 2: {ffffff}%s", boardData[id][bText3]);
                        SendClientMessage(playerid, COLOR_GRAD2, boardSTR);
                        format(boardSTR, 128,"บรรทัด 3: {ffffff}%s", boardData[id][bText4]);
                        SendClientMessage(playerid, COLOR_GRAD2, boardSTR);
                        format(boardSTR, 128,"บรรทัด 4: {ffffff}%s", boardData[id][bText5]);
                        SendClientMessage(playerid, COLOR_GRAD2, boardSTR);
                        format(boardSTR, 128,"บรรทัด 5: {ffffff}%s", boardData[id][bText6]);
                        SendClientMessage(playerid, COLOR_GRAD2, boardSTR);
                        return 1;
                    }

                    if(strlen(lineText) == 0) {
                        format(lineText, 64, "\r");
                    }

                    SetBoardText(id, lineID, lineText);

                    Board_Save(id);
                }
                else {
                    SendClientMessage(playerid, COLOR_GRAD1, "การใช้: /settingboard [ตัวเลือก]");
                    SendClientMessage(playerid, COLOR_GRAD2, "ตัวเลือกที่ใช้งานได้: ประเภท, ข้อความ");
                }
            }
            else {
                if(!strcmp(options, "ชื่ออันดับ", true)) {
                    new lineText[32];
                    if (sscanf(values, "s[32]", lineText))
                    {
                        SendClientMessage(playerid, COLOR_GRAD1, "การใช้: /settingboard ชื่ออันดับ [ชื่อ]");
                        SendClientMessage(playerid, COLOR_GRAD1, "ใช้ 'none' ลบล้างชื่อ");
                        return 1;
                    }
                    if(!strcmp(options, "none", true)) {
                        boardData[id][boardInfo][0] = '\0';
                    }
                    else format(boardData[id][boardInfo], 32, lineText);
                    RefreashBoard(id);

                    Board_Save(id);
                }
                else if(!strcmp(options, "ชื่อฟิลด์", true)) {
                    new lineText[16];
                    if (sscanf(values, "s[32]", lineText))
                    {
                        SendClientMessage(playerid, COLOR_GRAD1, "การใช้: /settingboard ชื่อฟิลด์ [ฟิลด์ (เฉพาะประเภท Integer เท่านั้น)]");
                        SendClientMessage(playerid, COLOR_GRAD1, "ใช้ 'none' ลบล้างชื่อ");
                        return 1;
                    }
                    if(!strcmp(options, "none", true)) {
                        boardData[id][bFieldName][0] = '\0';
                    }
                    else format(boardData[id][bFieldName], 32, lineText);   
                    RefreashBoard(id);

                    Board_Save(id);
                }
                else if(!strcmp(options, "รายชื่อสูงสุด", true)) {
                    new maxlv;
                    if (sscanf(values, "d", maxlv))
                    {
                        SendClientMessage(playerid, COLOR_GRAD1, "การใช้: /settingboard รายชื่อสูงสุด [จำนวน1-5]");
                        return 1;
                    }
                    if(maxlv < 0 || maxlv > 5) {
                        return SendClientMessage(playerid, COLOR_LIGHTRED, "รายชื่อสูงสุดต้องไม่ต่ำกว่า 0 หรือมากกว่า 5");
                    }
                    boardData[id][bMaxPlayer] = maxlv;
                    RefreashBoard(id);

                    Board_Save(id);
                }
                else {
                    SendClientMessage(playerid, COLOR_GRAD1, "การใช้: /settingboard [ตัวเลือก]");
                    SendClientMessage(playerid, COLOR_GRAD2, "ตัวเลือกที่ใช้งานได้: ประเภท, ชื่ออันดับ, ชื่อฟิลด์, รายชื่อสูงสุด(1-5)");
                }
            }

        }
    }
    else {
        SendClientMessage(playerid, COLOR_LIGHTRED, "ไม่พบบอร์ดอยู่รอบ ๆ ตัวของคุณ");
    }
	return 1;
}

stock ReturnBoardType(type) {
    new name[8];
    switch(type) {
        case BOARD_TYPE_STATIC: format(name, 8, "STATIC");
        case BOARD_TYPE_RANKING: format(name, 8, "RANKING");
    }
    return name;
}

stock Board_Nearest(playerid, Float:radius = 2.5)
{
	new
	    Float:fDistance = 0x7F800000,
	    iIndex = -1
	;
	foreach (new i : Iter_Board) {

		new
		 	Float:temp = GetPlayerDistanceFromPoint(playerid, boardData[i][bX], boardData[i][bY], boardData[i][bZ]);

		if (temp < fDistance && temp <= radius)
		{
			fDistance = temp;
			iIndex = i;
		}
	}
	return iIndex;
}

forward CreateBoard(id, Float:x, Float:y, Float:z, Float:a);
public CreateBoard(id, Float:x, Float:y, Float:z, Float:a) {

    if(!Iter_Contains(Iter_Board, id)) {
        if((id = Iter_Free(Iter_Board)) != -1) {

            boardData[id][bX] = x;
            boardData[id][bY] = y;
            boardData[id][bZ] = z;
            boardData[id][bA] = a;

            boardData[id][bObject] = CreateDynamicObject(3077, x, y, z, 0.0000, 0.0000, a);

            x += gboard * floatsin(-a, degrees);
            y += gboard * floatcos(-a, degrees);
            
	        boardData[id][bLineText][0] = CreateDynamicObject(18659, x, y, z + OffPosZ, 0.0, 0.0, a - 90);
	        SetDynamicObjectMaterialText(boardData[id][bLineText][0], 0, boardData[id][bText1], 140, "Calibri", SIZE_HEADER, 1, 0xFFFFFFFF, 0, 0);

	        boardData[id][bLineText][1] = CreateDynamicObject(18659, x, y, z + OffPosZ -0.4, 0.0, 0.0, a - 90);
	        SetDynamicObjectMaterialText(boardData[id][bLineText][1], 0, boardData[id][bText2], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);

	        boardData[id][bLineText][2] = CreateDynamicObject(18659, x, y, z + OffPosZ -0.7, 0.0, 0.0, a - 90);
	        SetDynamicObjectMaterialText(boardData[id][bLineText][2], 0, boardData[id][bText3], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);

	        boardData[id][bLineText][3] = CreateDynamicObject(18659, x, y, z + OffPosZ -1.0, 0.0, 0.0, a - 90);
	        SetDynamicObjectMaterialText(boardData[id][bLineText][3], 0, boardData[id][bText4], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);

	        boardData[id][bLineText][4] = CreateDynamicObject(18659, x, y, z + OffPosZ - 1.3, 0.0, 0.0, a - 90);
	        SetDynamicObjectMaterialText(boardData[id][bLineText][4], 0, boardData[id][bText5], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);

	        boardData[id][bLineText][5] = CreateDynamicObject(18659, x, y, z + OffPosZ - 1.6, 0.0, 0.0, a - 90);
	        SetDynamicObjectMaterialText(boardData[id][bLineText][5], 0, boardData[id][bText6], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);
            Iter_Add(Iter_Board, id);
        }
    }
    else {
        if(IsValidDynamicObject(boardData[id][bObject])) {
            DestroyDynamicObject(boardData[id][bObject]);
        }

        for(new line=0; line!=6; line++) {
            if(IsValidDynamicObject(boardData[id][bLineText][line])) {
                DestroyDynamicObject(boardData[id][bLineText][line]);
            }
        }

        boardData[id][bX] = x;
        boardData[id][bY] = y;
        boardData[id][bZ] = z;
        boardData[id][bA] = a;

        boardData[id][bObject] = CreateDynamicObject(3077, x, y, z, 0.0000, 0.0000, a);

      	x += gboard * floatsin(-a, degrees);
       	y += gboard * floatcos(-a, degrees);
        
        boardData[id][bLineText][0] = CreateDynamicObject(18659, x, y, z + OffPosZ, 0.0, 0.0, a - 90);
        SetDynamicObjectMaterialText(boardData[id][bLineText][0], 0, boardData[id][bText1], 140, "Calibri", SIZE_HEADER, 1, 0xFFFFFFFF, 0, 0);

        boardData[id][bLineText][1] = CreateDynamicObject(18659, x, y, z + OffPosZ -0.4, 0.0, 0.0, a - 90);
        SetDynamicObjectMaterialText(boardData[id][bLineText][1], 0, boardData[id][bText2], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);

        boardData[id][bLineText][2] = CreateDynamicObject(18659, x, y, z + OffPosZ -0.7, 0.0, 0.0, a - 90);
        SetDynamicObjectMaterialText(boardData[id][bLineText][2], 0, boardData[id][bText3], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);

        boardData[id][bLineText][3] = CreateDynamicObject(18659, x, y, z + OffPosZ -1.0, 0.0, 0.0, a - 90);
        SetDynamicObjectMaterialText(boardData[id][bLineText][3], 0, boardData[id][bText4], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);

        boardData[id][bLineText][4] = CreateDynamicObject(18659, x, y, z + OffPosZ - 1.3, 0.0, 0.0, a - 90);
        SetDynamicObjectMaterialText(boardData[id][bLineText][4], 0, boardData[id][bText5], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);

        boardData[id][bLineText][5] = CreateDynamicObject(18659, x, y, z + OffPosZ - 1.6, 0.0, 0.0, a - 90);
        SetDynamicObjectMaterialText(boardData[id][bLineText][5], 0, boardData[id][bText6], 140, "Calibri", SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);

    }
    return id;
}

forward OnBoardCreated(playerid);
public OnBoardCreated(playerid)
{
    new id = -1, Float:px, Float:py, Float:pz, Float:pa;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerFacingAngle(playerid, pa);
    GetXYInFrontOfPlayer(playerid, px, py, 2.0);
    pz -= 1.0;
    pa += 180;

    if((id = CreateBoard(-1, px, py, pz, pa)) == -1) {
        return SendClientMessage(playerid, COLOR_LIGHTRED, "บอร์ดอันดับมีมากเกินจำนวนจำกัดแล้ว !!");
    }
    else {
        if(Iter_Contains(Iter_Board, id)) {
            boardData[id][boardID] = cache_insert_id();
            boardData[id][boardType] = BOARD_TYPE_STATIC;
            boardData[id][bMaxPlayer] = 0;
            boardData[id][bFieldName][0] = '\0';
            boardData[id][boardInfo][0] = '\0';
            format(boardData[id][bText1], 64, "การตั้งค่า");
            format(boardData[id][bText2], 64, "พิมพ์ {ffff00}/settingboard{ffffff} เพื่อตั้งค่า");
            format(boardData[id][bText3], 64, "\r");
            format(boardData[id][bText4], 64, "\r");
            format(boardData[id][bText5], 64, "\r");
            format(boardData[id][bText6], 64, "\r");
            Board_Save(id);
            RefreashBoard(id);
            SendClientMessage(playerid, -1, "คุณได้สร้างบอร์ดเรียบร้อยแล้ว !!");
        }
    }
	return 1;
}

forward BoardUpdate();
public BoardUpdate() {
    new queryStr[256];
    foreach(new i : Iter_Board) {
        if(boardData[i][boardType] == BOARD_TYPE_RANKING && boardData[i][bMaxPlayer]>0 && IsValidDynamicObject(boardData[i][bObject])) {
            new header_text[128];
            format(header_text, 128, "%d อันดับ '%s'", boardData[i][bMaxPlayer], boardData[i][boardInfo]);
            UpdateBoardText(i, 0, header_text);
            format(queryStr, 256, "SELECT `%s`, `%s` FROM `%s` ORDER BY `%s` DESC LIMIT %d", PLAYER_FIELD_NAME, boardData[i][bFieldName], PLAYER_TABLE_NAME, boardData[i][bFieldName], boardData[i][bMaxPlayer]);
            mysql_pquery(dbCon, queryStr, "UpdateBoardRank", "d", i);
        }
    }
    return 1;
}

forward UpdateBoardRank(id);
public UpdateBoardRank(id) {
    new
	    rows, fieldName[32], temp_player[MAX_PLAYER_NAME], temp_value, board_str[128];

	cache_get_row_count(rows);

	for (new i = 0; i < 5; i ++)
	{
        if(i < rows) {
            cache_get_value_name(i, PLAYER_FIELD_NAME, temp_player, MAX_PLAYER_NAME);
            format(fieldName, 32, boardData[id][bFieldName]);
            cache_get_value_name_int(i, fieldName, temp_value);

            format(board_str, 128, "%d. %s (%d)", i + 1, temp_player, temp_value);
            UpdateBoardText(id, i + 1, board_str);
        }
        else {
            if(i < boardData[id][bMaxPlayer]) {
                format(board_str, 128, "%d. ว่าง", i + 1);
                UpdateBoardText(id, i + 1, board_str);
            }
            else {
                UpdateBoardText(id, i + 1, "\r");
            }
        }
    }
    return 1;
}

forward SetBoardText(id, line, str[]);
static SetBoardText(id, line, str[]) {
    if(Iter_Contains(Iter_Board, id) && line >= 0 && line <= 5) {
        SetDynamicObjectMaterialText(boardData[id][bLineText][line], 0, str, 140, "Calibri", line==0 ? SIZE_HEADER : SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);
        switch(line) {
            case 0: format(boardData[id][bText1], 64, str);
            case 1: format(boardData[id][bText2], 64, str);
            case 2: format(boardData[id][bText3], 64, str);
            case 3: format(boardData[id][bText4], 64, str);
            case 4: format(boardData[id][bText5], 64, str);
            case 5: format(boardData[id][bText6], 64, str);
        }
    }
}

forward UpdateBoardText(id, line, update_string[]);
public UpdateBoardText(id, line, update_string[]) {
    if(Iter_Contains(Iter_Board, id) && line >= 0 && line <= 5) {
        SetDynamicObjectMaterialText(boardData[id][bLineText][line], 0, update_string, 140, "Calibri", line==0 ? SIZE_HEADER : SIZE_TEXT, 1, 0xFFFFFFFF, 0, 0);
    }
}

forward RefreashBoard(id);
public RefreashBoard(id) {
    if(Iter_Contains(Iter_Board, id)  && boardData[id][boardType] == BOARD_TYPE_RANKING) {

        new str[128];
        UpdateBoardText(id, 0, "การตั้งค่า");

        UpdateBoardText(id, 1, "พิมพ์ {ffff00}/settingboard{ffffff} เพื่อตั้งค่า");

        if(strlen(boardData[id][boardInfo])) format(str, 128, "ชื่ออันดับ [{228B22}%s{ffffff}]", boardData[id][boardInfo]);
        else format(str, 128, "ชื่ออันดับ [{ff0000}X{ffffff}]");
        UpdateBoardText(id, 2, str);

        if(strlen(boardData[id][bFieldName])) format(str, 128, "ชื่อฟิลด์ [{228B22}%s{ffffff}]", boardData[id][bFieldName]);
        else format(str, 128, "ชื่อฟิลด์ [{ff0000}X{ffffff}]");
        UpdateBoardText(id, 3, str);

        if(boardData[id][bMaxPlayer]) format(str, 128, "จำนวนผู้เล่นสูงสุด [{228B22}%d{ffffff}]", boardData[id][bMaxPlayer]);
        else format(str, 128, "จำนวนผู้เล่นสูงสุด [{ff0000}X{ffffff}]");
        UpdateBoardText(id, 4, str);

        if(strlen(boardData[id][boardInfo]) && strlen(boardData[id][bFieldName]) && boardData[id][bMaxPlayer]) {
            UpdateBoardText(id, 5, "กำลังอัพเดทข้อมูลโปรดรอสักครู่...");
        }
        else UpdateBoardText(id, 5, "========================");
    }
    else {
        UpdateBoardText(id, 0, boardData[id][bText1]);
        UpdateBoardText(id, 1, boardData[id][bText2]);
        UpdateBoardText(id, 2, boardData[id][bText3]);
        UpdateBoardText(id, 3, boardData[id][bText4]);
        UpdateBoardText(id, 4, boardData[id][bText5]);
        UpdateBoardText(id, 5, boardData[id][bText6]);
    }
    return 1;
}

GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);

	if (GetPlayerVehicleID(playerid)) {
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	else GetPlayerFacingAngle(playerid, a);

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

Board_Save(id=-1) {
    if(Iter_Contains(Iter_Board, id)) {
        new query[512];
        format(query, sizeof(query), "UPDATE `board_sys` SET `boardX`=%f,`boardY`=%f,`boardZ`=%f,`boardA`=%f,`boardField`='%s',`boardInfo`='%s',`boardType`=%d,`boardMaxPlayer`=%d,`boardText1`='%s',`boardText2`='%s',`boardText3`='%s',`boardText4`='%s',`boardText5`='%s',`boardText6`='%s' WHERE `boardId`=%d",
			boardData[id][bX],
            boardData[id][bY],
            boardData[id][bZ],
            boardData[id][bA],
            boardData[id][bFieldName],
            boardData[id][boardInfo],
            boardData[id][boardType],
            boardData[id][bMaxPlayer],
            boardData[id][bText1],
            boardData[id][bText2],
            boardData[id][bText3],
            boardData[id][bText4],
            boardData[id][bText5],
            boardData[id][bText6],
            boardData[id][boardID]
		);
		return mysql_tquery(dbCon, query);
    }
    return false;
}

forward Board_Load();
public Board_Load() {

    new
	    rows;

	cache_get_row_count(rows);

	for (new i = 0; i < rows; i ++) if (i < MAX_BOARD_RANK)
	{
        cache_get_value_name_int(i, "boardId", boardData[i][boardID]);
        cache_get_value_name_float(i, "boardX", boardData[i][bX]);
        cache_get_value_name_float(i, "boardY", boardData[i][bY]);
        cache_get_value_name_float(i, "boardZ", boardData[i][bZ]);
        cache_get_value_name_float(i, "boardA", boardData[i][bA]);
        cache_get_value_name(i, "boardField", boardData[i][bFieldName], 32);
        cache_get_value_name(i, "boardInfo", boardData[i][boardInfo], 32);
        cache_get_value_name_int(i, "boardType", boardData[i][boardType]);
        cache_get_value_name_int(i, "boardMaxPlayer", boardData[i][bMaxPlayer]);
        cache_get_value_name(i, "boardText1", boardData[i][bText1], 64);
        cache_get_value_name(i, "boardText2", boardData[i][bText2], 64);
        cache_get_value_name(i, "boardText3", boardData[i][bText3], 64);
        cache_get_value_name(i, "boardText4", boardData[i][bText4], 64);
        cache_get_value_name(i, "boardText5", boardData[i][bText5], 64);
        cache_get_value_name(i, "boardText6", boardData[i][bText6], 64);

        CreateBoard(i, boardData[i][bX], boardData[i][bY], boardData[i][bZ], boardData[i][bA]);
	}

    printf("Board loaded (%d/%d)", Iter_Count(Iter_Board), MAX_BOARD_RANK);
	return 1;
}
