# Two-line Nushell prompt: directory + git + nix shell on line 1, ❯ on line 2.

def __prompt_dir [] {
    let home = $env.HOME
    let pwd = $env.PWD
    let path = if ($pwd | str starts-with $home) {
        $"~($pwd | str substring ($home | str length)..)"
    } else { $pwd }
    $"(ansi cyan)($path)(ansi reset)"
}

def __prompt_git [] {
    let inside = (do --ignore-errors { git rev-parse --is-inside-work-tree } | complete)
    if $inside.exit_code != 0 { return "" }

    let branch_raw = (do --ignore-errors { git symbolic-ref --short HEAD }
        | complete | get stdout | str trim)
    let branch = if ($branch_raw | is-empty) {
        (do --ignore-errors { git rev-parse --short HEAD } | complete | get stdout | str trim)
    } else { $branch_raw }

    let porcelain = (do --ignore-errors { git status --porcelain=v1 }
        | complete | get stdout | lines)

    let staged = ($porcelain
        | where { |l| ($l | str length) >= 2 and (($l | split chars | get 0) in ['M' 'A' 'D' 'R' 'C']) }
        | length)
    let modified = ($porcelain
        | where { |l| ($l | str length) >= 2 and (($l | split chars | get 1) in ['M' 'D']) }
        | length)
    let untracked = ($porcelain | where { |l| $l | str starts-with "??" } | length)

    let upstream = (do --ignore-errors { git rev-list --left-right --count '@{u}...HEAD' }
        | complete)
    let counts = if $upstream.exit_code == 0 {
        let parts = ($upstream.stdout | str trim | split row "\t")
        { behind: ($parts | get 0 | into int), ahead: ($parts | get 1 | into int) }
    } else { { behind: 0, ahead: 0 } }

    mut bits = [$"(ansi purple) ($branch)(ansi reset)"]
    if $counts.ahead  > 0 { $bits = ($bits | append $"(ansi green)⇡($counts.ahead)(ansi reset)") }
    if $counts.behind > 0 { $bits = ($bits | append $"(ansi green)⇣($counts.behind)(ansi reset)") }
    if $staged        > 0 { $bits = ($bits | append $"(ansi green)+($staged)(ansi reset)") }
    if $modified      > 0 { $bits = ($bits | append $"(ansi yellow)!($modified)(ansi reset)") }
    if $untracked     > 0 { $bits = ($bits | append $"(ansi red)?($untracked)(ansi reset)") }
    " " + ($bits | str join " ")
}

def __prompt_nix [] {
    if "IN_NIX_SHELL" in $env { $"(ansi blue)  nix(ansi reset)" } else { "" }
}

$env.PROMPT_COMMAND = {|| $"(__prompt_dir)(__prompt_git)(__prompt_nix)(char newline)" }
$env.PROMPT_COMMAND_RIGHT = ""

$env.PROMPT_INDICATOR = {||
    let color = if $env.LAST_EXIT_CODE == 0 { ansi green } else { ansi red }
    $"($color)❯(ansi reset) "
}
$env.PROMPT_INDICATOR_VI_INSERT = $env.PROMPT_INDICATOR
$env.PROMPT_INDICATOR_VI_NORMAL = {|| $"(ansi yellow)❮(ansi reset) " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }
