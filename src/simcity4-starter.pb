;
; ------------------------------------------------------------
;
;   SimCity 4 - starter / launcher
;
; ------------------------------------------------------------
;

Enumeration
  #Window_Main

  #Text_Info
  #Text_GamePath
  #Text_ConfigPath
  #Text_Requirement

  #Check_EnableIntroVideo
  #Check_PauseGameOnFocusLoss
  #Check_ForceDrawOnScroll

  #Text_Driver
  #Combo_Driver

  #Text_WindowMode
  #Combo_WindowMode

  #Text_Resolution
  #Combo_Resolution

  #Text_ColorDepth
  #Combo_ColorDepth

  #Button_Start
  #Button_SaveOnly
  #Button_Quit
EndEnumeration


Procedure.s BoolText(CheckState.i)
  If CheckState = #PB_Checkbox_Checked
    ProcedureReturn "true"
  Else
    ProcedureReturn "false"
  EndIf
EndProcedure


Procedure SetComboByText(Gadget.i, Value.s)
  Protected i.i

  For i = 0 To CountGadgetItems(Gadget) - 1
    If GetGadgetItemText(Gadget, i) = Value
      SetGadgetState(Gadget, i)
      ProcedureReturn
    EndIf
  Next

  SetGadgetState(Gadget, 0)
EndProcedure


Procedure.s GetCurrentComboText(Gadget.i)
  Protected Text.s

  Text = GetGadgetText(Gadget)

  If Text = "" And CountGadgetItems(Gadget) > 0
    Text = GetGadgetItemText(Gadget, 0)
  EndIf

  ProcedureReturn Text
EndProcedure

Procedure SaveStarterSettings(SettingsFile.s)

  If CreatePreferences(SettingsFile)

    WritePreferenceInteger("EnableIntroVideo", GetGadgetState(#Check_EnableIntroVideo))
    WritePreferenceInteger("PauseGameOnFocusLoss", GetGadgetState(#Check_PauseGameOnFocusLoss))
    WritePreferenceInteger("ForceDrawOnScroll", GetGadgetState(#Check_ForceDrawOnScroll))

    WritePreferenceString("Driver", GetCurrentComboText(#Combo_Driver))
    WritePreferenceString("WindowMode", GetCurrentComboText(#Combo_WindowMode))
    WritePreferenceString("Resolution", GetCurrentComboText(#Combo_Resolution))
    WritePreferenceString("ColorDepth", GetCurrentComboText(#Combo_ColorDepth))

    ClosePreferences()

  EndIf

EndProcedure

Procedure LoadStarterSettings(SettingsFile.s)

  Protected EnableIntroVideo.i
  Protected PauseGameOnFocusLoss.i
  Protected ForceDrawOnScroll.i
  Protected Driver.s
  Protected WindowMode.s
  Protected Resolution.s
  Protected ColorDepth.s

  EnableIntroVideo = #PB_Checkbox_Checked
  PauseGameOnFocusLoss = #PB_Checkbox_Unchecked
  ForceDrawOnScroll = #PB_Checkbox_Unchecked

  Driver = "DirectX"
  WindowMode = "BorderlessFullScreen"
  Resolution = "1920x1080"
  ColorDepth = "32"

  If OpenPreferences(SettingsFile)

    EnableIntroVideo = ReadPreferenceInteger("EnableIntroVideo", EnableIntroVideo)
    PauseGameOnFocusLoss = ReadPreferenceInteger("PauseGameOnFocusLoss", PauseGameOnFocusLoss)
    ForceDrawOnScroll = ReadPreferenceInteger("ForceDrawOnScroll", ForceDrawOnScroll)

    Driver = ReadPreferenceString("Driver", Driver)
    WindowMode = ReadPreferenceString("WindowMode", WindowMode)
    Resolution = ReadPreferenceString("Resolution", Resolution)
    ColorDepth = ReadPreferenceString("ColorDepth", ColorDepth)

    ClosePreferences()

  EndIf

  SetGadgetState(#Check_EnableIntroVideo, EnableIntroVideo)
  SetGadgetState(#Check_PauseGameOnFocusLoss, PauseGameOnFocusLoss)
  SetGadgetState(#Check_ForceDrawOnScroll, ForceDrawOnScroll)

  SetComboByText(#Combo_Driver, Driver)
  SetComboByText(#Combo_WindowMode, WindowMode)
  SetComboByText(#Combo_Resolution, Resolution)
  SetComboByText(#Combo_ColorDepth, ColorDepth)

EndProcedure

Procedure.i SaveSC4GraphicsConfig(ConfigFile.s)

  Protected Resolution.s
  Protected Width.s
  Protected Height.s
  Protected Driver.s
  Protected WindowMode.s
  Protected ColorDepth.s
  Protected ConfigDir.s

  ConfigDir = GetPathPart(ConfigFile)

  If FileSize(ConfigDir) <> -2
    CreateDirectory(ConfigDir)
  EndIf

  Resolution = GetCurrentComboText(#Combo_Resolution)
  Width = Trim(StringField(Resolution, 1, "x"))
  Height = Trim(StringField(Resolution, 2, "x"))

  Driver = GetCurrentComboText(#Combo_Driver)
  WindowMode = GetCurrentComboText(#Combo_WindowMode)
  ColorDepth = GetCurrentComboText(#Combo_ColorDepth)

  If CreateFile(0, ConfigFile)

    WriteStringN(0, "[GraphicsOptions]")
    WriteStringN(0, "EnableIntroVideo=" + BoolText(GetGadgetState(#Check_EnableIntroVideo)))
    WriteStringN(0, "PauseGameOnFocusLoss=" + BoolText(GetGadgetState(#Check_PauseGameOnFocusLoss)))
    WriteStringN(0, "ForceDrawOnScroll=" + BoolText(GetGadgetState(#Check_ForceDrawOnScroll)))
    WriteStringN(0, "Driver=" + Driver)
    WriteStringN(0, "WindowWidth=" + Width)
    WriteStringN(0, "WindowHeight=" + Height)
    WriteStringN(0, "ColorDepth=" + ColorDepth)
    WriteStringN(0, "WindowMode=" + WindowMode)

    CloseFile(0)

    ProcedureReturn #True

  EndIf

  ProcedureReturn #False

EndProcedure

Procedure StartGame(GameExe.s, ConfigFile.s, SettingsFile.s)

  If FileSize(GameExe) < 0
    MessageRequester("Error", "I can't find the game here:" + Chr(10) + GameExe)
    ProcedureReturn
  EndIf

  SaveStarterSettings(SettingsFile)

  If SaveSC4GraphicsConfig(ConfigFile) = #False
    MessageRequester("Error", "Config file saving error:" + Chr(10) + ConfigFile + Chr(10) + Chr(10) + "Administrator privileges may be required.")
    ProcedureReturn
  EndIf

  If RunProgram(GameExe, "", GetPathPart(GameExe)) = 0
    MessageRequester("Error", "I can't launch the game:" + Chr(10) + GameExe)
  Else
    End
  EndIf

EndProcedure

BaseDir.s = GetCurrentDirectory()
GameExe.s = BaseDir + "Apps\SimCity 4.exe"
ConfigFile.s = BaseDir + "Plugins\SC4GraphicsOptions.ini"
SettingsFile.s = BaseDir + "starter-settings.ini"


If OpenWindow(#Window_Main, 100, 200, 560, 455, "SimCity 4 - starter", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)

  TextGadget(#Text_Info, 20, 15, 510, 20, "The launcher automatically saves the config, then starts the game.")

  TextGadget(#Text_GamePath, 20, 45, 510, 20, "Game: " + GameExe)
  TextGadget(#Text_ConfigPath, 20, 70, 510, 20, "Config: " + ConfigFile)

  TextGadget(#Text_Requirement, 20, 100, 510, 52, "Required: sc4-graphics-options (https://github.com/0xC0000054/sc4-graphics-options) must be installed in the Plugins folder.", #PB_Text_Border)

  CheckBoxGadget(#Check_EnableIntroVideo, 20, 175, 300, 24, "Enable intro video")
  CheckBoxGadget(#Check_PauseGameOnFocusLoss, 20, 205, 300, 24, "Pause game when focus is lost")
  CheckBoxGadget(#Check_ForceDrawOnScroll, 20, 235, 300, 24, "Force draw on scroll")

  TextGadget(#Text_Driver, 20, 280, 120, 20, "Renderer:")
  ComboBoxGadget(#Combo_Driver, 150, 275, 190, 25)
  AddGadgetItem(#Combo_Driver, -1, "DirectX")
  AddGadgetItem(#Combo_Driver, -1, "OpenGL")
  AddGadgetItem(#Combo_Driver, -1, "SCGL")
  AddGadgetItem(#Combo_Driver, -1, "Software")

  TextGadget(#Text_WindowMode, 20, 315, 120, 20, "Window mode:")
  ComboBoxGadget(#Combo_WindowMode, 150, 310, 190, 25)
  AddGadgetItem(#Combo_WindowMode, -1, "Windowed")
  AddGadgetItem(#Combo_WindowMode, -1, "FullScreen")
  AddGadgetItem(#Combo_WindowMode, -1, "BorderlessFullScreen")
  AddGadgetItem(#Combo_WindowMode, -1, "Borderless")

  TextGadget(#Text_Resolution, 20, 350, 120, 20, "Resolution:")
  ComboBoxGadget(#Combo_Resolution, 150, 345, 190, 25)
  AddGadgetItem(#Combo_Resolution, -1, "800x600")
  AddGadgetItem(#Combo_Resolution, -1, "1024x768")
  AddGadgetItem(#Combo_Resolution, -1, "1280x720")
  AddGadgetItem(#Combo_Resolution, -1, "1280x1024")
  AddGadgetItem(#Combo_Resolution, -1, "1366x768")
  AddGadgetItem(#Combo_Resolution, -1, "1600x900")
  AddGadgetItem(#Combo_Resolution, -1, "1920x1080")
  AddGadgetItem(#Combo_Resolution, -1, "2560x1440")
  AddGadgetItem(#Combo_Resolution, -1, "3840x2160")

  TextGadget(#Text_ColorDepth, 20, 385, 120, 20, "Color depth:")
  ComboBoxGadget(#Combo_ColorDepth, 150, 380, 190, 25)
  AddGadgetItem(#Combo_ColorDepth, -1, "16")
  AddGadgetItem(#Combo_ColorDepth, -1, "32")

  ButtonGadget(#Button_Start, 360, 340, 150, 32, "Save and start")
  ButtonGadget(#Button_SaveOnly, 360, 377, 150, 28, "Save only")
  ButtonGadget(#Button_Quit, 360, 410, 150, 28, "Quit")

  LoadStarterSettings(SettingsFile)

  Repeat
    Event = WaitWindowEvent()

    Select Event

      Case #PB_Event_CloseWindow
        Quit = 1

      Case #PB_Event_Gadget

        Select EventGadget()

          Case #Button_Start
            StartGame(GameExe, ConfigFile, SettingsFile)

          Case #Button_SaveOnly
            SaveStarterSettings(SettingsFile)

            If SaveSC4GraphicsConfig(ConfigFile)
              MessageRequester("Success", "Settings saved:" + Chr(10) + ConfigFile)
            Else
              MessageRequester("Error", "Could not save:" + Chr(10) + ConfigFile)
            EndIf

          Case #Button_Quit
            Quit = 1

        EndSelect

    EndSelect

  Until Quit = 1

EndIf

End
; IDE Options = PureBasic 6.40 (Windows - x86)
; CursorPosition = 201
; FirstLine = 183
; Folding = --
; EnableXP
; DPIAware
; Executable = ..\sim4-starter.exe
