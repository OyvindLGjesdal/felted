program writeToFile (file2);

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Sysutils;

  const C_FNAME = '/home/oyvind/repos/oyvind/felted/OPE7.DTA';

  TYPE
      LINJETYPE = RECORD
                LINSTATUS  : INTEGER ;
                LININNHALD : STRING[80];
                LINNESTE: INTEGER;
              END;
  TYPE
      POSTTYPE = RECORD
                      LINTAL : INTEGER;
                      LINJE : ARRAY [1 .. 52] OF STRING[80];
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
                    END;
              {    ELSE IF XPOST.LINJE[XPOST.LINTAL[IP] = CHR(19) THEN
                    DELETE(XPOST.LINJE[XPOST.LINTAL],IP,80);  }
                  UNTIL IP >= LENGTH(XPOST.LINJE[XPOST.LINTAL]);
                  END;
          POST := XPOST;
          END;

  { you can add units after this }

     var file1: file of LINJETYPE;
     var linje: LINJETYPE;
     var test : integer;

begin

     assign(file1,'/home/oyvind/repos/oyvind/felted/OPE7.DTA');
     reset(file1);

     seek(file1, 0);
     PAKKUTPOST();
     writeLn(post.linje[0]);

     close(file1);

     end.
