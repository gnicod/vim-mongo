function! s:get_visual_selection()
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    return join(lines, "\n")
endfunction

function! s:ShowResultsInSplit(text)
    let windowNum = bufwinnr("__mongo_results__")
    if windowNum > -1
        execute(windowNum . "wincmd w")
    else
        " name our new split to be clear to the user
        vsplit __mongo_results__	
    endif

    " set syntax & clear
    setlocal filetype=javascript
    setlocal buftype=nofile
    normal! ggdG

    " add results
    call append(0, split(a:text, "\n"))
    normal! <CR>
    normal! gg
endfunction

function! MongoExecute() range
    if !exists("g:cli_mongo_db"):
        let g:cli_mongo_db = "test"
    endif
    if !exists("g:cli_mongo_username"):
        let cli_mongo_username = ""
    endif
    if !exists("g:cli_mongo_pass"):
        let cli_mongo_pass = ""
    endif
    if !exists("g:cli_mongo_host"):
        let cli_mongo_host = "localhost"
    endif

    let lines = s:get_visual_selection()
    " sucks, find another way
    silent execute "!rm /tmp/vimmongo_"
    redir > /tmp/vimmongo_
    echo  lines
    redir END
    let out = system("mongo --quiet --host ".g:cli_mongo_host." ".g:cli_mongo_db." < /tmp/vimmongo_")
    let res = s:ShowResultsInSplit(out)
endfunction

map <F5> :call MongoExecute()<CR>
