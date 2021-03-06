object DLfrmReference: TDLfrmReference
  Left = 0
  Top = 0
  Caption = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082
  ClientHeight = 562
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  ShowHint = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object pnlButon: TPanel
    Left = 0
    Top = 524
    Width = 784
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      784
      38)
    object btnCancel: TButton
      Left = 701
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1047#1072#1082#1088#1099#1090#1100
      ModalResult = 2
      TabOrder = 1
    end
    object btnOk: TButton
      Left = 620
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1042#1099#1073#1088#1072#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
  end
  object pnlFilter: TPanel
    Left = 0
    Top = 0
    Width = 784
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      784
      41)
    object Label1: TLabel
      Left = 10
      Top = 14
      Width = 40
      Height = 16
      Caption = #1053#1072#1081#1090#1080':'
    end
    object edtFilter: TEdit
      Left = 56
      Top = 11
      Width = 639
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = edtFilterChange
      OnKeyDown = edtFilterKeyDown
    end
    object btnFind: TButton
      Left = 701
      Top = 10
      Width = 75
      Height = 25
      Action = cmdRefresh
      Anchors = [akTop, akRight]
      TabOrder = 1
    end
  end
  object pnlContent: TPanel
    Left = 0
    Top = 41
    Width = 784
    Height = 483
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object dbNavigatorContent: TDBNavigator
      Left = 0
      Top = 458
      Width = 784
      Height = 25
      DataSource = dsContent
      VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
      Align = alBottom
      Hints.Strings = (
        #1053#1072' '#1087#1077#1088#1074#1091#1102' '#1079#1072#1087#1080#1089#1100
        #1055#1088#1077#1076#1099#1076#1091#1097#1072#1103' '#1079#1072#1087#1080#1089#1100
        #1057#1083#1077#1076#1091#1102#1097#1072#1103' '#1079#1072#1087#1080#1089#1100
        #1055#1086#1089#1083#1077#1076#1085#1103#1103' '#1079#1072#1087#1080#1089#1100
        #1044#1086#1073#1072#1074#1080#1090#1100' '#1079#1072#1087#1080#1089#1100
        #1059#1076#1072#1083#1080#1090#1100' '#1079#1072#1087#1080#1089#1100
        #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1079#1072#1087#1080#1089#1100
        #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1079#1072#1087#1080#1089#1100
        #1054#1090#1084#1077#1085#1072' '#1074#1074#1086#1076#1072)
      TabOrder = 0
    end
    object grdContent: TDBGridEh
      Left = 0
      Top = 0
      Width = 784
      Height = 458
      Align = alClient
      DataSource = dsContent
      DynProps = <>
      FooterParams.Color = clWindow
      IndicatorOptions = [gioShowRowIndicatorEh]
      TabOrder = 1
      OnDblClick = grdContentDblClick
      object RowDetailData: TRowDetailPanelControlEh
      end
    end
  end
  object dsContent: TDataSource
    Left = 24
    Top = 200
  end
  object mnActionList: TActionList
    Images = DLdmMain.ImageList1
    Left = 24
    Top = 152
    object cmdSave: TAction
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      OnExecute = cmdSaveExecute
    end
    object cmdCancel: TAction
      Caption = #1054#1090#1084#1077#1085#1072
      OnExecute = cmdCancelExecute
    end
    object cmdRefresh: TAction
      Caption = #1053#1072#1081#1090#1080
      OnExecute = cmdRefreshExecute
    end
  end
end
