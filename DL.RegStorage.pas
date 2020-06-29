unit DL.RegStorage;

interface

uses Registry, SysUtils;

function RegProp: TRegistry;

const
  cRegNode = 'Software\DjenyaSoft\';

implementation

var
  FRegProp: TRegistry = nil;

function RegProp: TRegistry;
begin
  Result := FRegProp;
end;

initialization
  FRegProp := TRegistry.Create;
finalization
  if Assigned(FRegProp) then FreeAndNil(FRegProp);

end.
