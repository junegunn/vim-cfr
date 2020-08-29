let s:jar = expand('<sfile>:h:h') .. '/cfr-latest.jar'

function! s:download() abort
  let json = json_decode(system('curl -sL https://api.github.com/repos/leibnitz27/cfr/releases/latest'))
  let url = json['assets'][0]['browser_download_url']
  echohl WarningMsg | echom 'Downloading cfr.jar from ' .. url | echohl None
  call system(printf('curl -sL %s -o %s', url, s:jar))
endfunction

function! s:decompile(class) abort
  if !filereadable(s:jar)
    call s:download()
  endif

  setlocal bufhidden=hide noswapfile filetype=java modifiable
  let command = printf('java -jar %s %s', s:jar, a:class)
  let lines = systemlist(command)
  if v:shell_error
    echoerr printf('Failed to run %s (%d)', command, v:shell_error)
    return
  endif

  normal! gg"_dG
  call setline(1, lines)
  setlocal nomodifiable
endfunction

function! s:nope()
  echohl WarningMsg | echom 'Nope.' | echohl None
endfunction

augroup vim-cfr
  autocmd!
  autocmd BufReadCmd *.class call <sid>decompile(expand('<afile>'))
  autocmd BufWriteCmd *.class call <sid>nope()
augroup END
