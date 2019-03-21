program writeToFile;
{$mode tp}{$H+}
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,LConvEncdoding;
  {$ENDIF}{$ENDIF}
  Classes,Sysutils;

  const C_FIELDSEP = '|||||';

  var input_fname : string;
  TYPE
      LINJETYPE = packed RECORD
                LINSTATUS  : INTEGER ;
                LININNHALD : STRING[80];
                LINNESTE: INTEGER;
              END;
  TYPE
      POSTTYPE = RECORD
                      LINTAL : INTEGER;
                      LINJE : ARRAY [1 .. 52] OF STRING[100];
                  END;

        VAR
        POST : POSTTYPE;

        PROCEDURE PAKKUTPOST;

        VAR
          XPOST : POSTTYPE;
          IT, IP, PP : INTEGER;

        BEGIN
          XPOST.LINTAL := 1;
          XPOST.LINJE[1] :='';
          IP := 0;
          FOR IT := 1 TO POST.LINTAL DO
            BEGIN
              XPOST.LINJE[XPOST.LINTAL] := XPOST.LINJE[XPOST.LINTAL] + POST.LINJE[IT];
              PP := 0;
                REPEAT;
                  REPEAT;
                    IP := IP + 1;
                    PP := PP +1;
                  UNTIL (XPOST.LINJE[XPOST.LINTAL][IP] IN [CHR(18),CHR(19)])
                    OR ( IP >= LENGTH(XPOST.LINJE[XPOST.LINTAL]));
                  IF XPOST.LINJE[XPOST.LINTAL][IP] = CHR(18) THEN
                    BEGIN
                      XPOST.LINTAL := XPOST.LINTAL + 1;
                      XPOST.LINJE[XPOST.LINTAL] := COPY(POST.LINJE[IT],PP+1,80);
                      DELETE(XPOST.LINJE[XPOST.LINTAL-1],IP,80);
                      IP := 0;
                    END
                  ELSE IF XPOST.LINJE[XPOST.LINTAL][IP] = CHR(19) THEN
                    DELETE(XPOST.LINJE[XPOST.LINTAL],IP,80);
                  UNTIL IP >= LENGTH(XPOST.LINJE[XPOST.LINTAL]);
                  END;
          POST := XPOST;
          END;



  { you can add units after this }
     var outputfile : Text;
     var file1: file of LINJETYPE;
     var linje: LINJETYPE;
     var size : integer;
     var l1 : String;
     var IT2 : INTEGER;
     var output_fname : String     ;

begin
     input_fname :=ParamStr(1);
     output_fname := copy(input_fname,1,length(input_fname) - 3) + 'txt';
     assign(file1,input_fname);
     assign(outputfile,output_fname);
     reset(file1);
     size := FileSize(file1) - 1 ;
     {     writeln('size' + intToStr(size)); }
     with TStringList.Create do
       BEGIN
  with TStringList.Create do
       BEGIN
       FOR IT2 := 0 TO size DO
       BEGIN
         seek(file1,IT2);
         read(file1,linje);
         l1 :=  '<linje nr="'+inttostr(IT2) + '" status="' + inttostr(linje.LINSTATUS) + '" neste="'+ inttostr(linje.LINNESTE)   + '">'  +'' + linje.LININNHALD + '</linje>' ;
	 { writeln(l1); }
         Add (l1)  ;
         end;
       SaveToFile(output_fname);
       END;
       free;
       END;
      end.
