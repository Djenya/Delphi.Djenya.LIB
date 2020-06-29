object DLfrmSplash: TDLfrmSplash
  Left = 0
  Top = 0
  AutoSize = True
  BorderStyle = bsNone
  Caption = #1040#1074#1090#1086#1088#1080#1079#1072#1094#1080#1103
  ClientHeight = 258
  ClientWidth = 391
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ScreenSnap = True
  ShowHint = True
  SnapBuffer = 20
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object PanelLP: TPanel
    Left = 0
    Top = 0
    Width = 391
    Height = 258
    AutoSize = True
    BevelInner = bvLowered
    BevelKind = bkFlat
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    OnMouseDown = PanelLPMouseDown
    object imgSplash: TImage
      Left = 2
      Top = 2
      Width = 383
      Height = 250
      AutoSize = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblLoginS: TLabel
      Left = 7
      Top = 13
      Width = 88
      Height = 13
      Caption = '%Shadow Login%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblPswS: TLabel
      Left = 7
      Top = 24
      Width = 109
      Height = 13
      Caption = '%Shadow Password%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblNameS: TLabel
      Left = 7
      Top = 3
      Width = 141
      Height = 13
      Caption = '%Shadow Name Programm%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblIPCaption: TLabel
      Left = 177
      Top = 101
      Width = 54
      Height = 13
      Caption = 'IP '#1072#1076#1088#1077#1089':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblVersion: TLabel
      Left = 172
      Top = 6
      Width = 206
      Height = 16
      Hint = #1042#1077#1088#1089#1080#1103' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103
      Alignment = taRightJustify
      AutoSize = False
      Caption = #1042#1077#1088#1089#1080#1103': %VER%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblIP: TLabel
      Left = 234
      Top = 101
      Width = 137
      Height = 16
      Hint = #1042#1072#1096' IP '#1072#1076#1088#1077#1089
      AutoSize = False
      Caption = '%IP addres%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblSavePsw: TLabel
      Left = 177
      Top = 177
      Width = 125
      Height = 16
      Hint = #1055#1072#1088#1086#1083#1100' '#1073#1091#1076#1077#1090' '#1089#1086#1093#1088#1072#1085#1105#1085' '#1074' '#1079#1072#1096#1080#1092#1088#1086#1074#1072#1085#1085#1086#1084' '#1074#1080#1076#1077
      Alignment = taRightJustify
      AutoSize = False
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1087#1072#1088#1086#1083#1100
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      OnClick = lblSavePswClick
    end
    object imgIconProg: TImage
      Left = 52
      Top = 41
      Width = 32
      Height = 32
      Center = True
      Proportional = True
      Stretch = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblName: TLabel
      Left = 104
      Top = 24
      Width = 270
      Height = 58
      Alignment = taRightJustify
      AutoSize = False
      Caption = '%Name Programm%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -23
      Font.Name = 'Impact'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblHostName: TLabel
      Left = 234
      Top = 87
      Width = 137
      Height = 16
      Hint = #1042#1072#1096#1077' '#1080#1084#1103' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072
      AutoSize = False
      Caption = '%Host Name%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblHostNameCaption: TLabel
      Left = 187
      Top = 87
      Width = 44
      Height = 13
      Caption = #1048#1084#1103' '#1055#1050':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      OnMouseDown = PanelLPMouseDown
    end
    object lblLogin: TLabel
      Left = 92
      Top = 118
      Width = 79
      Height = 28
      Alignment = taRightJustify
      AutoSize = False
      Caption = #1051#1086#1075#1080#1085':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentFont = False
      OnMouseDown = PanelLPMouseDown
    end
    object lblPsw: TLabel
      Left = 92
      Top = 149
      Width = 79
      Height = 28
      Alignment = taRightJustify
      AutoSize = False
      Caption = #1055#1072#1088#1086#1083#1100':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentFont = False
      OnMouseDown = PanelLPMouseDown
    end
    object lblCopyright: TLabel
      Left = 100
      Top = 232
      Width = 279
      Height = 16
      Hint = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1087#1088#1072#1074#1072#1093' '#1087#1088#1086#1076#1091#1082#1090#1072
      Alignment = taRightJustify
      AutoSize = False
      Caption = #169' DjenyaSoftware. '#1050#1086#1088#1087#1086#1088#1072#1094#1080#1103' '#1048#1057#1044', 2011.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      Transparent = True
      OnMouseDown = PanelLPMouseDown
    end
    object btok: TBitBtn
      Left = 177
      Top = 200
      Width = 94
      Height = 25
      Hint = #1042#1086#1081#1090#1080' '#1074' '#1087#1088#1086#1075#1088#1072#1084#1084#1091
      Caption = '&OK'
      Default = True
      TabOrder = 2
      OnClick = btokClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      NumGlyphs = 2
    end
    object btCancel: TBitBtn
      Left = 277
      Top = 200
      Width = 94
      Height = 25
      Hint = #1042#1099#1093#1086#1076' '#1080#1079' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
      Caption = '&'#1054#1090#1084#1077#1085#1072
      TabOrder = 3
      Kind = bkCancel
    end
    object edLogin: TEdit
      Left = 177
      Top = 120
      Width = 194
      Height = 22
      Hint = #1042#1074#1077#1076#1080#1090#1077' '#1074#1072#1096#1077' "'#1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103'"'
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
    end
    object edPassword: TEdit
      Left = 177
      Top = 151
      Width = 194
      Height = 22
      Hint = #1042#1074#1077#1076#1080#1090#1077' '#1074#1072#1096' '#1087#1072#1088#1086#1083#1100' '#1076#1086#1089#1090#1091#1087#1072
      Ctl3D = False
      ParentCtl3D = False
      PasswordChar = '*'
      TabOrder = 1
    end
    object cbSavePas: TCheckBox
      Left = 177
      Top = 179
      Width = 12
      Height = 12
      TabStop = False
      TabOrder = 4
      OnClick = cbSavePasClick
    end
    object btnCustomCon: TBitBtn
      Left = 7
      Top = 228
      Width = 71
      Height = 20
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = btnCustomConClick
    end
  end
end
