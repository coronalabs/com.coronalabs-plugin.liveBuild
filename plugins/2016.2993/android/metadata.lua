local metadata =
{
	plugin =
	{
		format = 'jar',
		manifest = 
		{
			permissions = {},
			usesPermissions =
			{
				"android.permission.INTERNET",
				"android.permission.WRITE_EXTERNAL_STORAGE",
			},
			usesFeatures = {},
			applicationChildElements =
			{
				-- Array of strings
				[[ 
				   <service android:name="plugin.liveBuild.LauncherService" />
				]],
			},
		},
	},
}

return metadata