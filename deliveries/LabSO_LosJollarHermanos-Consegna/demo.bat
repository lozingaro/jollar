START /MIN "timestamp" call "timestamp.bat"
timeout 1
START  "netview" call "NetVisualizer.bat"
timeout 2
START /MIN "serverA" call "serverA.bat"
timeout 1
START /MIN "serverB" call "serverB.bat"
timeout 1
START /MIN "serverC" call "serverC.bat"
timeout 1
START /MIN "serverD" call "serverD.bat"
timeout 3
START /MIN "clientA" call "clientA.bat"
timeout 1
START /MIN "clientB" call "clientB.bat"
timeout 1
START /MIN "clientC" call "clientC.bat"
timeout 1
START /MIN "clientD" call "clientD.bat"
timeout 1
START /MIN "transactionA" call "tranA.bat"