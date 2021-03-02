SET TEST=echo
SET TEST=
%TEST% git status
%TEST% git add *
%TEST% git commit -m "Update %DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%-%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%"
%TEST% git push
pause