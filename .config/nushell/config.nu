# Nushell config: only what differs from the defaults (see `config nu --doc`).

$env.config.buffer_editor = "hx"
$env.config.edit_mode = "vi"
$env.config.cursor_shape = { emacs: underscore vi_insert: line vi_normal: block }
$env.config.filesize.unit = "binary"

# Added after the defaults, so these win for the same keys
$env.config.keybindings ++= [
    {
      name: fuzzy_history
      modifier: control
      keycode: char_r
      mode: [emacs, vi_normal, vi_insert]
      event: [
        {
          send: ExecuteHostCommand
          cmd: "do {
            commandline edit --insert (
              history
              | get command
              | reverse
              | uniq
              | str join (char -i 0)
              | fzf --scheme=history 
                  --read0
                  --layout=reverse
                  --height=40%
                  --bind 'ctrl-/:change-preview-window(right,70%|right)'
                  --preview='echo -n {} | nu --stdin -c \'nu-highlight\''
                  # Run without existing commandline query for now to test composability
                  # -q (commandline)
              | decode utf-8
              | str trim
            )
          }"
        }
      ]
    }
    {
        name: ide_completion_menu_ctrl_n
        modifier: control
        keycode: char_n
        mode: [emacs vi_normal vi_insert]
        event: {
            until: [
                { send: menu name: ide_completion_menu }
                { send: menunext }
                { edit: complete }
            ]
        }
    }
    {
        name: move_down_control_char_t
        modifier: control
        keycode: char_t
        mode: [emacs, vi_normal, vi_insert]
        event: {
            until: [
                { send: menudown }
                { send: down }
            ]
        }
    }
    {
        name: escape
        modifier: none
        keycode: escape
        mode: [emacs, vi_normal, vi_insert]
        event: { send: esc }    # NOTE: does not appear to work
    }
]

alias l = ls -al
alias vi = nvim
alias pn = pnpm

# mise.nu is generated in env.nu
if (which mise | is-not-empty) {
    use ($nu.default-config-dir | path join mise.nu)
}
