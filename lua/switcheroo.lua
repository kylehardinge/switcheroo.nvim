local api = vim.api
local buf, win
local current_color

local function center(str)
    local width = api.nvim_win_get_width(0)
    local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
    return string.rep(' ', shift) .. str
end

local function open_window()
    buf = api.nvim_create_buf(false, true)

    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    local width = api.nvim_get_option('columns')
    local height = api.nvim_get_option('lines')

    local win_width = math.ceil(width * 0.8)
    local win_height = math.ceil(height * 0.8 - 4)

    local col = math.ceil((width - win_width) / 2)
    local row = math.ceil((height - win_height) / 2 - 1)

    local opts = {
        style = 'minimal',
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
    }

    local border_opts = {
        style = 'minimal',
        relative = 'editor',
        width = win_width + 2,
        height = win_height + 2,
        row = row - 1,
        col = col - 1,
    }

    local border_buf = api.nvim_create_buf(false, true)

    local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
    local middle_line = '║' .. string.rep(' ', win_width) .. '║'
    for i = 1, win_height do
        table.insert(border_lines, middle_line)
    end
    table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')

    api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

    local border_win = api.nvim_open_win(border_buf, true, border_opts)
    win = api.nvim_open_win(buf, true, opts)
    api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

    api.nvim_win_set_option(win, 'cursorline', true)

    api.nvim_buf_set_lines(buf, 0, -1, false, { center("Switcheroo v0.0.1"), "" })
    api.nvim_buf_add_highlight(buf, -1, 'WhidHeader', 0, 0, -1)
end

local function update_view()
    local colors = vim.fn.getcompletion('', 'color')
    if #colors == 0 then table.insert(colors, '') end
    for k, _ in pairs(colors) do
        colors[k] = '  ' .. colors[k]
    end
    api.nvim_buf_set_lines(buf, 4, -1, false, colors)
    api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function close_window()
    api.nvim_win_close(win, true)
end

local function set_color()
    local str = api.nvim_get_current_line()
    close_window()
    api.nvim_command('edit ' .. str)
end

local function move_cursor()
    local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
    api.nvim_win_set_cursor(win, { new_pos, 0 })
end

local function get_current_color()
    api.nvim_buf_set_lines(buf, 2, -1, false, { center("Current color scheme: ") })
    api.nvim_buf_add_highlight(buf, -1, 'WhidSubHeader', 2, 0, -1)
end

local function set_mappings()
    local mappings = {
        ['<cr>'] = 'open_file()',
        q = 'close_window()',
        k = 'move_cursor()',
        j = 'move_cursor()'
    }
    for k, v in pairs(mappings) do
        api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"switcheroo".' .. v .. '<cr>', {
            nowait = true, noremap = true, silent = true
        })
    end
    local other_chars = {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'i', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
    }
    for k, v in ipairs(other_chars) do
        api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
        api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
        api.nvim_buf_set_keymap(buf, 'n', '<c-' .. v .. '>', '', { nowait = true, noremap = true, silent = true })
    end
end

local function switcheroo()
    open_window()
    get_current_color()
    set_mappings()
    update_view()
    api.nvim_win_set_cursor(win, { 3, 1 }) -- set cursor on first list entry
end


return {
    switcheroo = switcheroo,
    move_cursor = move_cursor,
    set_color = set_color,
    close_window = close_window
}
