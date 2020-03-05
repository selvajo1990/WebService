table 50062 "Web Service Transaction Log"
{
    Caption = 'Web Service Transaction Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; BigInteger)
        {
            Caption = 'Entry No';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(21; Direction; Option)
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
            OptionMembers = "Incoming Request","Incoming Response","Outgoing Request","Outgoing Response";
            OptionCaption = 'Incoming Request,Incoming Response,Outgoing Request,Outgoing Response';
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
        field(24; "Reply to Entry No."; BigInteger)
        {
            Caption = 'Reply to Entry No.';
            DataClassification = CustomerContent;
        }
        field(25; "XML Document"; Media)
        {
            Caption = 'XML Document';
            DataClassification = CustomerContent;
        }
        field(26; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = "To be Processed",Failed,Processed,"Closed Manually","Skip Processing";
            OptionCaption = 'To be Processed,Failed,Processed,Closed Manually,Skip Processing';
        }
        field(27; "Has Error"; Boolean)
        {
            Caption = 'Has Error';
            FieldClass = FlowField;
            CalcFormula = exist ("Web Service Error Log" where("Transaction Entry No" = field("Entry No")));
        }
        field(28; "Free Text 1"; Text[250])
        {
            Caption = 'Free Text 1';
            DataClassification = CustomerContent;
        }
        field(29; "Free Text 2"; Text[250])
        {
            Caption = 'Free Text 2';
            DataClassification = CustomerContent;
        }
        field(30; "Free Text 3"; Text[250])
        {
            Caption = 'Free Text 3';
            DataClassification = CustomerContent;
        }
        field(31; "Transaction Sequence"; Integer)
        {
            Caption = 'Transaction Sequence';
            DataClassification = CustomerContent;
        }
        field(32; "Parent Entry No."; BigInteger)
        {
            Caption = 'Parent Entry No.';
            DataClassification = CustomerContent;
        }
        field(33; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
        }
        field(34; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(35; "Processed By"; Code[50])
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        "Entry Date" := Today();
        "Entry Time" := Time();
        "Processed By" := CopyStr(UserId(), 1, 50);
    end;

    procedure InsertTransactionLog(DirectionP: Option "Incoming Request","Incoming Response","Outgoing Request","Outgoing Response"; StatusP: Option "To be Processed",Failed,Processed,"Closed Manually","Skip Processing"; TemplateCodeP: Code[20]; LastEntryNoP: BigInteger; XmlTextP: Text): BigInteger
    var
        TempBlobL: Codeunit "Temp Blob";
        OutStreamL: OutStream;
        InStreamL: InStream;
    begin
        Init();
        "Entry No" := 0;
        Direction := DirectionP;
        Status := StatusP;
        "Template Code" := TemplateCodeP;
        if Direction IN [Direction::"Incoming Response", Direction::"Outgoing Response"] then
            "Reply to Entry No." := LastEntryNoP;
        // MessageHeaderL."Parent Entry No." := ParentEntryNoP;

        TempBlobL.CreateOutStream(OutStreamL);
        OutStreamL.WriteText(XmlTextP);
        TempBlobL.CreateInStream(InStreamL);
        "XML Document".ImportStream(InStreamL, TemplateCodeP);
        Insert(true);
        exit("Entry No");
    end;

    procedure ModifyStatus(EntryNoP: BigInteger)
    begin
        Rec.Get(EntryNoP);
        Rec.Status := Rec.Status::"To be Processed";
        Rec.Modify(true);
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
            Error(NoDataErr, Rec."Template Code");
        FileMgtL.BLOBExport(TempBlobL, "Template Code" + '.xml', true);
    end;


}
