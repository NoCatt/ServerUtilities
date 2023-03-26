global function FSU_MapLoadCallback

/**
 * Entry point for the entirety of FSU3.
 *
 * The goal of this major release is to allow server hosters
 * to be able to edit settings in real time, see their changes
 * take effect instantly and most importantly have the changes
 * persist between Server VM reloads. Most of this is achieved
 * using custom callbacks and JSON I/O. The second big goal is
 * graceful error handling, if it fails move on, we dont want
 * the server to have to restart due to a script error.
 */


/**
 * Gets called by native after the map is loaded.
 * We use cutom init callbacks so we have full control over them.
 */
void function FSU_MapLoadCallback() {
	thread FSU_RegisterModules_Threaded()
}

/**
 * Had to thread this so we can wait for settings to be loaded as
 * basically all other modules depend on them.
 */
void function FSU_RegisterModules_Threaded() {
	FSU_RegisterModule( FSU_RegisterSettingsModule )

	// Wait for settings to properly init before doing anything else
	while( !FSU_SettingsAreLoaded() ) { WaitFrame() }

	FSU_RegisterModule( FSU_RegisterChatHookModule )
	FSU_RegisterModule( FSU_RegisterCoreCommandsModule )

	FSU_GetSettingsTable()

	// Callbacks
	FSU_ReloadRegisteredCommands()
}

/**
 * Calls the module register func and logs the module
 * @param module The module register function
 */
void function FSU_RegisterModule( string functionref() module ) {
	FSU_Print( "Registering module:", module() )
}