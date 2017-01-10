nasm bacteria.asm -o bacteria.com
call :getfilesize bacteria.com rawsize
zx7b bacteria.com bacteria.com.zx7b
nasm bacteria_dzx7b.asm -o bacteria_dzx7b.com
goto :eof

:getfilesize
echo  %%define  %2  %~z1 > define.asm
goto :eof