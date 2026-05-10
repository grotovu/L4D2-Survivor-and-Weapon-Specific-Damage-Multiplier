#define PLUGIN_VERSION  "1.0"

#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

public Plugin myinfo =
{
	name = "Survivor and Weapon Specific Damage Multiplier",
	author = "Vibecoded by Gemini AI",
	description = "Total control over every survivor and weapon defense multiplier.",
	version = PLUGIN_VERSION
};

// Base Damage Multipliers
ConVar C_percent[8];
float O_percent[8];

// Survivor Specific Melee Modifiers
ConVar C_melee_enable;
bool O_melee_enable;
ConVar C_melee_percent[8];
float O_melee_percent[8];

// Weapon Specific Modifiers
ConVar C_wep_enable;
bool O_wep_enable;
ConVar C_wep_percent[34];
float O_wep_percent[34];

bool Late_load;

int GetSurvivorCharacter(int client)
{
    char model[128];
    GetClientModel(client, model, sizeof(model));

    if (StrContains(model, "gambler", false) != -1) return 0;       // Nick
    if (StrContains(model, "producer", false) != -1) return 1;      // Rochelle
    if (StrContains(model, "coach", false) != -1) return 2;         // Coach
    if (StrContains(model, "mechanic", false) != -1) return 3;      // Ellis
    if (StrContains(model, "namvet", false) != -1) return 4;        // Bill
    if (StrContains(model, "teenangst", false) != -1) return 5;     // Zoey
    if (StrContains(model, "biker", false) != -1) return 6;         // Francis
    if (StrContains(model, "manager", false) != -1) return 7;       // Louis

    return GetEntProp(client, Prop_Send, "m_survivorCharacter");
}

// Detects which weapon the player is holding
int GetActiveWeaponID(int weapon, const char[] classname)
{
    // Firearms & Chainsaw
    if (StrEqual(classname, "weapon_chainsaw")) return 14;
    if (StrEqual(classname, "weapon_pistol")) return 15;
    if (StrEqual(classname, "weapon_pistol_magnum")) return 16;
    
    if (StrEqual(classname, "weapon_smg")) return 17;
    if (StrEqual(classname, "weapon_smg_silenced")) return 18;
    if (StrEqual(classname, "weapon_smg_mp5")) return 19;
    if (StrEqual(classname, "weapon_pumpshotgun")) return 20;
    if (StrEqual(classname, "weapon_shotgun_chrome")) return 21;
    
    if (StrEqual(classname, "weapon_rifle")) return 22;
    if (StrEqual(classname, "weapon_rifle_ak47")) return 23;
    if (StrEqual(classname, "weapon_rifle_desert")) return 24;
    if (StrEqual(classname, "weapon_rifle_sg552")) return 25;
    if (StrEqual(classname, "weapon_autoshotgun")) return 26;
    if (StrEqual(classname, "weapon_shotgun_spas")) return 27;
    if (StrEqual(classname, "weapon_hunting_rifle")) return 28;
    if (StrEqual(classname, "weapon_sniper_military")) return 29;
    if (StrEqual(classname, "weapon_sniper_awp")) return 30;
    if (StrEqual(classname, "weapon_sniper_scout")) return 31;
    
    if (StrEqual(classname, "weapon_grenade_launcher")) return 32;
    if (StrEqual(classname, "weapon_rifle_m60")) return 33;

    // Melee Logic
    if (StrEqual(classname, "weapon_melee"))
    {
        char scriptName[64];
        GetEntPropString(weapon, Prop_Data, "m_strMapSetScriptName", scriptName, sizeof(scriptName));
        
        if (StrEqual(scriptName, "knife")) return 0;
        if (StrEqual(scriptName, "baseball_bat")) return 1;
        if (StrEqual(scriptName, "cricket_bat")) return 2;
        if (StrEqual(scriptName, "crowbar")) return 3;
        if (StrEqual(scriptName, "electric_guitar")) return 4;
        if (StrEqual(scriptName, "fireaxe")) return 5;
        if (StrEqual(scriptName, "frying_pan")) return 6;
        if (StrEqual(scriptName, "golfclub")) return 7;
        if (StrEqual(scriptName, "katana")) return 8;
        if (StrEqual(scriptName, "machete")) return 9;
        if (StrEqual(scriptName, "pitchfork")) return 10;
        if (StrEqual(scriptName, "riotshield")) return 11;
        if (StrEqual(scriptName, "shovel")) return 12;
        if (StrEqual(scriptName, "tonfa")) return 13;

        // Fallback for custom maps
        char modelName[128];
        GetEntPropString(weapon, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
        if (StrContains(modelName, "w_knife_t") != -1) return 0;
        if (StrContains(modelName, "w_bat") != -1) return 1;
        if (StrContains(modelName, "w_cricket_bat") != -1) return 2;
        if (StrContains(modelName, "w_crowbar") != -1) return 3;
        if (StrContains(modelName, "w_electric_guitar") != -1) return 4;
        if (StrContains(modelName, "w_fireaxe") != -1) return 5;
        if (StrContains(modelName, "w_frying_pan") != -1) return 6;
        if (StrContains(modelName, "w_golfclub") != -1) return 7;
        if (StrContains(modelName, "w_katana") != -1) return 8;
        if (StrContains(modelName, "w_machete") != -1) return 9;
        if (StrContains(modelName, "w_pitchfork") != -1) return 10;
        if (StrContains(modelName, "w_riotshield") != -1) return 11;
        if (StrContains(modelName, "w_shovel") != -1) return 12;
        if (StrContains(modelName, "w_tonfa") != -1) return 13;
    }

    return -1; // Unknown Weapon or Throwables/Pills
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage_client);
}

Action OnTakeDamage_client(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon_attack, float damageForce[3], float damagePosition[3], int damagecustom)
{
    if(damage >= 1.0 && GetClientTeam(victim) == 2 && IsPlayerAlive(victim))
    {
        int charID = GetSurvivorCharacter(victim);
        
        if(charID >= 0 && charID <= 7)
        {
            float final_multiplier = O_percent[charID];
            
            int active_weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
            if (active_weapon > 0 && IsValidEntity(active_weapon))
            {
                char classname[64];
                GetEntityClassname(active_weapon, classname, sizeof(classname));
                
                // Only trigger the specific Survivor Melee Multiplier if actually holding Melee/Chainsaw
                if (O_melee_enable && (StrEqual(classname, "weapon_melee") || StrEqual(classname, "weapon_chainsaw")))
                {
                    final_multiplier *= O_melee_percent[charID];
                }
                
                // Trigger the generic Weapon Modifier for everything else (Guns + Melee)
                if (O_wep_enable)
                {
                    int wepID = GetActiveWeaponID(active_weapon, classname);
                    if (wepID >= 0)
                    {
                        final_multiplier *= O_wep_percent[wepID];
                    }
                }
            }
            
            damage *= final_multiplier;
            
            if(damage < 1.0)
            {
                damage = 1.0;
            }
            return Plugin_Changed;
        }
    }
	return Plugin_Continue;
}

void get_all_cvars()
{
    O_melee_enable = C_melee_enable.BoolValue;
    O_wep_enable = C_wep_enable.BoolValue;

    for (int i = 0; i < 8; i++)
    {
        O_percent[i] = C_percent[i].FloatValue;
        O_melee_percent[i] = C_melee_percent[i].FloatValue;
    }
    
    for (int i = 0; i < 34; i++) // 34 Weapons
    {
        O_wep_percent[i] = C_wep_percent[i].FloatValue;
    }
}

void convar_changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
    get_all_cvars();
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    if(GetEngineVersion() != Engine_Left4Dead2)
    {
        strcopy(error, err_max, "this plugin only runs in \"Left 4 Dead 2\"");
        return APLRes_SilentFailure;
    }
    Late_load = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    char names[8][] = { "nick", "rochelle", "coach", "ellis", "bill", "zoey", "francis", "louis" };
    
    // 34 Weapons
    char wepNames[34][] = {
        // Melee (0-14)
        "knife", "bat", "cricket_bat", "crowbar", "guitar",
        "fireaxe", "pan", "golfclub", "katana", "machete",
        "pitchfork", "riotshield", "shovel", "tonfa", "chainsaw",
        // Pistols (15-16)
        "pistol", "magnum",
        // Tier 1 (17-21)
        "smg", "smg_silenced", "smg_mp5", "pumpshotgun", "shotgun_chrome",
        // Tier 2 (22-31)
        "rifle", "rifle_ak47", "rifle_desert", "rifle_sg552", 
        "autoshotgun", "shotgun_spas", 
        "hunting_rifle", "sniper_military", "sniper_awp", "sniper_scout",
        // Tier 3 (32-33)
        "grenade_launcher", "m60"
    };

    char cvarName[64], cvarDesc[128];

    // Globals
    C_melee_enable = CreateConVar("survivor_damage_melee_enable", "1", "Enable survivor specific melee modifiers?");
    C_melee_enable.AddChangeHook(convar_changed);
    
    C_wep_enable = CreateConVar("survivor_damage_weapon_enable", "1", "Enable weapon specific defense modifiers?");
    C_wep_enable.AddChangeHook(convar_changed);

    // Survivor Specific
    for (int i = 0; i < 8; i++)
    {
        Format(cvarName, sizeof(cvarName), "survivor_damage_multi_%s", names[i]);
        Format(cvarDesc, sizeof(cvarDesc), "Base damage modifier for %s", names[i]);
        C_percent[i] = CreateConVar(cvarName, "1.0", cvarDesc, _, true, 0.0);
        C_percent[i].AddChangeHook(convar_changed);

        Format(cvarName, sizeof(cvarName), "survivor_damage_melee_multi_%s", names[i]);
        Format(cvarDesc, sizeof(cvarDesc), "Melee modifier for %s", names[i]);
        C_melee_percent[i] = CreateConVar(cvarName, "0.8", cvarDesc, _, true, 0.0);
        C_melee_percent[i].AddChangeHook(convar_changed);
    }
    
    // Weapon Specific
    for (int i = 0; i < 34; i++)
    {
        Format(cvarName, sizeof(cvarName), "survivor_damage_wep_multi_%s", wepNames[i]);
        Format(cvarDesc, sizeof(cvarDesc), "Defensive multiplier when holding %s (e.g. 1.2 = 20%% MORE dmg)", wepNames[i]);
        
        // Pre-set Riot Shield to 0.5, everything else starts at a standard 1.0
        char defValue[8] = "1.0";
        if (StrEqual(wepNames[i], "riotshield")) strcopy(defValue, sizeof(defValue), "0.5");

        C_wep_percent[i] = CreateConVar(cvarName, defValue, cvarDesc, _, true, 0.0);
        C_wep_percent[i].AddChangeHook(convar_changed);
    }

    CreateConVar("survivor_damage_multi_version", PLUGIN_VERSION, "Version", FCVAR_NOTIFY | FCVAR_DONTRECORD);

    AutoExecConfig(true, "survivor_damage_multiplier");
	get_all_cvars();

    if(Late_load)
    {
        for(int client = 1; client <= MaxClients; client++)
        {
            if(IsClientInGame(client)) OnClientPutInServer(client);
        }
    }
}
