object DLMDIFormMain: TDLMDIFormMain
  Left = 0
  Top = 0
  ClientHeight = 542
  ClientWidth = 784
  Color = clBtnFace
  Constraints.MinHeight = 600
  Constraints.MinWidth = 800
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = mMain
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object imgBackground: TImage
    Left = 0
    Top = 0
    Width = 784
    Height = 503
    Align = alClient
    Stretch = True
    ExplicitLeft = -136
    ExplicitTop = -84
    ExplicitWidth = 792
    ExplicitHeight = 583
  end
  object pnlMainFooter: TPanel
    Left = 0
    Top = 503
    Width = 784
    Height = 20
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object lblHintCtrlTab: TLabel
      Left = 0
      Top = 0
      Width = 57
      Height = 20
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = 'Ctrl+Tab'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = -6
    end
    object TabSet: TTabSet
      Left = 57
      Top = 0
      Width = 559
      Height = 20
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      SelectedColor = 16510167
      SoftTop = True
      Style = tsModernPopout
      OnChange = TabSetChange
    end
    object lblHintServer: TStaticText
      Left = 700
      Top = 0
      Width = 84
      Height = 20
      Align = alRight
      Alignment = taCenter
      BorderStyle = sbsSingle
      Caption = '                    '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
    end
    object lblHintLogin: TStaticText
      Left = 616
      Top = 0
      Width = 84
      Height = 20
      Align = alRight
      Alignment = taCenter
      BorderStyle = sbsSingle
      Caption = '                    '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
    end
  end
  object MainStatusBar: TStatusBar
    Left = 0
    Top = 523
    Width = 784
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Width = 75
      end
      item
        Alignment = taCenter
        Width = 70
      end
      item
        Alignment = taCenter
        Width = 155
      end
      item
        Alignment = taCenter
        Width = 50
      end
      item
        Alignment = taCenter
        Width = 50
      end
      item
        Alignment = taCenter
        Width = 50
      end
      item
        Alignment = taCenter
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object cmdListMain: TActionList
    Images = dmMain.ImageList1
    Left = 16
    Top = 120
    object cmdCheckVersionsServer: TAction
      Category = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077
      Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1103
      ImageIndex = 29
      OnExecute = cmdCheckVersionsServerExecute
    end
    object cmdUpdate: TAction
      Category = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077
      Caption = 'cmdUpdate'
      OnExecute = cmdUpdateExecute
    end
    object cmdUpload: TAction
      Category = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077
      Caption = 'cmdUpload'
      OnExecute = cmdUploadExecute
    end
    object cmdfrmAbout: TAction
      Category = #1057#1087#1088#1072#1074#1082#1072
      Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077'...'
      Hint = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1090#1077#1082#1091#1097#1077#1081' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      ImageIndex = 2
      ShortCut = 112
      OnExecute = cmdfrmAboutExecute
    end
    object cmdConnect: TAction
      Category = #1057#1077#1088#1074#1077#1088
      Caption = 'cmdConnect'
      OnExecute = cmdConnectExecute
    end
    object cmdChangeUser: TAction
      Category = #1057#1077#1088#1074#1077#1088
      Caption = #1057#1084#1077#1085#1080#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103'...'
      Hint = #1047#1072#1081#1090#1080' '#1086#1090' '#1080#1084#1077#1085#1080' '#1076#1088#1091#1075#1086#1075#1086' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      ImageIndex = 56
      OnExecute = cmdChangeUserExecute
    end
    object cmdReconnect: TAction
      Category = #1057#1077#1088#1074#1077#1088
      Caption = #1055#1077#1088#1077#1087#1086#1076#1082#1083#1102#1095#1080#1090#1089#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1091'...'
      Hint = #1055#1077#1088#1077#1087#1086#1076#1082#1083#1102#1095#1080#1090#1089#1103' '#1082' '#1089#1077#1088#1074#1077#1088#1091' '#1080' '#1086#1073#1085#1086#1074#1080#1090#1100' '#1076#1072#1085#1085#1099#1077
      ImageIndex = 0
      OnExecute = cmdReconnectExecute
    end
    object cmdCreatePopupMenu: TAction
      Caption = 'cmdCreatePopupMenu'
      OnExecute = cmdCreatePopupMenuExecute
    end
  end
  object mMain: TMainMenu
    Images = dmMain.ImageList1
    Left = 16
    Top = 168
    object N6: TMenuItem
      Caption = #1060#1072#1081#1083
      GroupIndex = 10
      object cmdReconnect1: TMenuItem
        Action = cmdReconnect
      end
      object cmdChangeUser1: TMenuItem
        Action = cmdChangeUser
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object N9: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = N9Click
      end
    end
    object N2: TMenuItem
      Caption = #1042#1080#1076
      GroupIndex = 20
    end
    object N12: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082#1080
      GroupIndex = 30
    end
    object N11: TMenuItem
      Caption = #1054#1090#1095#1077#1090#1099
      GroupIndex = 40
    end
    object N3: TMenuItem
      Caption = #1057#1077#1088#1074#1080#1089
      GroupIndex = 50
      object N14: TMenuItem
        Action = cmdCheckVersionsServer
      end
    end
    object N10: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      GroupIndex = 60
      object N1: TMenuItem
        Action = cmdfrmAbout
      end
    end
  end
  object TimerCheckUpdate: TTimer
    Enabled = False
    Interval = 150000
    OnTimer = TimerCheckUpdateTimer
    Left = 16
    Top = 216
  end
  object RegPSMEhDjenyaSoft: TRegPropStorageManEh
    Left = 16
    Top = 72
  end
  object StatusTimer: TTimer
    Interval = 250
    OnTimer = StatusTimerTimer
    Left = 16
    Top = 464
  end
  object ApplicationEvents: TApplicationEvents
    OnHint = ApplicationEventsHint
    Left = 48
    Top = 464
  end
end
