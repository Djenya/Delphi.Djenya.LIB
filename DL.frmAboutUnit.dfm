object DLfrmAbout: TDLfrmAbout
  Left = 0
  Top = 0
  AutoSize = True
  BorderStyle = bsNone
  Caption = #1054' '#1087#1088#1086#1075#1077
  ClientHeight = 489
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    377
    489)
  PixelsPerInch = 96
  TextHeight = 13
  object ImagePicture: TImage
    Left = 0
    Top = 0
    Width = 377
    Height = 489
    Cursor = crHandPoint
    AutoSize = True
    OnClick = ImagePictureClick
  end
  object lblNameProgram: TLabel
    Left = 8
    Top = 8
    Width = 233
    Height = 32
    Cursor = crHelp
    Hint = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103
    Alignment = taCenter
    Anchors = []
    AutoSize = False
    Caption = '%Name Programm%'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 22207
    Font.Height = -28
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    WordWrap = True
    OnClick = ImagePictureClick
  end
  object lblSNameProgram: TLabel
    Left = 8
    Top = 4
    Width = 168
    Height = 13
    Caption = '%Shadow Name Programm%'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
end
