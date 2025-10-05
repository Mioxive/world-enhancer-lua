local ffi = require("ffi")
local weapons = require("gamesense/csgo_weapons")
local pui = require("gamesense/pui")
local group = pui.group("LUA", "A")


local client_latency, client_log, client_draw_rectangle, client_draw_circle_outline, client_userid_to_entindex, client_draw_indicator, client_draw_gradient, client_set_event_callback, client_screen_size, client_eye_position = client.latency, client.log, client.draw_rectangle, client.draw_circle_outline, client.userid_to_entindex, client.draw_indicator, client.draw_gradient, client.set_event_callback, client.screen_size, client.eye_position 
local client_draw_circle, client_color_log, client_delay_call, client_draw_text, client_visible, client_exec, client_trace_line, client_set_cvar = client.draw_circle, client.color_log, client.delay_call, client.draw_text, client.visible, client.exec, client.trace_line, client.set_cvar 
local client_world_to_screen, client_draw_hitboxes, client_get_cvar, client_draw_line, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float = client.world_to_screen, client.draw_hitboxes, client.get_cvar, client.draw_line, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float 
local entity_get_local_player, entity_is_enemy, entity_hitbox_position, entity_get_player_name, entity_get_steam64, entity_get_bounding_box, entity_get_all, entity_set_prop = entity.get_local_player, entity.is_enemy, entity.hitbox_position, entity.get_player_name, entity.get_steam64, entity.get_bounding_box, entity.get_all, entity.set_prop 
local entity_is_alive, entity_get_player_weapon, entity_get_prop, entity_get_players, entity_get_classname, entity_get_game_rules = entity.is_alive, entity.get_player_weapon, entity.get_prop, entity.get_players, entity.get_classname, entity.get_game_rules 
local globals_realtime, globals_absoluteframetime, globals_tickcount, globals_curtime, globals_mapname, globals_tickinterval, globals_framecount, globals_frametime, globals_maxplayers = globals.realtime, globals.absoluteframetime, globals.tickcount, globals.curtime, globals.mapname, globals.tickinterval, globals.framecount, globals.frametime, globals.maxplayers 
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_is_menu_open, ui_new_color_picker, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.is_menu_open, ui.new_color_picker, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get 
local math_ceil, math_tan, math_log10, math_randomseed, math_cos, math_sinh, math_random, math_huge, math_pi, math_max, math_atan2, math_ldexp, math_floor, math_sqrt, math_deg, math_atan, math_fmod = math.ceil, math.tan, math.log10, math.randomseed, math.cos, math.sinh, math.random, math.huge, math.pi, math.max, math.atan2, math.ldexp, math.floor, math.sqrt, math.deg, math.atan, math.fmod 
local math_acos, math_pow, math_abs, math_min, math_sin, math_frexp, math_log, math_tanh, math_exp, math_modf, math_cosh, math_asin, math_rad = math.acos, math.pow, math.abs, math.min, math.sin, math.frexp, math.log, math.tanh, math.exp, math.modf, math.cosh, math.asin, math.rad 
local table_maxn, table_foreach, table_sort, table_remove, table_foreachi, table_move, table_getn, table_concat, table_insert = table.maxn, table.foreach, table.sort, table.remove, table.foreachi, table.move, table.getn, table.concat, table.insert 
local string_find, string_format, string_rep, string_gsub, string_len, string_gmatch, string_dump, string_match, string_reverse, string_byte, string_char, string_upper, string_lower, string_sub = string.find, string.format, string.rep, string.gsub, string.len, string.gmatch, string.dump, string.match, string.reverse, string.byte, string.char, string.upper, string.lower, string.sub
local client_create_interface, client_find_signature, client_userid_to_entindex, client_reload_active_scripts, client_set_event_callback, client_unset_event_callback = client.create_interface, client.find_signature, client.userid_to_entindex, client.reload_active_scripts, client.set_event_callback, client.unset_event_callback
local ffi_cast, ffi_typeof, ffi_string, ffi_sizeof = ffi.cast, ffi.typeof, ffi.string, ffi.sizeof
local materialsystem_find_materials, bit_band, bit_bor = materialsystem.find_materials, bit.band, bit.bor

ffi.cdef([[
    typedef struct c_con_command_base {
        void *vtable;
        void *next;
        bool registered;
        const char *name;
        const char *help_string;
        int flags;
        void *s_cmd_base;
        void *accessor;
    } c_con_command_base;
]])

local tab_manager = {
    tabs = {},
    current = nil,
    combobox = nil
}

function tab_manager:create(name)
    self.tabs[name] = {}
    return self.tabs[name]
end

function tab_manager:add(tab_name, element)
    table.insert(self.tabs[tab_name], element)
    return element
end

function tab_manager:update()
    local current = self.combobox:get()
    
    for tab_name, elements in pairs(self.tabs) do
        local visible = (tab_name == current)
        for _, element in ipairs(elements) do
            element:set_visible(visible)
        end
    end
end

-- ============================================
-- VARIABLES
-- ============================================

local vars = {
    aspect_ratio = {
        old_aspect_ratio = client_get_cvar("r_aspectratio"),
    },

    thirdperson = {
        old_distance = client_get_cvar("cam_idealdist"),
    },

    skybox = {
        old_skybox = client_get_cvar("sv_skyname"),
        skyboxes = {
            "cs_tibet",
            "cs_baggage_skybox_",
            "embassy",
            "italy",
            "jungle",
            "office",
            "sky_cs15_daylight01_hdr",
            "vertigoblue_hdr",
            "sky_cs15_daylight02_hdr",
            "vertigo",
            "sky_day02_05_hdr",
            "nukeblank",
            "sky_venice",
            "sky_cs15_daylight03_hdr",
            "sky_cs15_daylight04_hdr",
            "sky_csgo_cloudy01",
            "sky_csgo_night02",
            "sky_csgo_night02b",
            "sky_csgo_night_flat",
            "sky_dust",
            "vietnam",
        },
    },

    hidden_cvars = {
        v_engine_cvar = client_create_interface('vstdlib.dll', 'VEngineCvar007'),
        cvars = {},
    },

    viewmodel = {
        old_fov = client_get_cvar("viewmodel_fov"),
        old_x = client_get_cvar("viewmodel_offset_x"),
        old_y = client_get_cvar("viewmodel_offset_y"),
        old_z = client_get_cvar("viewmodel_offset_z"),
    },

    autobuy = {
        primary = {
            "-",
            "SSG 08",
            "AWP",
            "SCAR-20/G3SG1",
        },
        
        secondary = {
            "-",
            "Deagle/R8",
            "CZ-75/Tec-9/Five-Seven",
            "Dual Berretas",
            "P250",
        },
        
        grenades = {
            "HE Grenade",
            "Molotov",
            "Smoke",
            "Flash",
            "Flash",
        },
        
        utilities = {
            "Armor",
            "Helmet",
            "Zeus",
            "Defuser",
        },
        commands = {
            ["-"] = "",
            ["AWP"] = "buy awp",
            ["SSG 08"] = "buy ssg08",
            ["SCAR-20/G3SG1"] = "buy scar20",
            ["Deagle/R8"] = "buy deagle",
            ["CZ-75/Tec-9/Five-Seven"] = "buy tec9",
            ["P250"] = "buy p250",
            ["Dual Berretas"] = "buy elite",
            ["HE Grenade"] = "buy hegrenade",
            ["Molotov"] = "buy molotov",
            ["Smoke"] = "buy smokegrenade",
            ["Flash"] = "buy flashbang",
            ["Armor"] = "buy vest",
            ["Helmet"] = "buy vesthelm",
            ["Zeus"] = "buy taser 34",
            ["Defuser"] = "buy defuser",
        }
    },

    unsafe_charge = {
        aimbot = pui.reference('RAGE', 'Aimbot', 'Enabled'),
        double_tap = { pui.reference('RAGE', 'Aimbot', 'Double tap') },
        hide_shots = { pui.reference('AA', 'Other', 'On shot anti-aim')},
        timer = globals_tickcount()
    },

    effects = {
        bloom_old = nil,
        exposure_min_old = nil,
        exposure_max_old = nil,
        bloom_prev = nil,
        exposure_prev = nil,
        model_ambient_prev = nil,
    },
}

-- ============================================
-- UTILS
-- ============================================

local utils = {
    bind_signature = function(module, interface, signature, typestring)
        local iface = client_create_interface(module, interface) or error("invalid interface", 2)
        local instance = client_find_signature(module, signature) or error("invalid signature", 2)
        local success, typeof = pcall(ffi_typeof, typestring)
        if not success then
            error(typeof, 2)
        end
        local fnptr = ffi_cast(typeof, instance) or error("invalid typecast", 2)
        return function(...)
            return fnptr(iface, ...)
        end
    end,

    int_ptr = ffi_typeof("int[1]"),
    char_buffer = ffi_typeof("char[?]"),

    table_diff = function(t1, t2)
        local diff = {}
        for k, v in pairs(t1) do
            if t2[k] ~= v then
                diff[k] = v
            end
        end
        for k, v in pairs(t2) do
            if t1[k] ~= v then
                diff[k] = v
            end
        end
        return next(diff) ~= nil
    end,

    reset_bloom = function(tone_map_controller)
        if vars.effects.bloom_default == -1 then
            entity_set_prop(tone_map_controller, "m_bUseCustomBloomScale", 0)
            entity_set_prop(tone_map_controller, "m_flCustomBloomScale", 0)
        elseif vars.effects.bloom_default and vars.effects.bloom_default ~= -1 then
            entity_set_prop(tone_map_controller, "m_bUseCustomBloomScale", 1)
            entity_set_prop(tone_map_controller, "m_flCustomBloomScale", vars.effects.bloom_default)
        end
    end,

    reset_exposure = function(tone_map_controller)
        -- Min exposure
        if vars.effects.exposure_min_default == -1 then
            entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMin", 0)
            entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMin", 0)
        elseif vars.effects.exposure_min_default and vars.effects.exposure_min_default ~= -1 then
            entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMin", 1)
            entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMin", vars.effects.exposure_min_default)
        end
        
        -- Max exposure
        if vars.effects.exposure_max_default == -1 then
            entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMax", 0)
            entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMax", 0)
        elseif vars.effects.exposure_max_default and vars.effects.exposure_max_default ~= -1 then
            entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMax", 1)
            entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMax", vars.effects.exposure_max_default)
        end
    end,
}
-- ============================================
-- WORLD TAB
-- ============================================
local world_tab = {
    init = function(self)
        self.fog = {
            override = tab_manager:add("World", pui.checkbox(group, "Fog override", {120, 160, 80, 255})),
            start = tab_manager:add("World", pui.slider(group, "Fog start", 0, 5000, 100)),
            end_ = tab_manager:add("World", pui.slider(group, "Fog end", 0, 10000, 1000)),
            density = tab_manager:add("World", pui.slider(group, "Fog density", 0, 100, 50)),
        }

        self.sunset = {
            override = tab_manager:add("World", pui.checkbox(group, "SunSet override")),
            azimuth = tab_manager:add("World", pui.slider(group, "Azimuth", -180, 180, 0)),
            elevation = tab_manager:add("World", pui.slider(group, "Elevation", -180, 180, 0)),
        }
        
        self.skybox = {
            override = tab_manager:add("World", pui.checkbox(group, "SkyBox override",  {255, 255, 255, 255})),
            list = tab_manager:add("World", pui.combobox(group, "SkyBox", vars.skybox.skyboxes)),
            remove_3d_sky = tab_manager:add("World", pui.checkbox(group, "Remove 3D Sky")),
        }

        self.bloom = {
            enable = tab_manager:add("World", pui.checkbox(group, "Bloom")),
            scale = tab_manager:add("World", pui.slider(group, "Bloom scale", -1, 500, -1, 0.01)),
        }
        self.exposure = {
            enable = tab_manager:add("World", pui.checkbox(group, "Exposure")),
            value = tab_manager:add("World", pui.slider(group, "Auto Exposure", -1, 1000, -1, 0.001)),
        }
        self.model_ambient = {
            enable = tab_manager:add("World", pui.checkbox(group, "Model ambient")),
            brightness = tab_manager:add("World", pui.slider(group, "Model brightness", 0, 1000, 0, 0.05))
        }
        
    end,


    setup_dependencies = function(self)
        self.fog.start:depend({self.fog.override, true})
        self.fog.end_:depend({self.fog.override, true})
        self.fog.density:depend({self.fog.override, true})

        self.sunset.azimuth:depend({self.sunset.override, true})
        self.sunset.elevation:depend({self.sunset.override, true})

        self.skybox.list:depend({self.skybox.override, true})
        self.skybox.remove_3d_sky:depend({self.skybox.override, true})

        self.bloom.scale:depend({self.bloom.enable, true})

        self.exposure.value:depend({self.exposure.enable, true})

        self.model_ambient.brightness:depend({self.model_ambient.enable, true})
    end,
    
    setup_tab_dependencies = function(self)
        for _, element in pairs(self.fog) do
            element:depend({tab_manager.combobox, "World"})
        end
        for _, element in pairs(self.sunset) do
            element:depend({tab_manager.combobox, "World"})
        end
        for _, element in pairs(self.skybox) do
            element:depend({tab_manager.combobox, "World"})
        end
        for _, element in pairs(self.bloom) do
            element:depend({tab_manager.combobox, "World"})
        end
        for _, element in pairs(self.exposure) do
            element:depend({tab_manager.combobox, "World"})
        end
        for _, element in pairs(self.model_ambient) do
            element:depend({tab_manager.combobox, "World"})
        end
    end,

    restore = function()
        client_set_cvar('fog_override', 0)
        client_set_cvar('cl_csm_rot_override', 0)

        vars.skybox.load_name_sky(vars.skybox.old_skybox)
        local materials = materialsystem_find_materials("skybox/")
        for i = 1, #materials do
            materials[i]:color_modulate(255, 255, 255)
            materials[i]:alpha_modulate(255)
        end

        local tone_map_controllers = entity_get_all("CEnvTonemapController")
        for i = 1, #tone_map_controllers do
            local controller = tone_map_controllers[i]
            
            if vars.effects.bloom_default ~= nil then
                utils.reset_bloom(controller)
            end
            
            if vars.effects.exposure_min_default ~= nil then
                utils.reset_exposure(controller)
            end
        end
    
        cvar.r_modelAmbientMin:set_raw_float(0)
        
        client_set_cvar("mat_ambient_light_r", 0)
        client_set_cvar("mat_ambient_light_g", 0)
        client_set_cvar("mat_ambient_light_b", 0)
    end,
}

-- ============================================
-- MISC TAB
-- ============================================
local misc_tab = {
    init = function(self)
        self.thirdperson = {
            override = tab_manager:add("Misc", pui.checkbox(group, "ThirdPerson distance")),
            distance = tab_manager:add("Misc", pui.slider(group, "Distance", 0, 300, 150)),
        }
        
        self.aspect_ratio = {
            override = tab_manager:add("Misc", pui.checkbox(group, "Aspect Ratio override")),
            value = tab_manager:add("Misc", pui.slider(group, "Aspect Ratio", 0, 200, 100, 0.01)),
        }
        self.viewmodel_in_scope = tab_manager:add("Misc", pui.checkbox(group, "Viewmodel in scope"))
        

        self.viewmodel_changer = {
            override = tab_manager:add("Misc", pui.checkbox(group, "Viewmodel changer")),
            fov = tab_manager:add("Misc", pui.slider(group, "FOV", -60, 100, vars.viewmodel.old_fov, 0.1)),
            x = tab_manager:add("Misc", pui.slider(group, "Offset X", -30, 30, vars.viewmodel.old_x, 0.1)),
            y = tab_manager:add("Misc", pui.slider(group, "Offset Y", -100, 100, vars.viewmodel.old_y,  0.1)),
            z = tab_manager:add("Misc", pui.slider(group, "Offset Z", -30, 30, vars.viewmodel.old_z, 0.1)),
       
        }

        self.autobuy = {
            enable = tab_manager:add("Misc", pui.checkbox(group, "AutoBuy")),
            disable_on_pistol = tab_manager:add("Misc", pui.checkbox(group, "Disable on pistol round")),
            primary = tab_manager:add("Misc", pui.combobox(group, "Primary weapon", vars.autobuy.primary)),
            secondary = tab_manager:add("Misc", pui.combobox(group, "Secondary weapon", vars.autobuy.secondary)),
            grenades = tab_manager:add("Misc", pui.multiselect(group, "Grenades", vars.autobuy.grenades)),
            utilities = tab_manager:add("Misc", pui.multiselect(group, "Other", vars.autobuy.utilities)),
        }
        self.unsafe_charge = tab_manager:add("Misc", pui.checkbox(group, "Unsafe Charge"))

        self.unlock_hidden_cvars = tab_manager:add("Misc", pui.button(group, "Unloch Hidden ConVars"))
    end,
    
    setup_dependencies = function(self)
        self.thirdperson.distance:depend({self.thirdperson.override, true})
        self.aspect_ratio.value:depend({self.aspect_ratio.override, true})

        self.viewmodel_changer.fov:depend({self.viewmodel_changer.override, true})
        self.viewmodel_changer.x:depend({self.viewmodel_changer.override, true})
        self.viewmodel_changer.y:depend({self.viewmodel_changer.override, true})
        self.viewmodel_changer.z:depend({self.viewmodel_changer.override, true})

        self.autobuy.disable_on_pistol:depend({self.autobuy.enable, true})
        self.autobuy.primary:depend({self.autobuy.enable, true})
        self.autobuy.secondary:depend({self.autobuy.enable, true})
        self.autobuy.grenades:depend({self.autobuy.enable, true})
        self.autobuy.utilities:depend({self.autobuy.enable, true})
    end,
    
    setup_tab_dependencies = function(self)
        for _, element in pairs(self.thirdperson) do
            element:depend({tab_manager.combobox, "Misc"})
        end
        for _, element in pairs(self.aspect_ratio) do
            element:depend({tab_manager.combobox, "Misc"})
        end
        for _, element in pairs(self.viewmodel_changer) do
            element:depend({tab_manager.combobox, "Misc"})
        end

        for _, element in pairs(self.autobuy) do
            element:depend({tab_manager.combobox, "Misc"})
        end

        self.unlock_hidden_cvars:depend({tab_manager.combobox, "Misc"})
        self.viewmodel_in_scope:depend({tab_manager.combobox, "Misc"})
        self.unsafe_charge:depend({tab_manager.combobox, "Misc"})
    end,

    restore = function()
        client_set_cvar('cam_idealdist', vars.thirdperson.old_distance)
        client_set_cvar('fov_cs_debug', 0)
        client_set_cvar('r_aspectratio', 0)


        client_set_cvar("viewmodel_fov", vars.viewmodel.old_fov)
        client_set_cvar("viewmodel_offset_x", vars.viewmodel.old_x)
        client_set_cvar("viewmodel_offset_y", vars.viewmodel.old_y)
        client_set_cvar("viewmodel_offset_z", vars.viewmodel.old_z)
    end
}

-- ============================================
-- CALLBACKS
-- ============================================
local callbacks = {
    fog_override = function()
        if not world_tab.fog.override:get() then
            client_set_cvar('fog_override', '0')
            return
        end
        
        client_set_cvar('fog_override', '1')
        
        local r, g, b, a = world_tab.fog.override:get_color()
        
        client_set_cvar('fog_color', string_format('%d %d %d', r, g, b))
        client_set_cvar('fog_start', world_tab.fog.start:get())
        client_set_cvar('fog_end', world_tab.fog.end_:get())
        client_set_cvar('fog_maxdensity', world_tab.fog.density:get() / 100)
    end,

    sunset_override = function()
        if not world_tab.sunset.override:get() then
            client_set_cvar('cl_csm_rot_override', 0)
            return
        end

        client_set_cvar('cl_csm_rot_override', 1)

        client_set_cvar("cl_csm_rot_x", world_tab.sunset.azimuth:get())
        client_set_cvar("cl_csm_rot_y", world_tab.sunset.elevation:get())
        
    end,

    skybox_override = function()
        local r, g, b, a = 255, 255, 255, 255


        if not world_tab.skybox.override:get() then
            vars.skybox.load_name_sky(vars.skybox.old_skybox)
            local materials = materialsystem_find_materials("skybox/")
            for i = 1, #materials do
                materials[i]:color_modulate(r, g, b)
                materials[i]:alpha_modulate(a)
            end
            return
        end
        
        local skybox = world_tab.skybox.list:get()
        
        vars.skybox.load_name_sky(skybox)

        local materials = materialsystem_find_materials("skybox/")

        r, g, b, a = world_tab.skybox.override:get_color()
		for i = 1, #materials do
			materials[i]:color_modulate(r, g, b)
			materials[i]:alpha_modulate(a)
		end
        
        local remove_3d = world_tab.skybox.remove_3d_sky:get() and 0 or 1
        client_set_cvar("r_3dsky", tostring(remove_3d))
    end,

    thirdperson_override = function()
        if not misc_tab.thirdperson.override:get() then
            client_set_cvar('cam_idealdist', vars.thirdperson.old_distance)
            return
        end

        local distance = misc_tab.thirdperson.distance:get()
        client_set_cvar('cam_idealdist', distance)
    end,

    aspect_ratio_override = function()
        if not misc_tab.aspect_ratio.override:get() then
            client_set_cvar('r_aspectratio', vars.aspect_ratio.old_aspect_ratio)
            return
        end

        local value = 2 - misc_tab.aspect_ratio.value:get() / 100
        local screen_width, screen_height = client_screen_size()

        value = (screen_width * value) / screen_height

        client_set_cvar("r_aspectratio", tostring(value))
    end,

    unlock_hidden_cvars = function()
        
        for i = 1, #vars.hidden_cvars.cvars do
            vars.hidden_cvars.cvars[i].flags = bit_band(vars.hidden_cvars.cvars[i].flags, -19) or bit_bor(vars.hidden_cvars.cvars[i].flags, 18)
        end
    end,

    viewmodel_in_scope = function()
        if not misc_tab.viewmodel_in_scope:get() then
            client_set_cvar('fov_cs_debug', 0)
            return
        end
        client_set_cvar('fov_cs_debug', 90)
    end,

    viewmodel_changer = function()
        if not misc_tab.viewmodel_changer.override:get() then
            client_set_cvar("viewmodel_fov", vars.viewmodel.old_fov)
            client_set_cvar("viewmodel_offset_x", vars.viewmodel.old_x)
            client_set_cvar("viewmodel_offset_y", vars.viewmodel.old_y)
            client_set_cvar("viewmodel_offset_z", vars.viewmodel.old_z)
            return
        end

        local fov = misc_tab.viewmodel_changer.fov:get()
        local x = misc_tab.viewmodel_changer.x:get() / 10
        local y = misc_tab.viewmodel_changer.y:get() / 10
        local z = misc_tab.viewmodel_changer.z:get() / 10

        client_set_cvar("viewmodel_fov", fov)
        client_set_cvar("viewmodel_offset_x", x)
        client_set_cvar("viewmodel_offset_y", y)
        client_set_cvar("viewmodel_offset_z", z)

    end,

    autobuy = function()
        if not misc_tab.autobuy.enable:get() then return end

        if misc_tab.autobuy.disable_on_pistol:get() then
            local game_rules = entity_get_game_rules()
            if game_rules then
                local round_number = entity_get_prop(game_rules, "m_totalRoundsPlayed")
                
                if round_number == 0 or 
                   (round_number > 30 and (round_number - 30) % 6 == 0) then
                    return
                end
            end
        end

        client_exec(vars.autobuy.commands[misc_tab.autobuy.primary:get()])
        client_exec(vars.autobuy.commands[misc_tab.autobuy.secondary:get()])

        local grenades = misc_tab.autobuy.grenades:get()
        local utilities = misc_tab.autobuy.utilities:get()

        for i = 1, #grenades do
			local grenade = grenades[i]
			client_exec(vars.autobuy.commands[grenade])
		end

        for i = 1, #utilities do
			local utility = utilities[i]
			client_exec(vars.autobuy.commands[utility])
		end
    end,

    unsafe_charge = function()

        local disable_tick = 14
        local local_player = entity_get_local_player()

        if not entity_is_alive(local_player) then return end

        local weapon = entity_get_player_weapon(local_player)
        if not weapon then return end

        disable_tick = weapons(weapon).is_revolver and 17 or 14

        local dt_active = vars.unsafe_charge.double_tap[2] and vars.unsafe_charge.double_tap[2]:get_hotkey() or false
        local os_active = vars.unsafe_charge.hide_shots[2] and vars.unsafe_charge.hide_shots[2]:get_hotkey() or false

        if dt_active or os_active then
            if globals_tickcount() >= vars.unsafe_charge.timer + disable_tick then
                vars.unsafe_charge.aimbot:set(true)
            else
                vars.unsafe_charge.aimbot:set(false)
            end
        else
            vars.unsafe_charge.timer = globals_tickcount()
            vars.unsafe_charge.aimbot:set(true)
        end
    end,

    effects_update = function()
        if world_tab.model_ambient.enable:get() then
            local model_ambient = world_tab.model_ambient.brightness:get()
            local value = model_ambient * 0.05
            
            if cvar.r_modelAmbientMin:get_float() ~= value then
                cvar.r_modelAmbientMin:set_raw_float(value)
            end
        else
            cvar.r_modelAmbientMin:set_raw_float(0)
        end
    
        local tone_map_controllers = entity_get_all("CEnvTonemapController")
        
        for i = 1, #tone_map_controllers do
            local controller = tone_map_controllers[i]
            
            -- === BLOOM ===
            if world_tab.bloom.enable:get() then
                local bloom = world_tab.bloom.scale:get()
                
                if vars.effects.bloom_default == nil then
                    if entity_get_prop(controller, "m_bUseCustomBloomScale") == 1 then
                        vars.effects.bloom_default = entity_get_prop(controller, "m_flCustomBloomScale")
                    else
                        vars.effects.bloom_default = -1
                    end
                end
                
                entity_set_prop(controller, "m_bUseCustomBloomScale", 1)
                entity_set_prop(controller, "m_flCustomBloomScale", bloom * 0.01)
                vars.effects.bloom_prev = bloom
            else
                if vars.effects.bloom_prev ~= nil and vars.effects.bloom_default ~= nil then
                    utils.reset_bloom(controller)
                    vars.effects.bloom_prev = nil
                end
            end
            
            -- === EXPOSURE ===
            if world_tab.exposure.enable:get() then
                local exposure = world_tab.exposure.value:get()
                
                if vars.effects.exposure_min_default == nil then
                    if entity_get_prop(controller, "m_bUseCustomAutoExposureMin") == 1 then
                        vars.effects.exposure_min_default = entity_get_prop(controller, "m_flCustomAutoExposureMin")
                    else
                        vars.effects.exposure_min_default = -1
                    end
                    
                    if entity_get_prop(controller, "m_bUseCustomAutoExposureMax") == 1 then
                        vars.effects.exposure_max_default = entity_get_prop(controller, "m_flCustomAutoExposureMax")
                    else
                        vars.effects.exposure_max_default = -1
                    end
                end
                
                local exp_value = math_max(0.0000, exposure * 0.001)
                entity_set_prop(controller, "m_bUseCustomAutoExposureMin", 1)
                entity_set_prop(controller, "m_bUseCustomAutoExposureMax", 1)
                entity_set_prop(controller, "m_flCustomAutoExposureMin", exp_value)
                entity_set_prop(controller, "m_flCustomAutoExposureMax", exp_value)
                vars.effects.exposure_prev = exposure
            else
                if vars.effects.exposure_prev ~= nil and vars.effects.exposure_min_default ~= nil then
                    utils.reset_exposure(controller)
                    vars.effects.exposure_prev = nil
                end
            end
        end
    end,
}

local function setup_callbacks()
    -- World tab
    world_tab.fog.override:set_callback(callbacks.fog_override)
    world_tab.fog.start:set_callback(callbacks.fog_override)
    world_tab.fog.end_:set_callback(callbacks.fog_override)
    world_tab.fog.density:set_callback(callbacks.fog_override)

    if world_tab.fog.override.color then
        world_tab.fog.override.color:set_callback(callbacks.fog_override)
    end

    world_tab.sunset.override:set_callback(callbacks.sunset_override)
    world_tab.sunset.azimuth:set_callback(callbacks.sunset_override)
    world_tab.sunset.elevation:set_callback(callbacks.sunset_override)

    world_tab.skybox.override:set_callback(callbacks.skybox_override)
    world_tab.skybox.list:set_callback(callbacks.skybox_override)

    if world_tab.skybox.override.color then
        world_tab.skybox.override.color:set_callback(callbacks.skybox_override)
    end

    world_tab.bloom.enable:set_callback(callbacks.effects_update)
    world_tab.bloom.scale:set_callback(callbacks.effects_update)
    world_tab.exposure.enable:set_callback(callbacks.effects_update)
    world_tab.exposure.value:set_callback(callbacks.effects_update)
    world_tab.model_ambient.enable:set_callback(callbacks.effects_update)
    world_tab.model_ambient.brightness:set_callback(callbacks.effects_update)

    -- Misc tab
    misc_tab.thirdperson.override:set_callback(callbacks.thirdperson_override)
    misc_tab.thirdperson.distance:set_callback(callbacks.thirdperson_override)

    misc_tab.aspect_ratio.override:set_callback(callbacks.aspect_ratio_override)
    misc_tab.aspect_ratio.value:set_callback(callbacks.aspect_ratio_override)

    misc_tab.unlock_hidden_cvars:set_callback(callbacks.unlock_hidden_cvars)

    misc_tab.viewmodel_in_scope:set_callback(callbacks.viewmodel_in_scope)

    misc_tab.viewmodel_changer.override:set_callback(callbacks.viewmodel_changer)
    misc_tab.viewmodel_changer.fov:set_callback(callbacks.viewmodel_changer)
    misc_tab.viewmodel_changer.x:set_callback(callbacks.viewmodel_changer)
    misc_tab.viewmodel_changer.y:set_callback(callbacks.viewmodel_changer)
    misc_tab.viewmodel_changer.z:set_callback(callbacks.viewmodel_changer)
end

-- ============================================
-- SETUP
-- ============================================
local function setup()
    group:label("------\v World enhancer!\r ------")
    
    local tab_names = {"World", "Misc", }
    tab_manager.combobox = pui.combobox(group, "Tabs", unpack(tab_names))

    for _, name in ipairs(tab_names) do
        tab_manager:create(name)
    end

    
    utils.find_first        = utils.bind_signature("filesystem_stdio.dll", "VFileSystem017", "\x55\x8B\xEC\x6A\x00\xFF\x75\x10\xFF\x75\x0C\xFF\x75\x08\xE8\xCC\xCC\xCC\xCC\x5D", "const char*(__thiscall*)(void*, const char*, const char*, int*)")
    utils.find_next         = utils.bind_signature("filesystem_stdio.dll", "VFileSystem017", "\x55\x8B\xEC\x83\xEC\x0C\x53\x8B\xD9\x8B\x0D\xCC\xCC\xCC\xCC", "const char*(__thiscall*)(void*, int)")
    utils.find_close        = utils.bind_signature("filesystem_stdio.dll", "VFileSystem017", "\x55\x8B\xEC\x53\x8B\x5D\x08\x85", "void(__thiscall*)(void*, int)")

    utils.current_directory = utils.bind_signature("filesystem_stdio.dll", "VFileSystem017", "\x55\x8B\xEC\x56\x8B\x75\x08\x56\xFF\x75\x0C", "bool(__thiscall*)(void*, char*, int)")
    utils.add_to_searchpath = utils.bind_signature("filesystem_stdio.dll", "VFileSystem017", "\x55\x8B\xEC\x81\xEC\xCC\xCC\xCC\xCC\x8B\x55\x08\x53\x56\x57", "void(__thiscall*)(void*, const char*, const char*, int)")
    utils.find_is_directory = utils.bind_signature("filesystem_stdio.dll", "VFileSystem017", "\x55\x8B\xEC\x0F\xB7\x45\x08", "bool(__thiscall*)(void*, int)")

    local load_name_sky_address = client_find_signature("engine.dll", "\x55\x8B\xEC\x81\xEC\xCC\xCC\xCC\xCC\x56\x57\x8B\xF9\xC7\x45") or error("signature for load_name_sky is outdated")
    vars.skybox.load_name_sky = ffi_cast(ffi_typeof("void(__fastcall*)(const char*)"), load_name_sky_address)

    vars.hidden_cvars.con_command_base = ffi_cast('c_con_command_base ***', ffi_cast('uint32_t', vars.hidden_cvars.v_engine_cvar) + 0x34)[0][0]
    vars.hidden_cvars.cmd = ffi_cast('c_con_command_base *', vars.hidden_cvars.con_command_base.next)

    while ffi_cast('uint32_t', vars.hidden_cvars.cmd) ~= 0 do
        if bit_band(vars.hidden_cvars.cmd.flags, 18) then
            table_insert(vars.hidden_cvars.cvars, vars.hidden_cvars.cmd)
        end
        vars.hidden_cvars.cmd = ffi_cast('c_con_command_base *', vars.hidden_cvars.cmd.next)
    end

    world_tab:init()
    misc_tab:init()

    world_tab:setup_dependencies()
    misc_tab:setup_dependencies()

    world_tab:setup_tab_dependencies()
    misc_tab:setup_tab_dependencies()

    setup_callbacks()
end

setup()

-- ============================================
-- EVENT CALLBACKS
-- ============================================

client_set_event_callback("player_connect_full", function(event)
    if client_userid_to_entindex(event.userid) == entity_get_local_player() then
        vars.skybox.old_skybox = client_get_cvar("sv_skyname")
        callbacks.skybox_override()
    end
    if globals_mapname() == nil then
        vars.effects.bloom_default = nil
        vars.effects.exposure_min_default = nil
        vars.effects.exposure_max_default = nil
        vars.effects.bloom_prev = nil
        vars.effects.exposure_prev = nil
    end
end)

client_set_event_callback("paint", function()
    callbacks.effects_update()
end)

client_set_event_callback("setup_command", function()
    callbacks.unsafe_charge()
end)

client_set_event_callback("level_init", function()
    vars.unsafe_charge.timer = globals_tickcount()
end)

client_set_event_callback("round_prestart", function()
	callbacks.autobuy()
end)

client_set_event_callback("shutdown", function()
    world_tab:restore()
    misc_tab:restore()

    vars.unsafe_charge.aimbot:set(true)
end)


client_set_event_callback("game_newmap", function()
    if globals_mapname() == nil then
        vars.effects.bloom_default = nil
        vars.effects.exposure_min_default = nil
        vars.effects.exposure_max_default = nil
        vars.effects.bloom_prev = nil
        vars.effects.exposure_prev = nil
    end
end)