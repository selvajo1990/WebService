table 50063 "Web Service Error Log"
{
    Caption = 'Web Service Error Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(21; "Transaction Entry No"; BigInteger)
        {
            Caption = 'Transaction Entry No';
            DataClassification = CustomerContent;
        }
        field(22; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
        }
        field(23; "Entry Time"; Time)
        {
            Caption = 'Entry Time';
            DataClassification = CustomerContent;
        }
        field(24; "Xml Document"; Media)
        {
            Caption = 'Xml Document';
            DataClassification = CustomerContent;
        }
        field(25; "Error Description"; Text[2048])
        {
            Caption = 'Error Description';
            DataClassification = CustomerContent;
        }
        field(26; "Error Code"; Code[50])
        {
            Caption = 'Error Code';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        "Entry Date" := Today();
        "Entry Time" := Time();
    end;

    procedure InsertErrorlog(TransactionEntryNoP: BigInteger; XmlTextP: Text)
    var
        TempBlobL: Codeunit "Temp Blob";
        OutStreamL: OutStream;
        InStreamL: InStream;
    begin
        Init();
        "Entry No." := 0;
        "Transaction Entry No" := TransactionEntryNoP;
        TempBlobL.CreateOutStream(OutStreamL);
        OutStreamL.WriteText(XmlTextP);
        TempBlobL.CreateInStream(InStreamL);
        "XML Document".ImportStream(InStreamL, Format(TransactionEntryNoP));
        Insert(true);
    end;

    procedure ExportTemplate(): Text
    var
        TempBlobL: Codeunit "Temp Blob";
        FileMgtL: Codeunit "File Management";
        OutStreamL: OutStream;
        NoDataErr: Label '%1 does have file.';
    begin

        TempBlobL.CreateOutStream(OutStreamL);
        "XML Document".ExportStream(OutStreamL);
        if not TempBlobL.HasValue() then
            Error(NoDataErr, "Entry No.");
        FileMgtL.BLOBExport(TempBlobL, Format("Entry No.") + '.xml', true);
    end;

}
