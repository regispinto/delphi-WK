program PeopleAddres;

uses
  Vcl.Forms,
  Windows,
  uDM in 'uDM.pas' {DM: TDataModule},
  uMaster in 'uMaster.pas' {frmMaster},
  ClassIntegrationAddress in 'IntegrationAddress\ClassIntegrationAddress.pas',
  ClassCreateTables in 'Tables\ClassCreateTables.pas',
  ClassPeople in 'People\ClassPeople.pas',
  ClassConnection in 'Connection\ClassConnection.pas',
  uFunctions in 'Functions\uFunctions.pas',
  uMasterFunctions in 'uMasterFunctions.pas',
  ClasseViaCep in 'ZipCode\ClasseViaCep.pas';

{$R *.res}

var
  HprevHist: Thandle;

begin
  Application.Initialize;

  begin
    HprevHist := FindWindow(Nil, 'Base de Pessoas');

    if(HprevHist <> 0)then begin
      Application.MessageBox('Aplicativo já se encontra em execução', 'Atenção', MB_OK);
      ShowWindow(HprevHist, SW_NORMAL);
      Application.Terminate;
    end;
  end;

  //ReportMemoryLeaksOnShutdown := True;

  Application.Title := 'Base de Pessoas';
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmMaster, frmMaster);
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.



