Output demo.gif

Set Shell "powershell"
Set FontSize 14
Set Width 780
Set Height 440
Set Theme "Dracula"
Set Padding 16
Set TypingSpeed 80ms
Set PlaybackSpeed 1

Sleep 500ms

# --- are you ok ---
Type "# 你: are you ok"
Sleep 300ms
Enter
Sleep 200ms
Type "powershell -File assets/demo.ps1 -Mode agent"
Enter
Sleep 1500ms

Sleep 1s

# --- 雷总唱歌给我听 ---
Type "# 你: 雷总唱歌给我听"
Sleep 300ms
Enter
Sleep 200ms
Type "powershell -File assets/demo.ps1 -Mode easter"
Enter
Sleep 1500ms

Sleep 2s
