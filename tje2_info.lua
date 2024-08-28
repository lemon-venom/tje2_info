console.log("Loading tje2 script")

config=
{
	["hk_format_toggle"] = "Ctrl+Shift+F"
}

color_green = 0xFF00FF00
color_black = 0xFF000000
color_red = 0xFFFF0000

format_toggle_pressed = false

FORMAT_MAX = 1
FORMAT_FIXED_POINT_12_4 = 0
FORMAT_FIXED_POINT_12_4_SCALED_PER_FRAME = 1
--FORMAT_INT = 2

format = FORMAT_FIXED_POINT_12_4

BUTTON_UP = 0x0001
BUTTON_DOWN = 0x0002
BUTTON_LEFT = 0x0004
BUTTON_RIGHT = 0x0008
BUTTON_A = 0x0040
BUTTON_B = 0x0010
BUTTON_C = 0x0020
BUTTON_START = 0x0080
BUTTON_MODE = 0x8000
BUTTON_X = 0x4000
BUTTON_Y = 0x2000
BUTTON_Z = 0x1000

function onconsoleclose()
    gui.clearGraphics()
end

function draw_gamepad_input_state(x_pos, y_pos)
    
    local prev_button_flags = mainmemory.read_u16_be(0x8570)

    local button_flags = mainmemory.read_u16_be(0x8580)

    gui.drawText(x_pos, y_pos, "input: ", color_green, color_black) 

    char_width = 8
    char_x = x_pos + 45
    char_y = y_pos

    buttons = { 
        [1]  = { id = BUTTON_UP,    label = "U" },
        [2]  = { id = BUTTON_DOWN,  label = "D" }, 
        [3]  = { id = BUTTON_LEFT,  label = "L" },  
        [4]  = { id = BUTTON_RIGHT, label = "R" },  
        [5]  = { id = BUTTON_A,     label = "A" },  
        [6]  = { id = BUTTON_B,     label = "B" },  
        [7]  = { id = BUTTON_C,     label = "C" },  
        [8]  = { id = BUTTON_START, label = "S" },  
        [9]  = { id = BUTTON_MODE,  label = "M" },  
        [10] = { id = BUTTON_X,     label = "X" },  
        [11] = { id = BUTTON_Y,     label = "Y" },  
        [12] = { id = BUTTON_Z,     label = "Z" } 
    }

    for i, button in ipairs(buttons) do

        if (button_flags & button.id) > 0 then

            color = color_green
    
            -- Button not pressed last frame, show it as red
            if (prev_button_flags & button.id) == 0 then
                color = color_red
            end
            
            gui.drawText(char_x, char_y, button.label, color, 0xFF000000) 

        end

        char_x = char_x + char_width

    end
        

end

function draw_scalar(label, x_pos, y_pos, val)
    gui.drawText(x_pos, y_pos, label .. "=" .. val, color_green, color_black) 
end

function draw_scalar_by_address(label, addr, x_pos, y_pos, honor_format, is_fractional, is_signed)
    val = 0
    
    if is_signed == true then
        val = mainmemory.read_s16_be(addr)
    else
        val = mainmemory.read_u16_be(addr)
    end

    local l_format = -1

    -- divide by 16 to convert the int value to a fixed point number
    -- then divide by 16 again to get the amount per frame
    -- multiply by 60 to get per second (60FPS)
    if honor_format == true then
        l_format = format
    end

    if l_format == FORMAT_FIXED_POINT_12_4 then
        val = ((val / 16.0) / 16.0) * 60
    elseif l_format == FORMAT_FIXED_POINT_12_4_SCALED_PER_FRAME then
        val = (val / 16.0) / 16.0
    end

    str = tostring(val)

    gui.drawText(x_pos, y_pos, label .. "=" .. str, color_green, color_black) 
end

function draw_vec(label, x_pos, y_pos, addr_x, addr_y, honor_format, is_fractional, is_signed)
    
    x = 0
    
    if is_signed == true then
        x = mainmemory.read_s16_be(addr_x)
    else
        x = mainmemory.read_u16_be(addr_x)
    end

    if is_signed == true then
        y = mainmemory.read_s16_be(addr_y)
    else
        y = mainmemory.read_u16_be(addr_y)
    end
    
    local l_format = -1

    -- divide by 16 to convert the int value to a fixed point number
    -- then divide by 16 again to get the amount per frame
    -- multiply by 60 to get per second (60FPS)
    if honor_format == true then
        l_format = format
    end

    if l_format == FORMAT_FIXED_POINT_12_4 then
        x = ((x / 16.0) / 16.0) * 60
        y = ((y/ 16.0) / 16.0) * 60
    elseif l_format == FORMAT_FIXED_POINT_12_4_SCALED_PER_FRAME then
        x = (x / 16.0) / 16.0
        y = (y / 16.0) / 16.0
    end

    if l_format ~= FORMAT_FIXED_POINT_12_4 and l_format ~= FORMAT_FIXED_POINT_12_4_SCALED_PER_FRAME then
        --x_str = tostring(x) 
        --y_str = tostring(y) 
        x_str = string.format("%6d", x) 
        y_str = string.format("%6d", y) 
    else
        if is_fractional == true then
            x_str = string.format("%6.2f", x) 
            y_str = string.format("%6.2f", y) 
        else    
            x_str = string.format("%6d", x) 
            y_str = string.format("%6d", y) 
        end
    end

    gui.drawText(x_pos, y_pos, label .. "=" .. x_str .. ", " .. y_str, color_green, color_black) 
    
end

-- Main worker
function onframe()

    gui.clearGraphics()

    -- Fill super jars, panic button, funk, coins, funkvacs, and hp
    mainmemory.write_u16_be(0xA91A, 7)  -- super jars
    mainmemory.write_u16_be(0xA91E, 5)  -- panic buttons
    mainmemory.write_u16_be(0xA920, 5)  -- funk vacs
    mainmemory.write_u16_be(0xA922, 99) -- coins
    mainmemory.write_u16_be(0xA928, 99) -- funk
    mainmemory.write_u16_be(0xA92A, 16) -- hp

    -- Draw the overlay
    draw_vec("p", 0, 0, 0x8DDC, 0x8DE4, false, false, false)
    
    draw_vec("v", 0, 15, 0x8DDE, 0x8DE6, true, true, true)
    
    draw_vec("a", 0, 30, 0x8DE0, 0x8DE8, true, true, true)

    draw_scalar_by_address("v_x_max", 0x8DE2, 0, 45, true, true, true)

    frame_count = emu.framecount()

    draw_scalar("frame", 225, 0, frame_count)
    
    draw_scalar("time", 130, 0, string.format("%.2f", (frame_count * (1.0 / 60.0))))
    
    if format == FORMAT_FIXED_POINT_12_4 then
        gui.drawText(130, 15, "px per sec", color_green, color_black) 
    elseif format == FORMAT_FIXED_POINT_12_4_SCALED_PER_FRAME then
        gui.drawText(130, 15, "px per frame", color_green, color_black) 
    end

    draw_gamepad_input_state(130, 30)

    -- Check for format toggle hotkey
    local input_rise = input.get()

    if input_rise[config.hk_format_toggle] then

        -- Only want to call this once. Keep track of when the hotkey is pressed and released
        if reset_pressed == false then

            format = format + 1

            if format > FORMAT_MAX then
                format = 0
            end
        end

        reset_pressed = true

    else    
        reset_pressed = false 
    end

end

event.onframestart(onframe)
event.onexit(function() exit = true end)
event.onconsoleclose(onconsoleclose)