object frm: Tfrm
  Left = 0
  Top = 0
  AutoSize = True
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  BorderWidth = 10
  Caption = 'DEMO DjenyaLibDialog'
  ClientHeight = 118
  ClientWidth = 160
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 16
  object bt0: TButton
    Left = 0
    Top = 0
    Width = 160
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = bt0Click
  end
  object bt2: TButton
    Left = 0
    Top = 62
    Width = 160
    Height = 25
    Caption = 'YES + NO'
    TabOrder = 2
    OnClick = bt2Click
  end
  object bt3: TButton
    Left = 0
    Top = 93
    Width = 160
    Height = 25
    Caption = 'YES + NO + CANCEL'
    TabOrder = 3
    OnClick = bt3Click
  end
  object bt1: TButton
    Left = 0
    Top = 32
    Width = 160
    Height = 25
    Caption = 'OK + CANCEL'
    TabOrder = 1
    OnClick = bt1Click
  end
end
