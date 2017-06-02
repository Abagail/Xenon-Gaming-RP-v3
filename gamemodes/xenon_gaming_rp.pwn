#include <a_samp>
#include <a_mysql>
#include <zcmd>
#include <strlib>

#define mysql_host 			 	"localhost"
#define mysql_username			        "root"
#define mysql_password                          "password"
#define mysql_database                          "xenon_gaming_rp"

native WP_Hash(buffer[], len, const str[]);

enum
{
	SpawnState: SpawnStateNone = 0,
	SpawnState: SpawnStateSpawned = 1
};

enum
{
	PlayerDialogLogin = 0,
	PlayerDialogRegister
};

enum p_PlayerData
{
	SpawnState: pSpawnState,
	bool: pLoggedIn,
	pLoginAttempts,
	Cache: pLoginCache,
	
	pPlayerName[MAX_PLAYER_NAME],
	pPlayerIP[32],
	
	pID,
	pPassword[129],
	pPasswordSalt[64],

	pLevel,
	pAdmin,
	pMoney,
	pKills,
	pDeaths,
	pSkinID,
	
	Float: pLastSpawnX,
	Float: pLastSpawnY,
	Float: pLastSpawnZ,
	Float: pLastSpawnA,
	pLastSpawnInt,
	pLastSpawnWorld,
	
	bool: pIsFrozen,
	pCurrentWorld,
	pCurrentInterior
}

new PlayerData[MAX_PLAYERS][p_PlayerData];

new
	Float: gSpawnX,
	Float: gSpawnY,
	Float: gSpawnZ,
	Float: gSpawnA,
	gSpawnInterior,
	gSpawnVW,

	gServerMOTD[80];
	
static
	gSQLConnection;

main() {}

// Misc Functions //
SendLocalClientMessageP(playerid, color, message[], Float: range)
{
	if(!IsPlayerConnected(playerid))
	    return -1;
	    
	new
	    local_count = -1;
	    
	GetPlayerPos(playerid, PlayerData[playerid][pLastSpawnX], PlayerData[playerid][pLastSpawnY], PlayerData[playerid][pLastSpawnZ]);
	for(new i; i <= GetPlayerPoolSize(); i++)
	{
	    if(!IsPlayerConnected(i) || PlayerData[i][pSpawnState] == SpawnState: SpawnStateNone || PlayerData[i][pCurrentWorld] != PlayerData[playerid][pCurrentWorld])
	        continue;
	        
		if(GetPlayerDistanceFromPoint(i, PlayerData[playerid][pLastSpawnX], PlayerData[playerid][pLastSpawnY], PlayerData[playerid][pLastSpawnZ]) <= range)
		{
			SendClientMessage(i, color, message);
			local_count ++;
		}
	}
	
	return local_count;
}

// End of Misc Functions
// SQL Functions //
LoadServerSettings()
{
	mysql_tquery(gSQLConnection, "SELECT SpawnX, SpawnY, SpawnZ, SpawnA, SpawnInterior, SpawnVW, ModeName, ServerMOTD FROM settings", "OnLoadServerSettings", "");
	return true;
}

forward OnLoadServerSettings();
public OnLoadServerSettings()
{
	if(cache_num_rows() == 0)
		return print("[Server]: Failed to load setting row. Reset to default.");
		
	else
	{
		gSpawnX = cache_get_field_content_float(0, "SpawnX");
		gSpawnY = cache_get_field_content_float(0, "SpawnY");
		gSpawnZ = cache_get_field_content_float(0, "SpawnZ");
		gSpawnA = cache_get_field_content_float(0, "SpawnA");
		gSpawnInterior = cache_get_field_content_int(0, "SpawnInterior");
		gSpawnVW = cache_get_field_content_int(0, "SpawnVW");
		
		new tempText[64];
		cache_get_field_content(0, "ModeName", tempText, sizeof tempText);
		cache_get_field_content(0, "ServerMOTD", gServerMOTD, sizeof gServerMOTD);
		
		if(strlen(gServerMOTD))
			strins(gServerMOTD, "Message of the day: ", 0);
			
		SetGameModeText(tempText);
	}
	
	return true;
}

forward OnPlayerConnectSQL(playerid);
public OnPlayerConnectSQL(playerid)
{
	if(cache_num_rows() == 0)
	{
	    ShowPlayerDialog(playerid, PlayerDialogRegister, DIALOG_STYLE_PASSWORD, "Please register.", "Please choose a password and click Register to continue.", "Register", "Logout");
	}
	else
	{
	    if(cache_get_field_content_int(0, "AccountDisabled") || cache_get_field_content_int(0, "AccountBanned"))
	        return Kick(playerid);
	        
		PlayerData[playerid][pLoginCache] = cache_save();
	    PlayerData[playerid][pID] = cache_get_field_content_int(0, "AccountID");
	    cache_get_field_content(0, "AccountPassword", PlayerData[playerid][pPassword], gSQLConnection, 129);
		ShowPlayerDialog(playerid, PlayerDialogLogin, DIALOG_STYLE_PASSWORD, "Please login.", "Please confirm your password and click Login.", "Login", "Logout");
	}
	
	return true;
}

forward OnPlayerRegisterSQL(playerid);
public OnPlayerRegisterSQL(playerid)
{
	if(cache_affected_rows() == 0)
	    return Kick(playerid);
	    
	PlayerData[playerid][pID] = cache_insert_id();
	PlayerData[playerid][pLevel] = 1;
	PlayerData[playerid][pAdmin] = 0;
	PlayerData[playerid][pMoney] = 250;
	PlayerData[playerid][pKills] = 0;
	PlayerData[playerid][pDeaths] = 0;
	PlayerData[playerid][pSkinID] = 299;
	
	PlayerData[playerid][pLastSpawnX] = gSpawnX;
	PlayerData[playerid][pLastSpawnY] = gSpawnY;
	PlayerData[playerid][pLastSpawnZ] = gSpawnZ;
	PlayerData[playerid][pLastSpawnInt] = gSpawnInterior;
	PlayerData[playerid][pLastSpawnWorld] = gSpawnVW;
	
	PlayerData[playerid][pLoggedIn] = true;
	SpawnPlayer(playerid);
	
	SendClientMessage(playerid, -1, "Logged in.");
	
	if(!isnull(gServerMOTD))
		SendClientMessage(playerid, -1, gServerMOTD);
		
	return true;
}

// End of SQL Functions
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(strcmp(inputtext, "\\", true) == 0)
	    return true;
	    
	else
	{
	    if(dialogid == PlayerDialogLogin)
	    {
	        if(!response)
	            return Kick(playerid);

			// strcat(inputtext, PlayerData[playerid][pPasswordSalt]);
			WP_Hash(inputtext, 129, inputtext);
			if(!isnull(inputtext) && strcmp(inputtext, PlayerData[playerid][pPassword], false) == 0)
			{
				if(cache_is_valid(PlayerData[playerid][pLoginCache], gSQLConnection))
				{
					cache_set_active(PlayerData[playerid][pLoginCache]);
					PlayerData[playerid][pLevel] = cache_get_field_content_int(0, "AccountLevel");
					PlayerData[playerid][pAdmin] = cache_get_field_content_int(0, "AccountAdmin");
					PlayerData[playerid][pMoney] = cache_get_field_content_int(0, "AccountMoney");
					PlayerData[playerid][pKills] = cache_get_field_content_int(0, "AccountKills");
					PlayerData[playerid][pDeaths] = cache_get_field_content_int(0, "AccountDeaths");
					PlayerData[playerid][pSkinID] = cache_get_field_content_int(0, "AccountSkin");
					
					PlayerData[playerid][pLastSpawnX] = cache_get_field_content_float(0, "AccountSpawnX");
					PlayerData[playerid][pLastSpawnY] = cache_get_field_content_float(0, "AccountSpawnY");
					PlayerData[playerid][pLastSpawnZ] = cache_get_field_content_float(0, "AccountSpawnZ");
					PlayerData[playerid][pLastSpawnA] = cache_get_field_content_float(0, "AccountSpawnA");
					PlayerData[playerid][pLastSpawnInt] = cache_get_field_content_int(0, "AccountSpawnInt");
					PlayerData[playerid][pLastSpawnWorld] = cache_get_field_content_int(0, "AccountSpawnWorld");
					
					TogglePlayerSpectating(playerid, false);
					PlayerData[playerid][pLoggedIn] = true;

					SpawnPlayer(playerid);
					cache_delete(PlayerData[playerid][pLoginCache]);
					
					SendClientMessage(playerid, -1, (PlayerData[playerid][pAdmin]) ? ("Logged in as an admin.") : ("Logged in"));

					if(!isnull(gServerMOTD))
						SendClientMessage(playerid, -1, gServerMOTD);
				}

				else return Kick(playerid);
			}
			else
			{
			    PlayerData[playerid][pLoginAttempts]++;
				if(PlayerData[playerid][pLoginAttempts] >= 3)
					return Kick(playerid);
					
				else
					return ShowPlayerDialog(playerid, PlayerDialogLogin, DIALOG_STYLE_PASSWORD, "Please login.", "Please confirm your password and click Login.", "Login", "Logout");
			}
		}
		
		else if(dialogid == PlayerDialogRegister)
		{
		    if(!response)
		        return Kick(playerid);
		        
			if(strlen(inputtext) < 6 || strlen(inputtext) >= 32)
			    return ShowPlayerDialog(playerid, PlayerDialogRegister, DIALOG_STYLE_PASSWORD, "Please register.", "Please choose a password and click Register to continue.\nPassword can not be shorter than 6 characters or longer than 32.", "Register", "Logout");
        		
			WP_Hash(PlayerData[playerid][pPassword], 129, inputtext);
			
			new local_query[500];
			mysql_format(gSQLConnection, local_query, sizeof local_query, "INSERT INTO users (AccountName, AccountPassword, AccountIP, AccountSpawnX, AccountSpawnY, AccountSpawnZ, AccountSpawnA, AccountSpawnInt, AccountSpawnWorld) VALUES ('%e', '%e', '%e', %f, %f, %f, %f, %i, %i)", PlayerData[playerid][pPlayerName], PlayerData[playerid][pPassword], PlayerData[playerid][pPlayerIP], gSpawnX, gSpawnY, gSpawnZ, gSpawnA, gSpawnInterior, gSpawnVW);
			mysql_tquery(gSQLConnection, local_query, "OnPlayerRegisterSQL", "i", playerid);
		}
	}
	
	return 0;
}
				
				
public OnGameModeInit()
{
	gSQLConnection = mysql_connect(mysql_host, mysql_username, mysql_database, mysql_password);
	if(mysql_errno(gSQLConnection) == 0)
	    print("[Server]: Database connection successful.");
	    
	else
	{
	    print("[Server]: Database connection failed.");
	    return SendRconCommand("exit");
	}
	
	ManualVehicleEngineAndLights();
	LoadServerSettings();
	return true;
}

public OnGameModeExit()
{
	for(new i; i <= GetPlayerPoolSize(); i++)
	{
	    if(IsPlayerConnected(i) && cache_is_valid(PlayerData[i][pLoginCache]))
			cache_delete(PlayerData[i][pLoginCache]);
	}
	
	mysql_close(gSQLConnection);
	return true;
}

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid))
	{
	    GetPlayerName(playerid, PlayerData[playerid][pPlayerName], MAX_PLAYER_NAME);
	    GetPlayerIp(playerid, PlayerData[playerid][pPlayerIP], 32);
	    
	    if(strcmp(PlayerData[playerid][pPlayerIP], "127.0.0.1", true) != 0)
	    {
	        printf("[Server]: External NPC kicked (ID: %d, Name: %s, IP: %s).", playerid, PlayerData[playerid][pPlayerName], PlayerData[playerid][pPlayerIP]);
	        return Kick(playerid);
	    }
		
	    SetSpawnInfo(playerid, NO_TEAM, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	    return true;
	}
		
    SetSpawnInfo(playerid, NO_TEAM, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
    PlayerData[playerid][pSpawnState] = SpawnState: SpawnStateNone;

	PlayerData[playerid][pLoggedIn] = false;
	TogglePlayerSpectating(playerid, true);
	
	GetPlayerName(playerid, PlayerData[playerid][pPlayerName], MAX_PLAYER_NAME);
	GetPlayerIp(playerid, PlayerData[playerid][pPlayerIP], 32);
	
	new local_query[128];
	// mysql_format(gSQLConnection, local_query, sizeof local_query, "SELECT AccountID, AccountPassword, AccountDisabled, AccountBanned, * FROM users WHERE AccountName = '%e'", PlayerData[playerid][pPlayerName]);
	mysql_format(gSQLConnection, local_query, sizeof local_query, "SELECT * FROM users WHERE AccountName = '%e'", PlayerData[playerid][pPlayerName]);
	mysql_tquery(gSQLConnection, local_query, "OnPlayerConnectSQL", "i", playerid);
	
	return true;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(PlayerData[playerid][pLoggedIn] == false)
	{
	    if(cache_is_valid(PlayerData[playerid][pLoginCache]))
	        cache_delete(PlayerData[playerid][pLoginCache]);
	}
	
	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
     SpawnPlayer(playerid);
     return true;
}

public OnPlayerSpawn(playerid)
{
	if(PlayerData[playerid][pLoggedIn] == false)
	    return Kick(playerid);

	TogglePlayerSpectating(playerid, false);
	SetPlayerSkin(playerid, PlayerData[playerid][pSkinID]);
	SetPlayerScore(playerid, PlayerData[playerid][pLevel]);
	
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);
	
	if(PlayerData[playerid][pSpawnState] == SpawnState: SpawnStateNone)
	{
	    SetPlayerPos(playerid, PlayerData[playerid][pLastSpawnX], PlayerData[playerid][pLastSpawnY], PlayerData[playerid][pLastSpawnZ]);
	    SetPlayerFacingAngle(playerid, PlayerData[playerid][pLastSpawnA]);
		SetPlayerVirtualWorld(playerid, PlayerData[playerid][pLastSpawnWorld]);
		SetPlayerInterior(playerid, PlayerData[playerid][pLastSpawnInt]);
		
		PlayerData[playerid][pSpawnState] = SpawnState: SpawnStateSpawned;
	}
	
	return true;
}

public OnPlayerText(playerid, text[])
{
	new
	    local_message[128];
	    
	format(local_message, sizeof local_message, "%s says: %s", str_replace("_", " ", PlayerData[playerid][pPlayerName]), text);
	SendLocalClientMessageP(playerid, -1, local_message, 10.0);
	
	if(!IsPlayerInAnyVehicle(playerid))
        ApplyAnimation(playerid, "PED", "IDLE_CHAT", 4.0, 1, 0, 0, 1, 1),
        SetTimerEx("ClearPlayerAnimations", 1500, false, "i", playerid);
	
	return false;
}

// Start of Timer Functions //
forward ClearPlayerAnimations(playerid);
public ClearPlayerAnimations(playerid)
{
	ClearAnimations(playerid);
 	ApplyAnimation(playerid, "CARRY", "crry_prtial", 1.0, 0, 0, 0, 0, 0);
 	
 	return true;
}
// End of Timer Functions
