unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, eventlog, SQLite3Conn, SQLDB, DB, SQLite3DS, Forms,
  Controls, Graphics, Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ColorBox,
  ValEdit, EditBtn, ComboEx, FileCtrl, Menus, DateTimePicker, Grids;

type

  { TMainForm }

  TMainForm = class(TForm)
    CreateNote: TButton;
    CheckBoxEdit: TCheckBox;
    Panel3: TPanel;
    SaveNoteAs: TButton;
    EditNote: TButton;
    DeleteNote: TButton;
    LabelName: TLabel;
    LabelText: TLabel;
    FontMenu: TFontDialog;
    MenuEdit: TMainMenu;
    EditMenu: TMenuItem;
    EditFont: TMenuItem;
    PanelNote: TPanel;
    SaveMenu: TSaveDialog;
    SaveNote: TButton;
    SQLite3Connect: TSQLite3Connection;
    Sqlite3Dataset1: TSqlite3Dataset;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    StringGridNotes: TStringGrid;
    TextNote: TMemo;
    NameNote: TMemo;
    procedure CreateNoteClick(Sender: TObject);
    procedure EditFontClick(Sender: TObject);
    procedure EditNoteClick(Sender: TObject);
    procedure DeleteNoteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure SaveNoteAsClick(Sender: TObject);
    procedure SaveNoteClick(Sender: TObject);
    procedure StringGridNotesSelection(Sender: TObject; aCol, aRow: Integer);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var row: integer;
  begin
    SaveNote.Color := clred;
    SQLite3Dataset1.FileName          :='Notes.db';
    SQLite3Dataset1.TableName         :='Note';
    SQLite3Connect.DatabaseName   :='Notes.db';
    SQLite3Connect.Transaction    :=SQLTransaction1;
    SQLTransaction1.DataBase          :=SQLite3Connect;
    SQLQuery1.DataBase                :=SQLite3Connect;
    SQLQuery1.Transaction             :=SQLTransaction1;

    try
       SQLite3Dataset1.Open;
       SQLite3Connect.Connected:=True;
    except
       On E:Exception do
          ShowMessage('Ошибка открытия базы: '+ E.Message);
    end;

    with SQLQuery1 do
      begin
        SQLQuery1.SQL.Clear;
        SQLQuery1.SQL.Add('SELECT * FROM Note');
        SQLQuery1.Open;

        While not SQLQuery1.Eof Do
          Begin
            row := StringGridNotes.RowCount;
            StringGridNotes.RowCount      := row + 1;
            StringGridNotes.Cells[0, row] := SQLQuery1.Fields[3].AsString;
            StringGridNotes.Cells[1, row] := SQLQuery1.Fields[1].AsString;
            StringGridNotes.Cells[2, row] := SQLQuery1.Fields[2].AsString;
            SQLQuery1.Next;
          End;
      end;
 end;

procedure TMainForm.Panel2Click(Sender: TObject);
  begin
    NameNote.Clear;
    TextNote.Clear;
    TextNote.Enabled := True;
    NameNote.Enabled := True;
  end;

procedure TMainForm.SaveNoteAsClick(Sender: TObject);
  begin
     if SaveMenu.execute then
     begin
       TextNote.lines.savetofile(SaveMenu.filename);
       TextNote.Append(TextNote.Text);
     end;
  end;

procedure TMainForm.SaveNoteClick(Sender: TObject);
  var
    s : string;
    row: integer;
  begin
    SQLite3Connect.Connected:=False;
    SQLite3Dataset1.Close;
    DateTimeToString(s, 'dd.mm.yyyy', Now);
    if CheckBoxEdit.Checked = TRUE then
      begin
        with SQLQuery1 do
          begin
            SQLQuery1.SQL.Clear;
            SQLQuery1.SQL.Add('UPDATE Note SET Name = :Name, Text = :Text WHERE id = :id');
            SQLQuery1.Params.ParamByName('Name').Text   := NameNote.Text;
            SQLQuery1.Params.ParamByName('Text').Text   := TextNote.Text;
            SQLQuery1.Params.ParamByName('id').Text     := StringGridNotes.Cells[0, StringGridNotes.Row];
            ExecSQL;
            SQLTransaction.Commit;
            Close;
            SQLQuery1.SQL.Clear;
            SQLQuery1.SQL.Add('SELECT id FROM Note ORDER BY id DESC LIMIT 1;');
            SQLQuery1.Open;
           end;
           SQLite3Dataset1.Close;
           StringGridNotes.Cells[1, StringGridNotes.Row] := NameNote.Text;
           StringGridNotes.Cells[2, StringGridNotes.Row] := TextNote.Text;
           TextNote.Enabled     := False;
           NameNote.Enabled     := False;
           CheckBoxEdit.Checked := False;
      end
    else
      begin
        with SQLQuery1 do
          begin
            SQLQuery1.SQL.Clear;
            SQLQuery1.SQL.Add('INSERT INTO Note(DateNote, Name, Text) VALUES(:DATE, :NAME, :TEXT)');
            SQLQuery1.Params.ParamByName('DATE').Text:= s;
            SQLQuery1.Params.ParamByName('NAME').Text:= NameNote.Text;
            SQLQuery1.Params.ParamByName('TEXT').Text:= TextNote.Text;
            ExecSQL;
            SQLTransaction.Commit;
            Close;
            SQLQuery1.SQL.Clear;
            SQLQuery1.SQL.Add('SELECT id FROM Note ORDER BY id DESC LIMIT 1;');
            SQLQuery1.Open;
         end;
         SQLite3Dataset1.Close;
         row := StringGridNotes.RowCount;
         StringGridNotes.RowCount := row + 1;
         StringGridNotes.Cells[0, row] := SQLQuery1.Fields[0].AsString;
         StringGridNotes.Cells[1, row] := NameNote.Text;
         StringGridNotes.Cells[2, row] := TextNote.Text;
         TextNote.Enabled := False;
         NameNote.Enabled := False;
     end;
  end;

procedure TMainForm.StringGridNotesSelection(Sender: TObject; aCol, aRow: Integer);
  begin
    NameNote.Clear;
    TextNote.Clear;
    TextNote.Text := StringGridNotes.Cells[2, StringGridNotes.Row];
    NameNote.Text := StringGridNotes.Cells[1, StringGridNotes.Row];
  end;

procedure TMainForm.EditNoteClick(Sender: TObject);
  begin
      CheckBoxEdit.Checked := True;
      TextNote.Enabled     := True;
      NameNote.Enabled     := True;
  end;

procedure TMainForm.EditFontClick(Sender: TObject);
  begin
      if FontMenu.execute then
        begin
          TextNote.Font := FontMenu.Font;
          NameNote.Font := FontMenu.Font;
        end;
  end;

procedure TMainForm.CreateNoteClick(Sender: TObject);
  begin
    NameNote.Clear;
    TextNote.Clear;
    TextNote.Enabled := True;
    NameNote.Enabled := True;
  end;

procedure TMainForm.DeleteNoteClick(Sender: TObject);
  begin
    SQLite3Connect.Connected:=False;
    SQLite3Dataset1.Close;
    with SQLQuery1 do
      begin
        SQLQuery1.SQL.Clear;
        SQLQuery1.SQL.Add('DELETE FROM Note Where id = :id');
        SQLQuery1.Params.ParamByName('id').Text:= StringGridNotes.Cells[0, StringGridNotes.Row];
        ExecSQL;
        SQLTransaction.Commit;
        Close;
      end;
    if StringGridNotes.RowCount > 1 then
       StringGridNotes.DeleteRow(StringGridNotes.Row);
  end;

end.

