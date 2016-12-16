
--[[
 _   _                       _          
| | | |                     (_)         
| | | | __ _ _ __ ___  _ __  _ _ __ ___ 
| | | |/ _` | '_ ` _ \| '_ \| | '__/ _ \
\ \_/ / (_| | | | | | | |_) | | | |  __/
 \___/ \__,_|_| |_| |_| .__/|_|_|  \___|
                      | |               
                      |_|               
  ___                                      _     _             
 / _ \                                    | |   | |            
/ /_\ \_ __ _ __ ___   __ _  __ _  ___  __| | __| | ___  _ __  
|  _  | '__| '_ ` _ \ / _` |/ _` |/ _ \/ _` |/ _` |/ _ \| '_ \ 
| | | | |  | | | | | | (_| | (_| |  __/ (_| | (_| | (_) | | | |
\_| |_/_|  |_| |_| |_|\__,_|\__, |\___|\__,_|\__,_|\___/|_| |_|
                             __/ |                             
                            |___/                  
							        							
--]]


if myHero.charName ~= "Vladimir" then return end

local bloodFury
local follow
local ts
local eStarted
local eStartedTime

function OnLoad()

	PrintChat("<font color=\"#61EE2E\" >Armageddon Vampire [BETA]</font>")
	ts = TargetSelector(TARGET_LESS_CAST,2050)
	Menu()
end

function OnTick()

	if myHero.dead then return end
	
		ts:update()
	
	if ts.target ~= nil then
		
		Combo(ts.target)
		KillSteal()
		LastBreath()
	end
end

function OnDraw()

    if myHero.dead or not Param.Draw.eDraw then return end
		
	if Param.Draw.Range then
		DrawCircle3D(myHero.x,myHero.y,myHero.z,900,2,ARGB(255,0,0,0))
		DrawCircle3D(myHero.x,myHero.y,myHero.z,600,2,ARGB(255,0,0,0))
	end
		
	if ts.target ~= nil then
		
		if Param.Draw.Damage then
	
			DrawText3D("" .. GetDamage(ts.target),ts.target.x,ts.target.y,ts.target.z,12,ARGB(255,255,0,0))		
			DrawText3D("" .. GetEDamageTimed(ts.target),ts.target.x,ts.target.y + 100,ts.target.z,12,ARGB(255,255,255,255))		
		end
		
		if Param.Draw.Potential then
	
			DrawkillPotential(GetDamage(ts.target))
		end		
	end
end

function DrawkillPotential(damage)


	for i, Target in pairs(GetEnemyHeroes()) do
	
		if Target.dead then else 
			if(damage >= Target.health) then

				DrawCircle3D(Target.x,Target.y,Target.z,150,3,ARGB(255,255,0,0))

			elseif damage * 1.2 >= Target.health then

				DrawCircle3D(Target.x,Target.y,Target.z,150,3,ARGB(255,0,255,0))

			elseif damage * 1.5 >= Target.health then

				DrawCircle3D(Target.x,Target.y,Target.z,150,3,ARGB(255,0,255,255))
			end
	end
end
end

function Menu()

	Param = scriptConfig("Vladimir", "Config");

	Param:addSubMenu("Keys", "Key");
		Param.Key:addParam("hkey", "Harass", SCRIPT_PARAM_ONKEYDOWN, false,32);
		Param.Key:addParam("ckey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false,17);
	
	Param:addSubMenu("Setup", "Setup");
		Param.Setup:addParam("flashkill", "FlashKillSteal", SCRIPT_PARAM_ONOFF, true);
		Param.Setup:addParam("breathon", "LastBreath", SCRIPT_PARAM_ONOFF, true);
		Param.Setup:addParam("breath", "LastBreathTreshhold %", SCRIPT_PARAM_SLICE,5.0,1.0,100.0,1.0);
		
	Param:addSubMenu("Draws", "Draw");
		Param.Draw:addParam("eDraw", "Enable", SCRIPT_PARAM_ONOFF, true);
        Param.Draw:addParam("Damage", "Damage", SCRIPT_PARAM_ONOFF, true);
        Param.Draw:addParam("Potential", "Kill", SCRIPT_PARAM_ONOFF, true);
		Param.Draw:addParam("Range", "Range", SCRIPT_PARAM_ONOFF, true);

end

function LastBreath()

	if Param.Setup.breathon and myHero.health <= myHero.maxHealth * (Param.Setup.breath / 100) then
	
		for i, enemy in pairs(GetEnemyHeroes()) do
	
			if InRange(enemy,600) then
		
				CastQ(enemy)
				CastW()
				CastE(enemy)
			end	
		end	
	end
end

function KillSteal()

	for i, enemy in pairs(GetEnemyHeroes()) do
			
		if enemy.dead then else
		
			if InRange(enemy,600) then
			
				if GetEDamageTimed(enemy) >= enemy.health then
				
					CastE(enemy)
					CastE(enemy)
				elseif GetQDamage(enemy) >= enemy.health then	
			
					CastQ(enemy)
				elseif GetEDamage(enemy) >= enemy.health then
				
				    followTarget(enemy)
					CastE(enemy)
				elseif GetQDamage(enemy) + GetEDamage(enemy) >= enemy.health then
				
					followTarget(enemy)
					CastQ(enemy)
					CastE(enemy)
				elseif GetDamage(enemy) >= enemy.health then
				
					followTarget(enemy)
					CastR(enemy)
					CastQ(enemy)
					CastE(enemy)
				end	
				
			elseif InRange(enemy,900) then
			
				if GetRDamage(enemy) >= enemy.health then
				
					CastR(enemy)
				end
				
			elseif InRange(enemy,1025) and Param.Setup.flashkill and GetFlashSlot() and myHero:CanUseSpell(GetFlashSlot()) == READY then
			
			if GetEDamageTimed(enemy) >= enemy.health then
			
					CastSpell(GetFlashSlot(),enemy.x,enemy.z)
					CastE(enemy)
					CastE(enemy)
				elseif GetQDamage(enemy) >= enemy.health then	
				
					CastSpell(GetFlashSlot(),enemy.x,enemy.z)
					CastQ(enemy)
				elseif GetEDamage(enemy) >= enemy.health then
				
					CastSpell(GetFlashSlot(),enemy.x,enemy.z)
				    followTarget(enemy)
					CastE(enemy)
				elseif GetQDamage(enemy) + GetEDamage(enemy) >= enemy.health then
				
					CastSpell(GetFlashSlot(),enemy.x,enemy.z)
					followTarget(enemy)
					CastQ(enemy)
					CastE(enemy)
				elseif GetDamage(enemy) >= enemy.health then
				
					CastSpell(GetFlashSlot(),enemy.x,enemy.z)
					followTarget(enemy)
					CastR(enemy)
					CastQ(enemy)
					CastE(enemy)
				end	
				
			elseif InRange(enemy,1325) and Param.Setup.flashkill and GetFlashSlot() and myHero:CanUseSpell(GetFlashSlot()) == READY then
			
				if GetRDamage(enemy) >= enemy.health then
					CastSpell(GetFlashSlot(),enemy.x,enemy.z)
					CastR(enemy)
				end
			end		
		end		
	end
end


function Combo(Target)

	if Target then
	
		if Param.Key.hkey and InRange(Target,600) then
		
			followTarget(Target)
			CastQ(Target)
			CastE(Target)
			
		elseif Param.Key.hkey and not InRange(Target,600) then
		
			for i, enemy in pairs(GetEnemyHeroes()) do
			
				if enemy.dead then else
					followTarget(Target)
					CastQ(enemy)
					CastE(Target)
				end				
			end
			
		elseif Param.Key.ckey then
		
		    followTarget(Target)
			CastR(Target)
			CastQ(Target)
			CastE(Target)				
		end	
	end
end


function GetDamage(Target)

	local modifier = 1
	
	if myHero:CanUseSpell(_R) == READY then
	
		modifier = 1.1
	end
	
	return math.ceil(myHero:CalcMagicDamage(Target,modifier * (GetQDamage(Target) + GetEDamage(Target) + GetRDamage(Target))))
end

function GetRDamage(Target)

	local RDamage = 0
	
	if myHero:CanUseSpell(_R) == READY then
	
		RDamage = myHero:GetSpellData(_R).level * 100 + 50 + 0.7 * myHero.ap
	end
	
	return math.ceil(myHero:CalcMagicDamage(Target,RDamage))
end

function GetEDamage(Target)

	local plagueBonus = 1

	if TargetPlagued(Target) then
	
		plagueBonus = 1.1
	end
	
	local EDamage = 0
	
	if myHero:CanUseSpell(_E) == READY then
	
		EDamage = myHero:GetSpellData(_E).level * 30 + 30 + 1 * myHero.ap + 0.06 * myHero.maxHealth
	end
		
	return math.ceil(myHero:CalcMagicDamage(Target,EDamage * plagueBonus))
end

function GetEDamageTimed(Target)

	local plagueBonus = 1

	if TargetPlagued(Target) then
	
		plagueBonus = 1.1
	end
	
	local EDamage = 0
	local startDamage = myHero:GetSpellData(_E).level * 15 + 15 + 0.35 * myHero.ap + 0.025 * myHero.maxHealth
	local difference = 0
	
	if myHero:CanUseSpell(_E) == READY then
	
		EDamage = myHero:GetSpellData(_E).level * 30 + 30 + 1 * myHero.ap + 0.06 * myHero.maxHealth
	end
	
	if not eStarted then else
	
		difference = (startDamage - EDamage) / 1500 * (GetTickCount() - eStartedTime)
	end
	
	if difference == 0 then return 0 end
	
	return math.ceil(myHero:CalcMagicDamage(Target,(startDamage + difference ) * plagueBonus))
end

function GetQDamage(Target)

	local plagueBonus = 1

	if TargetPlagued(Target) then
	
		plagueBonus = 1.1	
	end
	
	local furryBonus = 1
	local QDamage = 0
	
	if bloodFury then
	
		furryBonus = 2;
	end
	
	if myHero:CanUseSpell(_Q) == READY then
		QDamage = (myHero:GetSpellData(_Q).level * 15 + 60 + 0.55 * myHero.ap) * furryBonus
	end
	
	return math.ceil(myHero:CalcMagicDamage(Target,QDamage * plagueBonus))
end

function TargetPlagued(Target)


	for i= 20,1,-1 do 
	
	if Target:getBuff(i).name ~= nil and Target:getBuff(i).name:find("plaguedamage") then
	
		return true	
	end
	end
end


function followTarget(Target)

	if not follow or InRange(Target,600) then return end

		myHero:MoveTo(Target.x,Target.z)
end

function CastR(Target)

	if InRange(Target,700) and myHero:CanUseSpell(_R) == READY then

		CastSpell(_R,Target)

	end
end

function CastW()

	if myHero:CanUseSpell(_W) == READY then
	
		CastSpell(_W)
		
	end
end

function CastE(Target)

	if InRange(Target,600) and myHero:CanUseSpell(_E) == READY then

		follow = true
		CastSpell(_E)

	end
end

function CastQ(Target)

	if InRange(Target,600) and myHero:CanUseSpell(_Q) == READY then

		CastSpell(_Q,Target)

	end
end

function OnProcessSpell(unit,spell)

	if unit.isMe and spell.name == "VladimirE" and myHero:CanUseSpell(_E) then

		eStarted = true
		eStartedTime = GetTickCount()
	
	end
end

function OnApplyBuff(unit,target,buff)

	if unit.isMe and buff.name == "vladimirqfrenzy" then
	
		bloodFury = true
	end
end

function OnRemoveBuff(unit,buff)

    if unit.isMe then 
	
		if buff.name == "VladimirE" then
		
			eStarted = false
		end
		
		if buff.name == "vladimirqfrenzy" then
		
			bloodFury = false
		end
		
		if buff.name == "VladimirE" then
		
			follow = false
		end
		
	end
end

function GetFlashSlot()

	if myHero:GetSpellData(SUMMONER_1).name:find("Flash") then

		return SUMMONER_1
		
	elseif myHero:GetSpellData(SUMMONER_1).name:find("Flash") then
		return SUMMONER_2		
		
	end
end

function InRange(Target,range)

	if GetDistance(Target) < range then return true else return false end

end