data:extend({
	{
		name = "vanilla-fluid-fuel-values",
		type = "bool-setting",
		setting_type = "startup",
		default_value = true,
		order = "a"
	},
	{
		name = "recycle-previous-tiers",
		type = "bool-setting",
		setting_type = "startup",
		default_value = true,
		order = "ab"
	},
	{
		name = "generator-tiers",
		type = "string-setting",
		setting_type = "startup",
		default_value = "3",
		allowed_values = {"1","2","3","4","5","6"},
		order = "b"
	},
	{
		name = "generator-power",
		type = "double-setting",
		setting_type = "startup",
		default_value = 2.4,
		order = "bb"
	},
	{
		name = "color-scheme",
		type = "string-setting",
		setting_type = "startup",
		default_value = "midnightxrush",
		allowed_values = {"midnightxrush","Vanilla","Artisanal_Reskin"},
		order = "c"
	},
	{
		name = "use-tier-icons",
		type = "bool-setting",
		setting_type = "startup",
		default_value = true,
		order = "d"
	},
})