--[[
	地图对象
]]

return {
	[{
		mapname = "build_palace",
		mapenvs = {
			region = "region_xuzhou",
			town = "town_xuzhou",
		}
	}] = {
		EVENT = {
			["chest1"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(5,14,1,1),
				script = tools:parseScript("actions.ChestItem>G,10000|10"),
			}
			,["chest2"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(11,14,1,1),
				script = tools:parseScript("actions.ChestItem>I,I70|11"),
			}
			,["chest3"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(5,16,1,1),
				script = tools:parseScript("actions.ChestItem>I,I72|12"),
			}
			,["chest4"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(11,16,1,1),
				script = tools:parseScript("actions.ChestItem>I,I74|13"),
			}
			,["chest5"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(5,18,1,1),
				script = tools:parseScript("actions.ChestItem>I,I75|14"),
			}
			,["chest6"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(11,18,1,1),
				script = tools:parseScript("actions.ChestItem>I,I82,9|15"),
			}
			,["chest7"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(5,20,1,1),
				script = tools:parseScript("actions.ChestItem>I,I83|16"),
			}
			,["chest8"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(11,20,1,1),
				script = tools:parseScript("actions.ChestItem>I,I88,5|17"),
			}
			,["chest9"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(5,22,1,1),
				script = tools:parseScript("actions.ChestItem>I,I76,9|18"),
			}
			,["chest10"] = {
				trigger = "RESEARCH",
				tmxbounds = cc.rect(11,22,1,1),
				script = tools:parseScript("actions.ChestItem>I,I77,9|19"),
			}
		},
		NPC = {
			["xiandi"] = {
				id = "C239",
				tmxbounds = cc.rect(8,5,1,1),
				talk = tools:parseScript("actions.Dialogue>DM_WLC"),
			}
		}
	},
	[{
		mapname = "town_xuzhou",
		mapenvs = {
			region = "region_xuzhou",
		}
	}] = {
		NPC = {
			["caocao"] = {
				id = "C68",
				tmxbounds = cc.rect(28,33,1,1),
				talk = tools:parseScript("actions.Dialogue>DM_BATTLE||plays.DemoBattle"),
			}
		}
	}
}