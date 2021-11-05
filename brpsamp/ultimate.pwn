#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 50

#define CGEN_MEMORY 30000

#include <YSI_Coding\y_hooks>
#include <Pawn.CMD>
#include <sscanf2>

#define USE_COLANDREAS
#define USE_STREAMER_PLUGIN
#define USE_FOREACH

#if defined USE_COLANDREAS
	#tryinclude <colandreas>
#endif
#if defined USE_STREAMER_PLUGIN
	#include <streamer>
#endif

#if defined _streamer_included
	#define MAX_UC_OBJECTS			4096
	#define MAX_UC_ACTORS			4096
	#define MAX_UC_PICKUPS			4096
	#define MAX_UC_MAPICONS			512
	#define MAX_UC_3DTEXT_GLOBAL	4096
	#define MAX_UC_REMOVED_OBJECTS	1000
#else
	#define MAX_UC_OBJECTS			MAX_OBJECTS
	#define MAX_UC_ACTORS			MAX_ACTORS
	#define MAX_UC_PICKUPS			MAX_PICKUPS
	#define MAX_UC_MAPICONS			100
	#define MAX_UC_3DTEXT_GLOBAL	MAX_3DTEXT_GLOBAL
	#define MAX_UC_REMOVED_OBJECTS	1000
#endif

#if defined USE_FOREACH
	#tryinclude <YSI_Data\y_iterate>
	#if !defined foreach
		#tryinclude <foreach>
	#endif
#endif

#include <creator.pwn>
// #include <actors.pwn>

public OnPlayerConnect(playerid) {
    GameTextForPlayer(playerid, "~w~Ultimate Creator: ~g~brpsamp ~g~v1.0 fork", 8000, 5);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[128], idx;
	cmd = strtok_main(cmdtext, idx);
	if(!strcmp(cmd, "/weapon", true))
	{
		new tmp[128];
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /weapon [ID оружия] [патроны]");
		new wid = strval(tmp);
		if(wid < 0 || wid > 46) return SendClientMessage(playerid, -1, "0 <= weaponid <= 46!");
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /weapon [ID оружия] [патроны]");
		GivePlayerWeapon(playerid, wid, strval(tmp));
		return 1;
	}
	if(!strcmp(cmd, "/ammo", true))
	{
		new tmp[128];
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /ammo [ID оружия] [патроны]");
		new wid = strval(tmp);
		if(wid < 0 || wid > 46) return SendClientMessage(playerid, -1, "0 <= weaponid <= 46!");
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /ammo [ID оружия] [патроны]");
		SetPlayerAmmo(playerid, wid, strval(tmp));
		return 1;
	}
	if(!strcmp(cmd, "/seat", true))
	{
		new tmp[128];
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /seat [ID транспорта] [место]");
		new vid = strval(tmp);
		if(GetVehicleModel(vid) <= 0) return SendClientMessage(playerid, -1, "Транспорт не существует!");
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /seat [ID транспорта] [место]");
		PutPlayerInVehicle(playerid, vid, strval(tmp));
		return 1;
	}
	if(!strcmp(cmd, "/goto", true))
	{
		new tmp[128];
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /goto [ID игрока]");
		new pid = strval(tmp);
		if(!IsPlayerConnected(pid)) return SendClientMessage(playerid, -1, "Игрок не подключен!");
		new Float:x, Float:y, Float:z;
		GetPlayerPos(pid, x, y, z);
		SetPlayerPos(playerid, x, y, z);
		return 1;
	}
	if(!strcmp(cmd, "/specact", true))
	{
		new tmp[128];
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /specact [ID]");
		SetPlayerSpecialAction(playerid, strval(tmp));
		return 1;
	}
	if(!strcmp(cmd, "/health", true))
	{
		new tmp[128];
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /health [кол-во]");
		SetPlayerHealth(playerid, strval(tmp));
		return 1;
	}
	if(!strcmp(cmd, "/armour", true))
	{
		new tmp[128];
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /armour [кол-во]");
		SetPlayerArmour(playerid, strval(tmp));
		return 1;
	}
	if(!strcmp(cmd, "/skin", true))
	{
		new tmp[128];
		tmp = strtok_main(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, -1, "Используйте: /skin [ID]");
		SetPlayerSkin(playerid, strval(tmp));
		return 1;
	}
	return 0;
}

public OnPlayerSpawn(playerid) {
    SetPlayerInterior(playerid, 0);
    // if(!GetPVarInt(playerid, "ucFirstSpawn"));
    // SetPVarInt(playerid, "ucFirstSpawn", 1);
    if (!GetPVarInt(playerid, "ucFirstSpec")) {
        SendClientMessage(playerid, 0xFF6D7CFF, "Добро пожаловать в модифицированный Ultimate Creator!");
        SendClientMessage(playerid, 0x149C8EFF, "Введите /edit, чтобы войти в режим редактирования");
        SendClientMessage(playerid, 0x149C8EFF, "Используйте Enter, чтобы открыть главное меню");
        SendClientMessage(playerid, 0x149C8EFF, "Вновь введите /edit, чтобы выйти из режима редактирования");
        // SendClientMessage(playerid, 0xFF6D7CFF, "Подключена система актёров, узнать больше – /actorhelp");
    }
    SetPVarInt(playerid, "ucFirstSpec", 1);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
    if (newstate == PLAYER_STATE_SPECTATING) {
        if (!GetPVarInt(playerid, "ucFirstSpec")) {
            SendClientMessage(playerid, 0x149C8EFF, "Введите /edit, чтобы войти в режим редактирования");
            SendClientMessage(playerid, 0x149C8EFF, "Используйте Enter, чтобы открыть главное меню");
            SendClientMessage(playerid, 0x149C8EFF, "Вновь введите /edit, чтобы выйти из режима редактирования");
        }
        SetPVarInt(playerid, "ucFirstSpec", 1);
    }
    return 1;
}

SetupPlayerForClassSelection(playerid) {
    SetPlayerInterior(playerid, 14);
    SetPlayerPos(playerid, 258.4893, -41.4008, 1002.0234);
    SetPlayerFacingAngle(playerid, 270.0);
    SetPlayerCameraPos(playerid, 256.0815, -43.0475, 1004.0234);
    SetPlayerCameraLookAt(playerid, 258.4893, -41.4008, 1002.0234);
}

public OnPlayerRequestClass(playerid, classid) {
    SetupPlayerForClassSelection(playerid);
    return 1;
}

public OnGameModeInit() {
    SetGameModeText("brpsamp");
    AddPlayerClass(200, -1499.8979, 1964.4100, 48.4219, 6.0, 0, 0, 0, 0, -1, -1);
    return 1;
}

strtok_main(const string[], & index) {
    new length = strlen(string);
    while (index < length && string[index] <= ' ') index++;
    new offset = index, result[20];
    while (index < length && string[index] > ' ' && index - offset < sizeof(result) - 1) {
        result[index - offset] = string[index];
        index++;
    }
    result[index - offset] = EOS;
    return result;
}
