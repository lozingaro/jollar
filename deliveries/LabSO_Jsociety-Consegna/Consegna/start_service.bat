cd %~dp0
start jolie core.ol
timeout /t 2
start jolie networkVisualizer.ol
timeout /t 2
start jolie peer1.ol | start jolie peer2.ol | start jolie peer3.ol | start jolie peer4.ol
