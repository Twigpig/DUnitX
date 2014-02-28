{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2013 Vincent Parrett                              }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit DUnitX.Loggers.GUI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ActnList, StdActns, ActnCtrls,
  ToolWin, ActnMan, ActnMenus, ImgList,
  PlatformDefaultStyleActnCtrls, ExtCtrls, ComCtrls,
  DUnitX.TestFrameWork,
  DUnitX.Extensibility,
  DUnitX.InternalInterfaces,
  StdCtrls, Generics.Collections, System.Actions;

const
  WM_LOAD_TESTS = WM_USER + 123;

type
  TDUnitXGuiLoggerForm = class(TForm,ITestLogger)
    ActionManager1: TActionManager;
    ActionImages: TImageList;
    actRunSelected: TAction;
    actRunAll: TAction;
    Panel2: TPanel;
    Panel3: TPanel;
    Label2: TLabel;
    Edit1: TEdit;
    Splitter1: TSplitter;
    Panel4: TPanel;
    ToolBar1: TToolBar;
    StateImages: TImageList;
    RunImages: TImageList;
    Panel1: TPanel;
    TestTree: TTreeView;
    btnRunAll: TToolButton;
    FailList: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actRunAllExecute(Sender: TObject);
    procedure TestTreeCreateNodeClass(Sender: TCustomTreeView;
      var NodeClass: TTreeNodeClass);
  private
    { Private declarations }
    FRunner : ITestRunner;
    FFixtureList : ITestFixtureList;
    FApplicationName : string;
    FFailedTests: TDictionary<String, ITestResult>;
    procedure BuildTree(parentNode: TTreeNode; const fixtureList: ITestFixtureList);
    function GetNode(FullName: String): TTreeNode;
  protected

    procedure OnBeginTest(const threadId: Cardinal; const Test: ITestInfo);
    procedure OnEndSetupFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
    procedure OnEndSetupTest(const threadId: Cardinal; const Test: ITestInfo);
    procedure OnEndTearDownFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
    procedure OnEndTeardownTest(const threadId: Cardinal; const Test: ITestInfo);
    procedure OnEndTest(const threadId: Cardinal; const Test: ITestResult);
    procedure OnEndTestFixture(const threadId: Cardinal; const results: IFixtureResult);
    procedure OnExecuteTest(const threadId: Cardinal; const Test: ITestInfo);
    procedure OnLog(const logType: TLogLevel; const msg: string);
    procedure OnSetupFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
    procedure OnSetupTest(const threadId: Cardinal; const Test: ITestInfo);
    procedure OnStartTestFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
    procedure OnTearDownFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
    procedure OnTeardownTest(const threadId: Cardinal; const Test: ITestInfo);
    procedure OnTestError(const threadId: Cardinal; const Error: ITestError);
    procedure OnTestFailure(const threadId: Cardinal; const Failure: ITestError);
    procedure OnTestSuccess(const threadId: Cardinal; const Test: ITestResult);
    procedure OnTestMemoryLeak(const threadId : Cardinal; const Test: ITestResult);
    procedure OnTestIgnored(const threadId: Cardinal; const Ignored: ITestResult);
    procedure OnTestingEnds(const RunResults: IRunResults);
    procedure OnTestingStarts(const threadId: Cardinal; const testCount: Cardinal; const testActiveCount: Cardinal);

    procedure WMLoadTests(var message : TMessage); message WM_LOAD_TESTS;
    procedure Loaded; override;

  public
    { Public declarations }


  end;

var
  DUnitXGuiLoggerForm: TDUnitXGuiLoggerForm;

implementation

{$R *.dfm}


type
  TTestNode = class(TTreeNode)
  strict private
    FFullName: String;
  public
    constructor Create(Owner: TTreeView; Text: String; TestFullName: String); reintroduce;
    destructor Destroy; override;
    property FullName: String read FFullName write FFullName;
    procedure SetResultType(resultType: TTestResultType);
    procedure Reload;
  end;


procedure TDUnitXGuiLoggerForm.FormCreate(Sender: TObject);
begin
  FFailedTests := TDictionary<String, ITestResult>.Create;
  FRunner := TDUnitX.CreateRunner;
  FRunner.AddLogger(Self);
  FApplicationName := ExtractFileName(ParamStr(0));
  Self.Caption := Format('DUnitX - [%s]',[FApplicationName]);
end;

procedure TDUnitXGuiLoggerForm.FormDestroy(Sender: TObject);
begin
  FFailedTests.Free;
end;


function TDUnitXGuiLoggerForm.GetNode(FullName: String): TTreeNode;
var
  i: Integer;
  t : TTestNode;
begin
  Result := nil;
  i := 0;
  repeat begin
    t := TestTree.Items[i] as TTestNode;
    if t.FullName = FullName then
      Result := TestTree.Items[i];
    Inc(i);
  end
  until Assigned(Result) or (i >= TestTree.Items.Count);
end;

procedure TDUnitXGuiLoggerForm.Loaded;
begin
  inherited;
  PostMessage(Self.Handle,WM_LOAD_TESTS,0,0);
end;

procedure TDUnitXGuiLoggerForm.OnBeginTest(const threadId: Cardinal; const Test: ITestInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnEndSetupFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnEndSetupTest(const threadId: Cardinal; const Test: ITestInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnEndTearDownFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnEndTeardownTest(const threadId: Cardinal; const Test: ITestInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnEndTest(const threadId: Cardinal; const Test: ITestResult);
var
  failItem: TListItem;
  testNode: TTestNode;
begin
  if (Test.ResultType = TTestResultType.Failure)
    or (Test.ResultType = TTestResultType.Error)
    or (Test.ResultType = TTestResultType.MemoryLeak) then begin
    FFailedTests.Add(Test.Test.FullName, Test);
    failItem := FailList.Items.Add;
    failItem.Caption := Test.Test.Name;
    failItem.SubItems.Text := Test.Test.FullName;
  end;

  testNode := GetNode(Test.Test.FullName) as TTestNode;

  if Assigned(testNode) then begin
    testNode.SetResultType(Test.ResultType);
  end;
  self.TestTree.Repaint;
end;

procedure TDUnitXGuiLoggerForm.OnEndTestFixture(const threadId: Cardinal; const results: IFixtureResult);
begin

end;

procedure TDUnitXGuiLoggerForm.OnExecuteTest(const threadId: Cardinal; const Test: ITestInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnLog(const logType: TLogLevel; const msg: string);
begin

end;

procedure TDUnitXGuiLoggerForm.OnSetupFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnSetupTest(const threadId: Cardinal; const Test: ITestInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnStartTestFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnTearDownFixture(const threadId: Cardinal; const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnTeardownTest(const threadId: Cardinal; const Test: ITestInfo);
begin

end;

procedure TDUnitXGuiLoggerForm.OnTestError(const threadId: Cardinal; const Error: ITestError);
begin

end;

procedure TDUnitXGuiLoggerForm.OnTestFailure(const threadId: Cardinal; const Failure: ITestError);
begin

end;

procedure TDUnitXGuiLoggerForm.OnTestIgnored(const threadId: Cardinal; const Ignored: ITestResult);
begin

end;

procedure TDUnitXGuiLoggerForm.OnTestingEnds(const RunResults: IRunResults);
begin

end;

procedure TDUnitXGuiLoggerForm.OnTestingStarts(const threadId, testCount, testActiveCount: Cardinal);
begin

end;

procedure TDUnitXGuiLoggerForm.OnTestMemoryLeak(const threadId: Cardinal; const Test: ITestResult);
begin

end;

procedure TDUnitXGuiLoggerForm.OnTestSuccess(const threadId: Cardinal; const Test: ITestResult);
begin

end;


procedure TDUnitXGuiLoggerForm.TestTreeCreateNodeClass(Sender: TCustomTreeView;
  var NodeClass: TTreeNodeClass);
begin
  NodeClass := TTestNode;
end;

procedure TDUnitXGuiLoggerForm.actRunAllExecute(Sender: TObject);
begin
  FRunner.Execute;
end;

procedure TDUnitXGuiLoggerForm.BuildTree(parentNode : TTreeNode; const fixtureList : ITestFixtureList);
var
  fixture : ITestFixture;
  test : ITest;
  fixtureNode, testNode : TTestNode;
begin
  for fixture in fixtureList do
  begin
    fixtureNode := TestTree.Items.AddChild(parentNode,fixture.Name) as TTestNode;
    fixtureNode.FullName := fixture.FullName;
    if fixture.HasChildFixtures then
      BuildTree(fixtureNode,fixture.Children);
    for test in fixture.Tests do
    begin
      testNode := TestTree.Items.AddChild(fixtureNode,test.Name) as TTestNode;
      testNode.FullName := test.Fixture.FullName + '.' + test.Name;
    end;
  end;
end;


procedure TDUnitXGuiLoggerForm.WMLoadTests(var message: TMessage);
var
  rootNode : TTreeNode;
begin
  FFixtureList := FRunner.BuildFixtures as ITestFixtureList;
  TestTree.Items.BeginUpdate;
  TestTree.Items.Clear;
  try
    BuildTree(nil,FFixtureList);
  finally
    rootNode := TestTree.Items.GetFirstNode;
    if rootNode <> nil then
      rootNode.Expand(true);
    TestTree.Items.EndUpdate;
  end;



end;

{ TTestNode }

constructor TTestNode.Create(Owner: TTreeView; Text, TestFullName: String);
begin
  inherited Create(Owner.Items);
  Self.Text := Text;
  FFullName := TestFullName;
  ImageIndex := 0;
end;

destructor TTestNode.Destroy;
begin
  inherited;
end;

procedure TTestNode.Reload;
begin
end;

type
  TTestImage = (
    Unknown=0,
    MemoryLeak=1,
    Pass=2,
    Ignore=3,
    Fail=4,
    Error=5
    );


procedure TTestNode.SetResultType(resultType: TTestResultType);
begin
 case resultType of
   TTestResultType.Pass: begin
     ImageIndex := Ord(TTestImage.Pass);
   end;
   TTestResultType.Failure: begin
     ImageIndex := Ord(TTestImage.Fail);
     self.Parent.ImageIndex := Ord(TTestImage.Fail);
   end;
   TTestResultType.Error: begin
     ImageIndex := Ord(TTestImage.Error);
     self.Parent.ImageIndex := Ord(TTestImage.Fail);
   end;
   TTestResultType.Ignored: begin
     ImageIndex := Ord(TTestImage.Ignore);
   end;
   TTestResultType.MemoryLeak: begin
     ImageIndex := Ord(TTestImage.MemoryLeak);
   end;
 end;
 Application.ProcessMessages;
end;

end.
