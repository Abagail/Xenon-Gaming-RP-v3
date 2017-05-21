#if !defined _samp_included
	#error "a_samp.inc must be loaded before the include"
#endif

#if defined _dialogfunc_included
	#endinput
#else
	#define _dialogfunc_included
#endif

/* hooks
		ShowPlayerDialog,
		OnDialogResponse,
		OnPlayerConnect
		
// functions
		bool: IsPlayerDialogOpen(playerid)
		
		GetPlayerDialogID(playerid)
		GetPlayerDialogIDEx(playerid, &dialogid)
		GetPlayerDialogStyle(playerid)
		GetPlayerDialogStyleEx(playerid, &dialogstyle)
		GetPlayerDialogCaption(playerid)
		GetPlayerDialogCaptionEx(playerid, &dialogcaption[64])
		GetPlayerDialogText(playerid)
		GetPlayerDialogTextEx(playerid, &dialogtext[64])
		GetPlayerDialogButton1(playerid)
		GetPlayerDialogButton1Ex(playerid, &dialogbutton[64])
		GetPlayerDialogButton2(playerid)
		GetPlayerDialogButton2Ex(playerid, &dialogbutton[64])
		GetPlayerDialogOpenTime(playerid)
		GetPlayerDialogOpenTimeEx(playerid, &dialogopentime)
		
		ClosePlayerDialog(playerid)
		ResetPlayerDialog(playerid)
*/

// To preface, this is NOT a dialog management script, but rather a script with additional functionality.

// Things you can do:
	// Detect if a player has any dialog open,
	/* Get the ID of the players active dialog, get the style, caption, info text, button texts.
	Get the timestamp of when the dialog was shown for the player.
	Protect against dialog ID spoofing.
	*/
	

#define ClosePlayerDialog ResetPlayerDialog

#if defined _ALS_ShowPlayerDialog
  #undef ShowPlayerDialog
#else
#define _ALS_ShowPlayerDialog
#endif

#define ShowPlayerDialog ShowPlayerDialogEx

#if defined _ALS_OnPlayerConnect
  #undef OnPlayerConnect
#else
#define _ALS_OnPlayerConnect
#endif 
#define OnPlayerConnect Dialog_OnPlayerConnect

#if defined _ALS_OnDialogResponse
  #undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse Dialog_OnDialogResponse

forward Dialog_OnPlayerConnect(playerid);
forward Dialog_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
// ================= [Variables] ====================
enum p_DialogData {
	bool: pIsDialogOpen,
	pDialogID,
	pDialogStyle,
	pDialogCaption[64],
	pDialogText[64],
	pDialogButton1[64],
	pDialogButton2[64],
	pDialogOpenTime
};

static
	p_pDialogData[MAX_PLAYERS][p_DialogData];

public OnPlayerConnect(playerid)
{
	ResetPlayerDialog(playerid);
	return Dialog_OnPlayerConnect(playerid);
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(p_pDialogData[playerid][pDialogID] != dialogid) // anti-spoof protection
	    return false;

	// Logic: Call native dialog response. If dialog ID changed, another dialog was shown. Otherwise, reset dialog information.
	Dialog_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	if(GetPlayerDialogID(playerid) != dialogid)
		return true;
	else
		ResetPlayerDialog(playerid);

	return true;
}

static strcpy(dest[], const source[], maxlength=sizeof dest)
{
	strcat((dest[0] = EOS, dest), source, maxlength);
}

ShowPlayerDialogEx(playerid, dialogid, style, caption[64], info[64], button1[64], button2[64])
{
	if(p_pDialogData[playerid][pIsDialogOpen] == true)
	    ResetPlayerDialog(playerid);

	if(ShowPlayerDialog(playerid, dialogid, style, caption, info, button1, button2) == 1)
	{
	    p_pDialogData[playerid][pIsDialogOpen] = true;
	    p_pDialogData[playerid][pDialogID] = dialogid;
	    p_pDialogData[playerid][pDialogStyle] = style;
	    
        /*memcpy(p_pDialogData[playerid][pDialogCaption], caption, strlen(p_pDialogData[playerid][pDialogCaption]) * 4, sizeof caption * 4, 64);
        memcpy(p_pDialogData[playerid][pDialogText], info, strlen(p_pDialogData[playerid][pDialogText]) * 4, sizeof info * 4, 64);
        memcpy(p_pDialogData[playerid][pDialogButton1], button1, strlen(p_pDialogData[playerid][pDialogButton1]) * 4, sizeof button1 * 4, 64);
        memcpy(p_pDialogData[playerid][pDialogButton2], button2, strlen(p_pDialogData[playerid][pDialogButton2]) * 4, sizeof button2 * 4, 64); */
		
		*/ strcpy(p_pDialogData[playerid][pDialogCaption], caption, strlen(caption));
		strcpy(p_pDialogData[playerid][pDialogText], info, strlen(info));
		strcpy(p_pDialogData[playerid][pDialogButton1], button1, strlen(button1));
		strcpy(p_pDialogData[playerid][pDialogButton2], button2, strlen(button2)); /*

		return 1;
	}
	
	else
	    return 0;
}

// ============ [Functions] ==========
stock bool: IsPlayerDialogOpen(playerid)
	return p_pDialogData[playerid][pIsDialogOpen];

stock GetPlayerDialogID(playerid)
	return p_pDialogData[playerid][pDialogID];
	
stock GetPlayerDialogIDEx(playerid, &dialogid) {
	dialogid = p_pDialogData[playerid][pDialogID];
	return 1;
}

stock GetPlayerDialogStyle(playerid)
	return p_pDialogData[playerid][pDialogStyle];
	
stock GetPlayerDialogStyleEx(playerid, &dialogstyle) {
	dialogstyle = p_pDialogData[playerid][pDialogStyle];
	return 1;
}
	
stock GetPlayerDialogCaption(playerid)
    return p_pDialogData[playerid][pDialogCaption];

stock GetPlayerDialogCaptionEx(playerid, dialogcaption[64])
{
	memcpy(dialogcaption, p_pDialogData[playerid][pDialogCaption], 64, 64 * 4, 64);
	return 1;
}

stock GetPlayerDialogText(playerid)
    return p_pDialogData[playerid][pDialogText];

stock GetPlayerDialogTextEx(playerid, dialogtext[64])
{
	memcpy(dialogtext, p_pDialogData[playerid][pDialogText], 64, 64 * 4, 64);
	return 1;
}

stock GetPlayerDialogButton1(playerid)
    return p_pDialogData[playerid][pDialogButton1];
    
stock GetPlayerDialogButton1Ex(playerid, dialogbutton[64])
{
	memcpy(dialogbutton, p_pDialogData[playerid][pDialogButton1], 64, 64 * 4, 64);
	return 1;
}
    
stock GetPlayerDialogButton2(playerid)
	return p_pDialogData[playerid][pDialogButton2];
	
stock GetPlayerDialogButton2Ex(playerid, dialogbutton[64])
{
	memcpy(dialogbutton, p_pDialogData[playerid][pDialogButton2], 64, 64 * 4, 64);
	return 1;
}

stock GetPlayerDialogOpenTime(playerid)
    return p_pDialogData[playerid][pDialogOpenTime];

stock ResetPlayerDialog(playerid)
{
	if(IsPlayerDialogOpen(playerid) == true)
	{
		ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "", "", "", "");
	}
	
	p_pDialogData[playerid][pIsDialogOpen] = false;
	p_pDialogData[playerid][pDialogID] = -1;
	p_pDialogData[playerid][pDialogStyle] = -1;
	
	p_pDialogData[playerid][pDialogCaption][0] = '/';
	p_pDialogData[playerid][pDialogText][0] = '/';
	p_pDialogData[playerid][pDialogButton1][0] = '/';
	p_pDialogData[playerid][pDialogButton2][0] = '/';

	p_pDialogData[playerid][pDialogOpenTime] = 0;
	return 1;
}
