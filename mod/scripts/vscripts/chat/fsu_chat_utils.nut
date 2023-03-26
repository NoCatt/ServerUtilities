untyped
globalize_all_functions


/**
 * This file contains chat utility functions.
 */


/**
 * Sends a message as a player effectively impersonating them. Unlike
 * the northstar implementation this also adds tags before their name
 * @param entity entPlayer The player to impersonate
 * @param string strMessage The message to send
 * @param bool bIsTeam Wheter to use team chat
 */
void function FSU_SendMessageAsPlayer( entity entPlayer, string strMessage, bool bIsTeam ) {
	array<string> arrTags

	foreach( var varPlayer in FSU_GetPlayerArray() ) {
		table tabPlayer = expect table( varPlayer )

		if( tabPlayer["UID"] != entPlayer.GetUID() )
			continue

		foreach( var varTag in FSU_GetPlayerTags( tabPlayer ) ) {
			table tabTag = expect table( varTag )

			if( !FSU_DoesSettingExistInTable( tabTag, "Name" ) ) {
				FSU_Error( "Invalid tag entry for player", entPlayer.GetUID(), "!!!" )
				continue
			}

			int iRed = 255
			int iGreen = 255
			int iBlue = 255

			// The reason for the string( * ).tointeger() even though the elements are ints is
			// the squirrel complaining at compile time
			// When compiling tabTag["*"] is a var so we need to cast it to int, but
			// during execution tabTag["*"] is an int and we cant int( int )
			// TODO: Possibly make FSU_GetTable<type> functions for this

			if( FSU_DoesSettingExistInTable( tabTag, "Red" ) )
				iRed = string( tabTag["Red"] ).tointeger()

			if( FSU_DoesSettingExistInTable( tabTag, "Green" ) )
				iGreen = string( tabTag["Green"] ).tointeger()

			if( FSU_DoesSettingExistInTable( tabTag, "Blue" ) )
				iBlue = string( tabTag["Blue"] ).tointeger()


			arrTags.append( format( "%s[%s]", FSU_GetANSICodeFromRGB( iRed, iGreen, iBlue ), string( tabTag["Name"] ) ) )
		}
	}

	foreach( entity player in GetPlayerArray() ) {
		if( bIsTeam && entPlayer.GetTeam() != player.GetTeam() )
			continue

		string message

		foreach( string strTag in arrTags )
			message += strTag

		message += ( entPlayer.GetTeam() == player.GetTeam() ? "%F" : "%E" ) + entPlayer.GetPlayerName() + ( bIsTeam ? "(Team)" : "" ) + "%0: "
		message = FSU_FormatString( message )
		message += strMessage

		NSBroadcastMessage( -1, player.GetPlayerIndex(), message , true, false, 1 )
	}
}

/**
 * Sends a system message to a player.
 * @param entity entPlayer The player to send the message to
 * @param string strMessage The message to send them
 */
void function FSU_SendSystemMessageToPlayer( entity entPlayer, string strMessage ) {
	string message
	message += "[FSU] "
	message += strMessage
	message = FSU_FormatString( message )
	NSBroadcastMessage( -1, entPlayer.GetPlayerIndex(), message , true, false, 1 )
}