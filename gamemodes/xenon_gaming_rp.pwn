#include <a_samp>
#include <a_mysql>
#include <zcmd>

#define mysql_host 			 	"localhost"
#define mysql_username			"root"
#define mysql_password          "password"
#define mysql_database          "xenon_gaming_rp"

native WP_Hash(buffer[], len, const str[]);

enum
{
	PlayerDialogLogin = 0,
	PlayerDialogRegister
};

enum p_PlayerData
{
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
	
	bool: pIsFrozen
}

new PlayerData[MAX_PLAYERS][p_PlayerData];

new
	Float: SpawnX,
	Float: SpawnY,
	Float: SpawnZ,
	Float: SpawnA,
	SpawnInterior,
	SpawnVW,
	
	gSQLConnection;

main() {}

// SQL Functions //
LoadServerSettings()
{
	mysql_tquery(gSQLConnection, "SELECT SpawnX, SpawnY, SpawnZ, SpawnA, SpawnInterior, SpawnVW, ModeName FROM settings", "OnLoadServerSettings", "");
	return true;
}

forward OnLoadServerSettings();
public OnLoadServerSettings()
{
	if(cache_num_rows() == 0)
		return print("[Server]: Failed to load setting row. Reset to default.");
		
	else
	{
		SpawnX = cache_get_field_content_float(0, "SpawnX");
		SpawnY = cache_get_field_content_float(0, "SpawnY");
		SpawnZ = cache_get_field_content_float(0, "SpawnZ");
		SpawnA = cache_get_field_content_float(0, "SpawnA");
		SpawnInterior = cache_get_field_content_int(0, "SpawnInterior");
		SpawnVW = cache_get_field_content_int(0, "SpawnVW");
		
		new tempText[64];
		cache_get_field_content(0, "ModeName", tempText, sizeof tempText);
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
	
	PlayerData[playerid][pLastSpawnX] = SpawnX;
	PlayerData[playerid][pLastSpawnY] = SpawnY;
	PlayerData[playerid][pLastSpawnZ] = SpawnZ;
	PlayerData[playerid][pLastSpawnInt] = SpawnInterior;
	PlayerData[playerid][pLastSpawnWorld] = SpawnVW;
	
	PlayerData[playerid][pLoggedIn] = true;
	SetSpawnInfo(playerid, NO_TEAM, PlayerData[playerid][pSkinID], PlayerData[playerid][pLastSpawnX], PlayerData[playerid][pLastSpawnY], PlayerData[playerid][pLastSpawnZ], PlayerData[playerid][pLastSpawnA], 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	SetPlayerInterior(playerid, PlayerData[playerid][pLastSpawnInt]);
	SetPlayerVirtualWorld(playerid, PlayerData[playerid][pLastSpawnWorld]);
	SendClientMessage(playerid, -1, "Logged in.");
	
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
					
					SetSpawnInfo(playerid, NO_TEAM, PlayerData[playerid][pSkinID], PlayerData[playerid][pLastSpawnX], PlayerData[playerid][pLastSpawnY], PlayerData[playerid][pLastSpawnZ], PlayerData[playerid][pLastSpawnA], 0, 0, 0, 0, 0, 0);
					SpawnPlayer(playerid);
					
					SetPlayerInterior(playerid, PlayerData[playerid][pLastSpawnInt]);
					SetPlayerVirtualWorld(playerid, PlayerData[playerid][pLastSpawnWorld]);
					
					SetPlayerScore(playerid, PlayerData[playerid][pLevel]);
					GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);
					SendClientMessage(playerid, -1, "Logged in.");
					cache_delete(PlayerData[playerid][pLoginCache]);
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
			mysql_format(gSQLConnection, local_query, sizeof local_query, "INSERT INTO users (AccountName, AccountPassword, AccountIP, AccountSpawnX, AccountSpawnY, AccountSpawnZ, AccountSpawnA, AccountSpawnInt, AccountSpawnWorld) VALUES ('%e', '%e', '%e', %f, %f, %f, %f, %i, %i)", PlayerData[playerid][pPlayerName], PlayerData[playerid][pPassword], PlayerData[playerid][pPlayerIP], SpawnX, SpawnY, SpawnZ, SpawnA, SpawnInterior, SpawnVW);
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

public OnPlayerSpawn(playerid)
{
	if(PlayerData[playerid][pLoggedIn] == false)
	    return Kick(playerid);

	TogglePlayerSpectating(playerid, false);
	SetPlayerSkin(playerid, PlayerData[playerid][pSkinID]);
	SetPlayerScore(playerid, PlayerData[playerid][pLevel]);
	return true;
}
